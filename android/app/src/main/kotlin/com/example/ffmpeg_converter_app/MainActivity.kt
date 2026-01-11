package com.example.ffmpeg_converter_app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.arthenica.ffmpegkit.FFmpegKit
import com.arthenica.ffmpegkit.FFmpegSession
import com.arthenica.ffmpegkit.ReturnCode
import com.arthenica.ffmpegkit.SessionState
import android.os.Handler
import android.os.Looper
import java.util.concurrent.Executors

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.ffmpeg_converter_app/ffmpeg"
    private var currentSessionId: Long? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "execute") {
                val args = call.argument<List<String>>("args")
                if (args != null) {
                    executeFFmpeg(args, result)
                } else {
                    result.error("INVALID_ARGS", "Arguments cannot be null", null)
                }
            } else if (call.method == "cancel") {
                cancelFFmpeg(result)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun executeFFmpeg(args: List<String>, result: MethodChannel.Result) {
        // Convert List<String> to Array<String>
        val argsArray = args.toTypedArray()

        FFmpegKit.executeWithArgumentsAsync(argsArray, { session ->
            val state = session.state
            val returnCode = session.returnCode

            // FFmpegKit callbacks might not be on the main thread, so we switch back
            runOnUiThread {
                if (ReturnCode.isSuccess(returnCode)) {
                    val output = session.output
                    result.success(output)
                } else if (ReturnCode.isCancel(returnCode)) {
                    result.error("CANCELLED", "Operation cancelled", null)
                } else {
                    val failStackTrace = session.failStackTrace
                    val output = session.output
                    result.error("FAILED", "FFmpeg execution failed with code $returnCode.\nOutput: $output\nStack: $failStackTrace", null)
                }
                currentSessionId = null
            }
        }, { log ->
            // Optional: Send logs back to Flutter if needed via an EventChannel
            // For now, we rely on the final output or logcat
        }) { statistics ->
            // Optional: Send progress statistics back to Flutter
            // This would require a separate EventChannel or repeated callbacks which MethodChannel.Result doesn't support for single response.
            // For this implementation, we will rely on the final result.
            // If progress is strictly needed, we would need to set up an EventChannel.
        }.also { session ->
             currentSessionId = session.sessionId
        }
    }

    private fun cancelFFmpeg(result: MethodChannel.Result) {
        if (currentSessionId != null) {
            FFmpegKit.cancel(currentSessionId!!)
            result.success(true)
        } else {
            // Cancel all if no specific session (or just return success)
            FFmpegKit.cancel()
            result.success(true)
        }
    }
}
