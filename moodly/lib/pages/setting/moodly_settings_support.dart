import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String moodlyThemePrefKey = 'moodly_settings_theme_mode';
const String moodlyLanguagePrefKey = 'moodly_settings_language_code';
const String moodlyTwoFactorPrefKey = 'moodly_security_two_factor_enabled';

class MoodlySettingsPrefs {
  MoodlySettingsPrefs._();

  static String _languageCache = 'id';
  static bool _twoFactorCache = false;
  static bool _primed = false;

  static final ValueNotifier<String> languageNotifier =
      ValueNotifier<String>('id');

  // Backward-compatible getters
  static String get currentThemeMode => 'light';
  static String get currentLanguageCode => _languageCache;
  static bool get isHydrated => _primed;
  static bool get isHydated => _primed;

  static String get themeCache => 'light';
  static String get languageCache => _languageCache;
  static bool get twoFactorCache => _twoFactorCache;

  static Future<void> hydrate() async {
    if (_primed) return;
    final prefs = await SharedPreferences.getInstance();
    _languageCache =
        prefs.getString(moodlyLanguagePrefKey) == 'en' ? 'en' : 'id';
    _twoFactorCache = prefs.getBool(moodlyTwoFactorPrefKey) ?? false;
    languageNotifier.value = _languageCache;
    _primed = true;
  }

  static Future<void> prime() async {
    await hydrate();
  }

  static Future<String> loadThemeMode() async {
    return 'light';
  }

  static Future<String> loadLanguageCode() async {
    await hydrate();
    return _languageCache;
  }

  static Future<void> saveThemeMode(String value) async {
    // no-op, dark mode removed
    _primed = true;
  }

  static Future<void> saveLanguageCode(String value) async {
    _languageCache = value == 'en' ? 'en' : 'id';
    languageNotifier.value = _languageCache;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(moodlyLanguagePrefKey, _languageCache);
    _primed = true;
  }

  static Future<bool> loadTwoFactorEnabled() async {
    await hydrate();
    return _twoFactorCache;
  }

  static Future<void> saveTwoFactorEnabled(bool value) async {
    _twoFactorCache = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(moodlyTwoFactorPrefKey, value);
    _primed = true;
  }
}

class MoodlySettingsPalette {
  final Color bg;
  final Color card;
  final Color cardBorder;
  final Color green;
  final Color greenDark;
  final Color greenSoft;
  final Color mintSoft;
  final Color pinkSoft;
  final Color peachSoft;
  final Color yellowSoft;
  final Color textDark;
  final Color textSoft;
  final Color brand;
  final Color preferenceIcon;
  final Color logout;
  final Color scaffoldOverlay;
  final List<BoxShadow> shadow;

  const MoodlySettingsPalette({
    required this.bg,
    required this.card,
    required this.cardBorder,
    required this.green,
    required this.greenDark,
    required this.greenSoft,
    required this.mintSoft,
    required this.pinkSoft,
    required this.peachSoft,
    required this.yellowSoft,
    required this.textDark,
    required this.textSoft,
    required this.brand,
    required this.preferenceIcon,
    required this.logout,
    required this.scaffoldOverlay,
    required this.shadow,
  });

  static MoodlySettingsPalette of([String? _ignoredThemeMode]) {
    return const MoodlySettingsPalette(
      bg: Color(0xFFF4F8EA),
      card: Colors.white,
      cardBorder: Color(0xFFF0F0F0),
      green: Color(0xFF7BC25D),
      greenDark: Color(0xFF5E9E49),
      greenSoft: Color(0xFFDDEFCF),
      mintSoft: Color(0xFFE9F7E8),
      pinkSoft: Color(0xFFFFEEF2),
      peachSoft: Color(0xFFFFE9DD),
      yellowSoft: Color(0xFFF9F0CC),
      textDark: Color(0xFF1F1F1F),
      textSoft: Color(0xFF6F746E),
      brand: Color(0xFFC65F59),
      preferenceIcon: Color(0xFFE08C9B),
      logout: Colors.red,
      scaffoldOverlay: Color(0xFFF4F8EA),
      shadow: [
        BoxShadow(
          color: Color.fromRGBO(0, 0, 0, 0.08),
          offset: Offset(0, 8),
          blurRadius: 20,
          spreadRadius: 0,
        ),
      ],
    );
  }
}

class MoodlySettingsBackground extends StatelessWidget {
  final MoodlySettingsPalette palette;

  const MoodlySettingsBackground({
    super.key,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Stack(
        children: [
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: palette.pinkSoft.withOpacity(0.72),
              ),
            ),
          ),
          Positioned(
            top: 250,
            left: -70,
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: palette.mintSoft.withOpacity(0.82),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            right: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: palette.greenSoft.withOpacity(0.55),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MoodlySettingsHeader extends StatelessWidget {
  final MoodlySettingsPalette palette;
  final String title;
  final VoidCallback onBack;

  const MoodlySettingsHeader({
    super.key,
    required this.palette,
    required this.title,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: onBack,
          child: Icon(
            Icons.arrow_back_rounded,
            color: palette.greenDark,
            size: 26,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: palette.greenDark,
                ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'Moodly',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: palette.brand,
              ),
        ),
      ],
    );
  }
}

class MoodlySettingsCard extends StatelessWidget {
  final MoodlySettingsPalette palette;
  final Widget child;
  final EdgeInsetsGeometry padding;

  const MoodlySettingsCard({
    super.key,
    required this.palette,
    required this.child,
    this.padding = const EdgeInsets.all(18),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: palette.cardBorder),
        boxShadow: palette.shadow,
      ),
      child: child,
    );
  }
}

class MoodlySectionTitle extends StatelessWidget {
  final MoodlySettingsPalette palette;
  final String title;

  const MoodlySectionTitle({
    super.key,
    required this.palette,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: palette.greenDark,
          ),
    );
  }
}

class MoodlyPrimaryButton extends StatelessWidget {
  final MoodlySettingsPalette palette;
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  const MoodlyPrimaryButton({
    super.key,
    required this.palette,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: palette.green,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class MoodlyOutlineButton extends StatelessWidget {
  final MoodlySettingsPalette palette;
  final String label;
  final VoidCallback? onPressed;

  const MoodlyOutlineButton({
    super.key,
    required this.palette,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: palette.greenDark, width: 1.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: palette.greenDark,
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );
  }
}

class MoodlyOptionTile extends StatelessWidget {
  final MoodlySettingsPalette palette;
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? backgroundColor;

  const MoodlyOptionTile({
    super.key,
    required this.palette,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.isSelected,
    required this.onTap,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: backgroundColor ??
              (isSelected ? palette.pinkSoft : palette.mintSoft),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected
                ? palette.greenDark.withOpacity(0.24)
                : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: palette.card,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: palette.greenDark, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: subtitle == null
                  ? Text(
                      title,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: palette.textDark,
                          ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: palette.textDark,
                                  ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: palette.textSoft,
                                  ),
                        ),
                      ],
                    ),
            ),
            Icon(
              isSelected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: isSelected ? palette.greenDark : palette.textSoft,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

class MoodlySwitchTile extends StatelessWidget {
  final MoodlySettingsPalette palette;
  final IconData icon;
  final Color? iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const MoodlySwitchTile({
    super.key,
    required this.palette,
    required this.icon,
    this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: value ? palette.pinkSoft : palette.mintSoft,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: palette.card,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor ?? palette.greenDark, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: palette.textDark,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: palette.textSoft,
                      ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            activeColor: palette.greenDark,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class MoodlySettingsInput extends StatelessWidget {
  final MoodlySettingsPalette palette;
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData icon;
  final bool obscureText;
  final VoidCallback? onToggleObscure;
  final TextInputType keyboardType;
  final int maxLines;
  final bool enabled;
  final bool readOnly;

  const MoodlySettingsInput({
    super.key,
    required this.palette,
    required this.controller,
    required this.label,
    this.hint,
    required this.icon,
    this.obscureText = false,
    this.onToggleObscure,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.enabled = true,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: palette.textDark,
              ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: palette.card,
            borderRadius: BorderRadius.circular(24),
            boxShadow: palette.shadow,
            border: Border.all(color: palette.cardBorder),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            maxLines: maxLines,
            enabled: enabled,
            readOnly: readOnly,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: palette.textDark,
                ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: palette.textSoft,
                  ),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              prefixIcon: Icon(icon, color: palette.greenDark),
              suffixIcon: onToggleObscure == null
                  ? null
                  : IconButton(
                      onPressed: onToggleObscure,
                      icon: Icon(
                        obscureText
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        color: palette.textSoft,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}