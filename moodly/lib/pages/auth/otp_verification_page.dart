import 'package:flutter/material.dart';

import '../../core/services/otp_service.dart';
import '../../core/styles/app_colors.dart';
import '../../core/styles/app_text_styles.dart';
import '../../widgets/moodly_primary_button.dart';
import 'auth.dart';

class OtpVerificationPage extends StatefulWidget {
  final String fullName;
  final String email;
  final String phoneNumber;
  final String password;

  const OtpVerificationPage({
    super.key,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.password,
  });

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final List<TextEditingController> _otpControllers =
      List.generate(4, (_) => TextEditingController());

  bool _isLoading = false;
  bool _isResending = false;

  @override
  void dispose() {
    for (final controller in _otpControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    final otp = _otpControllers.map((controller) => controller.text).join();

    if (otp.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan 4 digit kode OTP'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await OtpService.instance.verifyRegisterOtpAndCreateUser(
        fullName: widget.fullName,
        email: widget.email,
        phoneNumber: widget.phoneNumber,
        password: widget.password,
        otp: otp,
      );

      if (!mounted) return;

      setState(() => _isLoading = false);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const RegisterSuccessPage(),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
          ),
        ),
      );
    }
  }

  Future<void> _resendCode() async {
    setState(() => _isResending = true);

    try {
      await OtpService.instance.sendRegisterOtp(
        fullName: widget.fullName,
        email: widget.email,
      );

      if (!mounted) return;

      setState(() => _isResending = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kode OTP dikirim ulang ke email.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() => _isResending = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
          ),
        ),
      );
    }
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
                    'assets/icons/login/image3.png',
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
                label: _isLoading ? 'Memeriksa...' : 'Verifikasi',
                onPressed: _isLoading ? () {} : _verifyOtp,
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
                onTap: _isResending ? null : _resendCode,
                child: Container(
                  width: 170,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8B7BF),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Center(
                    child: Text(
                      _isResending ? 'Mengirim...' : 'Kirim Ulang Kode',
                      style: const TextStyle(
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