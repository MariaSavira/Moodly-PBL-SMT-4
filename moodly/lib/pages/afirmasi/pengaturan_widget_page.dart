import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:moodly/pages/afirmasi/cara_memasang_widget_page.dart';
import 'package:moodly/pages/setting/moodly_settings_support.dart';
import 'package:moodly/services/afirmasi/widget_settings_service.dart';

class PengaturanWidgetPage extends StatefulWidget {
  const PengaturanWidgetPage({super.key});

  @override
  State<PengaturanWidgetPage> createState() => _PengaturanWidgetPageState();
}

class _PengaturanWidgetPageState extends State<PengaturanWidgetPage> {
  bool tampilkanKategori = true;
  bool tampilkanQuote = true;
  bool gunakanBackground = true;

  Color warnaTeks = Colors.white;

  String _languageCode = MoodlySettingsPrefs.currentLanguageCode;
  String previewCategory = 'Afirmasi';
  String previewQuote = '';

  final List<String> daftarWallpaper = const [
    'assets/icon/images/bg_afirmasi_1.jpg',
    'assets/icon/images/bg_afirmasi_2.jpg',
    'assets/icon/images/bg_afirmasi_3.jpg',
    'assets/icon/images/bg_afirmasi_4.jpg',
    'assets/icon/images/bg_afirmasi_5.jpg',
  ];

  String wallpaperTerpilih = 'assets/icon/images/bg_afirmasi_1.jpg';

  static const Color _bg = Color(0xFFF3F7E8);
  static const Color _card = Colors.white;
  static const Color _green = Color(0xFF96D47E);
  static const Color _greenDark = Color(0xFF5E9E4F);
  static const Color _greenSoft = Color(0xFFE4F4D7);
  static const Color _pinkSoft = Color(0xFFFFEEF2);
  static const Color _textDark = Color(0xFF1F1F1F);
  static const Color _textSoft = Color(0xFF6F7866);

  static const Map<String, Map<String, String>> _copy = {
    'id': {
      'header': 'Pengaturan Widget',
      'widgetSection': 'Widget',
      'showCategoryTitle': 'Tampilkan kategori',
      'showCategoryBody': 'Menampilkan label kategori di widget afirmasi',
      'showQuoteTitle': 'Tampilkan isi afirmasi',
      'showQuoteBody': 'Menampilkan kutipan afirmasi di widget',
      'useBackgroundTitle': 'Gunakan background gambar',
      'useBackgroundBody': 'Memakai latar belakang afirmasi pada widget',
      'wallpaperSection': 'Wallpaper',
      'wallpaperLabel': 'Wallpaper widget',
      'textColorLabel': 'Warna teks',
      'previewSection': 'Preview',
      'previewDefaultCategory': 'Afirmasi',
      'previewDefaultQuote': 'Belum ada afirmasi',
      'helpTitle': 'Cara pasang widget',
      'helpBody': 'Lihat langkah cepat untuk memasang widget Moodly.',
      'catGratitude': 'Rasa Syukur',
      'catAnxiety': 'Meredakan Kecemasan',
      'catMotivation': 'Motivasi',
      'catMental': 'Kesehatan Mental',
      'catSelfLove': 'Cinta Diri',
    },
    'en': {
      'header': 'Widget Settings',
      'widgetSection': 'Widget',
      'showCategoryTitle': 'Show category',
      'showCategoryBody': 'Shows the category label on the affirmation widget',
      'showQuoteTitle': 'Show affirmation text',
      'showQuoteBody': 'Shows the affirmation quote on the widget',
      'useBackgroundTitle': 'Use image background',
      'useBackgroundBody': 'Uses the affirmation background image on the widget',
      'wallpaperSection': 'Wallpaper',
      'wallpaperLabel': 'Widget wallpaper',
      'textColorLabel': 'Text color',
      'previewSection': 'Preview',
      'previewDefaultCategory': 'Affirmation',
      'previewDefaultQuote': 'No affirmation yet',
      'helpTitle': 'How to install widget',
      'helpBody': 'See the quick steps to install the Moodly widget.',
      'catGratitude': 'Gratitude',
      'catAnxiety': 'Ease Anxiety',
      'catMotivation': 'Motivation',
      'catMental': 'Mental Health',
      'catSelfLove': 'Self Love',
    },
  };

  String _t(String key) => _copy[_languageCode]?[key] ?? key;

  List<BoxShadow> get _softShadow => const [
        BoxShadow(
          color: Color.fromRGBO(0, 0, 0, 0.08),
          offset: Offset(0, 10),
          blurRadius: 24,
        ),
      ];

  @override
  void initState() {
    super.initState();
    MoodlySettingsPrefs.languageNotifier.addListener(_onLanguageChanged);
    _loadWidgetSettings();
  }

  @override
  void dispose() {
    MoodlySettingsPrefs.languageNotifier.removeListener(_onLanguageChanged);
    super.dispose();
  }

  void _onLanguageChanged() {
    if (!mounted) return;

    setState(() {
      _languageCode = MoodlySettingsPrefs.currentLanguageCode;
      previewCategory = _localizedCategoryLabel(previewCategory);
    });

    _updateHomeWidget();
  }

  String _localizedCategoryLabel(String raw) {
    final cleaned = raw.trim();

    if (_languageCode == 'en') {
      switch (cleaned) {
        case 'Rasa Syukur':
          return _t('catGratitude');
        case 'Meredakan Kecemasan':
          return _t('catAnxiety');
        case 'Motivasi':
          return _t('catMotivation');
        case 'Kesehatan Mental':
          return _t('catMental');
        case 'Cinta Diri':
          return _t('catSelfLove');
        case 'Afirmasi':
          return _t('previewDefaultCategory');
        default:
          return cleaned;
      }
    }

    return cleaned.isEmpty ? _t('previewDefaultCategory') : cleaned;
  }

  Future<void> _loadWidgetSettings() async {
    final savedShowCategory = await WidgetSettingsService.getBool(
      WidgetSettingsService.showCategoryKey,
    );
    final savedShowQuote = await WidgetSettingsService.getBool(
      WidgetSettingsService.showQuoteKey,
    );
    final savedUseBackground = await WidgetSettingsService.getBool(
      WidgetSettingsService.useBackgroundKey,
    );
    final savedTextColor = await WidgetSettingsService.getInt(
      WidgetSettingsService.textColorKey,
    );
    final savedWallpaper = await WidgetSettingsService.getString(
      WidgetSettingsService.selectedWallpaperKey,
    );

    final category = await HomeWidget.getWidgetData<String>(
      'previewCategory',
      defaultValue: _t('previewDefaultCategory'),
    );

    final quote = await HomeWidget.getWidgetData<String>(
      'previewQuote',
      defaultValue: '',
    );

    if (!mounted) return;

    setState(() {
      _languageCode = MoodlySettingsPrefs.currentLanguageCode;
      tampilkanKategori = savedShowCategory ?? tampilkanKategori;
      tampilkanQuote = savedShowQuote ?? tampilkanQuote;
      gunakanBackground = savedUseBackground ?? gunakanBackground;
      warnaTeks = savedTextColor != null ? Color(savedTextColor) : warnaTeks;
      wallpaperTerpilih = savedWallpaper ?? wallpaperTerpilih;
      previewCategory = _localizedCategoryLabel(
        category ?? _t('previewDefaultCategory'),
      );
      previewQuote = (quote != null && quote.trim().isNotEmpty)
          ? quote
          : _t('previewDefaultQuote');
    });

    await _updateHomeWidget();
  }

  Future<void> _updateHomeWidget() async {
    await HomeWidget.saveWidgetData<bool>('showCategory', tampilkanKategori);
    await HomeWidget.saveWidgetData<bool>('showQuote', tampilkanQuote);
    await HomeWidget.saveWidgetData<bool>('useBackground', gunakanBackground);
    await HomeWidget.saveWidgetData<int>('textColor', warnaTeks.value);
    await HomeWidget.saveWidgetData<String>(
      'selectedWallpaper',
      wallpaperTerpilih,
    );
    await HomeWidget.saveWidgetData<String>('languageCode', _languageCode);

    await HomeWidget.updateWidget(
      androidName: 'MoodlyWidgetProvider',
    );
  }

  void _showCaraPasangWidget() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CaraMemasangWidgetPage(),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 6),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontSize: 20,
                color: _textDark,
              ),
        ),
      ),
    );
  }

  Widget _settingTile({
    required BuildContext context,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _card.withOpacity(0.94),
        borderRadius: BorderRadius.circular(22),
        boxShadow: _softShadow,
      ),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        title: Text(
          title,
          style: textTheme.titleMedium?.copyWith(
            color: _textDark,
            fontSize: 16,
          ),
        ),
        subtitle: subtitle == null
            ? null
            : Text(
                subtitle,
                style: textTheme.bodyMedium?.copyWith(
                  fontSize: 12.5,
                  height: 1.45,
                  color: _textSoft,
                ),
              ),
        trailing: trailing,
      ),
    );
  }

  Widget _colorDot(Color color, bool selected, Future<void> Function() onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? const Color(0xFF232323) : Colors.transparent,
            width: 2.2,
          ),
          boxShadow: selected
              ? const [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.12),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ]
              : null,
        ),
      ),
    );
  }

  Widget _wallpaperItem(String path) {
    final bool isSelected = wallpaperTerpilih == path;

    return GestureDetector(
      onTap: () async {
        setState(() {
          wallpaperTerpilih = path;
        });

        await WidgetSettingsService.saveString(
          WidgetSettingsService.selectedWallpaperKey,
          path,
        );

        await _updateHomeWidget();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 54,
        height: 76,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFF6E9550) : Colors.transparent,
            width: 3,
          ),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: Color.fromRGBO(110, 149, 80, 0.26),
                    blurRadius: 12,
                    offset: Offset(0, 5),
                  ),
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(11),
          child: Image.asset(
            path,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: const Color(0xFFE8E3EA),
              alignment: Alignment.center,
              child: const Icon(
                Icons.image_outlined,
                color: Colors.grey,
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveTextColor(Color color) async {
    setState(() {
      warnaTeks = color;
    });

    await WidgetSettingsService.saveInt(
      WidgetSettingsService.textColorKey,
      color.value,
    );

    await _updateHomeWidget();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final shownPreviewQuote = previewQuote.trim().isNotEmpty
        ? previewQuote
        : _t('previewDefaultQuote');

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
          ),
        ),
        title: Text(
          _t('header'),
          style: textTheme.headlineLarge?.copyWith(
            fontSize: 22,
            color: _textDark,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _showCaraPasangWidget,
            icon: const Icon(
              Icons.help_outline_rounded,
              color: Colors.black,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _showCaraPasangWidget,
                borderRadius: BorderRadius.circular(28),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: _card.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: _softShadow,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: const BoxDecoration(
                          color: _pinkSoft,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.widgets_rounded,
                          color: Color(0xFFC97C86),
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _t('helpTitle'),
                              style: textTheme.titleMedium?.copyWith(
                                color: _textDark,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _t('helpBody'),
                              style: textTheme.bodyMedium?.copyWith(
                                color: _textSoft,
                                fontSize: 12.5,
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.open_in_new_rounded,
                        color: _textSoft,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            _sectionTitle(context, _t('widgetSection')),
            _settingTile(
              context: context,
              title: _t('showCategoryTitle'),
              subtitle: _t('showCategoryBody'),
              trailing: Switch(
                value: tampilkanKategori,
                activeColor: _green,
                onChanged: (value) async {
                  setState(() {
                    tampilkanKategori = value;
                  });

                  await WidgetSettingsService.saveBool(
                    WidgetSettingsService.showCategoryKey,
                    value,
                  );

                  await _updateHomeWidget();
                },
              ),
            ),
            _settingTile(
              context: context,
              title: _t('showQuoteTitle'),
              subtitle: _t('showQuoteBody'),
              trailing: Switch(
                value: tampilkanQuote,
                activeColor: _green,
                onChanged: (value) async {
                  setState(() {
                    tampilkanQuote = value;
                  });

                  await WidgetSettingsService.saveBool(
                    WidgetSettingsService.showQuoteKey,
                    value,
                  );

                  await _updateHomeWidget();
                },
              ),
            ),
            _settingTile(
              context: context,
              title: _t('useBackgroundTitle'),
              subtitle: _t('useBackgroundBody'),
              trailing: Switch(
                value: gunakanBackground,
                activeColor: _green,
                onChanged: (value) async {
                  setState(() {
                    gunakanBackground = value;
                  });

                  await WidgetSettingsService.saveBool(
                    WidgetSettingsService.useBackgroundKey,
                    value,
                  );

                  await _updateHomeWidget();
                },
              ),
            ),
            const SizedBox(height: 8),
            _sectionTitle(context, _t('wallpaperSection')),
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: _card.withOpacity(0.94),
                borderRadius: BorderRadius.circular(24),
                boxShadow: _softShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _t('wallpaperLabel'),
                    style: textTheme.titleMedium?.copyWith(
                      color: _textDark,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: daftarWallpaper.map((path) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: _wallpaperItem(path),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: _card.withOpacity(0.94),
                borderRadius: BorderRadius.circular(24),
                boxShadow: _softShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _t('textColorLabel'),
                    style: textTheme.titleMedium?.copyWith(
                      color: _textDark,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _colorDot(
                        Colors.white,
                        warnaTeks == Colors.white,
                        () => _saveTextColor(Colors.white),
                      ),
                      _colorDot(
                        Colors.black87,
                        warnaTeks == Colors.black87,
                        () => _saveTextColor(Colors.black87),
                      ),
                      _colorDot(
                        const Color(0xFFFFF1F1),
                        warnaTeks == const Color(0xFFFFF1F1),
                        () => _saveTextColor(const Color(0xFFFFF1F1)),
                      ),
                      _colorDot(
                        const Color(0xFFFFE7B8),
                        warnaTeks == const Color(0xFFFFE7B8),
                        () => _saveTextColor(const Color(0xFFFFE7B8)),
                      ),
                      _colorDot(
                        const Color(0xFFDAF5FF),
                        warnaTeks == const Color(0xFFDAF5FF),
                        () => _saveTextColor(const Color(0xFFDAF5FF)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _sectionTitle(context, _t('previewSection')),
            Container(
              height: 156,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                image: gunakanBackground
                    ? DecorationImage(
                        image: AssetImage(wallpaperTerpilih),
                        fit: BoxFit.cover,
                      )
                    : null,
                color: gunakanBackground ? null : const Color(0xFF8C6A8E),
                boxShadow: _softShadow,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0x44000000),
                  borderRadius: BorderRadius.circular(22),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (tampilkanKategori)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xCCFFFFFF),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          previewCategory.trim().isEmpty
                              ? _t('previewDefaultCategory')
                              : previewCategory,
                          style: textTheme.bodySmall?.copyWith(
                            color: Colors.black87,
                            fontSize: 11.5,
                          ),
                        ),
                      ),
                    if (tampilkanKategori) const SizedBox(height: 12),
                    if (tampilkanQuote)
                      Text(
                        shownPreviewQuote,
                        textAlign: TextAlign.center,
                        style: textTheme.headlineLarge?.copyWith(
                          fontSize: 16,
                          height: 1.42,
                          color: warnaTeks,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}