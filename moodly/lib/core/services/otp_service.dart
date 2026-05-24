import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class OtpService {
  OtpService._();

  static final OtpService instance = OtpService._();

  static const String baseUrl = 'http://192.168.1.4:5000';

  Future<void> sendRegisterOtp({
    required String fullName,
    required String email,
  }) async {
    final url = Uri.parse('$baseUrl/send-register-otp');

    try {
      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'fullName': fullName.trim(),
              'email': email.trim().toLowerCase(),
            }),
          )
          .timeout(const Duration(seconds: 12));

      final dynamic decodedBody =
          response.body.isNotEmpty ? jsonDecode(response.body) : null;

      final message = decodedBody is Map<String, dynamic>
          ? decodedBody['message']?.toString()
          : null;

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          message ??
              'Gagal mengirim OTP. [HTTP ${response.statusCode}] ${response.body}',
        );
      }
    } on SocketException {
      throw Exception(
        'Tidak bisa terhubung ke server OTP. Pastikan HP dan laptop satu Wi-Fi, server aktif, dan IP baseUrl benar.',
      );
    } on TimeoutException {
      throw Exception('Server OTP terlalu lama merespons.');
    } on FormatException {
      throw Exception(
        'Respons server OTP bukan JSON yang valid. Cek backend /send-register-otp.',
      );
    }
  }

  Future<void> verifyRegisterOtpAndCreateUser({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
    required String otp,
  }) async {
    final url = Uri.parse('$baseUrl/verify-register-otp');

    try {
      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'fullName': fullName.trim(),
              'email': email.trim().toLowerCase(),
              'phoneNumber': phoneNumber.trim(),
              'password': password,
              'otp': otp.trim(),
            }),
          )
          .timeout(const Duration(seconds: 12));

      final dynamic decodedBody =
          response.body.isNotEmpty ? jsonDecode(response.body) : null;

      final message = decodedBody is Map<String, dynamic>
          ? decodedBody['message']?.toString()
          : null;

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          message ??
              'Gagal memverifikasi OTP. [HTTP ${response.statusCode}] ${response.body}',
        );
      }
    } on SocketException {
      throw Exception(
        'Tidak bisa terhubung ke server OTP. Pastikan server aktif dan alamat baseUrl benar.',
      );
    } on TimeoutException {
      throw Exception('Server OTP terlalu lama merespons.');
    } on FormatException {
      throw Exception(
        'Respons server verifikasi OTP bukan JSON yang valid.',
      );
    }
  }
}