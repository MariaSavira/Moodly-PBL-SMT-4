import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/models/user_model.dart';
import '../../core/services/auth_service.dart';
import '../../widgets/admin_bottom_navbar.dart';
import '../afirmasi/widgets/cute_top_popup.dart';
import '../onboarding_page.dart';
import 'edit_profil_admin.dart';
import 'keamanan_akun_admin.dart';

class ProfilAdminPage extends StatefulWidget {
  const ProfilAdminPage({super.key});

  @override
  State<ProfilAdminPage> createState() => _ProfilAdminPageState();
}

class _ProfilAdminPageState extends State<ProfilAdminPage> {
  static const Color _bg = Color(0xFFF6F9EE);
  static const Color _card = Color(0xFFFFFEFB);
  static const Color _green = Color(0xFF84C96C);
  static const Color _greenDark = Color(0xFF4E7D45);
  static const Color _greenSoft = Color(0xFFDDEFCF);
  static const Color _greenMint = Color(0xFFEEF7E6);
  static const Color _pinkSoft = Color(0xFFFFF1F4);
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

  Stream<UserModel?> _adminStream() {
    final currentUser = _firebaseUser;
    if (currentUser == null) {
      return Stream.value(null);
    }

    return FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return UserModel.fromMap(snapshot.data()!, currentUser.uid);
      }

      return UserModel(
        uid: currentUser.uid,
        fullName: currentUser.displayName ?? 'Admin Moodly',
        email: currentUser.email ?? '',
        photoUrl: currentUser.photoURL,
        createdAt: currentUser.metadata.creationTime,
        isEmailVerified: currentUser.emailVerified,
        role: 'admin',
      );
    });
  }

  void _handleBack() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
      return;
    }

    Navigator.pushReplacementNamed(context, '/admin-dashboard');
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

  String _buildAdminId(UserModel? admin) {
    final uid = admin?.uid ?? '';
    if (uid.isEmpty) return 'ADM-0001';
    final short = uid.length >= 6
        ? uid.substring(0, 6).toUpperCase()
        : uid.toUpperCase();
    return 'ADM-$short';
  }

  String _safeRole(UserModel? admin) {
    final role = (admin?.role ?? 'admin').trim().toLowerCase();
    if (role.isEmpty || role == 'admin') return 'Administrator';
    return role[0].toUpperCase() + role.substring(1);
  }

  String _safeName(UserModel? admin) {
    final name = (admin?.fullName ?? '').trim();
    if (name.isNotEmpty) return name;

    final email = (admin?.email ?? '').trim();
    if (email.isNotEmpty) return email.split('@').first;

    return 'Admin Moodly';
  }

  ImageProvider _resolveProfileImage(String? photoUrl) {
    final value = (photoUrl ?? '').trim();

    if (value.isEmpty) {
      return const AssetImage('assets/profile_pic/PP_default.jpg');
    }

    if (value.startsWith('http')) {
      return NetworkImage(value);
    }

    return AssetImage(value);
  }

  Future<void> _logoutAdmin() async {
    try {
      await AuthService.instance.signOut();

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const OnboardingPage(),
        ),
        (route) => false,
      );
    } catch (_) {
      if (!mounted) return;

      showCuteTopPopup(
        context,
        title: 'Logout gagal',
        message: 'Admin belum berhasil keluar dari akun.',
        type: CutePopupType.error,
      );
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (_) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 28),
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(28),
              boxShadow: _softShadow,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    color: _pinkSoft,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: Color(0xFFD95067),
                    size: 30,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Keluar dari akun admin?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.fredoka(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: _textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Kamu akan kembali ke onboarding.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.openSans(
                    fontSize: 13,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                    color: _textSoft,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _dialogButton(
                        label: 'Batal',
                        bg: _greenMint,
                        textColor: _greenDark,
                        onTap: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _dialogButton(
                        label: 'Keluar',
                        bg: _pinkSoft,
                        textColor: const Color(0xFFD95067),
                        onTap: () async {
                          Navigator.pop(context);
                          await _logoutAdmin();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _dialogButton({
    required String label,
    required Color bg,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: textColor.withOpacity(0.18),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.openSans(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openEditProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EditProfilAdmin()),
    );

    if (result == true && mounted) {
      showCuteTopPopup(
        context,
        title: 'Profil diperbarui',
        message: 'Data admin berhasil disimpan.',
        type: CutePopupType.success,
      );
    }
  }

  Future<void> _openSecurity() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const KeamananAkunAdmin()),
    );
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
            child: StreamBuilder<UserModel?>(
              stream: _adminStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final admin = snapshot.data;

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTopBar(),
                      const SizedBox(height: 18),
                      _buildProfileHero(admin),
                      const SizedBox(height: 16),
                      _buildInfoSection(admin),
                      const SizedBox(height: 16),
                      _buildMenuSection(),
                      const SizedBox(height: 28),
                      _buildFooter(),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: AdminBottomNavbar(
        currentIndex: 3,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/admin-dashboard');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/admin-moderasi');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/admin-banding');
          }
        },
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        GestureDetector(
          onTap: _handleBack,
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
            'Profil Admin',
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

  Widget _buildProfileHero(UserModel? admin) {
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
              Stack(
                children: [
                  Container(
                    width: 108,
                    height: 108,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: _softShadow,
                      border: Border.all(
                        color: Colors.white,
                        width: 4,
                      ),
                      image: DecorationImage(
                        image: _resolveProfileImage(admin?.photoUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 4,
                    bottom: 4,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: _green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                _safeName(admin),
                textAlign: TextAlign.center,
                style: GoogleFonts.fredoka(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: _textDark,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: _greenMint,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _safeRole(admin),
                  style: GoogleFonts.openSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: _greenDark,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Kelola akun admin Moodly.',
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

  Widget _buildInfoSection(UserModel? admin) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(28),
        boxShadow: _softShadow,
      ),
      child: Column(
        children: [
          _infoRow(
            icon: Icons.email_outlined,
            title: 'Email',
            value: admin?.email.isNotEmpty == true ? admin!.email : '-',
            iconBg: _greenMint,
            iconColor: _greenDark,
          ),
          const SizedBox(height: 14),
          _infoRow(
            icon: Icons.badge_outlined,
            title: 'ID Admin',
            value: _buildAdminId(admin),
            iconBg: _pinkSoft,
            iconColor: const Color(0xFFE78BA0),
          ),
          const SizedBox(height: 14),
          _infoRow(
            icon: Icons.calendar_today_rounded,
            title: 'Bergabung',
            value: _formatTanggal(admin?.createdAt),
            iconBg: _greenMint,
            iconColor: _greenDark,
          ),
          const SizedBox(height: 14),
          _infoRow(
            icon: Icons.verified_user_outlined,
            title: 'Email',
            value: admin?.isEmailVerified == true
                ? 'Terverifikasi'
                : 'Belum diverifikasi',
            iconBg:
                admin?.isEmailVerified == true ? _greenMint : _pinkSoft,
            iconColor: admin?.isEmailVerified == true
                ? _greenDark
                : const Color(0xFFD95067),
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

  Widget _buildMenuSection() {
    return Container(
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(28),
        boxShadow: _softShadow,
      ),
      child: Column(
        children: [
          _menuTile(
            icon: Icons.person_outline_rounded,
            title: 'Edit Profil',
            subtitle: 'Ubah data admin',
            iconBg: _greenMint,
            iconColor: _greenDark,
            onTap: _openEditProfile,
          ),
          _divider(),
          _menuTile(
            icon: Icons.shield_outlined,
            title: 'Keamanan Akun',
            subtitle: 'Atur sandi admin',
            iconBg: _greenMint,
            iconColor: _greenDark,
            onTap: _openSecurity,
          ),
          _divider(),
          _menuTile(
            icon: Icons.logout_rounded,
            title: 'Keluar',
            subtitle: 'Kembali ke onboarding',
            iconBg: _pinkSoft,
            iconColor: const Color(0xFFD95067),
            textColor: const Color(0xFFD95067),
            onTap: _showLogoutDialog,
          ),
        ],
      ),
    );
  }

  Widget _menuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconBg,
    required Color iconColor,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    final resolvedTextColor = textColor ?? _textDark;

    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: iconBg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: 22,
        ),
      ),
      title: Text(
        title,
        style: GoogleFonts.openSans(
          fontSize: 15,
          fontWeight: FontWeight.w800,
          color: resolvedTextColor,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Text(
          subtitle,
          style: GoogleFonts.openSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _textSoft,
          ),
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: Color(0xFFB8BEB4),
      ),
      onTap: onTap,
    );
  }

  Widget _divider() {
    return const Divider(
      height: 1,
      thickness: 1,
      indent: 16,
      endIndent: 16,
      color: Color(0xFFF0F1EA),
    );
  }

  Widget _buildFooter() {
    return Center(
      child: Column(
        children: [
          Text(
            'Moodly',
            style: GoogleFonts.fredoka(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: _greenDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Admin panel',
            style: GoogleFonts.openSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _textSoft,
            ),
          ),
        ],
      ),
    );
  }
}