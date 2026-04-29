import 'package:flutter/material.dart';

// core
import '../../core/moodly_colors.dart';

// widgets
import '../../widgets/setting/profile_card.dart';
import '../../widgets/setting/section_card.dart';
import '../../widgets/setting/setting_tile.dart';
import '../../widgets/shared/moodly_app_bar.dart';

// pages (internal)
import 'edit_profile_page.dart';
import 'change_password_page.dart';
import 'theme_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MoodlyColors.bgLight,
      appBar: moodlyAppBar(context, 'Settings'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ✅ FIX ProfileCard (WAJIB ada onEdit)
            ProfileCard(
              onEdit: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const EditProfilePage(),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // ✅ FIX SectionCard (pakai children, bukan items)
            SectionCard(
              title: 'ACCOUNT SETTINGS',
              children: [
                SettingTile(
                  icon: Icons.person_outline,
                  iconColor: MoodlyColors.green,
                  label: 'Profile',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EditProfilePage(),
                    ),
                  ),
                ),
                SettingTile(
                  icon: Icons.shield_outlined,
                  iconColor: MoodlyColors.green,
                  label: 'Security',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ChangePasswordPage(),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            SectionCard(
              title: 'APP PREFERENCES',
              children: [
                SettingTile(
                  icon: Icons.palette_outlined,
                  iconColor: MoodlyColors.pinkAccent,
                  label: 'Theme',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ThemePage(),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ✅ FIX Logout (hapus LogoutButton, pakai manual)
            ElevatedButton(
              onPressed: () {
                // TODO: logout logic
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: MoodlyColors.redLogout,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}