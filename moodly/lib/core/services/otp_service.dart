import 'dart:convert';

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

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'fullName': fullName.trim(),
        'email': email.trim().toLowerCase(),
      }),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(data['message'] ?? 'Gagal mengirim OTP.');
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

    final response = await http.post(
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
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(data['message'] ?? 'Gagal memverifikasi OTP.');
    }
  }
}