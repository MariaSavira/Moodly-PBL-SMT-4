import 'package:flutter/material.dart';
import '../core/styles/app_text.dart';

class MoodlyBottomNavbar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onEmergencyTap;

  const MoodlyBottomNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onEmergencyTap,
  });

  static const Color _navBg = Color(0xFFE2EFCF);
  static const Color _selectedBg = Color(0xFFFFFFFF);
  static const Color _selectedIcon = Color(0xFF5F9E4E);
  static const Color _selectedText = Color(0xFF5F9E4E);
  static const Color _inactiveIcon = Color(0xFF8FA287);
  static const Color _inactiveText = Color(0xFF8FA287);
  static const Color _danger = Color(0xFFE95C69);
  static const Color _dangerRing = Color(0xFFF6D4DA);

  List<BoxShadow> get _softShadow => const [
        BoxShadow(
          color: Color.fromRGBO(0, 0, 0, 0.08),
          offset: Offset(0, 6),
          blurRadius: 18,
          spreadRadius: 0,
        ),
      ];

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
      onTap: onEmergencyTap,
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
                'SOS',
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
    return SafeArea(
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
                      label: 'Beranda',
                      selected: currentIndex == 0,
                      onPressed: () => onTap(0),
                    ),
                    _navItem(
                      context: context,
                      icon: Icons.book_rounded,
                      label: 'Diary',
                      selected: currentIndex == 1,
                      onPressed: () => onTap(1),
                    ),
                    const SizedBox(width: 76),
                    _navItem(
                      context: context,
                      icon: Icons.forum_rounded,
                      label: 'Connect',
                      selected: currentIndex == 3,
                      onPressed: () => onTap(3),
                    ),
                    _navItem(
                      context: context,
                      icon: Icons.local_florist_rounded,
                      label: 'Afirmasi',
                      selected: currentIndex == 4,
                      onPressed: () => onTap(4),
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
    );
  }
}