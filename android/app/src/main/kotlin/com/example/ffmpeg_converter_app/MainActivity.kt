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
    private val EVENT_CHANNEL = "com.example.ffmpeg_converter_app/ffmpeg/events"
    private var currentSessionId: Long? = null
    private var eventSink: io.flutter.plugin.common.EventChannel.EventSink? = null

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

        io.flutter.plugin.common.EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL).setStreamHandler(
            object : io.flutter.plugin.common.EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: io.flutter.plugin.common.EventChannel.EventSink?) {
                    eventSink = events
                }

                override fun onCancel(arguments: Any?) {
                    eventSink = null
                }
            }
        )
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
            // Log Callback
            runOnUiThread {
                eventSink?.success(mapOf(
                    "type" to "log",
                    "message" to log.message
                ))
            }
        }) { statistics ->
            // Statistics Callback
            runOnUiThread {
                eventSink?.success(mapOf(
                    "type" to "statistics",
                    "time" to statistics.time,
                    "size" to statistics.size,
                    "speed" to statistics.speed
                ))
            }
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
