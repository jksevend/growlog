import 'package:flutter/services.dart';

class GallerySaver {
  static const MethodChannel _channel = MethodChannel('org.jksevend.weedy');

  static Future<String?> saveImage(String imagePath) async {
    final String? newPath =
        await _channel.invokeMethod('saveImageToGallery', {'imagePath': imagePath});
    return newPath;
  }
}
