import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProfileOverlayPage extends StatefulWidget {
  final String profileName;
  final String selectedProfileImage;
  final List<String> profileAvatars;

  const ProfileOverlayPage({
    super.key,
    required this.profileName,
    required this.selectedProfileImage,
    required this.profileAvatars,
  });

  @override
  State<ProfileOverlayPage> createState() => _ProfileOverlayPageState();
}

class _ProfileOverlayPageState extends State<ProfileOverlayPage> {
  bool showAvatarPicker = false;

  late String profileName;
  late String selectedProfileImage;
  late TextEditingController profileNameController;

  @override
  void initState() {
    super.initState();
    profileName = widget.profileName;
    selectedProfileImage = widget.selectedProfileImage;
    profileNameController = TextEditingController(text: widget.profileName);
  }

  @override
  void dispose() {
    profileNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final bool keyboardOpen = keyboardHeight > 0;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Color(0xFFF3FADC),
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: false,
        body: Material(
          color: const Color(0x80000000),
          child: SafeArea(
            child: Stack(
              children: [
                Positioned(
                  top: 16,
                  left: 20,
                  right: 20,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        'Atur Profil',
                        style: Theme.of(context)
                            .textTheme
                            .headlineLarge
                            ?.copyWith(color: Colors.white),
                      ),
                      Positioned(
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            FocusScope.of(context).unfocus();
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: const BoxDecoration(
                              color: Color(0xFF84C76A),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 18,
                              color: Color(0xFF6F8B5E),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 140),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            FocusScope.of(context).unfocus();
                            setState(() {
                              showAvatarPicker = !showAvatarPicker;
                            });
                          },
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 105,
                                height: 105,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x22000000),
                                      blurRadius: 12,
                                      offset: Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: Image.asset(
                                    selectedProfileImage,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Container(
                                width: 34,
                                height: 34,
                                decoration: const BoxDecoration(
                                  color: Color(0x55FFFFFF),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.edit_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: 210,
                          height: 42,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x22000000),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: profileNameController,
                                  textAlign: TextAlign.center,
                                  maxLength: 20,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.black87,
                                  ),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    counterText: '',
                                    isCollapsed: true,
                                  ),
                                  onTap: () {
                                    setState(() {
                                      showAvatarPicker = false;
                                    });
                                  },
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  FocusScope.of(context).unfocus();
                                  setState(() {
                                    showAvatarPicker = !showAvatarPicker;
                                  });
                                },
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF84C76A),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.casino_rounded,
                                    size: 15,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '*Jangan gunakan nama asli\n*Maksimal 20 huruf',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Positioned(
                  right: 20,
                  bottom: 350,
                  child: GestureDetector(
                    onTap: () {
                      FocusScope.of(context).unfocus();

                      final String trimmed = profileNameController.text.trim();
                      profileName = trimmed.isEmpty ? 'Spaghetti Unyu' : trimmed;

                      Navigator.of(context).pop({
                        'profileName': profileName,
                        'selectedProfileImage': selectedProfileImage,
                      });
                    },
                    child: Container(
                      width: 126,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFF84C76A),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x22000000),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Konfirmasi',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                  ),
                ),

                if (showAvatarPicker && !keyboardOpen)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      height: 320,
                      decoration: const BoxDecoration(
                        color: Color(0xFFDCE9BE),
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(28),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x22000000),
                            blurRadius: 16,
                            offset: Offset(0, -2),
                          ),
                        ],
                      ),
                      child: Scrollbar(
                        thumbVisibility: true,
                        radius: const Radius.circular(20),
                        thickness: 4,
                        child: GridView.builder(
                          padding: const EdgeInsets.fromLTRB(22, 24, 22, 36),
                          itemCount: widget.profileAvatars.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            mainAxisSpacing: 18,
                            crossAxisSpacing: 18,
                          ),
                          itemBuilder: (context, index) {
                            final String avatar = widget.profileAvatars[index];
                            final bool isSelected =
                                avatar == selectedProfileImage;

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedProfileImage = avatar;
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: isSelected
                                      ? Border.all(
                                          color: const Color(0xFF84C76A),
                                          width: 4,
                                        )
                                      : null,
                                ),
                                child: ClipOval(
                                  child: Image.asset(
                                    avatar,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}