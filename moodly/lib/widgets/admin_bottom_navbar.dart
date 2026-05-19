import 'package:flutter/material.dart';
import '../core/styles/app_text.dart';

class AdminBottomNavbar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AdminBottomNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const Color _navBg = Color(0xFFB7E3A1);

  static const Color _selectedBg = Colors.white;
  static const Color _selectedIcon = Color(0xFF5F9E4E);
  static const Color _selectedText = Color(0xFF5F9E4E);

  static const Color _inactiveIcon = Colors.white;
  static const Color _inactiveText = Colors.white;

  List<BoxShadow> get _softShadow => const [
        BoxShadow(
          color: Color.fromRGBO(0, 0, 0, 0.08),
          offset: Offset(0, 6),
          blurRadius: 18,
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
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: selected
                      ? _selectedBg
                      : Colors.transparent,
                  shape: BoxShape.circle,
                  boxShadow: selected
                      ? _softShadow
                      : null,
                ),
                child: Icon(
                  icon,
                  size: 23,
                  color: selected
                      ? _selectedIcon
                      : _inactiveIcon,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                label,
                style: AppText.bodyAlt(context).copyWith(
                  fontSize: 11,
                  fontWeight: selected
                      ? FontWeight.w800
                      : FontWeight.w600,
                  color: selected
                      ? _selectedText
                      : _inactiveText,
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
        height: 108,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Positioned(
              left: 16,
              right: 16,
              bottom: 10,
              child: Container(
                height: 76,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10),
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
                      label: 'Dashboard',
                      selected: currentIndex == 0,
                      onPressed: () => onTap(0),
                    ),

                    _navItem(
                      context: context,
                      icon: Icons.gavel_rounded,
                      label: 'Moderasi',
                      selected: currentIndex == 1,
                      onPressed: () => onTap(1),
                    ),

                    _navItem(
                      context: context,
                      icon: Icons.shield_rounded,
                      label: 'Laporan',
                      selected: currentIndex == 2,
                      onPressed: () => onTap(2),
                    ),

                    _navItem(
                      context: context,
                      icon: Icons.description_rounded,
                      label: 'Banding',
                      selected: currentIndex == 3,
                      onPressed: () => onTap(3),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}