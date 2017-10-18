package tomek.com.podcast

import android.app.DownloadManager
import android.app.DownloadManager.Request.NETWORK_WIFI
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.media.AudioManager
import android.media.MediaPlayer
import android.net.Uri
import android.os.BatteryManager
import android.os.Bundle
import android.util.Log
import io.flutter.app.FlutterActivity
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import java.io.IOException

class MainActivity : FlutterActivity() {

    private val mediaPlayer: MediaPlayer by lazy {
        MediaPlayer()
    }



    companion object {
        private const val DOWNLOAD_CHANNEL = "podcast.com/download"
        private const val STREAM_CHANNEL = "podcast.com/stream"
        private const val PLAY_CHANNEL = "podcast.com/play"
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        GeneratedPluginRegistrant.registerWith(this)

        MethodChannel(flutterView, DOWNLOAD_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "downloadEpisode") {

                val dm = getSystemService(Context.DOWNLOAD_SERVICE) as DownloadManager

                val fileName = call.argument<String>("url")
                val id = downloadEpisode(dm, fileName)
                val receiver = object : BroadcastReceiver() {
                    override fun onReceive(context: Context, intent: Intent) {
                        val action = intent.action
                        if (DownloadManager.ACTION_DOWNLOAD_COMPLETE == action) {
                            val query = DownloadManager.Query()
                            query.setFilterById(id)
                            val c = dm.query(query)
                            if (c.moveToFirst()) {
                                val columnIndex = c
                                        .getColumnIndex(DownloadManager.COLUMN_STATUS)
                                if (DownloadManager.STATUS_SUCCESSFUL == c
                                        .getInt(columnIndex)) {

                                    val uriString = c
                                            .getString(c
                                                    .getColumnIndex(
                                                            DownloadManager.COLUMN_LOCAL_URI))
                                    val title = c.getString(
                                            c.getColumnIndex(DownloadManager.COLUMN_TITLE))
                                    result.success(title)
                                } else {
                                    result.error("UNAVAILABLE", "Could not download episode.", null)
                                }
                            } else {
                                result.error("UNAVAILABLE", "Could not download episode.", null)
                            }
                        }
                    }
                }
                registerReceiver(receiver, IntentFilter(
                        DownloadManager.ACTION_DOWNLOAD_COMPLETE))
            } else {
                result.notImplemented()
            }
        }
        Log.e("QQQ0", mediaPlayer.toString())
        EventChannel(flutterView, PLAY_CHANNEL).setStreamHandler(
                object : EventChannel.StreamHandler {
                    override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
                        mediaPlayer.setOnBufferingUpdateListener { mp, percent ->
                            events.success(percent)
                        }
                    }

                    override fun onCancel(arguments: Any?) {
                        mediaPlayer.setOnBufferingUpdateListener(null)
                    }
                }
        )
        MethodChannel(flutterView, STREAM_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "streamEpisode") {
                with(mediaPlayer) {
                    reset()

                    setAudioStreamType(AudioManager.STREAM_MUSIC)
                    setDataSource(applicationContext,
                            Uri.parse(call.argument<String>("url")))
                    try {
                        setOnPreparedListener { it.start() }
                        prepareAsync()
                    } catch ( e: IllegalArgumentException) {
                        Log.e("Error", e.toString())
                    } catch ( e: IllegalStateException) {
                        Log.e("Error", e.toString())
                    } catch ( e: IOException) {
                        Log.e("Error", e.toString())
                    }

                    result.success("Done!")
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun createChargingStateChangeReceiver(
            events: EventChannel.EventSink): BroadcastReceiver {
        return object : BroadcastReceiver() {
            override fun onReceive(context: Context, intent: Intent) {
                val status = intent.getIntExtra(BatteryManager.EXTRA_STATUS, -1)

                if (status == BatteryManager.BATTERY_STATUS_UNKNOWN) {
                    events.error("UNAVAILABLE", "Charging status unavailable", null)
                } else {
                    val isCharging = status == BatteryManager.BATTERY_STATUS_CHARGING || status == BatteryManager.BATTERY_STATUS_FULL
                    events.success(if (isCharging) "charging" else "discharging")
                }
            }
        }
    }

    private fun downloadEpisode(downloadManager: DownloadManager, file: String): Long {
        val request = DownloadManager.Request(
                Uri.parse(file))
                .setMimeType("audio/mpeg3")
                .setTitle("Podcast!")
                .setAllowedNetworkTypes(NETWORK_WIFI)
        return downloadManager.enqueue(request)
    }

    override fun onPause() {
        super.onPause()
        mediaPlayer.reset()
    }
}
