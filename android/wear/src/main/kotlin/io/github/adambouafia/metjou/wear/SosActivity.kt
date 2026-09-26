package io.github.adambouafia.metjou.wear

import android.app.Activity
import android.graphics.Color
import android.graphics.drawable.GradientDrawable
import android.os.Bundle
import android.os.VibrationEffect
import android.os.Vibrator
import android.view.Gravity
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView
import com.google.android.gms.wearable.Wearable

/**
 * One large SOS button. The press goes to the phone, which starts the
 * countdown so a mistaken press can still be cancelled there.
 */
class SosActivity : Activity() {
    companion object {
        private const val SOS_PATH = "/metjou/sos"
    }

    private lateinit var status: TextView

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val density = resources.displayMetrics.density
        val button = Button(this).apply {
            text = getString(R.string.sos)
            textSize = 28f
            setTextColor(Color.WHITE)
            background = GradientDrawable().apply {
                shape = GradientDrawable.OVAL
                colors = intArrayOf(Color.parseColor("#E64553"), Color.parseColor("#D20F39"))
            }
            setOnClickListener { sendSos() }
        }
        status = TextView(this).apply {
            text = getString(R.string.hint)
            textSize = 13f
            gravity = Gravity.CENTER
            setTextColor(Color.parseColor("#CDD6F4"))
        }
        setContentView(
            LinearLayout(this).apply {
                orientation = LinearLayout.VERTICAL
                gravity = Gravity.CENTER
                setBackgroundColor(Color.parseColor("#1E1E2E"))
                val size = (120 * density).toInt()
                addView(button, LinearLayout.LayoutParams(size, size))
                addView(
                    status,
                    LinearLayout.LayoutParams(
                        (170 * density).toInt(),
                        LinearLayout.LayoutParams.WRAP_CONTENT
                    ).apply { topMargin = (10 * density).toInt() }
                )
            }
        )
    }

    private fun sendSos() {
        vibrate()
        status.text = getString(R.string.sending)
        Wearable.getNodeClient(this).connectedNodes
            .addOnSuccessListener { nodes ->
                if (nodes.isEmpty()) {
                    status.text = getString(R.string.no_phone)
                    return@addOnSuccessListener
                }
                val messages = Wearable.getMessageClient(this)
                for (node in nodes) {
                    messages.sendMessage(node.id, SOS_PATH, ByteArray(0))
                        .addOnSuccessListener { status.text = getString(R.string.sent) }
                        .addOnFailureListener { status.text = getString(R.string.failed) }
                }
            }
            .addOnFailureListener { status.text = getString(R.string.failed) }
    }

    private fun vibrate() {
        getSystemService(Vibrator::class.java)
            ?.vibrate(VibrationEffect.createOneShot(200, VibrationEffect.DEFAULT_AMPLITUDE))
    }
}
