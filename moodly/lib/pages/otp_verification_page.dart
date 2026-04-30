import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/app_text_styles.dart';
import '../widgets/moodly_primary_button.dart';
import 'register_success_page.dart';

class OtpVerificationPage extends StatefulWidget {
  final String email;

  const OtpVerificationPage({
    super.key,
    required this.email,
  });

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final List<TextEditingController> _otpControllers =
      List.generate(4, (_) => TextEditingController());

  @override
  void dispose() {
    for (final controller in _otpControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _verifyOtp() {
    final otp = _otpControllers.map((controller) => controller.text).join();

    if (otp.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan 4 digit kode OTP'),
        ),
      );
      return;
    }

    // sementara untuk UI flow.
    // nanti bagian ini diganti validasi OTP real ke backend.
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const RegisterSuccessPage(),
      ),
    );
  }

  Widget _otpBox(int index) {
    return Container(
      width: 65,
      height: 72,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.22),
            blurRadius: 22,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: TextField(
        controller: _otpControllers[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 3) {
            FocusScope.of(context).nextFocus();
          }

          if (value.isEmpty && index > 0) {
            FocusScope.of(context).previousFocus();
          }
        },
      ),
    );
  }

  void _resendCode() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Kode OTP dikirim ulang'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const SizedBox(height: 16),

              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Moodly',
                    style: AppTextStyles.brandTitle.copyWith(fontSize: 30),
                  ),
                  const Spacer(),
                  const SizedBox(width: 22),
                ],
              ),

              const SizedBox(height: 85),

              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.45),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Image.asset(
                    'assets/icon/image3.png',
                    width: 72,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Text(
                'Verifikasi Akun Anda',
                textAlign: TextAlign.center,
                style: AppTextStyles.heading1.copyWith(fontSize: 24),
              ),

              const SizedBox(height: 10),

              Text(
                'Kami telah mengirim kode 4 digit ke ${widget.email}.\nSilakan masukkan kode tersebut di bawah ini.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 70),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _otpBox(0),
                  _otpBox(1),
                  _otpBox(2),
                  _otpBox(3),
                ],
              ),

              const SizedBox(height: 58),

              MoodlyPrimaryButton(
                label: 'Verifikasi',
                onPressed: _verifyOtp,
                width: 250,
              ),

              const SizedBox(height: 24),

              const Text(
                'Tidak menerima kode?',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 14),

              GestureDetector(
                onTap: _resendCode,
                child: Container(
                  width: 170,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8B7BF),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Center(
                    child: Text(
                      'Kirim Ulang Kode',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}