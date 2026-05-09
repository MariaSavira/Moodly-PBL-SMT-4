import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/services/otp_service.dart';
import '../../core/styles/app_colors.dart';
import '../../widgets/moodly_primary_button.dart';
import '../afirmasi/widgets/cute_top_popup.dart';
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
  final List<FocusNode> _otpFocusNodes =
      List.generate(4, (_) => FocusNode());

  bool _isLoading = false;
  bool _isResending = false;

  Timer? _countdownTimer;
  int _remainingSeconds = 30;

  @override
  void initState() {
    super.initState();
    _startResendCountdown();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();

    for (final controller in _otpControllers) {
      controller.dispose();
    }
    for (final node in _otpFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _showPopup({
    required String title,
    required String message,
    required CutePopupType type,
  }) {
    showCuteTopPopup(
      context,
      title: title,
      message: message,
      type: type,
    );
  }

  void _startResendCountdown() {
    _countdownTimer?.cancel();

    setState(() {
      _remainingSeconds = 30;
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      if (_remainingSeconds <= 1) {
        timer.cancel();
        setState(() {
          _remainingSeconds = 0;
        });
      } else {
        setState(() {
          _remainingSeconds--;
        });
      }
    });
  }

  String _formatCountdown(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  String get _currentOtp =>
      _otpControllers.map((controller) => controller.text).join();

  bool get _isOtpComplete => _otpControllers.every(
        (controller) => controller.text.trim().isNotEmpty,
      );

  void _tryAutoSubmit() {
    if (_isOtpComplete && !_isLoading) {
      _verifyOtp();
    }
  }

  Future<void> _verifyOtp() async {
    FocusScope.of(context).unfocus();
    final otp = _currentOtp;

    if (otp.length != 4) {
      _showPopup(
        title: 'Kode belum lengkap',
        message: 'Masukkan 4 digit kode OTP terlebih dahulu.',
        type: CutePopupType.warning,
      );
      return;
    }

    if (_isLoading) return;

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

      _showPopup(
        title: 'Verifikasi gagal',
        message: e.toString().replaceFirst('Exception: ', ''),
        type: CutePopupType.error,
      );
    }
  }

  Future<void> _resendCode() async {
    if (_remainingSeconds > 0 || _isResending) return;

    FocusScope.of(context).unfocus();
    setState(() => _isResending = true);

    try {
      await OtpService.instance.sendRegisterOtp(
        fullName: widget.fullName,
        email: widget.email,
      );

      if (!mounted) return;

      for (final controller in _otpControllers) {
        controller.clear();
      }

      _otpFocusNodes.first.requestFocus();

      setState(() => _isResending = false);
      _startResendCountdown();

      _showPopup(
        title: 'Kode terkirim',
        message: 'Kode OTP baru sudah dikirim ke email kamu.',
        type: CutePopupType.success,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isResending = false);

      _showPopup(
        title: 'Gagal kirim ulang',
        message: e.toString().replaceFirst('Exception: ', ''),
        type: CutePopupType.error,
      );
    }
  }

  Widget _otpBox(int index) {
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      width: 68,
      height: 78,
      child: TextField(
        controller: _otpControllers[index],
        focusNode: _otpFocusNodes[index],
        textAlign: TextAlign.center,
        textAlignVertical: TextAlignVertical.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: textTheme.headlineLarge?.copyWith(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF1D1D1D),
        ),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(
              color: Color(0xFFD9DEC8),
              width: 1.4,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(
              color: AppColors.primary,
              width: 2,
            ),
          ),
        ),
        onChanged: (value) {
          if (value.isNotEmpty) {
            if (index < 3) {
              _otpFocusNodes[index + 1].requestFocus();
            } else {
              FocusScope.of(context).unfocus();
              _tryAutoSubmit();
            }
          } else if (index > 0) {
            _otpFocusNodes[index - 1].requestFocus();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final brandTitleStyle = textTheme.headlineLarge?.copyWith(
      fontSize: 30,
      fontWeight: FontWeight.w700,
      color: const Color(0xFFD5676E),
    );

    final titleStyle = textTheme.headlineLarge?.copyWith(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      color: const Color(0xFF111111),
      height: 1.1,
    );

    final descStyle = textTheme.bodyMedium?.copyWith(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: const Color(0xFF303030),
      height: 1.5,
    );

    final emailStyle = textTheme.bodyMedium?.copyWith(
      fontSize: 13,
      fontWeight: FontWeight.w700,
      color: AppColors.primary,
      height: 1.5,
    );

    final infoStyle = textTheme.bodyMedium?.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      color: const Color(0xFF252525),
    );

    final resendStyle = textTheme.bodyMedium?.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      color: const Color(0xFFD96A87),
    );

    final countdownStyle = textTheme.bodyMedium?.copyWith(
      fontSize: 13,
      fontWeight: FontWeight.w700,
      color: const Color(0xFF91A17A),
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0xFFEFF5D6),
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFFEFF5D6),
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            Positioned.fill(
              child: Container(color: AppColors.background),
            ),
            Positioned(
              top: -70,
              left: -55,
              child: _softBlob(
                size: 220,
                color: const Color(0xFFFFDDE4).withOpacity(0.42),
              ),
            ),
            Positioned(
              right: -56,
              top: 120,
              child: _softBlob(
                size: 190,
                color: const Color(0xFFCDEAB6).withOpacity(0.30),
              ),
            ),
            Positioned(
              left: -78,
              bottom: 120,
              child: _softBlob(
                size: 210,
                color: const Color(0xFFFFE7EC).withOpacity(0.24),
              ),
            ),
            Positioned(
              right: -74,
              bottom: 10,
              child: _softBlob(
                size: 215,
                color: const Color(0xFFD5EDC3).withOpacity(0.22),
              ),
            ),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 26,
                      vertical: 18,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight - 36,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () => Navigator.pop(context),
                                child: const Padding(
                                  padding: EdgeInsets.all(4),
                                  child: Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    size: 18,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Text('Moodly', style: brandTitleStyle),
                              const Spacer(),
                              const SizedBox(width: 26),
                            ],
                          ),
                          const SizedBox(height: 26),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.fromLTRB(22, 30, 22, 28),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.75),
                                width: 1.1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Container(
                                  width: 112,
                                  height: 112,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFFFFE7EC),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 16,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Image.asset(
                                      'assets/icons/login/image3.png',
                                      width: 72,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 22),
                                Text(
                                  'Verifikasi Akun Anda',
                                  textAlign: TextAlign.center,
                                  style: titleStyle,
                                ),
                                const SizedBox(height: 14),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 12),
                                  child: RichText(
                                    textAlign: TextAlign.center,
                                    text: TextSpan(
                                      style: descStyle,
                                      children: [
                                        const TextSpan(
                                          text:
                                              'Kami telah mengirim kode 4 digit ke\n',
                                        ),
                                        TextSpan(
                                          text: widget.email,
                                          style: emailStyle,
                                        ),
                                        const TextSpan(
                                          text:
                                              '.\nMasukkan kode tersebut di bawah ini.',
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 28),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: List.generate(
                                    4,
                                    (index) => _otpBox(index),
                                  ),
                                ),
                                const SizedBox(height: 28),
                                MoodlyPrimaryButton(
                                  label: _isLoading
                                      ? 'Memeriksa...'
                                      : 'Verifikasi',
                                  onPressed: _isLoading ? null : _verifyOtp,
                                  width: double.infinity,
                                ),
                                const SizedBox(height: 22),
                                Text(
                                  'Tidak menerima kode?',
                                  style: infoStyle,
                                ),
                                const SizedBox(height: 8),
                                AnimatedOpacity(
                                  duration: const Duration(milliseconds: 180),
                                  opacity:
                                      (_isResending || _remainingSeconds > 0)
                                          ? 0.72
                                          : 1,
                                  child: TextButton(
                                    onPressed: (_isResending ||
                                            _remainingSeconds > 0)
                                        ? null
                                        : _resendCode,
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 18,
                                        vertical: 10,
                                      ),
                                      backgroundColor: const Color(0xFFE06982)
                                          .withOpacity(0.10),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      foregroundColor:
                                          const Color(0xFFD96A87),
                                    ),
                                    child: Text(
                                      _isResending
                                          ? 'Mengirim ulang...'
                                          : _remainingSeconds > 0
                                              ? 'Kirim ulang dalam ${_formatCountdown(_remainingSeconds)}'
                                              : 'Kirim ulang kode',
                                      style: resendStyle,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (_remainingSeconds > 0 && !_isResending)
                                  Text(
                                    'Tunggu sebentar sebelum meminta kode baru.',
                                    textAlign: TextAlign.center,
                                    style: countdownStyle,
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _softBlob({
    required double size,
    required Color color,
  }) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}