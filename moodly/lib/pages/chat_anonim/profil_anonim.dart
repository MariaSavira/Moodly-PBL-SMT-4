import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../afirmasi/widgets/cute_top_popup.dart';
import '../../widgets/shared/moodly_reward_frame_avatar.dart';

const String _prefLanguageKey = 'moodly_settings_language_code';

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
  String _languageCode = 'id';

  late String profileName;
  late String selectedProfileImage;
  late TextEditingController profileNameController;

  final Random _random = Random();

  static const Map<String, Map<String, String>> _copy = {
    'id': {
      'header': 'Atur Profil',
      'nameHint': 'Nama anonim',
      'tapAvatar': 'Ketuk avatar untuk mengganti',
      'note': 'Jangan gunakan nama asli',
      'limit': 'Maksimal 20 huruf',
      'confirm': 'Konfirmasi',
      'avatars': 'Pilih Avatar',
      'avatarHint': 'Yang belum terbuka akan terkunci dulu ya.',
      'lockedAvatarTitle': 'Avatar terkunci',
      'lockedAvatarMessage': 'Buka avatar ini melalui hadiah streak.',
    },
    'en': {
      'header': 'Edit Profile',
      'nameHint': 'Anonymous name',
      'tapAvatar': 'Tap the avatar to change it',
      'note': 'Do not use your real name',
      'limit': 'Max 20 characters',
      'confirm': 'Confirm',
      'avatars': 'Choose Avatar',
      'avatarHint': 'Locked avatars will stay unavailable for now.',
      'lockedAvatarTitle': 'Avatar locked',
      'lockedAvatarMessage': 'Unlock this avatar through streak rewards.',
    },
  };

  @override
  void initState() {
    super.initState();
    profileName = widget.profileName;
    selectedProfileImage = widget.selectedProfileImage;
    profileNameController = TextEditingController(text: widget.profileName);
    _loadLanguagePreference();
  }

  @override
  void dispose() {
    profileNameController.dispose();
    super.dispose();
  }

  String _t(String key) => _copy[_languageCode]?[key] ?? _copy['id']![key] ?? key;

  void _showLockedAvatarPopup() {
    showCuteTopPopup(
      context,
      title: _t('lockedAvatarTitle'),
      message: _t('lockedAvatarMessage'),
      type: CutePopupType.info,
    );
  }

  Future<void> _loadLanguagePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString(_prefLanguageKey);

    if (!mounted) return;
    setState(() {
      _languageCode = savedLanguage == 'en' ? 'en' : 'id';
    });
  }

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
      profileName = newName;
      profileNameController.text = newName;
      showAvatarPicker = false;
    });
  }

  void _confirm() {
    FocusScope.of(context).unfocus();

    final trimmed = profileNameController.text.trim();
    final resolvedName = trimmed.isEmpty ? _generateRandomNickname() : trimmed;

    Navigator.of(context).pop({
      'profileName': resolvedName,
      'selectedProfileImage': selectedProfileImage,
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets;
    final keyboardOpen = viewInsets.bottom > 0;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Color(0xFFF7FAEE),
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                  if (showAvatarPicker) {
                    setState(() {
                      showAvatarPicker = false;
                    });
                  }
                },
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
                  child: Container(
                    color: const Color(0xA6202B1A),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Stack(
                children: [
                  Positioned(
                    top: 12,
                    left: 20,
                    right: 20,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Text(
                          _t('header'),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        Positioned(
                          right: 0,
                          child: _TopCircleButton(
                            icon: Icons.close_rounded,
                            onTap: () => Navigator.of(context).pop(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedPadding(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    padding: EdgeInsets.fromLTRB(
                      18,
                      86,
                      18,
                      keyboardOpen
                          ? viewInsets.bottom + 18
                          : (showAvatarPicker ? 320 : 24),
                    ),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 380),
                          child: _buildMainCard(context),
                        ),
                      ),
                    ),
                  ),
                  if (showAvatarPicker && !keyboardOpen) _buildAvatarSheet(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAEE),
        borderRadius: BorderRadius.circular(34),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                width: 140,
                height: 140,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFFEDF0), Color(0xFFE6F4D9)],
                  ),
                ),
              ),
              MoodlyInventoryFrameAvatar(
                uid: FirebaseAuth.instance.currentUser?.uid,
                size: 116,
                explicitFrameId: null,
                innerPadding: 4,
                child: Container(
                  width: 116,
                  height: 116,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x22000000),
                        blurRadius: 16,
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
              ),
              Positioned(
                right: 8,
                bottom: 4,
                child: GestureDetector(
                  onTap: () {
                    FocusScope.of(context).unfocus();
                    setState(() {
                      showAvatarPicker = !showAvatarPicker;
                    });
                  },
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE8EF),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x22000000),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.edit_rounded,
                      color: Color(0xFFD86D88),
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            _t('tapAvatar'),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF7A866E),
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x18000000),
                  blurRadius: 16,
                  offset: Offset(0, 6),
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
                    inputFormatters: [LengthLimitingTextInputFormatter(20)],
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF202020),
                    ),
                    decoration: InputDecoration(
                      hintText: _t('nameHint'),
                      hintStyle: const TextStyle(
                        color: Color(0xFFB0B9A6),
                        fontWeight: FontWeight.w700,
                      ),
                      border: InputBorder.none,
                      counterText: '',
                    ),
                    onTap: () {
                      if (showAvatarPicker) {
                        setState(() {
                          showAvatarPicker = false;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _randomizeProfile,
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: const BoxDecoration(
                      color: Color(0xFF84C76A),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.casino_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${_t('note')}\n${_t('limit')}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF7A866E),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _confirm,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: const Color(0xFF84C76A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              child: Text(
                _t('confirm'),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarSheet() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        height: 300,
        decoration: const BoxDecoration(
          color: Color(0xFFDDECBF),
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: Color(0x26000000),
              blurRadius: 24,
              offset: Offset(0, -6),
            ),
          ],
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFADC28D),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _t('avatars'),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF1E271B),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _t('avatarHint'),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF6F7C69),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                itemCount: widget.profileAvatars.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                ),
                itemBuilder: (context, index) {
                  final avatar = widget.profileAvatars[index];
                  final isSelected = avatar == selectedProfileImage;
                  final isUnlocked = widget.unlockedProfileAvatars.contains(avatar);

                  return GestureDetector(
                    onTap: () {
                      if (isUnlocked) {
                        setState(() {
                          selectedProfileImage = avatar;
                        });
                        return;
                      }

                      _showLockedAvatarPopup();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF84C76A)
                              : Colors.white.withOpacity(0.60),
                          width: isSelected ? 4 : 2,
                        ),
                        boxShadow: isSelected
                            ? const [
                                BoxShadow(
                                  color: Color(0x3384C76A),
                                  blurRadius: 16,
                                  offset: Offset(0, 6),
                                ),
                              ]
                            : null,
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipOval(
                            child: Opacity(
                              opacity: isUnlocked ? 1 : 0.35,
                              child: Image.asset(
                                avatar,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          if (!isUnlocked)
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black.withOpacity(0.22),
                              ),
                            ),
                          if (!isUnlocked)
                            Center(
                              child: Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.92),
                                  shape: BoxShape.circle,
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x22000000),
                                      blurRadius: 8,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.lock_rounded,
                                  size: 18,
                                  color: Color(0xFF6F7C69),
                                ),
                              ),
                            ),
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
}

class _TopCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _TopCircleButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF84C76A),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(
            icon,
            color: const Color(0xFF507242),
            size: 22,
          ),
        ),
      ),
    );
  }
}