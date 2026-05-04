import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class OtpService {
  static const String serviceId = 'service_cta918i';
  static const String templateId = 'template_2oa8ifh';
  static const String publicKey = 'p0q7D6OkvfW2KOFKc';

  static Future<String> sendOtp(String email) async {
    final otp = (1000 + Random().nextInt(9000)).toString();

    await FirebaseFirestore.instance.collection('otp').doc(email).set({
      'email': email,
      'code': otp,
      'createdAt': FieldValue.serverTimestamp(),
      'expiredAt': Timestamp.fromDate(
        DateTime.now().add(const Duration(minutes: 5)),
      ),
      'isUsed': false,
    });

    final response = await http.post(
      Uri.parse('https://api.emailjs.com/api/v1.0/email/send'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'service_id': serviceId,
        'template_id': templateId,
        'user_id': publicKey,
        'template_params': {
          'to_email': email,
          'otp_code': otp,
        },
      }),
    );

    if (response.statusCode != 200) {
      print('EMAILJS STATUS: ${response.statusCode}');
      print('EMAILJS BODY: ${response.body}');
      throw Exception('Gagal kirim OTP: ${response.body}');
    }

    print('OTP berhasil dikirim ke email: $email');
    print('Kode OTP: $otp');

    return otp;
  }

  static Future<bool> verifyOtp(String email, String inputOtp) async {
    try {
      final doc =
          await FirebaseFirestore.instance.collection('otp').doc(email).get();

      if (!doc.exists) return false;

      final data = doc.data();
      if (data == null) return false;

      final code = data['code']?.toString();
      final isUsed = data['isUsed'] ?? false;
      final expiredAt = data['expiredAt'];

      if (code == null) return false;
      if (expiredAt is! Timestamp) return false;
      if (isUsed == true) return false;
      if (DateTime.now().isAfter(expiredAt.toDate())) return false;
      if (inputOtp != code) return false;

      await FirebaseFirestore.instance.collection('otp').doc(email).update({
        'isUsed': true,
      });

      return true;
    } catch (e) {
      print('ERROR VERIFIKASI OTP: $e');
      return false;
    }
  }
}