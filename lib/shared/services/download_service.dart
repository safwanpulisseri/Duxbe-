import 'dart:async';

import 'package:duxbe/shared/shared.dart';

class FileDownloader {
  static Future<bool> downloadFile({
    required String url,
    required String filename,
    void Function(double)? onProgress,
    void Function(String)? onError,
  }) async {
    try {
      final downloader = IPlatformDownloader();
      return await downloader.downloadFile(
        url: url,
        filename: filename,
        onProgress: onProgress,
        onError: onError,
      );
    } catch (e) {
      if (onError != null) onError(e.toString());
      return false;
    }
  }
}
