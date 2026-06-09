import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../widgets/shared/moodly_reward_frame_avatar.dart';
import '../../core/services/streak_service.dart';
import '../pages.dart';
import '../afirmasi/widgets/cute_top_popup.dart';
import 'moodly_settings_support.dart';

const String _profilePlaceholderAsset = 'assets/profile_pic/PP_default.jpg';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _languageCode = MoodlySettingsPrefs.currentLanguageCode;
  bool _isLoadingPrefs = !MoodlySettingsPrefs.isHydrated;

  static const Map<String, Map<String, String>> _copy = {
    'id': {
      'header': 'Profil',
      'notLoggedIn': 'Tidak ada user yang sedang login.',
      'verifiedYes': 'Email terverifikasi',
      'verifiedNo': 'Email belum verifikasi',
      'edit': 'Ubah Profil',
      'status': 'Status verifikasi',
      'provider': 'Metode login',
      'joined': 'Bergabung sejak',
      'role': 'Peran',
      'phone': 'User ID',
      'notAdded': '-',
      'copySuccessTitle': 'Berhasil',
      'copySuccessBody': 'User ID berhasil disalin',
      'yes': 'Ya',
      'no': 'Tidak',
      'badge': 'Badge Milestone',
      'noBadge': 'Belum ada badge',
      'moodlyUser': 'Pengguna Moodly',
      'emailProvider': 'Email',
      'google': 'Google',
      'facebook': 'Facebook',
      'anonymous': 'Anonim',
      'firebase': 'Firebase',
      'frame': 'Bingkai avatar',
      'changeFrame': 'Ganti Bingkai',
      'originalFrame': 'Original',
      'bloomFrame': 'Bingkai Bloom',
      'meadowFrame': 'Bingkai Meadow',
      'framePickerTitle': 'Pilih bingkai avatar',
      'framePickerDesc': 'Gunakan bingkai yang sudah kamu miliki dari halaman hadiah.',
      'noRedeemedFrame': 'Kamu belum punya bingkai tambahan.',
    },
    'en': {
      'header': 'Profile',
      'notLoggedIn': 'No user is currently signed in.',
      'verifiedYes': 'Email verified',
      'verifiedNo': 'Email not verified',
      'edit': 'Edit Profile',
      'status': 'Verification status',
      'provider': 'Sign-in method',
      'joined': 'Joined since',
      'role': 'Role',
      'phone': 'User ID',
      'notAdded': '-',
      'copySuccessTitle': 'Success',
      'copySuccessBody': 'User ID copied successfully',
      'yes': 'Yes',
      'no': 'No',
      'badge': 'Milestone Badge',
      'noBadge': 'No badge yet',
      'moodlyUser': 'Moodly User',
      'emailProvider': 'Email',
      'google': 'Google',
      'facebook': 'Facebook',
      'anonymous': 'Anonymous',
      'firebase': 'Firebase',
      'frame': 'Avatar frame',
      'changeFrame': 'Change Frame',
      'originalFrame': 'Original',
      'bloomFrame': 'Bloom Frame',
      'meadowFrame': 'Meadow Frame',
      'framePickerTitle': 'Choose avatar frame',
      'framePickerDesc': 'Use a frame you have already redeemed from the rewards page.',
      'noRedeemedFrame': 'You do not have any extra frames yet.',
    },
  };

  @override
  void initState() {
    super.initState();
    MoodlySettingsPrefs.languageNotifier.addListener(_onLanguageChanged);
    _loadPrefs();
  }

  void _onLanguageChanged() {
    if (!mounted) return;
    setState(() {
      _languageCode = MoodlySettingsPrefs.languageNotifier.value;
    });
  }

  @override
  void dispose() {
    MoodlySettingsPrefs.languageNotifier.removeListener(_onLanguageChanged);
    super.dispose();
  }

  Future<void> _loadPrefs() async {
    final language = await MoodlySettingsPrefs.loadLanguageCode();
    if (!mounted) return;
    setState(() {
      _languageCode = language;
      _isLoadingPrefs = false;
    });
  }

  String _t(String key) => _copy[_languageCode]?[key] ?? key;

  double _maxWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width > 430 ? 430 : width;
  }

  String _badgeTitleFor(int streak) {
    if (streak >= 120) return _languageCode == 'en' ? 'Growing Gently' : 'Tumbuh dengan Tenang';
    if (streak >= 30) return _languageCode == 'en' ? 'Steady Self-Care' : 'Menjaga Diri dengan Setia';
    if (streak >= 14) return _languageCode == 'en' ? 'Slow and Steady' : 'Tumbuh Pelan-Pelan';
    if (streak >= 7) return _languageCode == 'en' ? 'Friend to Yourself' : 'Teman Diri Sendiri';
    if (streak >= 3) return _languageCode == 'en' ? 'Starting Consistency' : 'Mulai Konsisten';
    return _t('noBadge');
  }

  String _resolveName(Map<String, dynamic>? data, User? user) {
    final fullName = (data?['fullName'] as String?)?.trim();
    if (fullName != null && fullName.isNotEmpty) return fullName;
    final displayName = user?.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) return displayName;
    final email = user?.email?.trim();
    if (email != null && email.isNotEmpty) return email.split('@').first;
    return _t('moodlyUser');
  }

  String _resolveEmail(Map<String, dynamic>? data, User? user) {
    final email = (data?['email'] as String?)?.trim() ?? user?.email?.trim();
    if (email != null && email.isNotEmpty) return email;
    return '-';
  }

  String? _resolvePhotoUrl(Map<String, dynamic>? data, User? user) {
    final photoUrl = (data?['photoUrl'] as String?)?.trim();
    if (photoUrl != null && photoUrl.isNotEmpty) return photoUrl;
    final authPhoto = user?.photoURL?.trim();
    if (authPhoto != null && authPhoto.isNotEmpty) return authPhoto;
    return null;
  }

  String? _resolveAvatarAsset(Map<String, dynamic>? data) {
    final avatarId = (data?['avatarId'] as String?)?.trim();
    if (avatarId != null && avatarId.isNotEmpty) return avatarId;
    return null;
  }

  String? _resolveActiveFrameId(Map<String, dynamic>? inventory) {
    return MoodlyRewardFrameAvatar.normalizeFrameId(
      (inventory?['activeFrameId'] as String?)?.trim(),
    );
  }

  String _resolveUserId(User? user) {
    return user?.uid ?? _t('notAdded');
  }

  Future<void> _copyUserId(String userId) async {
    if (userId.trim().isEmpty || userId == _t('notAdded')) return;

    await Clipboard.setData(ClipboardData(text: userId));

    if (!mounted) return;

    showCuteTopPopup(
      context,
      title: _t('copySuccessTitle'),
      message: _t('copySuccessBody'),
      type: CutePopupType.success,
    );
  }

  String _providerLabel(User? user) {
    if (user == null) return '-';
    final ids = user.providerData.map((e) => e.providerId).toList();
    if (ids.contains('google.com')) return _t('google');
    if (ids.contains('facebook.com')) return _t('facebook');
    if (ids.contains('password')) return _t('emailProvider');
    if (user.isAnonymous) return _t('anonymous');
    return _t('firebase');
  }

  DateTime? _parseCreatedAt(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  DateTime? _resolveCreatedAt(Map<String, dynamic>? data, User? user) {
    return _parseCreatedAt(data?['createdAt']) ?? user?.metadata.creationTime;
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    const monthsId = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    const monthsEn = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final months = _languageCode == 'en' ? monthsEn : monthsId;
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _frameLabel(String? frameId) {
    switch (MoodlyRewardFrameAvatar.normalizeFrameId(frameId)) {
      case 'frame_bloom':
        return _t('bloomFrame');
      case 'frame_meadow':
        return _t('meadowFrame');
      default:
        return _t('originalFrame');
    }
  }

  Future<void> _saveActiveFrame(String uid, String? frameId) async {
    final ref = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('reward_inventory')
        .doc('main');

    if (frameId == null) {
      await ref.set({
        'activeFrameId': FieldValue.delete(),
      }, SetOptions(merge: true));
      return;
    }

    await ref.set({
      'activeFrameId': frameId,
    }, SetOptions(merge: true));
  }

  Future<void> _showFramePicker({
    required String uid,
    required Map<String, dynamic>? inventory,
  }) async {
    final ownedFrameIds = List<String>.from(inventory?['ownedFrameIds'] ?? const []);
    final activeFrameId = _resolveActiveFrameId(inventory);

    final hasBloom = ownedFrameIds.contains('frame_bloom');
    final hasMeadow = ownedFrameIds.contains('frame_meadow');

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final palette = MoodlySettingsPalette.of();

        Widget optionTile({
          required String title,
          required bool selected,
          required VoidCallback onTap,
        }) {
          return InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onTap,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: selected ? palette.greenDark : palette.cardBorder,
                  width: selected ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: palette.textDark,
                          ),
                    ),
                  ),
                  if (selected)
                    Icon(
                      Icons.check_circle_rounded,
                      color: palette.greenDark,
                    ),
                ],
              ),
            ),
          );
        }

        return Container(
          margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
          decoration: BoxDecoration(
            color: palette.card,
            borderRadius: BorderRadius.circular(28),
            boxShadow: palette.shadow,
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 46,
                    height: 5,
                    decoration: BoxDecoration(
                      color: palette.cardBorder,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  _t('framePickerTitle'),
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: palette.textDark,
                        fontSize: 24,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  _t('framePickerDesc'),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: palette.textSoft,
                        height: 1.45,
                      ),
                ),
                const SizedBox(height: 16),

                optionTile(
                  title: _t('originalFrame'),
                  selected: activeFrameId == null,
                  onTap: () async {
                    await _saveActiveFrame(uid, null);
                    if (mounted) Navigator.pop(sheetContext);
                  },
                ),

                if (hasBloom) ...[
                  const SizedBox(height: 10),
                  optionTile(
                    title: _t('bloomFrame'),
                    selected: activeFrameId == 'frame_bloom',
                    onTap: () async {
                      await _saveActiveFrame(uid, 'frame_bloom');
                      if (mounted) Navigator.pop(sheetContext);
                    },
                  ),
                ],

                if (hasMeadow) ...[
                  const SizedBox(height: 10),
                  optionTile(
                    title: _t('meadowFrame'),
                    selected: activeFrameId == 'frame_meadow',
                    onTap: () async {
                      await _saveActiveFrame(uid, 'frame_meadow');
                      if (mounted) Navigator.pop(sheetContext);
                    },
                  ),
                ],

                if (!hasBloom && !hasMeadow) ...[
                  const SizedBox(height: 12),
                  Text(
                    _t('noRedeemedFrame'),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: palette.textSoft,
                        ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = MoodlySettingsPalette.of();
    final maxWidth = _maxWidth(context);
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;

    if (_isLoadingPrefs) {
      return Scaffold(
        backgroundColor: palette.bg,
        body: Center(child: CircularProgressIndicator(color: palette.greenDark)),
      );
    }

    return Scaffold(
      backgroundColor: palette.bg,
      body: Stack(
        children: [
          MoodlySettingsBackground(palette: palette),
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: maxWidth,
                child: uid == null
                    ? Center(
                        child: Text(
                          _t('notLoggedIn'),
                          style: _body(context, palette),
                        ),
                      )
                    : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                        stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            debugPrint('PROFILE PAGE USER SNAPSHOT ERROR: ${snapshot.error}');
                          }

                          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          final data = snapshot.data?.data();

                          debugPrint('PROFILE PAGE UID: $uid');
                          debugPrint('PROFILE PAGE PHONE RAW: ${data?['phoneNumber']}');
                          debugPrint('PROFILE PAGE DATA: $data');

                          final name = _resolveName(data, user);
                          final email = _resolveEmail(data, user);
                          final photoUrl = _resolvePhotoUrl(data, user);
                          final avatarAsset = _resolveAvatarAsset(data);
                          final userId = _resolveUserId(user);
                          final isVerified = (data?['isEmailVerified'] as bool?) ?? (user?.emailVerified ?? false);
                          final role = ((data?['role'] as String?) ?? 'user').trim();
                          final createdAt = _resolveCreatedAt(data, user);
                          final provider = _providerLabel(user);

                          return SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(24, 16, 24, 30),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _ProfileHeader(
                                  palette: palette,
                                  title: _t('header'),
                                  onBack: () => Navigator.pop(context),
                                ),
                                const SizedBox(height: 22),
                                StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                                  stream: FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(uid)
                                      .collection('reward_inventory')
                                      .doc('main')
                                      .snapshots(),
                                  builder: (context, inventorySnapshot) {
                                    final inventory = inventorySnapshot.data?.data();
                                    final activeFrameId = _resolveActiveFrameId(inventory);

                                    return _ProfileHeroCard(
                                      palette: palette,
                                      name: name,
                                      email: email,
                                      photoUrl: photoUrl,
                                      avatarAsset: avatarAsset,
                                      activeFrameId: activeFrameId,
                                      currentFrameLabel: _frameLabel(activeFrameId),
                                      changeFrameLabel: _t('changeFrame'),
                                      frameLabel: _t('frame'),
                                      isVerified: isVerified,
                                      provider: provider,
                                      verifiedLabel: isVerified ? _t('verifiedYes') : _t('verifiedNo'),
                                      editLabel: _t('edit'),
                                      onEdit: () async {
                                        final changed = await Navigator.push<bool>(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => const EditProfilePage(),
                                          ),
                                        );
                                        if (changed == true && mounted) {
                                          setState(() {});
                                        }
                                      },
                                      onChangeFrame: () => _showFramePicker(
                                        uid: uid,
                                        inventory: inventory,
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 14),
                                StreamBuilder<StreakState>(
                                  stream: StreakService.instance.watchState(),
                                  builder: (context, snapshot) {
                                    final streak = snapshot.data ?? StreakState.initial();
                                    return _BadgeCard(
                                      palette: palette,
                                      badgeTitle: _badgeTitleFor(streak.currentStreak),
                                      badgeLabel: _t('badge'),
                                    );
                                  },
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _MiniProfileCard(
                                        palette: palette,
                                        icon: Icons.verified_user_rounded,
                                        iconColor: palette.greenDark,
                                        value: isVerified ? _t('yes') : _t('no'),
                                        label: _t('status'),
                                        bg: palette.mintSoft,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _MiniProfileCard(
                                        palette: palette,
                                        icon: Icons.login_rounded,
                                        iconColor: palette.preferenceIcon,
                                        value: provider,
                                        label: _t('provider'),
                                        bg: palette.pinkSoft,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _AccountSummaryCard(
                                  palette: palette,
                                  joinedLabel: _t('joined'),
                                  roleLabel: _t('role'),
                                  phoneLabel: _t('phone'),
                                  joinedDate: _formatDate(createdAt),
                                  role: role,
                                  userId: userId,
                                  onCopyUserId: () => _copyUserId(userId),
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
    );
  }
}

TextStyle? _titleLarge(BuildContext context, MoodlySettingsPalette palette) {
  return Theme.of(context).textTheme.headlineLarge?.copyWith(
    color: palette.textDark,
    fontSize: MediaQuery.of(context).size.width < 380 ? 22 : 24,
  );
}

TextStyle? _titleMedium(BuildContext context, MoodlySettingsPalette palette) {
  return Theme.of(context).textTheme.titleMedium?.copyWith(
    color: palette.textDark,
  );
}

TextStyle? _body(BuildContext context, MoodlySettingsPalette palette) {
  return Theme.of(context).textTheme.bodyMedium?.copyWith(
    color: palette.textSoft,
    height: 1.35,
  );
}

TextStyle? _button(BuildContext context) {
  return Theme.of(context).textTheme.labelLarge?.copyWith(
    color: Colors.white,
    fontSize: 16,
  );
}

class _ProfileHeader extends StatelessWidget {
  final MoodlySettingsPalette palette;
  final String title;
  final VoidCallback onBack;

  const _ProfileHeader({
    required this.palette,
    required this.title,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: onBack,
          child: Icon(Icons.arrow_back, color: palette.greenDark, size: 22),
        ),
        const SizedBox(width: 6),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: palette.greenDark,
            fontSize: 17,
          ),
        ),
        const Spacer(),
        Text(
          'Moodly',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            color: palette.brand,
            fontSize: 32,
            letterSpacing: -1,
          ),
        ),
      ],
    );
  }
}

class _ProfileHeroCard extends StatelessWidget {
  final MoodlySettingsPalette palette;
  final String name;
  final String email;
  final String? photoUrl;
  final String? avatarAsset;
  final bool isVerified;
  final String provider;
  final String verifiedLabel;
  final String editLabel;
  final VoidCallback onEdit;
  final String? activeFrameId;
  final String currentFrameLabel;
  final String changeFrameLabel;
  final String frameLabel;
  final VoidCallback onChangeFrame;

  const _ProfileHeroCard({
    required this.palette,
    required this.name,
    required this.email,
    required this.photoUrl,
    required this.avatarAsset,
    required this.isVerified,
    required this.provider,
    required this.verifiedLabel,
    required this.editLabel,
    required this.onEdit,
    required this.activeFrameId,
    required this.currentFrameLabel,
    required this.changeFrameLabel,
    required this.frameLabel,
    required this.onChangeFrame,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: palette.cardBorder),
        boxShadow: palette.shadow,
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: onEdit,
            child: _ProfileAvatar(
              palette: palette,
              photoUrl: photoUrl,
              avatarAsset: avatarAsset,
              activeFrameId: activeFrameId,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: _titleLarge(context, palette),
          ),
          const SizedBox(height: 6),
          Text(
            email,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: _body(context, palette),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _InfoChip(
                label: verifiedLabel,
                icon: Icons.verified_rounded,
                bg: palette.greenSoft,
                fg: palette.greenDark,
              ),
              _InfoChip(
                label: provider,
                icon: Icons.login_rounded,
                bg: palette.pinkSoft,
                fg: palette.preferenceIcon,
              ),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: onChangeFrame,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: palette.mintSoft,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          frameLabel,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: palette.textSoft,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          currentFrameLabel,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: palette.textDark,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    changeFrameLabel,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: palette.greenDark,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: palette.greenDark,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: onEdit,
              style: ElevatedButton.styleFrom(
                backgroundColor: palette.green,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(editLabel, style: _button(context)),
                  const SizedBox(width: 10),
                  const Icon(Icons.arrow_forward_rounded),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  final MoodlySettingsPalette palette;
  final String? photoUrl;
  final String? avatarAsset;
  final String? activeFrameId;

  const _ProfileAvatar({
    required this.palette,
    required this.photoUrl,
    required this.avatarAsset,
    required this.activeFrameId,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageChild;
    if (photoUrl != null && photoUrl!.isNotEmpty) {
      imageChild = Image.network(
        photoUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallbackAvatar(),
      );
    } else if (avatarAsset != null && avatarAsset!.isNotEmpty) {
      imageChild = Image.asset(
        avatarAsset!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallbackAvatar(),
      );
    } else {
      imageChild = _fallbackAvatar();
    }

    return SizedBox(
      width: 132,
      height: 132,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          MoodlyRewardFrameAvatar(
            frameId: activeFrameId,
            size: 132,
            innerPadding: activeFrameId == null ? 0 : 6,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: palette.card,
              ),
              child: ClipOval(child: imageChild),
            ),
          ),
          Positioned(
            right: 4,
            bottom: 4,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: palette.pinkSoft,
                borderRadius: BorderRadius.circular(16),
                boxShadow: palette.shadow,
              ),
              child: Icon(
                Icons.edit_rounded,
                color: palette.greenDark,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fallbackAvatar() => Image.asset(
      _profilePlaceholderAsset,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Icon(
        Icons.person_rounded,
        size: 74,
        color: palette.textDark,
      ),
    );
}

class _FrameBadge extends StatelessWidget {
  final Color bg;
  final Color fg;
  final IconData icon;

  const _FrameBadge({required this.bg, required this.fg, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.08),
            offset: Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Icon(icon, color: fg, size: 18),
    );
  }
}

class _BadgeCard extends StatelessWidget {
  final MoodlySettingsPalette palette;
  final String badgeTitle;
  final String badgeLabel;

  const _BadgeCard({
    required this.palette,
    required this.badgeTitle,
    required this.badgeLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: palette.cardBorder),
        boxShadow: palette.shadow,
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: palette.pinkSoft,
            ),
            child: Icon(Icons.workspace_premium_rounded, color: palette.brand),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(badgeLabel, style: _body(context, palette)),
                const SizedBox(height: 4),
                Text(
                  badgeTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: _titleMedium(context, palette),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color bg;
  final Color fg;

  const _InfoChip({
    required this.label,
    required this.icon,
    required this.bg,
    required this.fg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: fg),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniProfileCard extends StatelessWidget {
  final MoodlySettingsPalette palette;
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final Color bg;

  const _MiniProfileCard({
    required this.palette,
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 126,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: palette.cardBorder),
        boxShadow: palette.shadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: iconColor),
          ),
          const Spacer(),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: _titleMedium(context, palette),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: _body(context, palette),
          ),
        ],
      ),
    );
  }
}

class _AccountSummaryCard extends StatelessWidget {
  final MoodlySettingsPalette palette;
  final String joinedLabel;
  final String roleLabel;
  final String phoneLabel;
  final String joinedDate;
  final String role;
  final String userId;
  final VoidCallback onCopyUserId;

  const _AccountSummaryCard({
    required this.palette,
    required this.joinedLabel,
    required this.roleLabel,
    required this.phoneLabel,
    required this.joinedDate,
    required this.role,
    required this.userId,
    required this.onCopyUserId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: palette.cardBorder),
        boxShadow: palette.shadow,
      ),
      child: Column(
        children: [
          _SummaryRow(label: joinedLabel, value: joinedDate, palette: palette),
          const SizedBox(height: 12),
          _SummaryRow(label: roleLabel, value: role, palette: palette),
          const SizedBox(height: 12),
          _CopyableSummaryRow(
            label: phoneLabel,
            value: userId,
            palette: palette,
            onCopy: onCopyUserId,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final MoodlySettingsPalette palette;
  final String label;
  final String value;

  const _SummaryRow({
    required this.palette,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(label, style: _body(context, palette)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: _titleMedium(context, palette),
          ),
        ),
      ],
    );
  }
}

class _CopyableSummaryRow extends StatelessWidget {
  final MoodlySettingsPalette palette;
  final String label;
  final String value;
  final VoidCallback onCopy;

  const _CopyableSummaryRow({
    required this.palette,
    required this.label,
    required this.value,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(label, style: _body(context, palette)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: _titleMedium(context, palette),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: onCopy,
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: palette.pinkSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.copy_rounded,
              size: 18,
              color: palette.preferenceIcon,
            ),
          ),
        ),
      ],
    );
  }
}
