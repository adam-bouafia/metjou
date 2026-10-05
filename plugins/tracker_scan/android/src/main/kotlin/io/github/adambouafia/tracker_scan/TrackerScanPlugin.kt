package io.github.adambouafia.tracker_scan

import android.Manifest
import android.annotation.SuppressLint
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothGatt
import android.bluetooth.BluetoothGattCallback
import android.bluetooth.BluetoothGattCharacteristic
import android.bluetooth.BluetoothGattDescriptor
import android.bluetooth.BluetoothManager
import android.bluetooth.BluetoothProfile
import android.bluetooth.le.ScanCallback
import android.bluetooth.le.ScanFilter
import android.bluetooth.le.ScanResult
import android.bluetooth.le.ScanSettings
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.ParcelUuid
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.util.UUID

/**
 * Bluetooth LE for MetJou: a timed scan, a live scan and one write to a
 * device. The filters and the bytes to write come from Dart, so this class
 * knows nothing about trackers.
 */
class TrackerScanPlugin : FlutterPlugin, MethodCallHandler, EventChannel.StreamHandler {

    private companion object {
        // Descriptor that switches notifications of a characteristic on.
        val CCCD: UUID = UUID.fromString("00002902-0000-1000-8000-00805f9b34fb")
        const val MAX_DEVICES = 200
    }

    private lateinit var channel: MethodChannel
    private lateinit var liveChannel: EventChannel
    private lateinit var context: Context
    private val handler = Handler(Looper.getMainLooper())

    // The running timed scan, live scan and connection, or null. Only
    // touched on the main thread, where Android also delivers scan callbacks.
    private var running: ScanCallback? = null
    private var live: ScanCallback? = null
    private var gatt: BluetoothGatt? = null

    // Devices from recent scans, by address. Connecting needs the device as
    // the scan reported it: an address alone does not say what type it is.
    private val devices = object : LinkedHashMap<String, BluetoothDevice>(64, 0.75f, true) {
        override fun removeEldestEntry(eldest: MutableMap.MutableEntry<String, BluetoothDevice>) =
            size > MAX_DEVICES
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, "metjou/tracker_scan")
        channel.setMethodCallHandler(this)
        liveChannel = EventChannel(binding.binaryMessenger, "metjou/tracker_scan/live")
        liveChannel.setStreamHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        liveChannel.setStreamHandler(null)
        handler.removeCallbacksAndMessages(null)
        running?.let { stop(it) }
        stopLive()
        gatt?.let { close(it) }
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "state" -> result.success(state())
            "scan" -> scan(call, result)
            "writeGatt" -> writeGatt(call, result)
            else -> result.notImplemented()
        }
    }

    private fun adapter(): BluetoothAdapter? =
        (context.getSystemService(Context.BLUETOOTH_SERVICE) as? BluetoothManager)?.adapter

    private fun state(): String {
        val hasLe = context.packageManager.hasSystemFeature(PackageManager.FEATURE_BLUETOOTH_LE)
        val adapter = adapter()
        return when {
            !hasLe || adapter == null -> "unsupported"
            adapter.isEnabled -> "on"
            else -> "off"
        }
    }

    private fun granted(permission: String) =
        context.checkSelfPermission(permission) == PackageManager.PERMISSION_GRANTED

    // Without precise location Android delivers no scan results at all,
    // silently, so it is checked here too.
    private fun hasScanPermission() =
        granted(Manifest.permission.ACCESS_FINE_LOCATION) &&
            (Build.VERSION.SDK_INT < Build.VERSION_CODES.S ||
                granted(Manifest.permission.BLUETOOTH_SCAN))

    @SuppressLint("MissingPermission") // checked by hasScanPermission()
    private fun scan(call: MethodCall, result: Result) {
        if (running != null) {
            result.error("busy", "A scan is already running", null)
            return
        }
        if (!hasScanPermission()) {
            result.error("permission", "Bluetooth scan or precise location not granted", null)
            return
        }
        val scanner = adapter()?.takeIf { it.isEnabled }?.bluetoothLeScanner
        if (scanner == null) {
            result.error("bluetooth_off", "Bluetooth is off or missing", null)
            return
        }

        val filters = call.argument<List<Map<String, Any?>>>("filters").orEmpty().map(::toFilter)
        val lowPower = call.argument<Boolean>("lowPower") == true
        val durationMs = (call.argument<Number>("durationMs") ?: 8000).toLong()
        val settings = ScanSettings.Builder()
            .setScanMode(
                if (lowPower) ScanSettings.SCAN_MODE_LOW_POWER
                else ScanSettings.SCAN_MODE_LOW_LATENCY
            )
            .build()

        // One entry per address, keeping the strongest signal: single
        // readings dip a lot, the peak says best how close the device is.
        val found = LinkedHashMap<String, Map<String, Any?>>()
        fun keep(r: ScanResult) {
            devices[r.device.address] = r.device
            val old = found[r.device.address]
            if (old == null || r.rssi > old["rssi"] as Int) found[r.device.address] = toMap(r)
        }

        val callback = object : ScanCallback() {
            override fun onScanResult(callbackType: Int, r: ScanResult) = keep(r)

            override fun onBatchScanResults(results: List<ScanResult>) = results.forEach(::keep)

            override fun onScanFailed(errorCode: Int) {
                if (running !== this) return
                running = null
                result.error("scan_failed", "Scan failed with code $errorCode", errorCode)
            }
        }

        try {
            scanner.startScan(filters, settings, callback)
        } catch (e: IllegalStateException) {
            // Bluetooth was switched off between the check and the start.
            result.error("bluetooth_off", e.message, null)
            return
        }
        running = callback
        handler.postDelayed({
            if (running === callback) {
                stop(callback)
                result.success(found.values.toList())
            }
        }, durationMs)
    }

    @SuppressLint("MissingPermission")
    private fun stop(callback: ScanCallback) {
        running = null
        try {
            adapter()?.bluetoothLeScanner?.stopScan(callback)
        } catch (_: IllegalStateException) {
            // Bluetooth went off during the scan; nothing left to stop.
        }
    }

    // Live scan: every matching advert goes to Dart as it arrives, until the
    // listener cancels. Used to walk towards one tracker.

    @SuppressLint("MissingPermission") // checked by hasScanPermission()
    override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
        stopLive()
        if (!hasScanPermission()) {
            events.error("permission", "Bluetooth scan or precise location not granted", null)
            return
        }
        val scanner = adapter()?.takeIf { it.isEnabled }?.bluetoothLeScanner
        if (scanner == null) {
            events.error("bluetooth_off", "Bluetooth is off or missing", null)
            return
        }
        @Suppress("UNCHECKED_CAST")
        val filters = ((arguments as? Map<String, Any?>)?.get("filters") as? List<Map<String, Any?>>)
            .orEmpty().map(::toFilter)
        val settings = ScanSettings.Builder()
            .setScanMode(ScanSettings.SCAN_MODE_LOW_LATENCY)
            .build()
        val callback = object : ScanCallback() {
            override fun onScanResult(callbackType: Int, r: ScanResult) {
                devices[r.device.address] = r.device
                events.success(toMap(r))
            }

            override fun onScanFailed(errorCode: Int) {
                events.error("scan_failed", "Scan failed with code $errorCode", errorCode)
            }
        }
        try {
            scanner.startScan(filters, settings, callback)
        } catch (e: IllegalStateException) {
            events.error("bluetooth_off", e.message, null)
            return
        }
        live = callback
    }

    override fun onCancel(arguments: Any?) = stopLive()

    @SuppressLint("MissingPermission")
    private fun stopLive() {
        val callback = live ?: return
        live = null
        try {
            adapter()?.bluetoothLeScanner?.stopScan(callback)
        } catch (_: IllegalStateException) {
            // Bluetooth went off; nothing left to stop.
        }
    }

    // One write to a device: connect, find the first characteristic from the
    // list that the device has, write the bytes, stay connected for a moment
    // and hang up. The answer to Dart is the index of the write that was used.

    @SuppressLint("MissingPermission") // BLUETOOTH_CONNECT is checked first
    private fun writeGatt(call: MethodCall, result: Result) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S &&
            !granted(Manifest.permission.BLUETOOTH_CONNECT)
        ) {
            result.error("permission", "Bluetooth connect not granted", null)
            return
        }
        val adapter = adapter()?.takeIf { it.isEnabled }
        if (adapter == null) {
            result.error("bluetooth_off", "Bluetooth is off or missing", null)
            return
        }
        if (gatt != null) {
            result.error("busy", "Already connected to a device", null)
            return
        }
        val address = call.argument<String>("address").orEmpty()
        val writes = call.argument<List<Map<String, Any?>>>("writes").orEmpty()
        val holdMs = (call.argument<Number>("holdMs") ?: 8000).toLong()
        val timeoutMs = (call.argument<Number>("timeoutMs") ?: 15000).toLong()
        val device = try {
            devices[address] ?: adapter.getRemoteDevice(address)
        } catch (e: IllegalArgumentException) {
            result.error("connect_failed", e.message, null)
            return
        }

        // Android calls the connection callback on a background thread; the
        // answer and the clean-up go back to the main thread.
        var answered = false
        fun answer(block: () -> Unit) = handler.post {
            if (!answered) {
                answered = true
                block()
            }
        }

        var chosen = -1
        var pending: Pair<BluetoothGattCharacteristic, Map<String, Any?>>? = null

        val callback = object : BluetoothGattCallback() {
            override fun onConnectionStateChange(g: BluetoothGatt, status: Int, newState: Int) {
                if (newState == BluetoothProfile.STATE_CONNECTED &&
                    status == BluetoothGatt.GATT_SUCCESS
                ) {
                    g.discoverServices()
                } else if (newState == BluetoothProfile.STATE_DISCONNECTED) {
                    // After a successful write this is the device hanging up,
                    // which an AirTag does once it has played its sound.
                    answer { result.error("connect_failed", "Disconnected, status $status", status) }
                    handler.post { close(g) }
                }
            }

            override fun onServicesDiscovered(g: BluetoothGatt, status: Int) {
                for ((index, write) in writes.withIndex()) {
                    val characteristic = g
                        .getService(UUID.fromString(write["service"] as String))
                        ?.getCharacteristic(UUID.fromString(write["characteristic"] as String))
                        ?: continue
                    chosen = index
                    val cccd = characteristic.getDescriptor(CCCD)
                    if (write["subscribe"] == true && cccd != null) {
                        // Some trackers only accept the command once
                        // notifications are on; the write follows in
                        // onDescriptorWrite.
                        g.setCharacteristicNotification(characteristic, true)
                        pending = characteristic to write
                        val indicate = characteristic.properties and
                            BluetoothGattCharacteristic.PROPERTY_INDICATE != 0
                        writeDescriptor(
                            g,
                            cccd,
                            if (indicate) BluetoothGattDescriptor.ENABLE_INDICATION_VALUE
                            else BluetoothGattDescriptor.ENABLE_NOTIFICATION_VALUE,
                        )
                    } else {
                        writeCharacteristic(g, characteristic, write)
                    }
                    return
                }
                answer { result.error("not_supported", "None of the characteristics found", null) }
                handler.post { close(g) }
            }

            override fun onDescriptorWrite(
                g: BluetoothGatt,
                descriptor: BluetoothGattDescriptor,
                status: Int,
            ) {
                val (characteristic, write) = pending ?: return
                pending = null
                writeCharacteristic(g, characteristic, write)
            }

            override fun onCharacteristicWrite(
                g: BluetoothGatt,
                characteristic: BluetoothGattCharacteristic,
                status: Int,
            ) {
                if (status == BluetoothGatt.GATT_SUCCESS) {
                    answer { result.success(chosen) }
                    handler.postDelayed({ close(g) }, holdMs)
                } else {
                    answer { result.error("write_failed", "Write failed, status $status", status) }
                    handler.post { close(g) }
                }
            }
        }

        val connection = device.connectGatt(context, false, callback, BluetoothDevice.TRANSPORT_LE)
        gatt = connection
        handler.postDelayed({
            if (!answered) {
                answered = true
                result.error("timeout", "No answer from the device", null)
                close(connection)
            }
        }, timeoutMs)
    }

    @SuppressLint("MissingPermission")
    private fun close(connection: BluetoothGatt) {
        if (gatt !== connection) return
        gatt = null
        connection.disconnect()
        connection.close()
    }

    @Suppress("DEPRECATION") // the old calls are the only ones before Android 13
    @SuppressLint("MissingPermission")
    private fun writeDescriptor(g: BluetoothGatt, descriptor: BluetoothGattDescriptor, value: ByteArray) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            g.writeDescriptor(descriptor, value)
        } else {
            descriptor.value = value
            g.writeDescriptor(descriptor)
        }
    }

    @Suppress("DEPRECATION")
    @SuppressLint("MissingPermission")
    private fun writeCharacteristic(
        g: BluetoothGatt,
        characteristic: BluetoothGattCharacteristic,
        write: Map<String, Any?>,
    ) {
        val value = write["value"] as? ByteArray ?: ByteArray(0)
        val type =
            if (write["noResponse"] == true) BluetoothGattCharacteristic.WRITE_TYPE_NO_RESPONSE
            else BluetoothGattCharacteristic.WRITE_TYPE_DEFAULT
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            g.writeCharacteristic(characteristic, value, type)
        } else {
            characteristic.value = value
            characteristic.writeType = type
            g.writeCharacteristic(characteristic)
        }
    }

    private fun toFilter(filter: Map<String, Any?>): ScanFilter {
        val data = filter["data"] as? ByteArray
        val mask = filter["mask"] as? ByteArray
        val builder = ScanFilter.Builder()
        (filter["manufacturerId"] as? Number)?.let {
            builder.setManufacturerData(it.toInt(), data, mask)
        }
        (filter["serviceData"] as? String)?.let {
            builder.setServiceData(ParcelUuid.fromString(it), data, mask)
        }
        (filter["serviceUuid"] as? String)?.let {
            builder.setServiceUuid(ParcelUuid.fromString(it))
        }
        return builder.build()
    }

    private fun toMap(r: ScanResult): Map<String, Any?> {
        val record = r.scanRecord
        val manufacturerData = HashMap<Int, ByteArray>()
        record?.manufacturerSpecificData?.let {
            for (i in 0 until it.size()) manufacturerData[it.keyAt(i)] = it.valueAt(i)
        }
        return mapOf(
            "address" to r.device.address,
            "rssi" to r.rssi,
            "name" to record?.deviceName,
            "manufacturerData" to manufacturerData,
            "serviceData" to record?.serviceData.orEmpty().mapKeys { it.key.toString() },
            "serviceUuids" to record?.serviceUuids.orEmpty().map { it.toString() },
        )
    }
}
