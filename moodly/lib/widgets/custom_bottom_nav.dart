import 'package:flutter/material.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      {'icon': Icons.home_outlined, 'filled': Icons.home, 'label': 'Beranda'},
      {'icon': Icons.book_outlined, 'filled': Icons.book, 'label': 'Diary'},
      {'icon': Icons.chat_bubble_outline, 'filled': Icons.chat_bubble, 'label': 'Connect'},
      {'icon': Icons.emoji_emotions_outlined, 'filled': Icons.emoji_emotions, 'label': 'Afirmasi'},
    ];

    return SizedBox(
      height: 80,
      child: Stack(
        children: [
          // Background navbar
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white, Colors.green[50]!],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
            ),
          ),
          // Row items
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final item = items[index];
              bool isActive = currentIndex == index;

              return GestureDetector(
                onTap: () => onTap(index),
                child: SizedBox(
                  width: 80,
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      // Notch circle
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        top: isActive ? -20 : 0,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: isActive ? 48 : 0,
                          height: isActive ? 48 : 0,
                          decoration: BoxDecoration(
                            color: Colors.green[700],
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      // Icon & label
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 8),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            transform: Matrix4.translationValues(0, isActive ? -16 : 0, 0),
                            child: Icon(
                              isActive ? item['filled'] as IconData : item['icon'] as IconData,
                              color: isActive ? Colors.white : Colors.grey[600],
                              size: 28,
                            ),
                          ),
                          const SizedBox(height: 4),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            style: TextStyle(
                              color: isActive ? Colors.green[700] : Colors.grey[600],
                              fontWeight: isActive ? FontWeight.w800 : FontWeight.normal,
                            ),
                            child: Text(item['label'] as String),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}