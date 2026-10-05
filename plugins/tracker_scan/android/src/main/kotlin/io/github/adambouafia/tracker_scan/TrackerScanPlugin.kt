package io.github.adambouafia.tracker_scan

import android.Manifest
import android.annotation.SuppressLint
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothManager
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
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/**
 * One filtered Bluetooth LE scan at a time. The filters come from Dart, so
 * this class knows nothing about trackers.
 */
class TrackerScanPlugin : FlutterPlugin, MethodCallHandler {

    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private val handler = Handler(Looper.getMainLooper())

    // The running scan, or null. Only touched on the main thread, where
    // Android also delivers the scan callbacks.
    private var running: ScanCallback? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, "metjou/tracker_scan")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        handler.removeCallbacksAndMessages(null)
        running?.let { stop(it) }
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "state" -> result.success(state())
            "scan" -> scan(call, result)
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
            val old = found[r.device.address]
            if (old == null || r.rssi > old["rssi"] as Int) found[r.device.address] = toMap(r)
        }

        val callback = object : ScanCallback() {
            override fun onScanResult(callbackType: Int, r: ScanResult) = keep(r)

            override fun onBatchScanResults(results: List<ScanResult>) = results.forEach(::keep)

            override fun onScanFailed(errorCode: Int) {
                if (running !== this) return
                running = null
                handler.removeCallbacksAndMessages(null)
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
