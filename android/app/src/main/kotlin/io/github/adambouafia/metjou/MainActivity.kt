package io.github.adambouafia.metjou

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.hardware.camera2.CameraCharacteristics
import android.hardware.camera2.CameraManager
import android.media.AudioManager
import android.media.Ringtone
import android.media.RingtoneManager
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Device features Flutter plugins do not cover: flashlight, volume boost for
 * the siren, the system ringtone for the fake call, the disguised launcher
 * icon, and actions from the Quick Settings tile, widget and shortcuts.
 */
class MainActivity : FlutterActivity() {
    companion object {
        const val EXTRA_ACTION = "metjou_action"
        private const val CHANNEL = "metjou/device"
    }

    private var channel: MethodChannel? = null
    private var pendingAction: String? = null
    private var ringtone: Ringtone? = null
    private var savedVolume: Int? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        pendingAction = intent?.getStringExtra(EXTRA_ACTION)
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).apply {
            setMethodCallHandler { call, result ->
                when (call.method) {
                    "takeLaunchAction" -> {
                        result.success(pendingAction)
                        pendingAction = null
                    }
                    "setTorch" -> result.success(setTorch(call.argument<Boolean>("on") == true))
                    "boostVolume" -> {
                        boostVolume()
                        result.success(null)
                    }
                    "restoreVolume" -> {
                        restoreVolume()
                        result.success(null)
                    }
                    "startRingtone" -> {
                        startRingtone()
                        result.success(null)
                    }
                    "stopRingtone" -> {
                        ringtone?.stop()
                        ringtone = null
                        result.success(null)
                    }
                    "setDiscreet" -> {
                        setDiscreet(call.argument<Boolean>("enabled") == true)
                        result.success(null)
                    }
                    "setSecure" -> {
                        // Hides the app's content in the recent apps screen.
                        if (call.argument<Boolean>("enabled") == true) {
                            window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
                        } else {
                            window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                        }
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        intent.getStringExtra(EXTRA_ACTION)?.let { channel?.invokeMethod("launchAction", it) }
    }

    override fun onDestroy() {
        ringtone?.stop()
        setTorch(false)
        restoreVolume()
        super.onDestroy()
    }

    private fun setTorch(on: Boolean): Boolean {
        val camera = getSystemService(Context.CAMERA_SERVICE) as CameraManager
        val id = camera.cameraIdList.firstOrNull {
            camera.getCameraCharacteristics(it).get(CameraCharacteristics.FLASH_INFO_AVAILABLE) == true
        } ?: return false
        return try {
            camera.setTorchMode(id, on)
            true
        } catch (e: Exception) {
            false
        }
    }

    private fun boostVolume() {
        val audio = getSystemService(Context.AUDIO_SERVICE) as AudioManager
        if (savedVolume == null) savedVolume = audio.getStreamVolume(AudioManager.STREAM_MUSIC)
        audio.setStreamVolume(
            AudioManager.STREAM_MUSIC,
            audio.getStreamMaxVolume(AudioManager.STREAM_MUSIC),
            0
        )
    }

    private fun restoreVolume() {
        val volume = savedVolume ?: return
        val audio = getSystemService(Context.AUDIO_SERVICE) as AudioManager
        audio.setStreamVolume(AudioManager.STREAM_MUSIC, volume, 0)
        savedVolume = null
    }

    private fun startRingtone() {
        ringtone?.stop()
        val uri = RingtoneManager.getActualDefaultRingtoneUri(this, RingtoneManager.TYPE_RINGTONE)
            ?: RingtoneManager.getDefaultUri(RingtoneManager.TYPE_RINGTONE)
        ringtone = RingtoneManager.getRingtone(this, uri)?.apply {
            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.P) isLooping = true
            play()
        }
    }

    /** Swaps the launcher entry between MetJou and the disguised icon. */
    private fun setDiscreet(enabled: Boolean) {
        fun set(alias: String, on: Boolean) = packageManager.setComponentEnabledSetting(
            ComponentName(this, "$packageName.$alias"),
            if (on) PackageManager.COMPONENT_ENABLED_STATE_ENABLED
            else PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
            PackageManager.DONT_KILL_APP
        )
        set("DiscreetLauncher", enabled)
        set("DefaultLauncher", !enabled)
    }
}
