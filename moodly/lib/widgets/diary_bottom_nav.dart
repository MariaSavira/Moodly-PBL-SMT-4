import 'package:flutter/material.dart';

class DiaryBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const DiaryBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Wavy Background
          CustomPaint(
            painter: _WavyNavPainter(),
            child: const SizedBox(height: 80, width: double.infinity),
          ),
          // Nav Items Row
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home_outlined, 'Beranda'),
                const SizedBox(width: 40), // Space for floating button
                _buildNavItem(2, Icons.chat_bubble_outline, 'Connect'),
                _buildNavItem(3, Icons.local_florist_outlined, 'Afirmasi'),
              ],
            ),
          ),
          // Floating Center Button
          Positioned(
            top: 0,
            child: GestureDetector(
              onTap: () => onTap(1),
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.eco,
                  color: Color(0xFFA8D5A2),
                  size: 28,
                ),
              ),
            ),
          ),
          // Center Label
          Positioned(
            bottom: 4,
            child: Text(
              'Diary',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: currentIndex == 1
                    ? Colors.white
                    : Colors.white.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.6),
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Painter untuk efek gelombang/lengkungan
class _WavyNavPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFA8D5A2)
      ..style = PaintingStyle.fill;

    final path = Path();
    final w = size.width;
    final h = size.height;
    final curveWidth = 60.0;
    final centerX = w / 2;
    final dipDepth = 18.0;

    path.moveTo(0, 0);
    path.lineTo(centerX - curveWidth / 2, 0);
    path.cubicTo(
      centerX - curveWidth / 2,
      0,
      centerX - 8,
      dipDepth,
      centerX,
      dipDepth,
    );
    path.cubicTo(
      centerX + 8,
      dipDepth,
      centerX + curveWidth / 2,
      0,
      centerX + curveWidth / 2,
      0,
    );
    path.lineTo(w, 0);
    path.lineTo(w, h);
    path.lineTo(0, h);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
