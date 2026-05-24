import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

class ProfileOverlayPage extends StatefulWidget {
  final String profileName;
  final String selectedProfileImage;
  final List<String> profileAvatars;
  final List<String> unlockedProfileAvatars;

  const ProfileOverlayPage({
    super.key,
    required this.profileName,
    required this.selectedProfileImage,
    required this.profileAvatars,
    required this.unlockedProfileAvatars,
  });

  @override
  State<ProfileOverlayPage> createState() => _ProfileOverlayPageState();
}

class _ProfileOverlayPageState extends State<ProfileOverlayPage> {
  bool showAvatarPicker = false;

  late String profileName;
  late String selectedProfileImage;
  late TextEditingController profileNameController;

  final Random _random = Random();

  String _generateRandomNickname() {
    final foods = [
      'Spaghetti',
      'Bakso',
      'Seblak',
      'Dimsum',
      'Mochi',
      'Donat',
      'Sushi',
      'Ramen',
      'Pempek',
      'Cireng',
      'Matcha',
      'Puding',
      'Brownies',
      'Nugget',
      'Martabak',
      'Klepon',
      'Waffle',
      'Pancake',
      'Boba',
      'Kebab',
      'Risoles',
      'Cilok',
      'Tteokbokki',
      'Onigiri',
      'Lasagna',
      'Sate',
      'Siomay',
      'Batagor',
      'Croissant',
      'Macaron',
    ];

    final adjectives = [
      'Unyu',
      'Kalem',
      'Ceria',
      'Mellow',
      'Santuy',
      'Manis',
      'Lucu',
      'Lembut',
      'Gemoy',
      'Penyabar',
      'Pemalu',
      'Heboh',
      'Tenang',
      'Hangat',
      'Kocak',
      'Lugu',
      'Riang',
      'Ajaib',
      'Imut',
      'Bijak',
      'Lincah',
      'Damai',
      'Puitis',
      'Mini',
      'Berani',
      'Teduh',
      'Receh',
      'Jujur',
      'Canggung',
      'Sopan',
    ];

    final food = foods[_random.nextInt(foods.length)];
    final adjective = adjectives[_random.nextInt(adjectives.length)];

    return '$food $adjective';
  }

  String _generateRandomUnlockedAvatar() {
    final unlocked = widget.unlockedProfileAvatars;
    return unlocked[_random.nextInt(unlocked.length)];
  }

  void _randomizeProfile() {
    final newName = _generateRandomNickname();
    final newAvatar = _generateRandomUnlockedAvatar();

    setState(() {
      selectedProfileImage = newAvatar;
      profileNameController.text = newName;
      profileName = newName;
    });
  }

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

  Widget _buildConfirmButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();

        final String trimmed = profileNameController.text.trim();
        profileName = trimmed.isEmpty ? _generateRandomNickname() : trimmed;

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
    );
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
    Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          20,
          140,
          20,
          keyboardOpen
              ? keyboardHeight + 24
              : (showAvatarPicker ? 340 : 24),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
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
                        _randomizeProfile();
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
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.only(top: 18),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: _buildConfirmButton(context),
                ),
              ),
            ],
          ),
        ),
      ),
    ),

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
            child: SizedBox(
              width: 40,
              height: 40,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    FocusScope.of(context).unfocus();
                    Navigator.of(context).pop();
                  },
                  child: Center(
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
              ),
            ),
          ),
        ],
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
                final bool isSelected = avatar == selectedProfileImage;
                final bool isUnlocked =
                    widget.unlockedProfileAvatars.contains(avatar);

                return GestureDetector(
                  onTap: isUnlocked
                      ? () {
                          setState(() {
                            selectedProfileImage = avatar;
                          });
                        }
                      : null,
                  child: Stack(
                    children: [
                      Container(
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
                    ],
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