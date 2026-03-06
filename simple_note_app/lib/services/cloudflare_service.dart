import 'dart:io';
import 'package:dio/dio.dart';
import 'package:aws_signature_v4/aws_signature_v4.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

class CloudflareService {
  // --- THÔNG TIN CẤU HÌNH CLOUDFLARE R2 ---
  final String accessKey = 'YOUR_ACCESS_KEY';
  final String secretKey = 'YOUR_SECRET_KEY';
  final String endpoint = 'https://YOUR_ACCOUNT_ID.r2.cloudflarestorage.com';
  final String bucketName = 'YOUR_BUCKET_NAME';
  final String region = 'auto';
  final String publicUrl = 'https://pub-your-id.r2.dev'; // Link để xem file công khai

  final Dio _dio = Dio();

  Future<String?> uploadFile(dynamic fileSource, String originalName) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${p.basename(originalName)}';
    final uploadUrl = '$endpoint/$bucketName/$fileName';
    final downloadUrl = '$publicUrl/$fileName';

    try {
      Uint8List fileBytes;
      if (fileSource is File) {
        fileBytes = await fileSource.readAsBytes();
      } else if (fileSource is Uint8List) {
        fileBytes = fileSource;
      } else {
        return null;
      }

      // Ký xác thực AWS V4 (R2 tương thích chuẩn S3)
      final signer = AWSSigV4Signer(
        credentials: AWSCredentials(accessKey, secretKey),
        region: region,
        service: 's3',
      );

      final request = AWSHttpRequest(
        method: AWSHttpMethod.put,
        uri: Uri.parse(uploadUrl),
        body: fileBytes,
        headers: {
          'Content-Type': _getContentType(fileName),
        },
      );

      final signedRequest = await signer.sign(request);

      final response = await _dio.put(
        uploadUrl,
        data: Stream.fromIterable([fileBytes]),
        options: Options(
          headers: signedRequest.headers,
        ),
      );

      if (response.statusCode == 200) {
        debugPrint('Cloudflare Upload Success: $downloadUrl');
        return downloadUrl;
      }
    } catch (e) {
      debugPrint('Cloudflare Upload Error: $e');
    }
    return null;
  }

  String _getContentType(String fileName) {
    final ext = p.extension(fileName).toLowerCase();
    if (ext == '.pdf') return 'application/pdf';
    if (ext == '.png') return 'image/png';
    if (ext == '.jpg' || ext == '.jpeg') return 'image/jpeg';
    return 'application/octet-stream';
  }
}
