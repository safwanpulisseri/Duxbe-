import 'dart:typed_data';

import 'package:duxbe/shared/shared.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseStorageService {
  SupabaseStorageService(this._supabaseClient);
  final SupabaseClient _supabaseClient;

  /// Uploads a single image to Supabase Storage.
  /// Returns the public URL of the uploaded image.
  Future<String?> uploadImage({
    required String businessId,
    required String fileName,
    required String filePath,
    required Uint8List file,
  }) async {
    try {
      final storageRef = _supabaseClient.storage.from('business-assets');
      final fileURL = '$businessId/$filePath/$fileName';

      // Upload the image as binary data
      await storageRef.uploadBinary(fileURL, file, fileOptions: const FileOptions(upsert: true));
      // Retrieve the public URL
      return storageRef.getPublicUrl(fileURL);
    } catch (e) {
      // Log the error or handle it as needed
      throw AppException('Failed to upload image: $e');
    }
  }

  /// Uploads a single file to Supabase Storage.
  /// Returns the public URL of the uploaded image.
  Future<String?> uploadPlatformFile({
    required String businessId,
    required String fileName,
    required String filePath,
    required PlatformFile file,
  }) async {
    try {
      final storageRef = _supabaseClient.storage.from('business-assets');
      final fileURL = '$businessId/$filePath/$fileName';

      // Upload the image as binary data
      await storageRef.uploadBinary(fileURL, file.bytes!, fileOptions: const FileOptions(upsert: true));
      // Retrieve the public URL
      return storageRef.getPublicUrl(fileURL);
    } catch (e) {
      // Log the error or handle it as needed
      throw AppException('Failed to upload image: $e');
    }
  }

  /// Deletes a single image from Supabase Storage.
  Future<void> deleteImage({
    required String businessId,
    required String fileName,
    required String filePath,
  }) async {
    try {
      final storageRef = _supabaseClient.storage.from('business-assets');
      final fileUrl = '$businessId/$filePath/$fileName';

      // Delete the image
      final _ = await storageRef.remove([fileUrl]);
    } catch (e) {
      // Log the error or handle it as needed
      throw Exception('Failed to delete image: $e');
    }
  }

  Future<String?> uploadOrgImage({
    required String fileName,
    required String filePath,
    required Uint8List file,
  }) async {
    try {
      final storageRef = _supabaseClient.storage.from('org-assets');
      final fileURL = '$filePath/$fileName';

      // Upload the image as binary data
      await storageRef.uploadBinary(fileURL, file, fileOptions: const FileOptions(upsert: true));
      // Retrieve the public URL
      return storageRef.getPublicUrl(fileURL);
    } catch (e) {
      // Log the error or handle it as needed
      throw AppException('Failed to upload image: $e');
    }
  }
}
