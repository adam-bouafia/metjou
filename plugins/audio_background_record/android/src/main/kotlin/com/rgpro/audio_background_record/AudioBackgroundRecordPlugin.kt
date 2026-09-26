package com.rgpro.audio_background_record

import android.app.Activity
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.ServiceConnection
import android.content.SharedPreferences
import android.net.Uri
import android.os.IBinder
import android.util.Log
import androidx.core.content.ContextCompat
import androidx.documentfile.provider.DocumentFile
import com.rgpro.audio_background_record.audiorecordservice.AudioRecordService
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry

class AudioBackgroundRecordPlugin :
    FlutterPlugin,
    MethodCallHandler,
    ActivityAware,
    PluginRegistry.ActivityResultListener,
    ServiceConnection,
    AudioRecordService.OnRecordStatusChangedListener {

    companion object {
        val TAG: String = AudioBackgroundRecordPlugin::class.java.name
        private const val PICK_DIRECTORY_REQUEST = 7331
        private const val KEY_TREE_URI = "treeUri"
        private const val KEY_DURATION = "duration"
        private const val KEY_DIRECTORY = "directory"
    }

    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private lateinit var serviceIntent: Intent
    private lateinit var prefs: SharedPreferences
    private var service: AudioRecordService? = null
    private var activityBinding: ActivityPluginBinding? = null
    private var pendingPick: Result? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "audio_background_record")
        channel.setMethodCallHandler(this)
        context = binding.applicationContext
        serviceIntent = Intent(context, AudioRecordService::class.java)
        prefs = context.getSharedPreferences("AudioBackgroundRecordConfig", Context.MODE_PRIVATE)
        // Binds to the service if it is already running; flag 0 does not start it.
        context.bindService(serviceIntent, this, 0)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    // Activity, needed for the system folder picker.

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activityBinding = binding
        binding.addActivityResultListener(this)
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) =
        onAttachedToActivity(binding)

    override fun onDetachedFromActivityForConfigChanges() = onDetachedFromActivity()

    override fun onDetachedFromActivity() {
        activityBinding?.removeActivityResultListener(this)
        activityBinding = null
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        val service = this.service
        when (call.method) {
            "startRecording" ->
                result.success(service != null && !service.isRecording() && run { service.startRecording(); true })
            "stopRecording" ->
                result.success(service != null && service.isRecording() && run { service.stopRecording(); true })
            "isRecording" -> result.success(service?.isRecording() ?: false)
            "isServiceRunning" -> result.success(service != null)
            "startService" -> startService(result)
            "stopService" -> stopService(result)
            "getRecordingDirectory" -> result.success(treeUri()?.let { folderName(it) })
            "getMaxRecordDuration" ->
                result.success(prefs.getInt(KEY_DURATION, AudioRecordService.default_MaxDuration))
            "setConfiguration" -> setConfiguration(call, result)
            "pickDirectory" -> pickDirectory(result)
            "resetDirectory" -> {
                treeUri()?.let { releasePermission(it) }
                prefs.edit().remove(KEY_TREE_URI).apply()
                service?.setOutputTree(null)
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    private fun startService(result: Result) {
        if (service != null) {
            result.success(true)
            return
        }
        try {
            ContextCompat.startForegroundService(context, serviceIntent)
            context.bindService(serviceIntent, this, 0)
            result.success(true)
        } catch (e: Exception) {
            // Android 12+ refuses to start a foreground service from background.
            Log.e(TAG, "service starting failed", e)
            result.success(false)
        }
    }

    private fun stopService(result: Result) {
        val running = service ?: run {
            result.success(true)
            return
        }
        running.onStatusChangedListener = null
        service = null
        result.success(context.stopService(serviceIntent))
    }

    private fun setConfiguration(call: MethodCall, result: Result) {
        // App-private fallback folder, used when no folder was picked.
        (call.argument<String>("directory"))?.let {
            prefs.edit().putString(KEY_DIRECTORY, it).apply()
            service?.setOutputDirectory(it)
        }
        (call.argument<Int>("duration"))?.let {
            prefs.edit().putInt(KEY_DURATION, it).apply()
            service?.setMaxDuration(it)
        }
        (call.argument<Map<String, String>>("notificationText"))?.let {
            AudioRecordService.updateNotificationKeyValue(it)
        }
        result.success(null)
    }

    // Folder chosen with the Storage Access Framework, so recordings can go
    // to any folder the user picks (Downloads, Music, an SD card, ...).

    private fun pickDirectory(result: Result) {
        val activity: Activity = activityBinding?.activity ?: run {
            result.error("NO_ACTIVITY", "The folder picker needs a visible app", null)
            return
        }
        pendingPick?.success(null)
        pendingPick = result
        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT_TREE).addFlags(
            Intent.FLAG_GRANT_READ_URI_PERMISSION or
                Intent.FLAG_GRANT_WRITE_URI_PERMISSION or
                Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION
        )
        activity.startActivityForResult(intent, PICK_DIRECTORY_REQUEST)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode != PICK_DIRECTORY_REQUEST) return false
        val result = pendingPick ?: return true
        pendingPick = null
        val uri = data?.data
        if (resultCode != Activity.RESULT_OK || uri == null) {
            result.success(null)
            return true
        }
        try {
            context.contentResolver.takePersistableUriPermission(
                uri,
                Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION
            )
            treeUri()?.takeIf { it != uri }?.let { releasePermission(it) }
            prefs.edit().putString(KEY_TREE_URI, uri.toString()).apply()
            service?.setOutputTree(uri)
            result.success(folderName(uri))
        } catch (e: SecurityException) {
            Log.e(TAG, "could not keep access to $uri", e)
            result.error("NO_PERMISSION", e.message, null)
        }
        return true
    }

    private fun treeUri(): Uri? = prefs.getString(KEY_TREE_URI, null)?.let(Uri::parse)

    private fun folderName(uri: Uri): String =
        DocumentFile.fromTreeUri(context, uri)?.name ?: uri.lastPathSegment ?: uri.toString()

    private fun releasePermission(uri: Uri) {
        try {
            context.contentResolver.releasePersistableUriPermission(
                uri,
                Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION
            )
        } catch (_: SecurityException) {
        }
    }

    // Service connection

    override fun onServiceConnected(name: ComponentName?, binder: IBinder?) {
        val bridge = binder as? AudioRecordService.AudioRecordServiceBridge ?: return
        service = bridge.service.also {
            it.onStatusChangedListener = this
            prefs.getString(KEY_DIRECTORY, null)?.let(it::setOutputDirectory)
            it.setOutputTree(treeUri())
            it.setMaxDuration(prefs.getInt(KEY_DURATION, AudioRecordService.default_MaxDuration))
        }
    }

    override fun onServiceDisconnected(name: ComponentName?) {
        service = null
    }

    override fun onStatusChanged(state: Int, errorMsg: String?) {
        channel.invokeMethod(
            "recordStoppedCallBack",
            hashMapOf("status" to state, "error" to errorMsg)
        )
    }
}
