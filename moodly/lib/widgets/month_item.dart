import 'package:flutter/material.dart';

class MonthItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const MonthItem({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEAC1C7) : const Color(0xFFA8D08D),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Center(
          child: Text(label, style: Theme.of(context).textTheme.titleMedium),
        ),
      ),
    );
  }
}
