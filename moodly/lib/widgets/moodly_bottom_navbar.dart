import 'package:flutter/material.dart';
import '../core/styles/app_text.dart';
import '../pages/setting/moodly_settings_support.dart';

class MoodlyBottomNavbar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onEmergencyTap;
  final Color? outerBackgroundColor;

  const MoodlyBottomNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onEmergencyTap,
    this.outerBackgroundColor,
  });

  @override
  State<MoodlyBottomNavbar> createState() => _MoodlyBottomNavbarState();
}

class _MoodlyBottomNavbarState extends State<MoodlyBottomNavbar> {
  static const Color _navBg = Color(0xFFE2EFCF);
  static const Color _selectedBg = Color(0xFFFFFFFF);
  static const Color _selectedIcon = Color(0xFF5F9E4E);
  static const Color _selectedText = Color(0xFF5F9E4E);
  static const Color _inactiveIcon = Color(0xFF8FA287);
  static const Color _inactiveText = Color(0xFF8FA287);
  static const Color _danger = Color(0xFFE95C69);
  static const Color _dangerRing = Color(0xFFF6D4DA);

  String _languageCode = MoodlySettingsPrefs.currentLanguageCode;
  bool _isLoadingPrefs = !MoodlySettingsPrefs.isHydrated;

  static const Map<String, Map<String, String>> _copy = {
    'id': {
      'home': 'Beranda',
      'diary': 'Diary',
      'connect': 'Connect',
      'affirmation': 'Afirmasi',
      'sos': 'SOS',
    },
    'en': {
      'home': 'Home',
      'diary': 'Diary',
      'connect': 'Connect',
      'affirmation': 'Affirmation',
      'sos': 'SOS',
    },
  };

  List<BoxShadow> get _softShadow => const [
        BoxShadow(
          color: Color.fromRGBO(0, 0, 0, 0.08),
          offset: Offset(0, 6),
          blurRadius: 18,
          spreadRadius: 0,
        ),
      ];

  @override
  void initState() {
    super.initState();
    MoodlySettingsPrefs.languageNotifier.addListener(_onLanguageChanged);
    _loadPrefs();
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
      _languageCode = language == 'en' ? 'en' : 'id';
      _isLoadingPrefs = false;
    });
  }

  void _onLanguageChanged() {
    if (!mounted) return;

    setState(() {
      _languageCode = MoodlySettingsPrefs.languageNotifier.value == 'en'
          ? 'en'
          : 'id';
    });
  }

  String _t(String key) => _copy[_languageCode]?[key] ?? key;

  Widget _navItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onPressed,
        child: SizedBox(
          height: 72,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: selected ? _selectedBg : Colors.transparent,
                  shape: BoxShape.circle,
                  boxShadow: selected ? _softShadow : null,
                ),
                child: Icon(
                  icon,
                  size: 22,
                  color: selected ? _selectedIcon : _inactiveIcon,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.bodyAlt(context).copyWith(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  color: selected ? _selectedText : _inactiveText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sosButton(BuildContext context) {
    return GestureDetector(
      onTap: widget.onEmergencyTap,
      child: Container(
        width: 78,
        height: 78,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(
            color: _dangerRing,
            width: 4,
          ),
          boxShadow: _softShadow,
        ),
        child: Center(
          child: Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: _danger,
            ),
            child: Center(
              child: Text(
                _t('sos'),
                style: AppText.bodyAlt(context).copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingPrefs) {
      return const SizedBox.shrink();
    }

    return Container(
      color: widget.outerBackgroundColor ?? Colors.transparent,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 108,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              Positioned(
                left: 16,
                right: 16,
                bottom: 10,
                child: Container(
                  height: 76,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: _navBg,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: _softShadow,
                  ),
                  child: Row(
                    children: [
                      _navItem(
                        context: context,
                        icon: Icons.home_rounded,
                        label: _t('home'),
                        selected: widget.currentIndex == 0,
                        onPressed: () => widget.onTap(0),
                      ),
                      _navItem(
                        context: context,
                        icon: Icons.book_rounded,
                        label: _t('diary'),
                        selected: widget.currentIndex == 1,
                        onPressed: () => widget.onTap(1),
                      ),
                      const SizedBox(width: 76),
                      _navItem(
                        context: context,
                        icon: Icons.forum_rounded,
                        label: _t('connect'),
                        selected: widget.currentIndex == 3,
                        onPressed: () => widget.onTap(3),
                      ),
                      _navItem(
                        context: context,
                        icon: Icons.local_florist_rounded,
                        label: _t('affirmation'),
                        selected: widget.currentIndex == 4,
                        onPressed: () => widget.onTap(4),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 24,
                child: _sosButton(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}