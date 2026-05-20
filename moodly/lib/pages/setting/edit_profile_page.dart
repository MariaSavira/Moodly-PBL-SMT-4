import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/services/cloudinary_service.dart';
import '../afirmasi/widgets/cute_top_popup.dart';

const Color _editBg = Color(0xFFF4F8EA);
const Color _editCard = Colors.white;
const Color _editGreen = Color(0xFF7BC25D);
const Color _editGreenDark = Color(0xFF5E9E49);
const Color _editPinkSoft = Color(0xFFFFEEF2);
const Color _editTextDark = Color(0xFF1F1F1F);
const Color _editTextSoft = Color(0xFF6F746E);
const Color _editBrand = Color(0xFFC65F59);

List<BoxShadow> get _editShadow => const [
      BoxShadow(
        color: Color.fromRGBO(0, 0, 0, 0.08),
        offset: Offset(0, 8),
        blurRadius: 20,
      ),
    ];

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
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final data = doc.data();

      nameController.text =
          data?['fullName'] ??
          user.displayName ??
          user.email?.split('@').first ??
          '';

      emailController.text = data?['email'] ?? user.email ?? '';
      phoneController.text = data?['phoneNumber'] ?? '';

      _photoUrl = data?['photoUrl'] ?? user.photoURL;
      _avatarAsset = data?['avatarId'];
    } catch (_) {
      showCuteTopPopup(
        context,
        title: 'Gagal',
        message: 'Gagal memuat profil',
        type: CutePopupType.error,
      );
    }

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _pickImage() async {
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
  }

  Future<void> _saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (nameController.text.trim().isEmpty) {
      showCuteTopPopup(
        context,
        title: 'Perhatian',
        message: 'Nama lengkap tidak boleh kosong',
        type: CutePopupType.error,
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      String? uploadedPhotoUrl = _photoUrl;

      if (!kIsWeb && _pickedImageFile != null) {
        final result = await CloudinaryService.uploadImage(_pickedImageFile!);
        uploadedPhotoUrl = result['imageUrl'];
      }

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'fullName': nameController.text.trim(),
        'email': emailController.text.trim(),
        'phoneNumber': phoneController.text.trim(),
        'photoUrl': uploadedPhotoUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await user.updateDisplayName(nameController.text.trim());

      if (uploadedPhotoUrl != null && uploadedPhotoUrl.isNotEmpty) {
        await user.updatePhotoURL(uploadedPhotoUrl);
      }

      showCuteTopPopup(
        context,
        title: 'Berhasil',
        message: 'Profil berhasil diperbarui',
        type: CutePopupType.success,
      );

      await Future.delayed(const Duration(milliseconds: 600));

      if (mounted) Navigator.pop(context);
    } catch (_) {
      showCuteTopPopup(
        context,
        title: 'Gagal',
        message: 'Gagal menyimpan profil',
        type: CutePopupType.error,
      );
    }

    if (mounted) setState(() => _isSaving = false);
  }

  ImageProvider? _buildPreviewImage() {
    if (_pickedImageBytes != null) return MemoryImage(_pickedImageBytes!);
    if (_pickedImageFile != null) return FileImage(_pickedImageFile!);
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
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: pageWidth,
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: _editGreenDark,
                    ),
                  )
                : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _EditHeader(
                          onBack: () => Navigator.pop(context),
                        ),
                        const SizedBox(height: 28),
                        Center(
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Stack(
                              children: [
                                Container(
                                  width: 132,
                                  height: 132,
                                  padding: const EdgeInsets.all(5),
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFF92D373),
                                        Color(0xFFD9EDC5),
                                      ],
                                    ),
                                  ),
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                    ),
                                    child: ClipOval(
                                      child: _buildPreviewImage() != null
                                          ? Image(
                                              image: _buildPreviewImage()!,
                                              fit: BoxFit.cover,
                                            )
                                          : const Icon(
                                              Icons.person_rounded,
                                              size: 76,
                                              color: _editTextDark,
                                            ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 4,
                                  bottom: 4,
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: _editPinkSoft,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt_outlined,
                                      color: _editGreenDark,
                                      size: 22,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        _InputCard(
                          label: 'Nama Lengkap',
                          icon: Icons.person_outline_rounded,
                          controller: nameController,
                        ),
                        const SizedBox(height: 16),
                        _InputCard(
                          label: 'Alamat Email',
                          icon: Icons.mail_outline_rounded,
                          controller: emailController,
                          readOnly: true,
                        ),
                        const SizedBox(height: 16),
                        _InputCard(
                          label: 'Nomor Telepon',
                          icon: Icons.phone_rounded,
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 34),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : _saveProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _editGreen,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                            child: _isSaving
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.4,
                                    ),
                                  )
                                : const Text(
                                    'Simpan Perubahan',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _EditHeader extends StatelessWidget {
  final VoidCallback onBack;

  const _EditHeader({
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: onBack,
          child: const Icon(
            Icons.arrow_back,
            color: _editGreenDark,
            size: 22,
          ),
        ),
        const SizedBox(width: 6),
        const Text(
          'Ubah Profil',
          style: TextStyle(
            color: _editGreenDark,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        const Text(
          'Moodly',
          style: TextStyle(
            color: _editBrand,
            fontSize: 32,
            fontWeight: FontWeight.w800,
            letterSpacing: -1,
          ),
        ),
      ],
    );
  }
}

class _InputCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final TextEditingController controller;
  final bool readOnly;
  final TextInputType keyboardType;

  const _InputCard({
    required this.label,
    required this.icon,
    required this.controller,
    this.readOnly = false,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: BoxDecoration(
        color: _editCard,
        borderRadius: BorderRadius.circular(24),
        boxShadow: _editShadow,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: _editGreenDark,
            size: 24,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: TextField(
              controller: controller,
              readOnly: readOnly,
              keyboardType: keyboardType,
              style: const TextStyle(
                fontSize: 16,
                color: _editTextDark,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: label,
                hintStyle: const TextStyle(
                  color: _editTextSoft,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}