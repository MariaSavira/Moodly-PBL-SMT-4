import 'package:flutter/material.dart';
import '../../core/moodly_colors.dart';
import '../../widgets/shared/moodly_app_bar.dart';

class ThemePage extends StatefulWidget {
  const ThemePage({super.key});

  @override
  State<ThemePage> createState() => _ThemePageState();
}

class _ThemePageState extends State<ThemePage> {
  String selected = 'light';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MoodlyColors.bgLight,
      appBar: moodlyAppBar(context, 'Theme'),
      body: Column(
        children: [
          RadioListTile(
            value: 'light',
            groupValue: selected,
            onChanged: (v) => setState(() => selected = v!),
            title: const Text('Light'),
          ),
          RadioListTile(
            value: 'dark',
            groupValue: selected,
            onChanged: (v) => setState(() => selected = v!),
            title: const Text('Dark'),
          ),
        ],
      ),
    );
  }
}