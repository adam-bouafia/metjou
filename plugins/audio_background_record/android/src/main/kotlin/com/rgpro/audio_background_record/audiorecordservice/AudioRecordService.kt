package com.rgpro.audio_background_record.audiorecordservice

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Intent
import android.content.pm.ServiceInfo
import android.media.MediaRecorder
import android.net.Uri
import android.os.ParcelFileDescriptor
import android.media.MediaRecorder.MEDIA_RECORDER_INFO_MAX_DURATION_REACHED
import android.media.MediaRecorder.MEDIA_RECORDER_INFO_MAX_FILESIZE_REACHED
import android.os.Binder
import android.os.Build
import android.os.IBinder
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.core.app.ServiceCompat
import androidx.documentfile.provider.DocumentFile
import com.rgpro.audio_background_record.R
import java.io.IOException
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

/**
 * Foreground service of type "microphone". It has to be started while the
 * app is visible; after that it may record while the app is in background.
 */
class AudioRecordService : Service(), MediaRecorder.OnInfoListener {
    companion object {
        val TAG: String = AudioRecordService::class.java.name
        private const val CHANNEL_ID = "audioRecordNotification"
        private const val NOTIFICATION_ID = 7
        var DEFAULT_OUT_DIRECTORY: String = ""
            private set
        const val default_MaxDuration = 20000 // 20 seconds

        private val notificationText = mutableMapOf(
            "title" to "Audio Recording Service",
            "ready" to "Service is ready to record",
            "recording" to "Recording",
        )

        fun updateNotificationKeyValue(source: Map<String, String>) {
            for (key in listOf("title", "ready", "recording")) {
                source[key]?.let { notificationText[key] = it }
            }
        }
    }

    inner class AudioRecordServiceBridge(val service: AudioRecordService) : Binder()

    interface OnRecordStatusChangedListener {
        fun onStatusChanged(state: Int, errorMsg: String? = null)
    }

    private var recorder: MediaRecorder? = null
    private val binder = AudioRecordServiceBridge(this)
    private var isRecording = false
    private var outDirectory: String? = null
    private var outTree: Uri? = null
    private var outDescriptor: ParcelFileDescriptor? = null
    private var savedLocation: String? = null
    private var maxDuration: Int = default_MaxDuration

    var onStatusChangedListener: OnRecordStatusChangedListener? = null

    override fun onBind(intent: Intent): IBinder = binder

    override fun onCreate() {
        super.onCreate()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID, notificationText.getValue("title"), NotificationManager.IMPORTANCE_LOW
            )
            getSystemService(NotificationManager::class.java).createNotificationChannel(channel)
        }
        DEFAULT_OUT_DIRECTORY = filesDir.absolutePath
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        updateNotification()
        return START_STICKY
    }

    override fun onDestroy() {
        stopRecording()
        super.onDestroy()
    }

    private fun updateNotification() {
        val notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle(notificationText["title"])
            .setContentText(notificationText[if (isRecording) "recording" else "ready"])
            .setSmallIcon(R.drawable.ic_bg_service_small)
            .setOngoing(true)
            .build()
        val type = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            ServiceInfo.FOREGROUND_SERVICE_TYPE_MICROPHONE
        } else {
            0
        }
        ServiceCompat.startForeground(this, NOTIFICATION_ID, notification, type)
    }

    private fun prepareNewRecorderInstance(): MediaRecorder? {
        val newRecorder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            MediaRecorder(this)
        } else {
            @Suppress("DEPRECATION")
            MediaRecorder()
        }
        return try {
            newRecorder.apply {
                setOnInfoListener(this@AudioRecordService)
                setAudioSource(MediaRecorder.AudioSource.MIC)
                setOutputFormat(MediaRecorder.OutputFormat.AAC_ADTS)
                setAudioEncoder(MediaRecorder.AudioEncoder.AAC)
            }
        } catch (e: Exception) {
            Log.e(TAG, "recorder setup failed", e)
            newRecorder.release()
            onStatusChangedListener?.onStatusChanged(0, e.message)
            null
        }
    }

    private fun newFileName(): String =
        "MetJou_" + SimpleDateFormat("yyyy-MM-dd_HH-mm-ss", Locale.ROOT).format(Date()) + ".aac"

    /**
     * Points the recorder at a file in the folder the user picked. Returns
     * false when that folder is gone or access was revoked, so the caller
     * falls back to the app's private folder.
     */
    private fun useTreeOutput(recorder: MediaRecorder, tree: Uri): Boolean {
        return try {
            val folder = DocumentFile.fromTreeUri(this, tree) ?: return false
            val file = folder.createFile("audio/aac", newFileName()) ?: return false
            val descriptor = contentResolver.openFileDescriptor(file.uri, "w") ?: return false
            outDescriptor = descriptor
            recorder.setOutputFile(descriptor.fileDescriptor)
            savedLocation = "${folder.name}/${file.name}"
            true
        } catch (e: Exception) {
            Log.e(TAG, "cannot write to picked folder", e)
            false
        }
    }

    fun startRecording() {
        val newRecorder = prepareNewRecorderInstance() ?: return
        try {
            val tree = outTree
            if (tree == null || !useTreeOutput(newRecorder, tree)) {
                val name = newFileName()
                newRecorder.setOutputFile("${outDirectory ?: DEFAULT_OUT_DIRECTORY}/$name")
                savedLocation = name
            }
            newRecorder.setMaxDuration(maxDuration)
            newRecorder.prepare()
            newRecorder.start()
            recorder = newRecorder
            isRecording = true
            updateNotification()
            onStatusChangedListener?.onStatusChanged(1, null)
        } catch (e: IOException) {
            recordingFailed(newRecorder, e)
        } catch (e: IllegalStateException) {
            recordingFailed(newRecorder, e)
        }
    }

    private fun recordingFailed(failed: MediaRecorder, e: Exception) {
        Log.e(TAG, "startRecording failed", e)
        failed.release()
        closeDescriptor()
        isRecording = false
        onStatusChangedListener?.onStatusChanged(0, e.message)
    }

    fun stopRecording() {
        recorder?.let {
            if (isRecording) {
                try {
                    it.stop()
                    // For status 2 the message is where the file was saved.
                    onStatusChangedListener?.onStatusChanged(2, savedLocation)
                } catch (e: Exception) {
                    onStatusChangedListener?.onStatusChanged(0, e.message)
                }
            }
            it.release()
        }
        recorder = null
        closeDescriptor()
        if (isRecording) {
            isRecording = false
            updateNotification()
        }
    }

    fun isRecording(): Boolean = isRecording

    fun setOutputDirectory(directory: String) {
        outDirectory = directory
    }

    fun setOutputTree(tree: Uri?) {
        outTree = tree
    }

    private fun closeDescriptor() {
        try {
            outDescriptor?.close()
        } catch (_: Exception) {
        }
        outDescriptor = null
    }

    fun setMaxDuration(duration: Int) {
        maxDuration = duration
    }

    override fun onInfo(mr: MediaRecorder?, what: Int, extra: Int) {
        if (what == MEDIA_RECORDER_INFO_MAX_DURATION_REACHED ||
            what == MEDIA_RECORDER_INFO_MAX_FILESIZE_REACHED
        ) {
            stopRecording()
        }
    }
}
