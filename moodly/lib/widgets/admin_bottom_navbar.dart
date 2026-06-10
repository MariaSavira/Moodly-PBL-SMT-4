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

  static const Color _navBg = Color(0xFFBFE2A9);
  static const Color _navBgTop = Color(0xFFD9EFC9);
  static const Color _navBorder = Color(0xFFEAF7E1);
  static const Color _selectedBg = Colors.white;
  static const Color _selectedIconBubble = Color(0xFFEFF7E8);
  static const Color _selectedColor = Color(0xFF4E7D45);
  static const Color _inactiveColor = Color(0xFF6E8E67);

  List<BoxShadow> get _softShadow => const [
        BoxShadow(
          color: Color.fromRGBO(0, 0, 0, 0.10),
          offset: Offset(0, 8),
          blurRadius: 24,
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
        borderRadius: BorderRadius.circular(24),
        onTap: onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          height: 62,
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 9),
          decoration: BoxDecoration(
            color: selected ? _selectedBg : Colors.transparent,
            borderRadius: BorderRadius.circular(22),
            boxShadow: selected ? _softShadow : null,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (selected)
                Positioned(
                  top: 0,
                  child: Container(
                    width: 26,
                    height: 4,
                    decoration: BoxDecoration(
                      color: _selectedColor,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: selected
                          ? _selectedIconBubble
                          : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      size: 19,
                      color: selected ? _selectedColor : _inactiveColor,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.bodyAlt(context).copyWith(
                      fontSize: 10.5,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
                      color: selected ? _selectedColor : _inactiveColor,
                    ),
                  ),
                ],
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
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
          child: Container(
            height: 82,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_navBgTop, _navBg],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: _navBorder, width: 1.2),
              boxShadow: _softShadow,
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 10,
                  left: 22,
                  right: 22,
                  child: Container(
                    height: 1,
                    color: Colors.white.withOpacity(0.42),
                  ),
                ),
                Row(
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
                      icon: Icons.description_rounded,
                      label: 'Banding',
                      selected: currentIndex == 2,
                      onPressed: () => onTap(2),
                    ),
                    _navItem(
                      context: context,
                      icon: Icons.person_rounded,
                      label: 'Profil',
                      selected: currentIndex == 3,
                      onPressed: () => onTap(3),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}