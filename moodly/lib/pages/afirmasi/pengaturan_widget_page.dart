import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_widget/home_widget.dart';
import 'package:moodly/pages/afirmasi/cara_memasang_widget_page.dart';
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

  String previewCategory = 'Afirmasi';
  String previewQuote = '';

  final List<String> daftarWallpaper = [
    'assets/icon/images/bg_afirmasi_1.jpg',
    'assets/icon/images/bg_afirmasi_2.jpg',
    'assets/icon/images/bg_afirmasi_3.jpg',
    'assets/icon/images/bg_afirmasi_4.jpg',
    'assets/icon/images/bg_afirmasi_5.jpg',
  ];

  String wallpaperTerpilih = 'assets/icon/images/bg_afirmasi_1.jpg';

  @override
  void initState() {
    super.initState();
    _loadWidgetSettings();
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
      defaultValue: 'Afirmasi',
    );

    final quote = await HomeWidget.getWidgetData<String>(
      'previewQuote',
      defaultValue: '',
    );

    if (!mounted) return;

    setState(() {
      tampilkanKategori = savedShowCategory ?? tampilkanKategori;
      tampilkanQuote = savedShowQuote ?? tampilkanQuote;
      gunakanBackground = savedUseBackground ?? gunakanBackground;
      warnaTeks = savedTextColor != null ? Color(savedTextColor) : warnaTeks;
      wallpaperTerpilih = savedWallpaper ?? wallpaperTerpilih;

      previewCategory = category ?? 'Afirmasi';
      previewQuote = quote ?? '';
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

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 6),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: GoogleFonts.fredoka(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _settingTile({
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          title,
          style: GoogleFonts.openSans(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        subtitle: subtitle == null
            ? null
            : Text(
                subtitle,
                style: GoogleFonts.openSans(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
        trailing: trailing,
      ),
    );
  }

  Widget _colorDot(Color color, bool selected, Future<void> Function() onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? Colors.black87 : Colors.transparent,
            width: 2,
          ),
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
    child: Container(
      width: 58,
      height: 82,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? const Color(0xFF6E9550) : Colors.transparent,
          width: 3,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
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
    final shownPreviewQuote =
        previewQuote.trim().isNotEmpty ? previewQuote : 'Belum ada afirmasi';

    return Scaffold(
      backgroundColor: const Color(0xFFF1F4DE),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF1F4DE),
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
          'Pengaturan Widget',
          style: GoogleFonts.fredoka(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.black,
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
            _sectionTitle('Widget'),
            _settingTile(
              title: 'Tampilkan kategori',
              subtitle: 'Menampilkan label kategori di widget afirmasi',
              trailing: Switch(
                value: tampilkanKategori,
                activeColor: const Color(0xFF99D28F),
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
              title: 'Tampilkan isi afirmasi',
              subtitle: 'Menampilkan kutipan afirmasi di widget',
              trailing: Switch(
                value: tampilkanQuote,
                activeColor: const Color(0xFF99D28F),
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
              title: 'Gunakan background gambar',
              subtitle: 'Memakai latar belakang afirmasi pada widget',
              trailing: Switch(
                value: gunakanBackground,
                activeColor: const Color(0xFF99D28F),
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
            _sectionTitle('Wallpaper'),
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Wallpaper widget',
                    style: GoogleFonts.openSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _wallpaperItem(daftarWallpaper[0]),
                        const SizedBox(width: 10),
                        _wallpaperItem(daftarWallpaper[1]),
                        const SizedBox(width: 10),
                        _wallpaperItem(daftarWallpaper[2]),
                        const SizedBox(width: 10),
                        _wallpaperItem(daftarWallpaper[3]),
                        const SizedBox(width: 10),
                        _wallpaperItem(daftarWallpaper[4]),
                        const SizedBox(width: 10),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Warna teks',
                    style: GoogleFonts.openSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
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
            _sectionTitle('Preview'),
            Container(
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: gunakanBackground
    ? DecorationImage(
        image: AssetImage(wallpaperTerpilih),
        fit: BoxFit.cover,
      )
    : null,
                color: gunakanBackground ? null : const Color(0xFF8C6A8E),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0x33000000),
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (tampilkanKategori)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0x80FFFFFF),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          previewCategory,
                          style: GoogleFonts.openSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    if (tampilkanKategori) const SizedBox(height: 16),
                    if (tampilkanQuote)
                      Text(
                        shownPreviewQuote,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.fredoka(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
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