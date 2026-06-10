import 'package:flutter/material.dart';

class MoodlySettingsHeader extends StatelessWidget {
  final String title;

  const MoodlySettingsHeader({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final bool isSmall = screenWidth < 360;

    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(
            Icons.arrow_back,
            color: const Color(0xFF6EAF57),
            size: isSmall ? 20 : 22,
          ),
        ),

        SizedBox(width: isSmall ? 4 : 6),

        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: const Color(0xFF6EAF57),
              fontSize: isSmall ? 16 : 17,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),

        SizedBox(width: isSmall ? 8 : 12),

        Text(
          'Moodly',
          style: TextStyle(
            color: const Color(0xFFC65F59),
            fontSize: isSmall ? 28 : 32,
            fontWeight: FontWeight.w800,
            letterSpacing: -1,
          ),
        ),
      ],
    );
  }
}