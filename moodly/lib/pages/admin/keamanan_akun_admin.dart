import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../afirmasi/widgets/cute_top_popup.dart';

class KeamananAkunAdmin extends StatefulWidget {
  const KeamananAkunAdmin({super.key});

  @override
  State<KeamananAkunAdmin> createState() => _KeamananAkunAdminState();
}

class _KeamananAkunAdminState extends State<KeamananAkunAdmin> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  String _email = '';
  String _role = 'admin';
  DateTime? _createdAt;

  static const Color _bg = Color(0xFFF6F9EE);
  static const Color _card = Color(0xFFFFFEFB);
  static const Color _green = Color(0xFF84C96C);
  static const Color _greenDark = Color(0xFF4E7D45);
  static const Color _greenSoft = Color(0xFFDDEFCF);
  static const Color _greenMint = Color(0xFFEEF7E6);
  static const Color _pinkSoft = Color(0xFFFFF1F4);
  static const Color _peachSoft = Color(0xFFFFEFD9);
  static const Color _textDark = Color(0xFF243127);
  static const Color _textSoft = Color(0xFF6E776B);

  List<BoxShadow> get _softShadow => const [
        BoxShadow(
          color: Color.fromRGBO(0, 0, 0, 0.08),
          offset: Offset(0, 8),
          blurRadius: 24,
        ),
      ];

  User? get _firebaseUser => FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadAdminInfo();
  }

  Future<void> _loadAdminInfo() async {
    setState(() => _isLoading = true);

    try {
      final user = _firebaseUser;
      if (user == null) {
        throw Exception('Admin belum login');
      }

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final data = doc.data() ?? <String, dynamic>{};

      DateTime? parseDate(dynamic value) {
        if (value is Timestamp) return value.toDate();
        if (value is String) return DateTime.tryParse(value);
        return null;
      }

      _email = (data['email'] ?? user.email ?? '').toString();
      _role = (data['role'] ?? 'admin').toString();
      _createdAt = parseDate(data['createdAt']) ?? user.metadata.creationTime;
    } catch (_) {
      if (!mounted) return;

      showCuteTopPopup(
        context,
        title: 'Gagal memuat',
        message: 'Data keamanan admin belum berhasil dimuat.',
        type: CutePopupType.error,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _buildAdminId() {
    final uid = _firebaseUser?.uid ?? '';
    if (uid.isEmpty) return 'ADM-0001';
    final short =
        uid.length >= 6 ? uid.substring(0, 6).toUpperCase() : uid.toUpperCase();
    return 'ADM-$short';
  }

  String _safeRole() {
    final role = _role.trim().toLowerCase();
    if (role.isEmpty || role == 'admin') return 'Administrator';
    return role[0].toUpperCase() + role.substring(1);
  }

  String _formatTanggal(DateTime? date) {
    if (date == null) return '-';

    const bulan = [
      '',
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    return '${date.day} ${bulan[date.month]} ${date.year}';
  }

  Future<void> _changePassword() async {
    final currentPassword = _currentPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (currentPassword.isEmpty ||
        newPassword.isEmpty ||
        confirmPassword.isEmpty) {
      showCuteTopPopup(
        context,
        title: 'Form belum lengkap',
        message: 'Isi semua kolom password dulu.',
        type: CutePopupType.warning,
      );
      return;
    }

    if (newPassword != confirmPassword) {
      showCuteTopPopup(
        context,
        title: 'Password tidak cocok',
        message: 'Konfirmasi password baru belum sama.',
        type: CutePopupType.error,
      );
      return;
    }

    if (newPassword.length < 6) {
      showCuteTopPopup(
        context,
        title: 'Password terlalu pendek',
        message: 'Minimal 6 karakter.',
        type: CutePopupType.warning,
      );
      return;
    }

    if (newPassword == currentPassword) {
      showCuteTopPopup(
        context,
        title: 'Password sama',
        message: 'Password baru harus berbeda dari password lama.',
        type: CutePopupType.warning,
      );
      return;
    }

    final user = _firebaseUser;
    if (user == null || user.email == null) {
      showCuteTopPopup(
        context,
        title: 'Admin tidak ditemukan',
        message: 'Sesi login admin tidak tersedia.',
        type: CutePopupType.error,
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);

      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();

      if (!mounted) return;

      showCuteTopPopup(
        context,
        title: 'Password diperbarui',
        message: 'Perubahan password berhasil disimpan.',
        type: CutePopupType.success,
      );
    } on FirebaseAuthException catch (e) {
      String message = 'Gagal mengubah password';

      if (e.code == 'wrong-password' ||
          e.code == 'invalid-credential' ||
          e.code == 'invalid-login-credentials') {
        message = 'Password saat ini salah.';
      } else if (e.code == 'weak-password') {
        message = 'Password baru terlalu lemah.';
      } else if (e.code == 'requires-recent-login') {
        message = 'Silakan login ulang untuk keamanan.';
      }

      if (!mounted) return;

      showCuteTopPopup(
        context,
        title: 'Gagal',
        message: message,
        type: CutePopupType.error,
      );
    } catch (_) {
      if (!mounted) return;

      showCuteTopPopup(
        context,
        title: 'Terjadi error',
        message: 'Password belum berhasil diubah.',
        type: CutePopupType.error,
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showDeviceInfo() {
    showCuteTopPopup(
      context,
      title: 'Info sesi',
      message: 'Manajemen perangkat belum diaktifkan di versi ini.',
      type: CutePopupType.info,
    );
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          Positioned(
            top: -70,
            left: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _pinkSoft.withOpacity(0.65),
              ),
            ),
          ),
          Positioned(
            top: 170,
            right: -70,
            child: Container(
              width: 210,
              height: 210,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _greenSoft.withOpacity(0.50),
              ),
            ),
          ),
          Positioned(
            bottom: 90,
            left: -80,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _greenMint.withOpacity(0.90),
              ),
            ),
          ),
          SafeArea(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTopBar(),
                        const SizedBox(height: 18),
                        _buildHeroCard(),
                        const SizedBox(height: 16),
                        _buildPasswordCard(),
                        const SizedBox(height: 16),
                        _buildInfoCard(),
                        const SizedBox(height: 16),
                        _buildSessionCard(),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: _card,
              shape: BoxShape.circle,
              boxShadow: _softShadow,
            ),
            child: const Icon(
              Icons.arrow_back_rounded,
              color: _greenDark,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Keamanan Akun',
            style: GoogleFonts.fredoka(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: _greenDark,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(30),
        boxShadow: _softShadow,
      ),
      child: Stack(
        children: [
          Positioned(
            right: -16,
            top: -18,
            child: Container(
              width: 118,
              height: 118,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _pinkSoft.withOpacity(0.95),
              ),
            ),
          ),
          Positioned(
            left: -18,
            bottom: -18,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _greenMint.withOpacity(0.90),
              ),
            ),
          ),
          Column(
            children: [
              Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  color: _greenMint,
                  shape: BoxShape.circle,
                  boxShadow: _softShadow,
                ),
                child: const Icon(
                  Icons.shield_rounded,
                  size: 42,
                  color: _greenDark,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Keamanan Admin',
                textAlign: TextAlign.center,
                style: GoogleFonts.fredoka(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: _textDark,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  _heroChip(
                    icon: Icons.badge_outlined,
                    text: _buildAdminId(),
                  ),
                  _heroChip(
                    icon: Icons.verified_user_outlined,
                    text: _safeRole(),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Atur password admin tanpa bikin panel ini kelihatan seperti form tahun 2014.',
                textAlign: TextAlign.center,
                style: GoogleFonts.openSans(
                  fontSize: 12,
                  height: 1.45,
                  fontWeight: FontWeight.w600,
                  color: _textSoft,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroChip({
    required IconData icon,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: _greenMint,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: _greenDark),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.openSans(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: _textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(28),
        boxShadow: _softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ubah Password',
            style: GoogleFonts.fredoka(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: _textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Masukkan password lama lalu tentukan password baru.',
            style: GoogleFonts.openSans(
              fontSize: 12,
              height: 1.45,
              fontWeight: FontWeight.w600,
              color: _textSoft,
            ),
          ),
          const SizedBox(height: 14),
          _buildPasswordField(
            controller: _currentPasswordController,
            label: 'Password Saat Ini',
            obscureText: _obscureCurrent,
            onToggle: () {
              setState(() => _obscureCurrent = !_obscureCurrent);
            },
          ),
          const SizedBox(height: 14),
          _buildPasswordField(
            controller: _newPasswordController,
            label: 'Password Baru',
            obscureText: _obscureNew,
            onToggle: () {
              setState(() => _obscureNew = !_obscureNew);
            },
          ),
          const SizedBox(height: 14),
          _buildPasswordField(
            controller: _confirmPasswordController,
            label: 'Konfirmasi Password Baru',
            obscureText: _obscureConfirm,
            onToggle: () {
              setState(() => _obscureConfirm = !_obscureConfirm);
            },
          ),
          const SizedBox(height: 18),
          GestureDetector(
            onTap: _isSaving ? null : _changePassword,
            child: Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                color: _isSaving ? const Color(0xFFD9DED2) : _green,
                borderRadius: BorderRadius.circular(18),
                boxShadow: _isSaving ? null : _softShadow,
              ),
              child: Center(
                child: _isSaving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Simpan Password',
                        style: GoogleFonts.openSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.openSans(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: _textSoft,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE7E9E2)),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            style: GoogleFonts.openSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _textDark,
            ),
            decoration: InputDecoration(
              hintText: label,
              hintStyle: GoogleFonts.openSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF9AA097),
              ),
              prefixIcon: const Icon(
                Icons.lock_outline_rounded,
                color: _greenDark,
                size: 20,
              ),
              suffixIcon: IconButton(
                onPressed: onToggle,
                icon: Icon(
                  obscureText
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  size: 20,
                  color: const Color(0xFF8E968A),
                ),
              ),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(28),
        boxShadow: _softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informasi Akun',
            style: GoogleFonts.fredoka(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: _textDark,
            ),
          ),
          const SizedBox(height: 14),
          _infoRow(
            icon: Icons.email_outlined,
            title: 'Email',
            value: _email.isEmpty ? '-' : _email,
            iconBg: _greenMint,
            iconColor: _greenDark,
          ),
          const SizedBox(height: 14),
          _infoRow(
            icon: Icons.badge_outlined,
            title: 'ID Admin',
            value: _buildAdminId(),
            iconBg: _pinkSoft,
            iconColor: const Color(0xFFE78BA0),
          ),
          const SizedBox(height: 14),
          _infoRow(
            icon: Icons.calendar_today_rounded,
            title: 'Bergabung',
            value: _formatTanggal(_createdAt),
            iconBg: _greenMint,
            iconColor: _greenDark,
          ),
        ],
      ),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String title,
    required String value,
    required Color iconBg,
    required Color iconColor,
  }) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.openSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: _textSoft,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.openSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: _textDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSessionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(28),
        boxShadow: _softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sesi Admin',
            style: GoogleFonts.fredoka(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: _textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pengelolaan perangkat lain belum diaktifkan.',
            style: GoogleFonts.openSans(
              fontSize: 12,
              height: 1.45,
              fontWeight: FontWeight.w600,
              color: _textSoft,
            ),
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: _showDeviceInfo,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _peachSoft,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.devices_rounded,
                    color: Color(0xFFD6984E),
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Kelola perangkat',
                      style: GoogleFonts.openSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: _textDark,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFFB8BEB4),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}