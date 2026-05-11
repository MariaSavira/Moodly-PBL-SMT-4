import 'package:flutter/material.dart';
import '../../core/styles/moodly_colors.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final nameController = TextEditingController(text: 'Muhammad Yusuf');
  final emailController = TextEditingController(text: 'yusuf@gamil.com');
  final phoneController = TextEditingController(text: '+ 62 812-1283-9131');

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  double _pageWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width > 390 ? 390 : width;
  }

  @override
  Widget build(BuildContext context) {
    final pageWidth = _pageWidth(context);

    return Scaffold(
      backgroundColor: MoodlyColors.bgLight,
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: pageWidth,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _Header(
                    title: 'Ubah Profile',
                    onBack: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 48),
                  const _AvatarEdit(),
                  const SizedBox(height: 18),
                  const Text(
                    'UBAH FOTO',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: MoodlyColors.green,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 42),
                  _InputSection(
                    label: 'Nama Lengkap',
                    controller: nameController,
                    icon: Icons.person_outline_rounded,
                    textColor: Colors.black,
                    keyboardType: TextInputType.name,
                  ),
                  const SizedBox(height: 26),
                  _InputSection(
                    label: 'Alamat Email',
                    controller: emailController,
                    icon: Icons.mail_outline_rounded,
                    textColor: Colors.black,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 26),
                  _InputSection(
                    label: 'Nomor Telepon',
                    controller: phoneController,
                    icon: Icons.phone_rounded,
                    textColor: Colors.grey,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 46),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MoodlyColors.green,
                        foregroundColor: Colors.white,
                        elevation: 12,
                        shadowColor: Colors.black.withOpacity(0.20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Simpan Perubahan',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
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

class _Header extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const _Header({
    required this.title,
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
            color: MoodlyColors.green,
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            color: MoodlyColors.green,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        const Text(
          'Moodly',
          style: TextStyle(
            color: Color(0xFFC65F59),
            fontSize: 36,
            fontWeight: FontWeight.w800,
            letterSpacing: -1,
          ),
        ),
      ],
    );
  }
}

class _AvatarEdit extends StatelessWidget {
  const _AvatarEdit();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 154,
      height: 154,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 154,
            height: 154,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: MoodlyColors.green,
                width: 10,
              ),
            ),
            child: const Icon(
              Icons.person,
              size: 100,
              color: Colors.black,
            ),
          ),
          Positioned(
            right: 6,
            bottom: 0,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFFFC8C8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.camera_alt_outlined,
                color: MoodlyColors.green,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InputSection extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final Color textColor;
  final TextInputType? keyboardType;

  const _InputSection({
    required this.label,
    required this.controller,
    required this.icon,
    required this.textColor,
    this.keyboardType,
  });

  void _selectAll() {
    controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: controller.text.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: MoodlyColors.green,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 14),
        Container(
          height: 72,
          padding: const EdgeInsets.symmetric(horizontal: 26),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 24,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Row(
            children: [
              SizedBox(
                width: 34,
                child: Center(
                  child: Icon(
                    icon,
                    color: Colors.black,
                    size: 30,
                  ),
                ),
              ),
              const SizedBox(width: 22),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  maxLines: 1,
                  onTap: _selectAll,
                  textAlignVertical: TextAlignVertical.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}