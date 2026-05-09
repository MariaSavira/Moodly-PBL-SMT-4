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

  static const Color _greenMain = Color(0xFF84C96C);
  static const Color _greenSoft = Color(0xFFBFE3AF);
  static const Color _navBg = Color(0xFFCDE8B9);
  static const Color _white = Color(0xFFFFFFFF);
  static const Color _danger = Color(0xFFE95C69);
  static const Color _dangerSoft = Color(0xFFFFD7DD);
  static const Color _textInactive = Color(0xFFF4FFF0);

  List<BoxShadow> get _softShadow => const [
        BoxShadow(
          color: Color.fromRGBO(0, 0, 0, 0.25),
          offset: Offset(0, 1),
          blurRadius: 5,
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
    final activeColor = _white;
    final inactiveColor = _textInactive.withOpacity(0.92);

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onPressed,
        child: SizedBox(
          height: 72,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 24,
                color: selected ? activeColor : inactiveColor,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: AppText.bodyAlt(context).copyWith(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  color: selected ? activeColor : inactiveColor,
                ),
              ),
            ],
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
        height: 112,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            Positioned(
              left: 14,
              right: 14,
              bottom: 10,
              child: Container(
                height: 72,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: _navBg,
                  borderRadius: BorderRadius.circular(30),
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
                    const SizedBox(width: 72),
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
              bottom: 34,
              child: GestureDetector(
                onTap: onEmergencyTap,
                child: Container(
                  width: 74,
                  height: 74,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _white,
                    boxShadow: _softShadow,
                    border: Border.all(
                      color: _dangerSoft,
                      width: 3,
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: _danger,
                      ),
                      child: const Icon(
                        Icons.sos_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}