import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../premium/premium_page.dart';
import '../premium/premium_catalog.dart';
import '../../core/services/premium_service.dart';
import '../../widgets/moodly_bottom_navbar.dart';
import '../../widgets/shared/moodly_reward_frame_avatar.dart';
import '../afirmasi/widgets/cute_top_popup.dart';
import '../pages.dart';

const String _prefLanguageKey = 'moodly_settings_language_code';

void main() {
  runApp(const HomeChatAnonim());
}

class HomeChatAnonim extends StatelessWidget {
  const HomeChatAnonim({super.key});

  @override
  Widget build(BuildContext context) {
    return const AnonymousChatHomePage();
  }
}

class AnonymousChatHomePage extends StatefulWidget {
  const AnonymousChatHomePage({super.key});

  @override
  State<AnonymousChatHomePage> createState() => _AnonymousChatHomePageState();
}

class _AnonymousChatHomePageState extends State<AnonymousChatHomePage> {
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
      _userRoomSubscription;

  String? _lastKnownRoomId;
  String? _lastHandledNoticeId;
  bool _isOpeningRoom = false;
  bool _isMatchingPageOpen = false;

  String _languageCode = 'id';

  bool _hasPremiumAccess = false;
  String? _userGender;

  int selectedGenderIndex = 1;
  int selectedNavIndex = 3;

  int? pressedGenderIndex;
  bool isProfilePressed = false;
  bool isCtaPressed = false;

  String profileName = '';
  String selectedProfileImage = '';
  List<String> ownedRewardAvatarIds = [];

  static const List<String> _oranyeImutPack = [
    'assets/profile_pic/PP_12.png',
    'assets/profile_pic/PP_13.png',
    'assets/profile_pic/PP_14.png',
    'assets/profile_pic/PP_15.png',
    'assets/profile_pic/PP_21.png',
  ];

  static const List<String> _matchaKalemPack = [
    'assets/profile_pic/PP_16.png',
    'assets/profile_pic/PP_17.png',
    'assets/profile_pic/PP_18.png',
    'assets/profile_pic/PP_19.png',
    'assets/profile_pic/PP_2.png',
  ];

  final List<String> profileAvatars = const [
    'assets/profile_pic/PP.png',
    'assets/profile_pic/PP_2.png',
    'assets/profile_pic/PP_3.png',
    'assets/profile_pic/PP_4.png',
    'assets/profile_pic/PP_5.png',
    'assets/profile_pic/PP_6.png',
    'assets/profile_pic/PP_7.png',
    'assets/profile_pic/PP_8.png',
    'assets/profile_pic/PP_9.png',
    'assets/profile_pic/PP_10.png',
    'assets/profile_pic/PP_11.png',
    'assets/profile_pic/PP_12.png',
    'assets/profile_pic/PP_13.png',
    'assets/profile_pic/PP_14.png',
    'assets/profile_pic/PP_15.png',
    'assets/profile_pic/PP_16.png',
    'assets/profile_pic/PP_17.png',
    'assets/profile_pic/PP_18.png',
    'assets/profile_pic/PP_19.png',
    'assets/profile_pic/PP_20.png',
    'assets/profile_pic/PP_21.png',
    'assets/profile_pic/PP_22.png',
  ];

  static const Map<String, Map<String, String>> _copy = {
    'id': {
      'header': 'Ruang Curhat',
      'heroChip': 'Chat anonim',
      'heroTitle': 'Temukan teman cerita yang lembut',
      'heroSubtitle': 'Mulai obrolan hangat hari ini!',
      'editProfile': 'Atur Profil',
      'genderFilter': 'Filter Gender',
      'male': 'Laki-laki',
      'both': 'Keduanya',
      'female': 'Perempuan',
      'startChat': 'Mulai Bercerita',
      'helperLead': 'Tolong hormati orang lain dan patuhi ',
      'helperLink': 'peraturan kami',
      'rulesTitle': 'Peraturan Ruang Curhat',
      'rule1': 'Jaga privasi diri sendiri dan lawan bicara.',
      'rule2': 'Gunakan bahasa yang sopan, hangat, dan tidak menyerang.',
      'rule3':
          'Jangan meminta data pribadi seperti nomor, alamat, atau akun media sosial.',
      'rule4':
          'Jangan membagikan isi chat, screenshot, atau rekaman percakapan ke platform lain.',
      'rule5':
          'Kalau merasa tidak nyaman, akhiri percakapan atau gunakan fitur laporan.',
      'understand': 'Aku Mengerti',
      'chatEndedTitle': 'Percakapan berakhir',
      'chatEndedMessage': 'Teman chat telah mengakhiri percakapan atau room sudah ditutup.',
      'noticeFallback': 'Room chat telah selesai.',
      'profileFallback': 'Spaghetti Unyu',
      'genderQuestionTitle': 'Kenalan dulu yuk',
      'genderQuestionDesc': 'Sebelum mulai matching, pilih gender kamu dulu ya.',
      'continueMatching': 'Lanjut Matching',
      'selectGenderFirst': 'Pilih gender dulu yaa',
      'genderSavedTitle': 'Gender tersimpan',
      'genderSavedDesc': 'Sekarang kamu sudah bisa mulai matching.',
      'premiumGenderTitle': 'Filter gender premium',
      'premiumGenderDesc': 'Pilih preferensi gender matching khusus untuk pengguna premium.',
      'myGender': 'Gender Kamu',
      'genderNotSet': 'Belum diatur',
    },
    'en': {
      'header': 'Chat Space',
      'heroChip': 'Anonymous chat',
      'heroTitle': 'Find a gentle space to talk',
      'heroSubtitle': 'Start a warm conversation today!',
      'editProfile': 'Edit Profile',
      'genderFilter': 'Gender Filter',
      'male': 'Male',
      'both': 'Both',
      'female': 'Female',
      'startChat': 'Start Talking',
      'helperLead': 'Please be kind and follow our ',
      'helperLink': 'rules',
      'rulesTitle': 'Chat Room Rules',
      'rule1': 'Protect your privacy and your chat partner’s privacy.',
      'rule2': 'Use kind language and avoid attacking or shaming others.',
      'rule3':
          'Do not ask for personal data such as phone numbers, addresses, or social media accounts.',
      'rule4':
          'Do not share chat contents, screenshots, or recordings outside the app.',
      'rule5':
          'If something feels uncomfortable, leave the conversation or use the report feature.',
      'understand': 'Got it',
      'chatEndedTitle': 'Conversation ended',
      'chatEndedMessage': 'Your chat partner ended the conversation or the room was closed.',
      'noticeFallback': 'The chat room has ended.',
      'profileFallback': 'Spaghetti Unyu',
      'genderQuestionTitle': 'Let’s get to know you first',
      'genderQuestionDesc': 'Before matching, choose your gender first.',
      'continueMatching': 'Continue Matching',
      'selectGenderFirst': 'Please choose your gender first',
      'genderSavedTitle': 'Gender saved',
      'genderSavedDesc': 'You can start matching now.',
      'premiumGenderTitle': 'Premium gender filter',
      'premiumGenderDesc': 'Choose your matching gender preference as a premium user.',
      'myGender': 'Your Gender',
      'genderNotSet': 'Not set',
    },
  };

  @override
  void initState() {
    super.initState();
    initApp();
  }

  @override
  void dispose() {
    _userRoomSubscription?.cancel();
    super.dispose();
  }

  List<_GenderOption> get genders => [
        _GenderOption(
          label: _t('male'),
          icon: Icons.male_rounded,
          background: const Color(0xFFB8E8FF),
          surface: const Color(0xFFEAF8FF),
          border: const Color(0xFF7EC9F4),
          iconColor: const Color(0xFF57A9DA),
          showCrown: true,
        ),
        _GenderOption(
          label: _t('both'),
          icon: Icons.transgender_rounded,
          background: const Color(0xFFF8FBF4),
          surface: const Color(0xFFFFFFFF),
          border: const Color(0xFFB8D996),
          iconColor: const Color(0xFF72B35B),
        ),
        _GenderOption(
          label: _t('female'),
          icon: Icons.female_rounded,
          background: const Color(0xFFFFD5DD),
          surface: const Color(0xFFFFF1F4),
          border: const Color(0xFFF09AAC),
          iconColor: const Color(0xFFD86D88),
          showCrown: true,
        ),
      ];

  String _t(String key) => _copy[_languageCode]?[key] ?? _copy['id']![key] ?? key;

  String? _normalizeGender(dynamic value) {
    final raw = value?.toString().trim().toLowerCase();
    if (raw == null || raw.isEmpty) return null;

    if (raw == 'male' ||
        raw == 'laki-laki' ||
        raw == 'laki_laki' ||
        raw == 'cowok' ||
        raw == 'pria') {
      return 'male';
    }

    if (raw == 'female' ||
        raw == 'perempuan' ||
        raw == 'cewek' ||
        raw == 'wanita') {
      return 'female';
    }

    return null;
  }

  String _preferredGenderValueFromIndex() {
    switch (selectedGenderIndex) {
      case 0:
        return 'male';
      case 2:
        return 'female';
      default:
        return 'all';
    }
  }

  Future<void> _loadPremiumAccess() async {
    final hasPremium = await PremiumService.instance.hasActivePremium();

    if (!mounted) return;
    setState(() {
      _hasPremiumAccess = hasPremium;
      if (!_hasPremiumAccess && selectedGenderIndex != 1) {
        selectedGenderIndex = 1;
      }
    });
  }

  Future<void> _loadUserGenderFromFirestore() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final snap =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final data = snap.data() ?? {};

    if (!mounted) return;
    setState(() {
      _userGender = _normalizeGender(data['gender']);
    });
  }

  Future<String?> _showGenderQuestionDialog() async {
    String? pickedGender;

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.42),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Widget genderCard({
              required String value,
              required String label,
              required IconData icon,
              required Color fill,
              required Color border,
              required Color iconColor,
            }) {
              final isSelected = pickedGender == value;

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setModalState(() {
                      pickedGender = value;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: fill,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: isSelected ? border : border.withOpacity(0.55),
                        width: isSelected ? 2.3 : 1.4,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: border.withOpacity(0.18),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.92),
                          ),
                          child: Icon(
                            icon,
                            color: iconColor,
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          label,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontSize: 14,
                                color: const Color(0xFF243021),
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFDF9),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 22,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFFFEEF3),
                      ),
                      child: const Icon(
                        Icons.favorite_rounded,
                        color: Color(0xFFE58696),
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      _t('genderQuestionTitle'),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            fontSize: 22,
                            color: const Color(0xFF1F1F1F),
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _t('genderQuestionDesc'),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 13,
                            height: 1.45,
                            color: const Color(0xFF6B7763),
                          ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        genderCard(
                          value: 'male',
                          label: _t('male'),
                          icon: Icons.male_rounded,
                          fill: const Color(0xFFEAF8FF),
                          border: const Color(0xFF7EC9F4),
                          iconColor: const Color(0xFF57A9DA),
                        ),
                        const SizedBox(width: 10),
                        genderCard(
                          value: 'female',
                          label: _t('female'),
                          icon: Icons.female_rounded,
                          fill: const Color(0xFFFFF1F4),
                          border: const Color(0xFFF09AAC),
                          iconColor: const Color(0xFFD86D88),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: pickedGender == null
                            ? null
                            : () => Navigator.pop(context, pickedGender),
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: const Color(0xFF84C76A),
                          disabledBackgroundColor: const Color(0xFFD5E8C6),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: Text(
                          _t('continueMatching'),
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<bool> _ensureUserGenderBeforeMatching() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return false;

    final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
    final snap = await userRef.get();
    final data = snap.data() ?? {};

    final existingGender = _normalizeGender(data['gender']);
    if (existingGender != null) {
      if (mounted) {
        setState(() {
          _userGender = existingGender;
        });
      }
      return true;
    }

    final pickedGender = await _showGenderQuestionDialog();
    if (pickedGender == null) return false;

    await userRef.set({
      'gender': pickedGender,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    if (!mounted) return false;

    setState(() {
      _userGender = pickedGender;
    });

    showCuteTopPopup(
      context,
      title: _t('genderSavedTitle'),
      message: _t('genderSavedDesc'),
      type: CutePopupType.success,
    );

    return true;
  }

  Widget _buildPageHeader() {
    const textDark = Color(0xFF1F1F1F);

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.88),
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.10),
                    offset: Offset(0, 6),
                    blurRadius: 18,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: textDark,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _t('header'),
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: textDark,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  List<String> get unlockedProfileAvatars {
    final lockedRewardAssets = <String>{
      ..._oranyeImutPack,
      ..._matchaKalemPack,
    };

    final baseUnlocked =
        profileAvatars.where((avatar) => !lockedRewardAssets.contains(avatar)).toList();

    final result = [...baseUnlocked];

    if (ownedRewardAvatarIds.contains('avatar_oren_imut')) {
      result.addAll(_oranyeImutPack);
    }

    if (ownedRewardAvatarIds.contains('avatar_matcha_calm')) {
      result.addAll(_matchaKalemPack);
    }

    return result.toSet().toList();
  }

  Future<void> initApp() async {
    await _loadLanguagePreference();

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginPage(),
        ),
      );
      return;
    }

    await _loadRewardInventory();
    await loadProfileFromFirestoreOrLocal();
    await _loadPremiumAccess();
    await _loadUserGenderFromFirestore();

    if (!mounted) return;

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    final userData = userDoc.data();
    final initialRoomId = userData?['currentRoomId'];
    final initialNotice = userData?['chatNotice'];
    final resolvedRoomId = initialRoomId is String && initialRoomId.isNotEmpty
        ? initialRoomId
        : null;

    _lastKnownRoomId = resolvedRoomId;

    if (initialNotice is Map<String, dynamic>) {
      await _consumeChatNotice(user.uid, initialNotice);
    } else if (initialNotice is Map) {
      await _consumeChatNotice(user.uid, Map<String, dynamic>.from(initialNotice));
    }

    _startUserRoomWatcher(user.uid);

    if (resolvedRoomId != null) {
      if (!_isMatchingPageOpen) {
        await _openRoomIfNeeded(resolvedRoomId);
      }
      return;
    }

    await syncUserProfileToFirestore();
  }

  Future<void> _loadLanguagePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString(_prefLanguageKey);

    if (!mounted) return;
    setState(() {
      _languageCode = savedLanguage == 'en' ? 'en' : 'id';
    });
  }

  Future<void> _consumeChatNotice(String uid, Map<String, dynamic> notice) async {
    final noticeId = notice['id']?.toString();
    if (noticeId == null || noticeId.isEmpty) return;
    if (_lastHandledNoticeId == noticeId) return;

    _lastHandledNoticeId = noticeId;
    if (!mounted) return;

    showCuteTopPopup(
      context,
      title: (notice['title']?.toString().isNotEmpty ?? false)
          ? notice['title'].toString()
          : _t('chatEndedTitle'),
      message: (notice['message']?.toString().isNotEmpty ?? false)
          ? notice['message'].toString()
          : _t('noticeFallback'),
      type: _mapNoticeType(notice['type']?.toString()),
    );

    await FirebaseFirestore.instance.collection('users').doc(uid).set(
      {
        'chatNotice': null,
      },
      SetOptions(merge: true),
    );
  }

  CutePopupType _mapNoticeType(String? rawType) {
    switch (rawType) {
      case 'success':
        return CutePopupType.success;
      case 'error':
        return CutePopupType.error;
      case 'warning':
        return CutePopupType.warning;
      default:
        return CutePopupType.info;
    }
  }

  Future<void> _openRoomIfNeeded(String roomId) async {
    if (_isOpeningRoom || !mounted) return;

    _isOpeningRoom = true;

    try {
      final roomDoc =
          await FirebaseFirestore.instance.collection('chat_rooms').doc(roomId).get();

      if (!mounted) return;

      if (!roomDoc.exists) {
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid != null) {
          await FirebaseFirestore.instance.collection('users').doc(uid).set(
            {
              'currentRoomId': null,
              'status': 'idle',
              'updatedAt': FieldValue.serverTimestamp(),
            },
            SetOptions(merge: true),
          );
        }
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ChatAnonimPage(roomId: roomId),
        ),
      );
    } finally {
      _isOpeningRoom = false;
    }
  }

  void _startUserRoomWatcher(String uid) {
    _userRoomSubscription?.cancel();

    _userRoomSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .listen((doc) async {
      final data = doc.data();
      final currentRoomId = data?['currentRoomId'];
      final notice = data?['chatNotice'];

      if (notice is Map<String, dynamic>) {
        await _consumeChatNotice(uid, notice);
      } else if (notice is Map) {
        await _consumeChatNotice(uid, Map<String, dynamic>.from(notice));
      }

      final hasRoomNow = currentRoomId is String && currentRoomId.trim().isNotEmpty;
      final hadRoomBefore = _lastKnownRoomId != null && _lastKnownRoomId!.trim().isNotEmpty;

      if (hadRoomBefore && !hasRoomNow) {
        _lastKnownRoomId = null;
        return;
      }

      if (hasRoomNow) {
        final roomId = currentRoomId as String;
        _lastKnownRoomId = roomId;

        if (!_isMatchingPageOpen) {
          await _openRoomIfNeeded(roomId);
        }
      }
    });
  }

  Future<void> syncUserProfileToFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final currentSnap = await userRef.get();
    final currentData = currentSnap.data() ?? {};

    await userRef.set(
      {
        'uid': user.uid,
        'nickname': profileName.isNotEmpty
            ? profileName
            : generateRandomNickname(),
        'avatarId': selectedProfileImage,
        'gender': _userGender,
        'status': currentData['status'] ?? 'idle',
        'currentRoomId': currentData['currentRoomId'],
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  String generateRandomNickname() {
    final random = Random();

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

    final food = foods[random.nextInt(foods.length)];
    final adjective = adjectives[random.nextInt(adjectives.length)];
    return '$food $adjective';
  }

  String generateRandomUnlockedAvatar() {
    final random = Random();
    return unlockedProfileAvatars[random.nextInt(unlockedProfileAvatars.length)];
  }

  Future<void> _loadRewardInventory() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('reward_inventory')
        .doc('main')
        .get();

    final data = snap.data() ?? {};
    if (!mounted) return;

    setState(() {
      ownedRewardAvatarIds = List<String>.from(data['ownedAvatarIds'] ?? []);
    });
  }

  Future<void> loadProfileFromFirestoreOrLocal() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final prefs = await SharedPreferences.getInstance();
    final nameKey = 'profileName_${user.uid}';
    final avatarKey = 'selectedProfileImage_${user.uid}';

    final localName = prefs.getString(nameKey);
    final localAvatar = prefs.getString(avatarKey);

    if (localName != null &&
        localName.isNotEmpty &&
        localAvatar != null &&
        localAvatar.isNotEmpty) {
      if (!mounted) return;
      setState(() {
        profileName = localName;
        selectedProfileImage = localAvatar;
      });
      return;
    }

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    final data = userDoc.data();

    final firestoreName = data?['nickname'] as String?;
    final firestoreAvatar = data?['avatarId'] as String?;

    final resolvedName =
        firestoreName != null && firestoreName.isNotEmpty ? firestoreName : generateRandomNickname();

    final fallbackAvatar = generateRandomUnlockedAvatar();
    final resolvedAvatar = firestoreAvatar != null &&
            firestoreAvatar.isNotEmpty &&
            unlockedProfileAvatars.contains(firestoreAvatar)
        ? firestoreAvatar
        : fallbackAvatar;

    await prefs.setString(nameKey, resolvedName);
    await prefs.setString(avatarKey, resolvedAvatar);

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
      {
        'uid': user.uid,
        'nickname': resolvedName,
        'avatarId': resolvedAvatar,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    if (!mounted) return;
    setState(() {
      profileName = resolvedName;
      selectedProfileImage = resolvedAvatar;
    });
  }

  Future<void> saveProfileData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final prefs = await SharedPreferences.getInstance();
    final nameKey = 'profileName_${user.uid}';
    final avatarKey = 'selectedProfileImage_${user.uid}';

    await prefs.setString(nameKey, profileName);
    await prefs.setString(avatarKey, selectedProfileImage);
  }

  void _onNavbarTap(int index) {
    switch (index) {
      case 0:
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => const Homepage(),
          ),
          (route) => false,
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const MonthPage(),
          ),
        );
        break;
      case 3:
        if (selectedNavIndex != 3) {
          setState(() {
            selectedNavIndex = 3;
          });
        }
        break;
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const AfirmasiPage(),
          ),
        );
        break;
    }
  }

  void _onEmergencyTap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const EmergencySupportPage(),
      ),
    );
  }

  Future<void> _openProfileOverlay() async {
    FocusScope.of(context).unfocus();

    final result = await Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: false,
        pageBuilder: (context, animation, secondaryAnimation) => ProfileOverlayPage(
          profileName: profileName.isNotEmpty ? profileName : generateRandomNickname(),
          selectedProfileImage: selectedProfileImage.isNotEmpty
              ? selectedProfileImage
              : unlockedProfileAvatars.first,
          profileAvatars: profileAvatars,
          unlockedProfileAvatars: unlockedProfileAvatars,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 180),
        reverseTransitionDuration: const Duration(milliseconds: 180),
      ),
    );

    if (!mounted) return;

    if (result is Map<String, dynamic>) {
      setState(() {
        profileName = result['profileName'] as String? ?? profileName;
        selectedProfileImage =
            result['selectedProfileImage'] as String? ?? selectedProfileImage;
      });

      await saveProfileData();
      await syncUserProfileToFirestore();
    }
  }

  Future<void> _startMatchingFlow() async {
    await _loadPremiumAccess();

    final hasGender = await _ensureUserGenderBeforeMatching();
    if (!hasGender) return;

    final preferredGender =
        _hasPremiumAccess ? _preferredGenderValueFromIndex() : 'all';

    if (!_hasPremiumAccess && selectedGenderIndex != 1) {
      setState(() {
        selectedGenderIndex = 1;
      });
    }

    setState(() {
      _isMatchingPageOpen = true;
    });

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MatchingPage(
          preferredGender: preferredGender,
        ),
      ),
    );

    if (!mounted) return;

    setState(() {
      _isMatchingPageOpen = false;
    });
  }

  void _showRulesDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFCF8),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.10),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _t('rulesTitle'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 20,
                    color: const Color(0xFF222222),
                  ),
                ),
                const SizedBox(height: 16),
                _ruleItem(_t('rule1')),
                _ruleItem(_t('rule2')),
                _ruleItem(_t('rule3')),
                _ruleItem(_t('rule4')),
                _ruleItem(_t('rule5')),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: const Color(0xFF84C76A),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: Text(
                      _t('understand'),
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _ruleItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 6),
            decoration: const BoxDecoration(
              color: Color(0xFF84C76A),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 12,
                color: const Color(0xFF3A3A3A),
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final safeBottom = media.padding.bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0xFFF7FAEE),
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFFF7FAEE),
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarDividerColor: Color(0xFFF7FAEE),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF7FAEE),
        extendBody: true,
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            const Positioned.fill(child: _ChatHomeBackground()),
            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(20, 14, 20, 132 + safeBottom),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPageHeader(),
                    const SizedBox(height: 18),
                    _buildHeroCard(),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: _buildProfileButton(),
                    ),
                    const SizedBox(height: 18),
                    _buildFilterCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: MoodlyBottomNavbar(
          currentIndex: selectedNavIndex,
          onTap: _onNavbarTap,
          onEmergencyTap: _onEmergencyTap,
          outerBackgroundColor: const Color(0xFFF7FAEE),
        ),
      ),
    );
  }

  Widget _buildHeroCard() {
    final textTheme = Theme.of(context).textTheme;

    final avatar = selectedProfileImage.isNotEmpty
        ? selectedProfileImage
        : (unlockedProfileAvatars.isNotEmpty
            ? unlockedProfileAvatars.first
            : 'assets/profile_pic/PP.png');

    final displayName =
        profileName.isNotEmpty ? profileName : _t('profileFallback');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.90),
        borderRadius: BorderRadius.circular(34),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB7CC98).withOpacity(0.30),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFFFFFFF),
          width: 1.2,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 12,
            right: 4,
            child: Container(
              width: 88,
              height: 88,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFF7DDE4),
              ),
            ),
          ),
          Positioned(
            bottom: 8,
            left: 0,
            child: Container(
              width: 110,
              height: 110,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFE4F3D0),
              ),
            ),
          ),
          Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE8EF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.forum_rounded,
                        size: 15,
                        color: Color(0xFFD86D88),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _t('heroChip'),
                        style: textTheme.bodySmall?.copyWith(
                          fontSize: 12,
                          color: const Color(0xFFD86D88),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 138,
                    height: 138,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFFFF6F7), Color(0xFFEAF6DB)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFC7D7AA).withOpacity(0.46),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                  ),
                  MoodlyInventoryFrameAvatar(
                    uid: FirebaseAuth.instance.currentUser?.uid,
                    size: 128,
                    innerPadding: 5,
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
                          avatar,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                displayName,
                textAlign: TextAlign.center,
                style: textTheme.headlineLarge?.copyWith(
                  fontSize: 28,
                  color: const Color(0xFF181818),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Text(
                  _t('heroSubtitle'),
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    color: const Color(0xFF6F7C69),
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileButton() {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          isProfilePressed = true;
        });
      },
      onTapUp: (_) {
        setState(() {
          isProfilePressed = false;
        });
      },
      onTapCancel: () {
        setState(() {
          isProfilePressed = false;
        });
      },
      onTap: _openProfileOverlay,
      child: AnimatedScale(
        scale: isProfilePressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF84C76A),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF84C76A).withOpacity(0.26),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.edit_rounded,
                size: 16,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Text(
                _t('editProfile'),
                style: textTheme.labelLarge?.copyWith(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterCard() {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: const Color(0xFFDDECBF),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFA8C67A).withOpacity(0.24),
            blurRadius: 26,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _t('genderFilter'),
            style: textTheme.bodySmall?.copyWith(
              fontSize: 15,
              color: const Color(0xFF1D271C),
            ),
          ),
          const SizedBox(height: 14),
          _buildGenderOptions(),
          const SizedBox(height: 16),
          _buildCTAButton(),
          const SizedBox(height: 12),
          _buildHelperText(),
        ],
      ),
    );
  }

  Widget _buildGenderOptions() {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: List.generate(genders.length, (index) {
        final option = genders[index];
        final isSelected = selectedGenderIndex == index;
        final isPressed = pressedGenderIndex == index;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: index == genders.length - 1 ? 0 : 10,
            ),
            child: GestureDetector(
              onTapDown: (_) {
                setState(() {
                  pressedGenderIndex = index;
                });
              },
              onTapUp: (_) {
                setState(() {
                  pressedGenderIndex = null;
                });

                final needPremium = index == 0 || index == 2;

                if (needPremium && !_hasPremiumAccess) {
                  openMoodlyPremiumPage(
                    context,
                    source: PremiumEntrySource.chatGender,
                  );
                  return;
                }

                setState(() {
                  selectedGenderIndex = index;
                });
              },
              onTapCancel: () {
                setState(() {
                  pressedGenderIndex = null;
                });
              },
              child: AnimatedScale(
                scale: isPressed ? 0.97 : 1.0,
                duration: const Duration(milliseconds: 120),
                child: SizedBox(
                  height: 126,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? option.background : option.surface,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: isSelected
                                ? option.border
                                : option.border.withOpacity(0.62),
                            width: isSelected ? 2.2 : 1.4,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: option.border.withOpacity(0.22),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(
                                    isSelected ? 0.75 : 0.95,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  option.icon,
                                  size: 28,
                                  color: option.iconColor,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                option.label,
                                textAlign: TextAlign.center,
                                style: textTheme.bodySmall?.copyWith(
                                  fontSize: 14,
                                  color: const Color(0xFF263123),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (option.showCrown && !_hasPremiumAccess)
                        Positioned(
                          top: -6,
                          right: -2,
                          child: Image.asset(
                            'assets/icons/crown.png',
                            width: 20,
                            height: 20,
                            fit: BoxFit.contain,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCTAButton() {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          isCtaPressed = true;
        });
      },
      onTapUp: (_) {
        setState(() {
          isCtaPressed = false;
        });
      },
      onTapCancel: () {
        setState(() {
          isCtaPressed = false;
        });
      },
      onTap: _startMatchingFlow,
      child: AnimatedScale(
        scale: isCtaPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          width: double.infinity,
          height: 54,
          decoration: BoxDecoration(
            color: const Color(0xFF84C76A),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF84C76A).withOpacity(0.28),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            _t('startChat'),
            style: textTheme.labelLarge?.copyWith(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHelperText() {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: textTheme.bodySmall?.copyWith(
            height: 1.35,
            color: const Color(0xFF2C3628),
          ),
          children: [
            TextSpan(text: _t('helperLead')),
            TextSpan(
              text: _t('helperLink'),
              style: textTheme.bodySmall?.copyWith(
                color: const Color(0xFF79BE62),
              ),
              recognizer: TapGestureRecognizer()..onTap = _showRulesDialog,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatHomeBackground extends StatelessWidget {
  const _ChatHomeBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -48,
          right: -40,
          child: Container(
            width: 190,
            height: 190,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFFFE5EC),
            ),
          ),
        ),
        Positioned(
          top: 210,
          left: -84,
          child: Container(
            width: 210,
            height: 210,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFE6F2D4),
            ),
          ),
        ),
        Positioned(
          bottom: 90,
          right: -72,
          child: Container(
            width: 220,
            height: 220,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFE8F6D8),
            ),
          ),
        ),
        Positioned(
          bottom: -18,
          left: 0,
          right: 0,
          child: Container(
            height: 170,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withOpacity(0.0),
                  Colors.white.withOpacity(0.40),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _RoundIconButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.95),
      shape: const CircleBorder(),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(
            icon,
            size: 18,
            color: const Color(0xFF1F231D),
          ),
        ),
      ),
    );
  }
}

class _GenderOption {
  final String label;
  final IconData icon;
  final Color background;
  final Color surface;
  final Color border;
  final Color iconColor;
  final bool showCrown;

  const _GenderOption({
    required this.label,
    required this.icon,
    required this.background,
    required this.surface,
    required this.border,
    required this.iconColor,
    this.showCrown = false,
  });
}