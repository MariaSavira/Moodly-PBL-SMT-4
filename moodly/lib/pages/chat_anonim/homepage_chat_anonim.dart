import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/moodly_bottom_navbar.dart';
import 'dart:math';
import 'dart:async';
import '../afirmasi/widgets/cute_top_popup.dart';
import 'package:flutter/gestures.dart';
import '../pages.dart';

// App entry point.
void main() {
  runApp(const HomeChatAnonim());
}

// Root application widget.
class HomeChatAnonim extends StatelessWidget {
  const HomeChatAnonim({super.key});

  @override
  Widget build(BuildContext context) {
    return const AnonymousChatHomePage();
  }
}

// Homepage widget.
class AnonymousChatHomePage extends StatefulWidget {
  const AnonymousChatHomePage({super.key});

  @override
  State<AnonymousChatHomePage> createState() => _AnonymousChatHomePageState();
}

class _AnonymousChatHomePageState extends State<AnonymousChatHomePage> {
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
    _userRoomSubscription;

  String? _lastKnownRoomId;
  bool _isOpeningRoom = false;
  String? _lastHandledNoticeId;
  bool _isMatchingPageOpen = false;

  @override
  void initState() {
    super.initState();
    initApp();
  }

  Future<void> initApp() async {
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

    await loadProfileFromFirestoreOrLocal();

    if (!mounted) return;

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

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

  @override
  void dispose() {
    _userRoomSubscription?.cancel();
    super.dispose();
  }

  void _showChatEndedPopup() {
    if (!mounted) return;

    showCuteTopPopup(
      context,
      title: 'Percakapan berakhir',
      message: 'Teman chat telah mengakhiri percakapan atau room sudah ditutup.',
      type: CutePopupType.warning,
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

  void _showRulesDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.45),
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFCF8),
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.10),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Peraturan Ruang Curhat',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                ),
                const SizedBox(height: 14),
                _ruleItem('Jaga privasi diri sendiri dan lawan bicara.'),
                _ruleItem('Gunakan bahasa yang sopan dan tidak menyerang.'),
                _ruleItem('Jangan meminta data pribadi seperti nomor, alamat, atau akun media sosial.'),
                _ruleItem('Jangan membagikan isi chat, screenshot, atau rekaman percakapan ke media sosial atau platform apa pun demi menjaga privasi dan kenyamanan pengguna.'),
                _ruleItem('Kalau merasa tidak nyaman, akhiri percakapan atau gunakan fitur laporan.'),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: const Color(0xFF84C76A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    child: const Text(
                      'Aku Mengerti',
                      style: TextStyle(
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
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    height: 1.5,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _consumeChatNotice(
    String uid,
    Map<String, dynamic> notice,
  ) async {
    final noticeId = notice['id']?.toString();
    if (noticeId == null || noticeId.isEmpty) return;
    if (_lastHandledNoticeId == noticeId) return;

    _lastHandledNoticeId = noticeId;

    if (!mounted) return;

    showCuteTopPopup(
      context,
      title: (notice['title']?.toString().isNotEmpty ?? false)
          ? notice['title'].toString()
          : 'Percakapan berakhir',
      message: (notice['message']?.toString().isNotEmpty ?? false)
          ? notice['message'].toString()
          : 'Room chat telah selesai.',
      type: _mapNoticeType(notice['type']?.toString()),
    );

    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'chatNotice': null,
    }, SetOptions(merge: true));
  }

  Future<void> _openRoomIfNeeded(String roomId) async {
    if (_isOpeningRoom || !mounted) return;

    _isOpeningRoom = true;

    try {
      final roomDoc = await FirebaseFirestore.instance
          .collection('chat_rooms')
          .doc(roomId)
          .get();

      if (!mounted) return;

      if (!roomDoc.exists) {
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid != null) {
          await FirebaseFirestore.instance.collection('users').doc(uid).set({
            'currentRoomId': null,
            'status': 'idle',
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
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

      final hasRoomNow =
          currentRoomId is String && currentRoomId.trim().isNotEmpty;
      final hadRoomBefore =
          _lastKnownRoomId != null && _lastKnownRoomId!.trim().isNotEmpty;

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
    if (user == null) {
      print('FIRESTORE SYNC BATAL: user null');
      return;
    }

    print('SYNCING USER: ${user.uid}');
    print('nickname: $profileName');
    print('avatarId: $selectedProfileImage');

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'nickname': profileName.isNotEmpty ? profileName : generateRandomNickname(),
      'avatarId': selectedProfileImage,
      'status': 'idle',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    print('FIRESTORE WRITE BERHASIL');
  }

  int selectedGenderIndex = 1;
  int selectedNavIndex = 3;

  int? pressedGenderIndex;
  bool isProfilePressed = false;
  bool isCtaPressed = false;

  bool showProfileOverlay = false;

  String profileName = '';
  String selectedProfileImage = '';

  // Avatar yang terbuka untuk user baru.
// NANTI kalau sistem streak/reward sudah jadi, pindahkan kontrol unlock ke Firestore/user inventory di sini.
final List<String> unlockedProfileAvatars = const [
  'assets/profile_pic/PP.png',
  'assets/profile_pic/PP_2.png',
  'assets/profile_pic/PP_3.png',
  'assets/profile_pic/PP_4.png',
  'assets/profile_pic/PP_5.png',
  'assets/profile_pic/PP_6.png',
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

  final List<_GenderOption> genders = const [
    _GenderOption(
      label: 'Laki-laki',
      icon: Icons.male_rounded,
      background: Color(0xFFA5E2F9),
      border: Color(0xFFC97B26),
      iconColor: Color(0xFFF8FAFF),
    ),
    _GenderOption(
      label: 'Keduanya',
      icon: Icons.transgender_rounded,
      background: Color(0xFFF3F5F2),
      border: Color(0xFFAED48B),
      iconColor: Color(0xFF7FC066),
    ),
    _GenderOption(
      label: 'Perempuan',
      icon: Icons.female_rounded,
      background: Color(0xFFF8BDC0),
      border: Color(0xFFC97B26),
      iconColor: Color(0xFFF8FAFF),
    ),
  ];

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

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final data = userDoc.data();

    final firestoreName = data?['nickname'] as String?;
    final firestoreAvatar = data?['avatarId'] as String?;

    final resolvedName =
        firestoreName != null && firestoreName.isNotEmpty
            ? firestoreName
            : generateRandomNickname();

    final resolvedAvatar =
      firestoreAvatar != null && firestoreAvatar.isNotEmpty
          ? firestoreAvatar
          : generateRandomUnlockedAvatar();

    await prefs.setString(nameKey, resolvedName);
    await prefs.setString(avatarKey, resolvedAvatar);

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'nickname': resolvedName,
      'avatarId': resolvedAvatar,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

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
        // Sudah di halaman Connect / Chat Anonim
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

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0xFFF3FADC),
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFFF3FADC),
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarDividerColor: Color(0xFFE0EBBB),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFDDE2C4),
        extendBody: true,
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(child: Container(color: const Color(0xFFF3FADC))),

              // TOP CONTENT
              Positioned(
                top: 16,
                left: 20,
                right: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Opacity(
                      opacity: showProfileOverlay ? 0.0 : 1.0,
                      child: IgnorePointer(
                        ignoring: showProfileOverlay,
                        child: _buildHeader(),
                      ),
                    ),
                    const SizedBox(height: 88),
                    Opacity(
                      opacity: showProfileOverlay ? 0.0 : 1.0,
                      child: IgnorePointer(
                        ignoring: showProfileOverlay,
                        child: _buildCenterContent(),
                      ),
                    ),
                    const SizedBox(height: 52),
                  ],
                ),
              ),

              Positioned(
                right: 20,
                bottom: 350,
                child: Opacity(
                  opacity: showProfileOverlay ? 0.0 : 1.0,
                  child: IgnorePointer(
                    ignoring: showProfileOverlay,
                    child: _buildProfileButton(),
                  ),
                ),
              ),

              // BOTTOM SHEET
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _buildFilterCard(),
              ),

              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: IgnorePointer(
                  child: Container(
                    height: 140,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0x00EFCACC),
                          Color(0x66EFCACC),
                          Color(0xFFEFCACC),
                        ],
                        stops: [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: MoodlyBottomNavbar(
          currentIndex: selectedNavIndex,
          onTap: _onNavbarTap,
          onEmergencyTap: _onEmergencyTap,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (_) => const Homepage(),
              ),
              (route) => false,
            );
          },
          child: const Padding(
            padding: EdgeInsets.all(4),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          'Ruang Curhat',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
      ],
    );
  }

  Widget _buildCenterContent() {
    return Center(
      child: Column(
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
                selectedProfileImage.isNotEmpty
                    ? selectedProfileImage
                    : 'assets/profile_pic/PP.png', // <- placeholder sementara kalau state belum selesai load
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(profileName, style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 6),
          Text(
            'Mulailah Mengobrol!',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileButton() {
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
      onTap: () async {
        FocusScope.of(context).unfocus();

        setState(() {
          showProfileOverlay = true;
        });

        final result = await Navigator.of(context).push(
          PageRouteBuilder(
            opaque: false,
            barrierDismissible: false,
            pageBuilder: (context, animation, secondaryAnimation) =>
                ProfileOverlayPage(
                  profileName: profileName,
                  selectedProfileImage: selectedProfileImage.isNotEmpty
                      ? selectedProfileImage
                      : unlockedProfileAvatars.first,
                  profileAvatars: profileAvatars,
                  unlockedProfileAvatars: unlockedProfileAvatars,
                ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
            transitionDuration: const Duration(milliseconds: 150),
            reverseTransitionDuration: const Duration(milliseconds: 150),
          ),
        );

        if (!mounted) return;

        setState(() {
          showProfileOverlay = false;
        });

        if (result is Map<String, dynamic>) {
          setState(() {
            profileName = result['profileName'] as String;
            selectedProfileImage = result['selectedProfileImage'] as String;
          });

          await saveProfileData();
          await syncUserProfileToFirestore();
        }
      },
      child: AnimatedScale(
        scale: isProfilePressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: SizedBox(
          width: 126,
          height: 36,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF82C46B),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              'Atur Profil',
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterCard() {
    return Container(
      height: 340,
      decoration: const BoxDecoration(
        color: Color(0xFFDCE9BE),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x33A4CD87),
                      blurRadius: 20,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 138),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filter Gender',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 14),
                _buildGenderOptions(),
                const SizedBox(height: 16),
                _buildCTAButton(),
                const SizedBox(height: 10),
                _buildHelperText(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderOptions() {
    return Row(
      children: List.generate(genders.length, (index) {
        final option = genders[index];
        final isSelected = selectedGenderIndex == index;
        final isPressed = pressedGenderIndex == index;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: index == genders.length - 1 ? 0 : 12,
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
                  selectedGenderIndex = index;
                });
              },
              onTapCancel: () {
                setState(() {
                  pressedGenderIndex = null;
                });
              },
              child: AnimatedScale(
                scale: isPressed ? 0.96 : 1.0,
                duration: const Duration(milliseconds: 120),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    SizedBox(
                      height: 74,
                      width: double.infinity,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        decoration: BoxDecoration(
                          color: option.background,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? option.border
                                : option.border.withOpacity(0.7),
                            width: isSelected ? 2.0 : 1.4,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              option.icon,
                              size: 26,
                              color: isSelected
                                  ? option.iconColor
                                  : const Color(0xFF88B97A),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              option.label,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (index != 1)
                      Positioned(
                        top: -8,
                        right: 6,
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: Image.asset(
                            'assets/icons/crown.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCTAButton() {
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
      onTap: () async {
        setState(() {
          _isMatchingPageOpen = true;
        });

        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const MatchingPage(),
          ),
        );

        if (!mounted) return;

        setState(() {
          _isMatchingPageOpen = false;
        });
      },
      child: AnimatedScale(
        scale: isCtaPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          width: double.infinity,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFF84C76A),
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.center,
          child: Text(
            'Mulai Bercerita',
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
      ),
    );
  }

  Widget _buildHelperText() {
    return Center(
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(height: 1.2, color: Colors.black87),
          children: [
            const TextSpan(text: 'Tolong hormati orang lain dan patuhi '),
            TextSpan(
              text: 'peraturan kami',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF7DCB66),
                    fontWeight: FontWeight.w900,
                  ),
              recognizer: TapGestureRecognizer()..onTap = _showRulesDialog,
            ),
          ],
        ),
      ),
    );
  }
}

class _GenderOption {
  final String label;
  final IconData icon;
  final Color background;
  final Color border;
  final Color iconColor;

  const _GenderOption({
    required this.label,
    required this.icon,
    required this.background,
    required this.border,
    required this.iconColor,
  });
}