package tomek.com.podcast

import android.os.Bundle

import io.flutter.app.FlutterActivity
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import android.app.DownloadManager
import android.content.Context
import android.net.Uri
import android.content.Intent
import android.content.BroadcastReceiver
import android.content.IntentFilter

class MainActivity() : FlutterActivity() {
    private val DOWNLOAD_CHANNEL = "podcast.com/download"
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        GeneratedPluginRegistrant.registerWith(this)

        MethodChannel(getFlutterView(), DOWNLOAD_CHANNEL).setMethodCallHandler(
                object : MethodChannel.MethodCallHandler {
                    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
                        if (call.method == "downloadEpisode") {
                            val dm = getSystemService(Context.DOWNLOAD_SERVICE) as DownloadManager
                            val id = downloadEpisode(dm)
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
                                                result.success(uriString)
                                            }
                                            else
                                            {
                                                result.error("UNAVAILABLE", "Could not download episode.", null)
                                            }
                                        }
                                        else
                                        {
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
                }
        )
    }


    fun downloadEpisode(downloadManager: DownloadManager): Long {
        val request = DownloadManager.Request(
                Uri.parse("http://www.vogella.de/img/lars/LarsVogelArticle7.png"))
        return downloadManager.enqueue(request)
    }
}
