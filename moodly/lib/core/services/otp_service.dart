import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class OtpService {
  OtpService._();

  static final OtpService instance = OtpService._();

  static const String _envBaseUrl = String.fromEnvironment(
    'OTP_BASE_URL',
    defaultValue: '',
  );

  static String get _resolvedBaseUrl {
    final configured = _envBaseUrl.trim();

    if (configured.isNotEmpty) {
      return configured.replaceAll(RegExp(r'/+$'), '');
    }

    // Fallback otomatis khusus debug web
    if (kDebugMode && kIsWeb) {
      return 'http://localhost:5000';
    }

    throw Exception(
      'Backend OTP belum dikonfigurasi. Untuk web lokal, backend bisa di http://localhost:5000. Untuk Android/iOS fisik, localhost tidak bisa dipakai. Jalankan Flutter dengan --dart-define=OTP_BASE_URL=http://IP_LAPTOP:5000',
    );
  }

  static Uri _buildUri(String path) {
    return Uri.parse('$_resolvedBaseUrl$path');
  }

  void _logRequest({
    required String label,
    required Uri url,
    required Map<String, dynamic> body,
  }) {
    debugPrint('[$label] URL: $url');
    debugPrint('[$label] BODY: ${jsonEncode(body)}');
  }

  void _logResponse({
    required String label,
    required http.Response response,
  }) {
    debugPrint('[$label] STATUS: ${response.statusCode}');
    debugPrint('[$label] RESPONSE: ${response.body}');
  }

  void _logError({
    required String label,
    required Object error,
  }) {
    debugPrint('[$label] ERROR: $error');
  }

  Future<void> sendRegisterOtp({
    required String fullName,
    required String email,
  }) async {
    final url = _buildUri('/send-register-otp');
    final requestBody = {
      'fullName': fullName.trim(),
      'email': email.trim().toLowerCase(),
    };

    try {
      _logRequest(
        label: 'SEND_REGISTER_OTP',
        url: url,
        body: requestBody,
      );

      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: 12));

      _logResponse(
        label: 'SEND_REGISTER_OTP',
        response: response,
      );

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
    } on SocketException catch (e) {
      _logError(label: 'SEND_REGISTER_OTP', error: e);
      throw Exception(
        'Tidak bisa terhubung ke server OTP. Pastikan backend aktif dan alamat backend benar.',
      );
    } on TimeoutException catch (e) {
      _logError(label: 'SEND_REGISTER_OTP', error: e);
      throw Exception('Server OTP terlalu lama merespons.');
    } on FormatException catch (e) {
      _logError(label: 'SEND_REGISTER_OTP', error: e);
      throw Exception(
        'Respons server OTP bukan JSON yang valid. Cek backend /send-register-otp.',
      );
    } catch (e) {
      _logError(label: 'SEND_REGISTER_OTP', error: e);
      rethrow;
    }
  }

  Future<void> verifyRegisterOtpAndCreateUser({
    required String fullName,
    required String email,
    required String password,
    required String otp,
  }) async {
    final url = _buildUri('/verify-register-otp');
    final requestBody = {
      'fullName': fullName.trim(),
      'email': email.trim().toLowerCase(),
      'password': password,
      'otp': otp.trim(),
    };

    try {
      _logRequest(
        label: 'VERIFY_REGISTER_OTP',
        url: url,
        body: requestBody,
      );

      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: 12));

      _logResponse(
        label: 'VERIFY_REGISTER_OTP',
        response: response,
      );

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
    } on SocketException catch (e) {
      _logError(label: 'VERIFY_REGISTER_OTP', error: e);
      throw Exception(
        'Tidak bisa terhubung ke server OTP. Pastikan backend aktif dan alamat backend benar.',
      );
    } on TimeoutException catch (e) {
      _logError(label: 'VERIFY_REGISTER_OTP', error: e);
      throw Exception('Server OTP terlalu lama merespons.');
    } on FormatException catch (e) {
      _logError(label: 'VERIFY_REGISTER_OTP', error: e);
      throw Exception('Respons server verifikasi OTP bukan JSON yang valid.');
    } catch (e) {
      _logError(label: 'VERIFY_REGISTER_OTP', error: e);
      rethrow;
    }
  }

  Future<void> sendForgotPasswordResetEmail({
    required String email,
  }) async {
    final url = _buildUri('/send-forgot-password-email');
    final requestBody = {
      'email': email.trim().toLowerCase(),
    };

    try {
      _logRequest(
        label: 'SEND_FORGOT_PASSWORD',
        url: url,
        body: requestBody,
      );

      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: 12));

      _logResponse(
        label: 'SEND_FORGOT_PASSWORD',
        response: response,
      );

      final dynamic decodedBody =
          response.body.isNotEmpty ? jsonDecode(response.body) : null;

      final message = decodedBody is Map<String, dynamic>
          ? decodedBody['message']?.toString()
          : null;

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          message ??
              'Gagal mengirim email reset password. [HTTP ${response.statusCode}] ${response.body}',
        );
      }
    } on SocketException catch (e) {
      _logError(label: 'SEND_FORGOT_PASSWORD', error: e);
      throw Exception(
        'Tidak bisa terhubung ke server reset password. Pastikan backend aktif dan alamat backend benar.',
      );
    } on TimeoutException catch (e) {
      _logError(label: 'SEND_FORGOT_PASSWORD', error: e);
      throw Exception('Server reset password terlalu lama merespons.');
    } on FormatException catch (e) {
      _logError(label: 'SEND_FORGOT_PASSWORD', error: e);
      throw Exception(
        'Respons server reset password bukan JSON yang valid.',
      );
    } catch (e) {
      _logError(label: 'SEND_FORGOT_PASSWORD', error: e);
      rethrow;
    }
  }
}