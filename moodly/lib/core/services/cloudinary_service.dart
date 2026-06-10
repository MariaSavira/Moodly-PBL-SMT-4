import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class CloudinaryService {
  static const String cloudName = 'ddmyv6zoh';

  /// JANGAN DIUBAH PERILAKUNYA:
  /// preset lama untuk upload foto profil / chat yang sudah kepakai.
  static const String uploadPreset = 'moodly_chat_upload';

  /// preset diary sengaja dipisah secara semantic.
  /// kalau nanti kamu bikin preset Cloudinary khusus diary, tinggal ganti ini.
  static const String diaryUploadPreset = 'moodly_chat_upload';

  static Uri get _uploadUri =>
      Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

  /// ================= EXISTING GENERIC / PROFILE UPLOAD =================
  /// Tetap dipertahankan supaya flow foto profil tidak ikut rusak.
  static Future<Map<String, String>> uploadImage(File imageFile) async {
    return _uploadSingleImage(
      imageFile: imageFile,
      uploadPresetValue: uploadPreset,
      uploadContext: 'generic',
    );
  }

  /// ================= DIARY SINGLE IMAGE UPLOAD =================
  static Future<Map<String, String>> uploadDiaryImage(File imageFile) async {
    return _uploadSingleImage(
      imageFile: imageFile,
      uploadPresetValue: diaryUploadPreset,
      uploadContext: 'diary',
    );
  }

  /// ================= DIARY MULTI IMAGE UPLOAD =================
  /// Upload satu per satu biar lebih stabil dan tidak bikin request numpuk brutal.
  static Future<List<Map<String, String>>> uploadDiaryImages(
    List<File> imageFiles,
  ) async {
    final results = <Map<String, String>>[];

    for (final file in imageFiles) {
      final uploaded = await uploadDiaryImage(file);
      results.add(uploaded);
    }

    return results;
  }

  /// ================= PRIVATE CORE =================
  static Future<Map<String, String>> _uploadSingleImage({
    required File imageFile,
    required String uploadPresetValue,
    required String uploadContext,
  }) async {
    if (!await imageFile.exists()) {
      throw Exception('File gambar tidak ditemukan.');
    }

    final request = http.MultipartRequest('POST', _uploadUri)
      ..fields['upload_preset'] = uploadPresetValue
      ..fields['context'] = 'app=Moodly|source=$uploadContext'
      ..files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );

    final response = await request.send().timeout(
      const Duration(seconds: 45),
    );

    final responseBody = await response.stream.bytesToString();

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Cloudinary upload failed: $responseBody');
    }

    final data = jsonDecode(responseBody) as Map<String, dynamic>;

    return {
      'imageUrl': (data['secure_url'] ?? '').toString(),
      'publicId': (data['public_id'] ?? '').toString(),
      'format': (data['format'] ?? '').toString(),
      'resourceType': (data['resource_type'] ?? '').toString(),
    };
  }
}