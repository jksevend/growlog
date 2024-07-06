package org.jksevend.growlog

import android.content.ContentValues
import android.net.Uri
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.IOException
import java.io.OutputStream

class MainActivity : FlutterActivity() {
    private val CHANNEL = "org.jksevend.growlog"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "saveImageToGallery") {
                val imagePath = call.argument<String>("imagePath")
                val newImagePath = saveImageToGallery(imagePath)
                if (newImagePath != null) {
                    result.success(newImagePath)
                } else {
                    result.error("UNAVAILABLE", "Failed to save image to gallery.", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun saveImageToGallery(imagePath: String?): String? {
        if (imagePath == null) {
            return null
        }

        val file = File(imagePath)
        if (!file.exists()) {
            return null
        }

        val resolver = contentResolver
        val contentValues = ContentValues().apply {
            put(MediaStore.MediaColumns.DISPLAY_NAME, file.name)
            put(MediaStore.MediaColumns.MIME_TYPE, "image/jpeg")
            put(MediaStore.MediaColumns.RELATIVE_PATH, "Pictures/GrowLog")
        }

        val uri: Uri? = resolver.insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, contentValues)
        if (uri != null) {
            var outputStream: OutputStream? = null
            try {
                outputStream = resolver.openOutputStream(uri)
                val inputStream = file.inputStream()
                inputStream.copyTo(outputStream!!)
                outputStream!!.close()
                inputStream.close()
            } catch (e: IOException) {
                e.printStackTrace()
                return null
            } finally {
                outputStream?.close()
            }
        }

        return uri?.toString()
    }
}
