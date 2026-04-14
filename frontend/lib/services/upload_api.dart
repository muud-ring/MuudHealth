// MUUD Health — Upload API Service (S3 presigned URLs)
// © Muud Health — Armin Hoes, MD

import 'api_client.dart';

class UploadApi {
  UploadApi._();

  /// Get presigned S3 URL for file upload
  static Future<Map<String, dynamic>> getPresignedUrl({
    required String fileName,
    required String contentType,
    String folder = 'uploads',
  }) async {
    final res = await ApiClient.post('/api/v1/uploads/presign', body: {
      'fileName': fileName,
      'contentType': contentType,
      'folder': folder,
    });
    return ApiClient.handleResponse(res);
  }
}
