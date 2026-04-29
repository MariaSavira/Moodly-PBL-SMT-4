import 'package:flutter/material.dart';
import '../../core/moodly_colors.dart';

class ProfileCard extends StatelessWidget {
  final VoidCallback onEdit;

  const ProfileCard({super.key, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MoodlyColors.cardBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const CircleAvatar(child: Text('🧠')),
          const SizedBox(width: 10),
          const Expanded(child: Text('Muhammad Yusuf')),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: onEdit,
          )
        ],
      ),
    );
  }
}