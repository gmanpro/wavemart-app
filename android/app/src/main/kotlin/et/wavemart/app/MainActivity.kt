package et.wavemart.app

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import java.io.File

class MainActivity: FlutterActivity() {

    private val crashLogFile by lazy {
        File(cacheDir, "crash_log.txt")
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        // Native crash handler - catches crashes before Flutter loads
        Thread.setDefaultUncaughtExceptionHandler { thread, throwable ->
            val crashInfo = buildString {
                appendLine("=== NATIVE CRASH: ${java.util.Date()} ===")
                appendLine("Thread: ${thread.name}")
                appendLine("Error: ${throwable.message}")
                appendLine("Stack: ${throwable.stackTraceToString()}")
            }
            crashLogFile.appendText(crashInfo)
            
            // Also log to logcat
            android.util.Log.e("WaveMartCrash", crashInfo)
        }

        super.onCreate(savedInstanceState)
    }
}
