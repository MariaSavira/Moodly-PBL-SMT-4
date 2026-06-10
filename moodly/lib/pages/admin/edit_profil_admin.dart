import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../afirmasi/widgets/cute_top_popup.dart';

class EditProfilAdmin extends StatefulWidget {
  const EditProfilAdmin({super.key});

  @override
  State<EditProfilAdmin> createState() => _EditProfilAdminState();
}

class _EditProfilAdminState extends State<EditProfilAdmin> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _teleponController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;

  String _initialName = '';
  String _initialPhone = '';
  String _email = '';
  String _role = 'admin';
  String _photoUrl = '';
  DateTime? _createdAt;

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

  bool get _hasChanges {
    return _namaController.text.trim() != _initialName.trim() ||
        _teleponController.text.trim() != _initialPhone.trim();
  }

  @override
  void initState() {
    super.initState();
    _loadProfileData();

    _namaController.addListener(() {
      if (mounted) setState(() {});
    });

    _teleponController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  Future<void> _loadProfileData() async {
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

      final fullName =
          (data['fullName'] ?? user.displayName ?? 'Admin Moodly').toString();
      final phone = (data['phoneNumber'] ?? '').toString();
      final email = (data['email'] ?? user.email ?? '').toString();
      final role = (data['role'] ?? 'admin').toString();
      final photoUrl =
          (data['photoUrl'] ?? user.photoURL ?? '').toString();
      final createdAt =
          parseDate(data['createdAt']) ?? user.metadata.creationTime;

      _initialName = fullName;
      _initialPhone = phone;
      _email = email;
      _role = role;
      _photoUrl = photoUrl;
      _createdAt = createdAt;

      _namaController.text = fullName;
      _teleponController.text = phone;
    } catch (_) {
      if (!mounted) return;

      showCuteTopPopup(
        context,
        title: 'Gagal memuat',
        message: 'Data admin belum berhasil dimuat.',
        type: CutePopupType.error,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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

  ImageProvider _resolveProfileImage() {
    final value = _photoUrl.trim();

    if (value.isEmpty) {
      return const AssetImage('assets/profile_pic/PP_default.jpg');
    }

    if (value.startsWith('http')) {
      return NetworkImage(value);
    }

    return AssetImage(value);
  }

  String _initialOf(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return 'A';
    return trimmed[0].toUpperCase();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_hasChanges) return;

    final user = _firebaseUser;
    if (user == null) {
      showCuteTopPopup(
        context,
        title: 'Admin belum login',
        message: 'Tidak ada sesi admin aktif.',
        type: CutePopupType.error,
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final namaBaru = _namaController.text.trim();
      final teleponBaru = _teleponController.text.trim();

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'fullName': namaBaru,
        'email': _email,
        'phoneNumber': teleponBaru.isEmpty ? null : teleponBaru,
        'role': _role.isEmpty ? 'admin' : _role,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if ((user.displayName ?? '').trim() != namaBaru) {
        await user.updateDisplayName(namaBaru);
      }

      _initialName = namaBaru;
      _initialPhone = teleponBaru;

      if (!mounted) return;

      showCuteTopPopup(
        context,
        title: 'Berhasil disimpan',
        message: 'Profil admin sudah diperbarui.',
        type: CutePopupType.success,
      );

      await Future.delayed(const Duration(milliseconds: 650));

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;

      showCuteTopPopup(
        context,
        title: 'Gagal menyimpan',
        message: 'Perubahan profil belum berhasil disimpan.',
        type: CutePopupType.error,
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _teleponController.dispose();
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
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTopBar(),
                          const SizedBox(height: 18),
                          _buildHeroCard(),
                          const SizedBox(height: 16),
                          _buildFormCard(),
                          const SizedBox(height: 18),
                          _buildSaveButton(),
                        ],
                      ),
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
            'Edit Profil',
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
                width: 108,
                height: 108,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: _softShadow,
                  border: Border.all(color: Colors.white, width: 4),
                ),
                child: ClipOval(
                  child: Image(
                    image: _resolveProfileImage(),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return Container(
                        color: _greenMint,
                        alignment: Alignment.center,
                        child: Text(
                          _initialOf(_namaController.text),
                          style: GoogleFonts.fredoka(
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                            color: _greenDark,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                _namaController.text.trim().isEmpty
                    ? 'Admin Moodly'
                    : _namaController.text.trim(),
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
                  _heroChip(
                    icon: Icons.calendar_today_rounded,
                    text: _formatTanggal(_createdAt),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Foto mengikuti akun yang sedang dipakai.',
                textAlign: TextAlign.center,
                style: GoogleFonts.openSans(
                  fontSize: 12,
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

  Widget _buildFormCard() {
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
          _buildInputField(
            controller: _namaController,
            label: 'Nama Lengkap',
            hint: 'Masukkan nama admin',
            icon: Icons.person_outline_rounded,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Nama tidak boleh kosong';
              }
              if (value.trim().length < 3) {
                return 'Nama terlalu pendek';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildReadonlyField(
            label: 'Email',
            value: _email.isEmpty ? '-' : _email,
            icon: Icons.email_outlined,
          ),
          const SizedBox(height: 16),
          _buildInputField(
            controller: _teleponController,
            label: 'Nomor Telepon',
            hint: 'Opsional',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
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
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator: validator,
            style: GoogleFonts.openSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _textDark,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.openSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF9AA097),
              ),
              prefixIcon: Icon(icon, color: _greenDark, size: 20),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReadonlyField({
    required String label,
    required String value,
    required IconData icon,
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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: _greenMint,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _greenSoft),
          ),
          child: Row(
            children: [
              Icon(icon, color: _greenDark, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  value,
                  style: GoogleFonts.openSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _textDark,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    final enabled = _hasChanges && !_isSaving;

    return GestureDetector(
      onTap: enabled ? _saveProfile : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: enabled ? _green : const Color(0xFFD9DED2),
          borderRadius: BorderRadius.circular(18),
          boxShadow: enabled ? _softShadow : null,
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
                  enabled ? 'Simpan Perubahan' : 'Belum Ada Perubahan',
                  style: GoogleFonts.openSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: enabled ? Colors.white : const Color(0xFF7A8375),
                  ),
                ),
        ),
      ),
    );
  }
}