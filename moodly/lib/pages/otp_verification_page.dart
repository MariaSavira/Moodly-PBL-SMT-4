import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/app_colors.dart';
import '../core/app_text_styles.dart';
import '../widgets/moodly_primary_button.dart';
import '../services/otp_service.dart';
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

  bool _isLoading = false;
  bool _isResending = false;

  String get _otpCode =>
      _otpControllers.map((controller) => controller.text).join();

  @override
  void dispose() {
    for (final controller in _otpControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    if (_otpCode.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan 4 digit kode OTP')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final success = await OtpService.verifyOtp(widget.email, _otpCode);

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const RegisterSuccessPage(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kode OTP salah atau kedaluwarsa')),
      );
    }
  }

  Future<void> _resendCode() async {
    setState(() => _isResending = true);

    try {
      await OtpService.sendOtp(widget.email);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kode OTP dikirim ulang')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mengirim ulang kode OTP')),
      );
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
      }
    }
  }

  Widget _otpBox(int index, double boxWidth, double boxHeight) {
    return Container(
      width: boxWidth,
      height: boxHeight,
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
      child: Center(
        child: TextField(
          controller: _otpControllers[index],
          textAlign: TextAlign.center,
          textAlignVertical: TextAlignVertical.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          style: const TextStyle(
            fontSize: 34,
            height: 1.0,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          decoration: const InputDecoration(
            counterText: '',
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 430;
    final contentWidth = isWide ? 402.0 : screenWidth;

    final otpBoxWidth = isWide ? 65.0 : screenWidth * 0.16;
    final otpBoxHeight = isWide ? 72.0 : 70.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: contentWidth,
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
                        'assets/icon/image4.png',
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
                      _otpBox(0, otpBoxWidth, otpBoxHeight),
                      _otpBox(1, otpBoxWidth, otpBoxHeight),
                      _otpBox(2, otpBoxWidth, otpBoxHeight),
                      _otpBox(3, otpBoxWidth, otpBoxHeight),
                    ],
                  ),

                  const SizedBox(height: 58),

                  MoodlyPrimaryButton(
                    label: _isLoading ? 'Memverifikasi...' : 'Verifikasi',
                    onPressed: _isLoading ? null : _verifyOtp,
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
        ),
      ),
    );
  }
}