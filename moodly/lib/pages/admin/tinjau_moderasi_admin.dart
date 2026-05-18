import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'moderasi_admin.dart';

class TinjauModerasiAdmin extends StatefulWidget {
  final ModerasiModel moderasi;

  const TinjauModerasiAdmin({super.key, required this.moderasi});

  @override
  State<TinjauModerasiAdmin> createState() => _TinjauModerasiAdminState();
}

class _TinjauModerasiAdminState extends State<TinjauModerasiAdmin> {
  bool? _aksiDipilih;
  String? _durasiDipilih;
  bool _isLoading = false;

  final List<String> _durasiOptions = [
    '24 Jam',
    '7 Hari',
    '30 Hari',
    '∞ Permanen',
  ];

  Future<void> _kirim() async {
    if (_aksiDipilih == null) {
      _showSnack('Pilih jenis aksi terlebih dahulu');
      return;
    }
    if (_durasiDipilih == null) {
      _showSnack('Pilih durasi pelanggaran terlebih dahulu');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // ✅ Update ke collection yang benar
      await FirebaseFirestore.instance
          .collection('reportedUserInfo')
          .doc(widget.moderasi.uid)
          .update({
        'userData.hasWarning': true,
        'userData.warningMessage': _aksiDipilih!
            ? 'Akun Anda dibanned sementara selama $_durasiDipilih'
            : 'Akses Anda dibatasi selama $_durasiDipilih',
        'userData.warningUpdatedAt': FieldValue.serverTimestamp(),
        'userData.chatNotice': _aksiDipilih!
            ? 'Akun Anda dibanned sementara. Harap perhatikan aturan komunitas.'
            : 'Akses Anda dibatasi. Harap berhati-hati dalam berkomunikasi.',
      });

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      _showSnack('Gagal menyimpan: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1FBD8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(),
              const SizedBox(height: 20),
              _buildTitle(),
              const SizedBox(height: 20),
              _buildProfileCard(),
              const SizedBox(height: 20),
              if (_aksiDipilih == null) ...[
                _buildAksiSection(),
              ] else ...[
                _buildDurasiSection(),
                const SizedBox(height: 28),
                _buildActionButtons(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        Text(
          'Moodly',
          style: GoogleFonts.fredoka(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            height: 22 / 24,
            color: const Color(0xFFFFB6CC),
          ),
        ),
        const Spacer(),
        const Icon(Icons.notifications_rounded,
            size: 24, color: Color(0xFF8B8B8B)),
        const SizedBox(width: 14),
        Container(
          width: 38,
          height: 38,
          decoration: const BoxDecoration(
            color: Color(0xFFFFC4D7),
            shape: BoxShape.circle,
          ),
          child: const Center(
              child: Text('👩🏻‍💻', style: TextStyle(fontSize: 20))),
        ),
        const SizedBox(width: 7),
        Text(
          'Admin',
          style: GoogleFonts.openSans(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 22 / 14,
            color: const Color(0xFF0C0E0C),
          ),
        ),
      ],
    );
  }

  Widget _buildTitle() {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            if (_aksiDipilih != null) {
              setState(() {
                _aksiDipilih = null;
                _durasiDipilih = null;
              });
            } else {
              Navigator.pop(context);
            }
          },
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: Color(0xFF486253)),
        ),
        const SizedBox(width: 8),
        Text(
          'Moderasi :',
          style: GoogleFonts.fredoka(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            height: 22 / 24,
            color: const Color(0xFF486253),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCard() {
    final m = widget.moderasi;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: BoxDecoration(
        color: const Color(0xFFDDF5C5),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: m.avatarId.isNotEmpty
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  m.avatarId,
                  width: 74,
                  height: 74,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _defaultAvatarLarge(),
                ),
              )
                  : _defaultAvatarLarge(),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            m.nickname,
            style: GoogleFonts.openSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 22 / 14,
              color: const Color(0xFF49A828),
            ),
          ),
        ],
      ),
    );
  }

  Widget _defaultAvatarLarge() {
    return const Text('☁',
        style: TextStyle(
            fontSize: 40,
            color: Color(0xFF2B2B2B),
            fontWeight: FontWeight.w700));
  }

  Widget _buildAksiSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFDDF5C5),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            'Pilih tingkat dan durasi yang sesuai untuk pelanggaran kebijakan',
            textAlign: TextAlign.center,
            style: GoogleFonts.openSans(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              height: 1.5,
              color: const Color(0xFF486253),
            ),
          ),
        ),
        const SizedBox(height: 24),
        _buildAksiButton(
          label: 'Ban User Sementara',
          icon: Icons.block_rounded,
          isBan: true,
        ),
        const SizedBox(height: 14),
        _buildAksiButton(
          label: 'Batasi Akses',
          icon: Icons.timer_rounded,
          isBan: false,
        ),
      ],
    );
  }

  Widget _buildAksiButton({
    required String label,
    required IconData icon,
    required bool isBan,
  }) {
    return GestureDetector(
      onTap: () => setState(() => _aksiDipilih = isBan),
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: const Color(0xFFFFB3C0),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              label,
              style: GoogleFonts.openSans(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                height: 1,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurasiSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
          decoration: BoxDecoration(
            color: const Color(0xFFDDF5C5),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Durasi Pelanggaran',
                style: GoogleFonts.fredoka(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF486253),
                ),
              ),
              const SizedBox(height: 14),
              _buildDurasiGrid(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDurasiGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 3.2,
      children: _durasiOptions.map((d) => _buildDurasiChip(d)).toList(),
    );
  }

  Widget _buildDurasiChip(String label) {
    final isSelected = _durasiDipilih == label;
    return GestureDetector(
      onTap: () => setState(() => _durasiDipilih = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFB3C0) : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFFF8EA4)
                : const Color(0xFFD9D9D9),
            width: 1.2,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.openSans(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? Colors.white : const Color(0xFF0C0E0C),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        _isLoading
            ? const Center(
            child: CircularProgressIndicator(color: Color(0xFFFF8EA4)))
            : _buildPrimaryButton(
          label: 'Kirim',
          onTap: _kirim,
        ),
        const SizedBox(height: 12),
        _buildSecondaryButton(
          label: 'Batal',
          onTap: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFFFB3C0),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          label,
          style: GoogleFonts.openSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: const Color(0xFFFFB3C0), width: 1.5),
        ),
        child: Text(
          label,
          style: GoogleFonts.openSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFFF8EA4),
          ),
        ),
      ),
    );
  }
}