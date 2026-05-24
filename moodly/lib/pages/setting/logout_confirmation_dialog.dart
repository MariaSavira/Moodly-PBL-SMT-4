import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _prefLanguageKey = 'moodly_settings_language_code';

Future<bool?> showLogoutConfirmationDialog(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  final languageCode = prefs.getString(_prefLanguageKey) == 'en' ? 'en' : 'id';

  const copy = {
    'id': {
      'title': 'Keluar dari Akun?',
      'message': 'Apakah kamu yakin ingin keluar dari akun Moodly?',
      'cancel': 'Batal',
      'logout': 'Keluar',
    },
    'en': {
      'title': 'Log out of your account?',
      'message': 'Are you sure you want to log out of your Moodly account?',
      'cancel': 'Cancel',
      'logout': 'Log out',
    },
  };

  String t(String key) => copy[languageCode]?[key] ?? key;

  return showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) {
      return Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: Color(0xFFE9F7E8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  size: 38,
                  color: Color(0xFF5E9E49),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                t('title'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF1F1F1F),
                    ) ??
                    const TextStyle(
                      color: Color(0xFF1F1F1F),
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 10),
              Text(
                t('message'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.black54,
                      height: 1.4,
                    ) ??
                    const TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(dialogContext, false),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Color(0xFF7BC25D),
                            width: 1.4,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: Text(
                          t('cancel'),
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: const Color(0xFF5E9E49),
                                fontWeight: FontWeight.w700,
                              ) ??
                              const TextStyle(
                                color: Color(0xFF5E9E49),
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(dialogContext, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7BC25D),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: Text(
                          t('logout'),
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ) ??
                              const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
