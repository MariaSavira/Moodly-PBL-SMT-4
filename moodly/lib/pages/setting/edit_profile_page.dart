import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/services/cloudinary_service.dart';
import '../afirmasi/widgets/cute_top_popup.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

const Color _editBg = Color(0xFFF4F8EA);
const Color _editCard = Colors.white;
const Color _editGreen = Color(0xFF7BC25D);
const Color _editGreenDark = Color(0xFF5E9E49);
const Color _editGreenSoft = Color(0xFFDDEFCF);
const Color _editMintSoft = Color(0xFFE9F7E8);
const Color _editPinkSoft = Color(0xFFFFEEF2);
const Color _editPeachSoft = Color(0xFFFFE9DD);
const Color _editTextDark = Color(0xFF1F1F1F);
const Color _editTextSoft = Color(0xFF6F746E);
const Color _editBrand = Color(0xFFC65F59);

List<BoxShadow> get _editShadow => const [
      BoxShadow(
        color: Color.fromRGBO(0, 0, 0, 0.08),
        offset: Offset(0, 8),
        blurRadius: 20,
        spreadRadius: 0,
      ),
    ];

TextStyle? _eh1(BuildContext context, {Color color = _editTextDark}) {
  return Theme.of(context).textTheme.headlineLarge?.copyWith(color: color);
}

TextStyle? _eh2(BuildContext context, {Color color = _editTextDark}) {
  return Theme.of(context).textTheme.titleMedium?.copyWith(color: color);
}

TextStyle? _ebody(BuildContext context, {Color color = _editTextSoft}) {
  return Theme.of(context).textTheme.bodyMedium?.copyWith(color: color);
}

TextStyle? _ebodyAlt(BuildContext context, {Color color = _editTextDark}) {
  return Theme.of(context).textTheme.bodySmall?.copyWith(color: color);
}

TextStyle? _ebutton(BuildContext context, {Color color = Colors.white}) {
  return Theme.of(context).textTheme.labelLarge?.copyWith(color: color);
}

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  bool _isLoading = true;
  bool _isSaving = false;

  String? _photoUrl;
  String? _avatarAsset;

  File? _pickedImageFile;
  Uint8List? _pickedImageBytes;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  double _pageWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width > 430 ? 430 : width;
  }

  Future<void> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final data = doc.data();

      final fullName =
          (data?['fullName'] as String?)?.trim().isNotEmpty == true
              ? (data!['fullName'] as String).trim()
              : (user.displayName?.trim().isNotEmpty == true
                  ? user.displayName!.trim()
                  : (user.email?.split('@').first ?? ''));

      final email =
          (data?['email'] as String?)?.trim().isNotEmpty == true
              ? (data!['email'] as String).trim()
              : (user.email ?? '');

      final phone = (data?['phoneNumber'] as String?)?.trim() ?? '';

      final photo =
          (data?['photoUrl'] as String?)?.trim().isNotEmpty == true
              ? (data!['photoUrl'] as String).trim()
              : user.photoURL;

      final avatarAsset = (data?['avatarId'] as String?)?.trim();

      nameController.text = fullName;
      emailController.text = email;
      phoneController.text = phone;
      _photoUrl = photo;
      _avatarAsset = (avatarAsset != null && avatarAsset.isNotEmpty)
          ? avatarAsset
          : null;
    } catch (e, st) {
      debugPrint('LOAD PROFILE ERROR: $e');
      debugPrintStack(stackTrace: st);
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (picked == null) return;

      if (kIsWeb) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _pickedImageBytes = bytes;
          _pickedImageFile = null;
        });
      } else {
        setState(() {
          _pickedImageFile = File(picked.path);
          _pickedImageBytes = null;
        });
      }

      _showTopPopup(
        title: 'Foto dipilih',
        message: 'Jangan lupa simpan perubahan profilmu.',
        type: CutePopupType.info,
      );
    } catch (e) {
      _showTopPopup(
        title: 'Gagal memilih foto',
        message: 'Coba pilih gambar lain.',
        type: CutePopupType.error,
      );
    }
  }

  Future<String?> _uploadProfilePhoto() async {
    if (_pickedImageFile == null && _pickedImageBytes == null) {
      return _photoUrl;
    }

    if (kIsWeb) {
      throw UnsupportedError(
        'Upload foto via Cloudinary untuk web belum disambungkan.',
      );
    }

    if (_pickedImageFile == null) {
      throw Exception('File foto tidak ditemukan saat diproses.');
    }

    final result = await CloudinaryService.uploadImage(_pickedImageFile!);
    return result['imageUrl'];
  }

  String _firebaseErrorToMessage(Object error) {
    final raw = error.toString().toLowerCase();

    if (raw.contains('storage/unauthorized') ||
        raw.contains('permission-denied') ||
        raw.contains('not authorized')) {
      return 'Upload foto ditolak. Cek Firebase Storage Rules-mu.';
    }

    if (raw.contains('object-not-found')) {
      return 'File foto tidak ditemukan saat diproses.';
    }

    if (raw.contains('bucket')) {
      return 'Firebase Storage bucket belum benar atau belum aktif.';
    }

    if (raw.contains('network')) {
      return 'Koneksi bermasalah saat upload foto.';
    }

    return 'Gagal menyimpan perubahan profil.';
  }

  void _showTopPopup({
    required String title,
    required String message,
    required CutePopupType type,
  }) {
    if (!mounted) return;

    showCuteTopPopup(
      context,
      title: title,
      message: message,
      type: type,
    );
  }

  String _profileErrorMessage(Object error) {
    final raw = error.toString().toLowerCase();

    if (raw.contains('unsupported')) {
      return 'Upload foto di web belum disambungkan ke Cloudinary.';
    }

    if (raw.contains('cloudinary')) {
      return 'Upload foto ke Cloudinary gagal. Cek upload preset atau koneksi.';
    }

    if (raw.contains('file foto tidak ditemukan')) {
      return 'File foto tidak ditemukan saat diproses.';
    }

    if (raw.contains('network')) {
      return 'Koneksi bermasalah saat upload foto.';
    }

    return 'Gagal menyimpan perubahan profil.';
  }

  Future<void> _saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final newName = nameController.text.trim();
    final newPhone = phoneController.text.trim();

    if (newName.isEmpty) {
      _showTopPopup(
        title: 'Nama belum lengkap',
        message: 'Nama lengkap tidak boleh kosong.',
        type: CutePopupType.warning,
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final uploadedPhotoUrl = await _uploadProfilePhoto();

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'fullName': newName,
        'phoneNumber': newPhone,
        if (uploadedPhotoUrl != null) 'photoUrl': uploadedPhotoUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if ((user.displayName ?? '') != newName) {
        await user.updateDisplayName(newName);
      }

      if (uploadedPhotoUrl != null && (user.photoURL ?? '') != uploadedPhotoUrl) {
        await user.updatePhotoURL(uploadedPhotoUrl);
      }

      await user.reload();

      _showTopPopup(
        title: 'Berhasil disimpan',
        message: 'Profilmu sudah diperbarui.',
        type: CutePopupType.success,
      );

      await Future.delayed(const Duration(milliseconds: 450));

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      _showTopPopup(
        title: 'Gagal menyimpan',
        message: _profileErrorMessage(e),
        type: CutePopupType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Widget _background() {
    return Stack(
      children: [
        Positioned(
          top: -30,
          right: -30,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _editPinkSoft.withOpacity(0.7),
            ),
          ),
        ),
        Positioned(
          top: 230,
          left: -70,
          child: Container(
            width: 170,
            height: 170,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _editMintSoft.withOpacity(0.85),
            ),
          ),
        ),
        Positioned(
          bottom: 120,
          right: -60,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _editGreenSoft.withOpacity(0.55),
            ),
          ),
        ),
      ],
    );
  }

  ImageProvider? _buildPreviewImage() {
    if (_pickedImageBytes != null) {
      return MemoryImage(_pickedImageBytes!);
    }
    if (_pickedImageFile != null) {
      return FileImage(_pickedImageFile!);
    }
    if (_photoUrl != null && _photoUrl!.isNotEmpty) {
      return NetworkImage(_photoUrl!);
    }
    if (_avatarAsset != null && _avatarAsset!.isNotEmpty) {
      return AssetImage(_avatarAsset!);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final pageWidth = _pageWidth(context);

    return Scaffold(
      backgroundColor: _editBg,
      body: Stack(
        children: [
          _background(),
          SafeArea(
            child: Center(
              child: SizedBox(
                width: pageWidth,
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: _editGreenDark),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _EditHeader(
                              onBack: () => Navigator.pop(context),
                            ),
                            const SizedBox(height: 22),
                            Container(
                              width: double.infinity,
                              padding:
                                  const EdgeInsets.fromLTRB(18, 18, 18, 18),
                              decoration: BoxDecoration(
                                color: _editCard,
                                borderRadius: BorderRadius.circular(28),
                                boxShadow: _editShadow,
                              ),
                              child: Column(
                                children: [
                                  _EditAvatarSection(
                                    imageProvider: _buildPreviewImage(),
                                    onPickImage: _pickImage,
                                  ),
                                  const SizedBox(height: 18),
                                  _EditFieldCard(
                                    label: 'Nama Lengkap',
                                    controller: nameController,
                                    icon: Icons.person_outline_rounded,
                                    tint: _editMintSoft,
                                    keyboardType: TextInputType.name,
                                  ),
                                  const SizedBox(height: 14),
                                  _EditFieldCard(
                                    label: 'Alamat Email',
                                    controller: emailController,
                                    icon: Icons.mail_outline_rounded,
                                    tint: _editPinkSoft,
                                    readOnly: true,
                                    keyboardType: TextInputType.emailAddress,
                                    helper:
                                        'Email ditampilkan sebagai info akun. Kalau mau mengubah email, lakukan lewat pengaturan keamanan.',
                                  ),
                                  const SizedBox(height: 14),
                                  _EditFieldCard(
                                    label: 'Nomor Telepon',
                                    controller: phoneController,
                                    icon: Icons.phone_rounded,
                                    tint: _editPeachSoft,
                                    keyboardType: TextInputType.phone,
                                    helper:
                                        'Nomor telepon dipakai untuk melengkapi identitas akunmu.',
                                  ),
                                  const SizedBox(height: 20),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 54,
                                    child: ElevatedButton(
                                      onPressed: _isSaving ? null : _saveProfile,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _editGreen,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(26),
                                        ),
                                      ),
                                      child: _isSaving
                                          ? const SizedBox(
                                              width: 22,
                                              height: 22,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.6,
                                                color: Colors.white,
                                              ),
                                            )
                                          : Text(
                                              'Simpan Perubahan',
                                              style: _ebutton(context),
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditHeader extends StatelessWidget {
  final VoidCallback onBack;

  const _EditHeader({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: onBack,
          child: const Icon(
            Icons.arrow_back_rounded,
            color: _editGreenDark,
            size: 26,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'Ubah Profil',
          style: _eh2(context, color: _editGreenDark),
        ),
        const Spacer(),
        Text(
          'Moodly',
          style: _eh1(context, color: _editBrand),
        ),
      ],
    );
  }
}

class _EditAvatarSection extends StatelessWidget {
  final ImageProvider? imageProvider;
  final VoidCallback onPickImage;

  const _EditAvatarSection({
    required this.imageProvider,
    required this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 138,
          height: 138,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 138,
                height: 138,
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFF92D373), Color(0xFFD9EDC5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: ClipOval(
                    child: imageProvider != null
                        ? Image(
                            image: imageProvider!,
                            fit: BoxFit.cover,
                          )
                        : const Icon(
                            Icons.person_rounded,
                            size: 82,
                            color: _editTextDark,
                          ),
                  ),
                ),
              ),
              Positioned(
                right: 4,
                bottom: 4,
                child: GestureDetector(
                  onTap: onPickImage,
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: _editPinkSoft,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: _editShadow,
                    ),
                    child: const Icon(
                      Icons.camera_alt_outlined,
                      color: _editGreenDark,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Bikin profilmu terasa lebih kamu',
          style: _ebody(context),
        ),
      ],
    );
  }
}

class _EditFieldCard extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final Color tint;
  final bool readOnly;
  final TextInputType? keyboardType;
  final String? helper;

  const _EditFieldCard({
    required this.label,
    required this.controller,
    required this.icon,
    required this.tint,
    this.readOnly = false,
    this.keyboardType,
    this.helper,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: _editCard,
        borderRadius: BorderRadius.circular(24),
        boxShadow: _editShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: tint,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              label,
              style: _ebodyAlt(context, color: _editTextDark),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
            decoration: BoxDecoration(
              color: tint.withOpacity(0.45),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(icon, color: _editGreenDark, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: controller,
                    readOnly: readOnly,
                    keyboardType: keyboardType,
                    style: _eh2(
                      context,
                      color: readOnly ? _editTextSoft : _editTextDark,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: label,
                      hintStyle: _ebody(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (helper != null) ...[
            const SizedBox(height: 8),
            Text(
              helper!,
              style: _ebody(context),
            ),
          ],
        ],
      ),
    );
  }
}