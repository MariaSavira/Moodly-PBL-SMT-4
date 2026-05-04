import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_widget/home_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:moodly/pages/afirmasi/cara_memasang_widget_page.dart';
import 'package:moodly/pages/afirmasi/widgets/cute_top_popup.dart';
import 'package:moodly/services/afirmasi/widget_settings_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PengaturanWidgetPage extends StatefulWidget {
  const PengaturanWidgetPage({super.key});

  @override
  State<PengaturanWidgetPage> createState() => _PengaturanWidgetPageState();
}

class _PengaturanWidgetPageState extends State<PengaturanWidgetPage> {
  static const String _customWallpaperPathKey = 'custom_wallpaper_path';
  static const String _useCustomWallpaperKey = 'use_custom_wallpaper';

  final ImagePicker _imagePicker = ImagePicker();

  bool tampilkanKategori = true;
  bool tampilkanQuote = true;
  bool gunakanBackground = true;
  bool autoRefresh = false;

  double ukuranWidget = 1.0;

  Color warnaTeks = Colors.white;
  Color warnaOverlay = const Color(0x33000000);

  bool isPremiumUser = true;

  String? customWallpaperPath;
  bool useCustomWallpaper = false;

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
    final savedAutoRefresh = await WidgetSettingsService.getBool(
      WidgetSettingsService.autoRefreshKey,
    );
    final savedScale = await WidgetSettingsService.getDouble(
      WidgetSettingsService.widgetScaleKey,
    );
    final savedTextColor = await WidgetSettingsService.getInt(
      WidgetSettingsService.textColorKey,
    );
    final savedOverlayColor = await WidgetSettingsService.getInt(
      WidgetSettingsService.overlayColorKey,
    );
    final savedWallpaper = await WidgetSettingsService.getString(
      WidgetSettingsService.selectedWallpaperKey,
    );
    final savedCustomWallpaperPath = await WidgetSettingsService.getString(
      WidgetSettingsService.customWallpaperPathKey,
    );
    final savedUseCustomWallpaper = await WidgetSettingsService.getBool(
      WidgetSettingsService.useCustomWallpaperKey,
    );

    if (!mounted) return;

    setState(() {
      tampilkanKategori = savedShowCategory ?? tampilkanKategori;
      tampilkanQuote = savedShowQuote ?? tampilkanQuote;
      gunakanBackground = savedUseBackground ?? gunakanBackground;
      autoRefresh = savedAutoRefresh ?? autoRefresh;
      ukuranWidget = savedScale ?? ukuranWidget;
      warnaTeks = savedTextColor != null ? Color(savedTextColor) : warnaTeks;
      warnaOverlay =
          savedOverlayColor != null ? Color(savedOverlayColor) : warnaOverlay;
      wallpaperTerpilih = savedWallpaper ?? wallpaperTerpilih;
      customWallpaperPath = savedCustomWallpaperPath;
      useCustomWallpaper = savedCustomWallpaperPath != null &&
          (savedUseCustomWallpaper ?? false);
    });

    await _updateHomeWidget();
  }

  Future<void> _updateHomeWidget() async {
    await HomeWidget.saveWidgetData<bool>('showCategory', tampilkanKategori);
    await HomeWidget.saveWidgetData<bool>('showQuote', tampilkanQuote);
    await HomeWidget.saveWidgetData<bool>('useBackground', gunakanBackground);
    await HomeWidget.saveWidgetData<bool>('autoRefresh', autoRefresh);

    await HomeWidget.saveWidgetData<double>('widgetScale', ukuranWidget);
    await HomeWidget.saveWidgetData<int>('textColor', warnaTeks.value);
    await HomeWidget.saveWidgetData<int>('overlayColor', warnaOverlay.value);

    await HomeWidget.saveWidgetData<String>(
      'selectedWallpaper',
      wallpaperTerpilih,
    );

    if (customWallpaperPath != null) {
      await HomeWidget.saveWidgetData<String>(
        'customWallpaperPath',
        customWallpaperPath!,
      );
    }

    await HomeWidget.saveWidgetData<bool>(
      'useCustomWallpaper',
      useCustomWallpaper,
    );

    await HomeWidget.saveWidgetData<String>(
      'previewCategory',
      'Kesehatan Mental',
    );

    await HomeWidget.saveWidgetData<String>(
      'previewQuote',
      'Aku boleh beristirahat tanpa merasa bersalah.',
    );

    await HomeWidget.updateWidget(
      androidName: 'MoodlyWidgetProvider',
    );
  }

  Future<void> _saveCustomWallpaper() async {
    final prefs = await SharedPreferences.getInstance();

    if (customWallpaperPath != null) {
      await prefs.setString(_customWallpaperPathKey, customWallpaperPath!);
      await WidgetSettingsService.saveString(
        WidgetSettingsService.customWallpaperPathKey,
        customWallpaperPath!,
      );
    }

    await prefs.setBool(_useCustomWallpaperKey, useCustomWallpaper);
    await WidgetSettingsService.saveBool(
      WidgetSettingsService.useCustomWallpaperKey,
      useCustomWallpaper,
    );

    await _updateHomeWidget();
  }

  Future<void> _pickCustomPhoto() async {
    if (!isPremiumUser) {
      _showPremiumDialog();
      return;
    }

    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      final file = File(pickedFile.path);

      if (!file.existsSync()) {
        if (!mounted) return;
        showCuteTopPopup(
          context,
          title: 'File tidak ditemukan',
          message: 'Foto tidak bisa diakses',
          type: CutePopupType.error,
        );
        return;
      }

      setState(() {
        customWallpaperPath = file.path;
        useCustomWallpaper = true;
      });

      await _saveCustomWallpaper();

      if (!mounted) return;
      showCuteTopPopup(
        context,
        title: 'Wallpaper diperbarui',
        message: 'Foto sendiri berhasil dipakai untuk wallpaper widget',
        type: CutePopupType.success,
      );
    } catch (_) {
      if (!mounted) return;
      showCuteTopPopup(
        context,
        title: 'Gagal memilih foto',
        message: 'Coba pilih foto lagi ya',
        type: CutePopupType.error,
      );
    }
  }

  ImageProvider _previewImageProvider() {
    if (useCustomWallpaper &&
        customWallpaperPath != null &&
        File(customWallpaperPath!).existsSync()) {
      return FileImage(File(customWallpaperPath!));
    }

    return AssetImage(wallpaperTerpilih);
  }

  void _showCaraPasangWidget() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CaraMemasangWidgetPage(),
      ),
    );
  }

  void _showPremiumDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: const Color(0xFFF4EEF2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Image.asset(
                      'assets/icons/crown.png',
                      width: 28,
                      height: 28,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.workspace_premium_rounded,
                        size: 28,
                        color: Color(0xFF8A7A8C),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Fitur Premium',
                      style: GoogleFonts.fredoka(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  'Fitur tambah foto sendiri untuk wallpaper widget hanya tersedia untuk pengguna premium.',
                  style: GoogleFonts.openSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF9B9B9B),
                      ),
                      child: Text(
                        'Nanti',
                        style: GoogleFonts.openSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF9B9B9B),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          showCuteTopPopup(
                            this.context,
                            title: 'Segera hadir',
                            message: 'Halaman upgrade premium akan ditambahkan',
                            type: CutePopupType.info,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF99D28F),
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shadowColor: Colors.black26,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          'Upgrade',
                          style: GoogleFonts.openSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
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
                  fontWeight: FontWeight.w400,
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
    final bool isSelected = !useCustomWallpaper && wallpaperTerpilih == path;

    return GestureDetector(
      onTap: () async {
        setState(() {
          wallpaperTerpilih = path;
          useCustomWallpaper = false;
        });

        await WidgetSettingsService.saveString(
          WidgetSettingsService.selectedWallpaperKey,
          path,
        );

        await WidgetSettingsService.saveBool(
          WidgetSettingsService.useCustomWallpaperKey,
          false,
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

  Widget _customPhotoItem() {
    final bool hasCustomPhoto =
        customWallpaperPath != null && File(customWallpaperPath!).existsSync();

    return GestureDetector(
      onTap: _pickCustomPhoto,
      child: Container(
        width: 58,
        height: 82,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: useCustomWallpaper
                ? const Color(0xFF6E9550)
                : const Color(0xFFD8D8D8),
            width: useCustomWallpaper ? 3 : 1.5,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: hasCustomPhoto
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(
                      File(customWallpaperPath!),
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      right: 4,
                      bottom: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE7B8),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'PRO',
                          style: GoogleFonts.openSans(
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.add_photo_alternate_outlined,
                      color: Colors.black54,
                      size: 22,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Foto\nSendiri',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.openSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE7B8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'PRO',
                        style: GoogleFonts.openSans(
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
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

  Future<void> _saveOverlayColor(Color color) async {
    setState(() {
      warnaOverlay = color;
    });

    await WidgetSettingsService.saveInt(
      WidgetSettingsService.overlayColorKey,
      color.value,
    );

    await _updateHomeWidget();
  }

  @override
  Widget build(BuildContext context) {
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
            _settingTile(
              title: 'Refresh otomatis',
              subtitle: 'Widget mengganti afirmasi secara berkala',
              trailing: Switch(
                value: autoRefresh,
                activeColor: const Color(0xFF99D28F),
                onChanged: (value) async {
                  setState(() {
                    autoRefresh = value;
                  });

                  await WidgetSettingsService.saveBool(
                    WidgetSettingsService.autoRefreshKey,
                    value,
                  );

                  await _updateHomeWidget();
                },
              ),
            ),
            const SizedBox(height: 8),
            _sectionTitle('Kustom tampilan'),
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
                    'Ukuran widget',
                    style: GoogleFonts.openSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Slider(
                    value: ukuranWidget,
                    min: 0.8,
                    max: 1.3,
                    divisions: 5,
                    activeColor: const Color(0xFF99D28F),
                    onChanged: (value) async {
                      setState(() {
                        ukuranWidget = value;
                      });

                      await WidgetSettingsService.saveDouble(
                        WidgetSettingsService.widgetScaleKey,
                        value,
                      );

                      await _updateHomeWidget();
                    },
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
                        _customPhotoItem(),
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
                    'Overlay background',
                    style: GoogleFonts.openSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _colorDot(
                        const Color(0x1A000000),
                        warnaOverlay == const Color(0x1A000000),
                        () => _saveOverlayColor(const Color(0x1A000000)),
                      ),
                      const SizedBox(width: 12),
                      _colorDot(
                        const Color(0x33000000),
                        warnaOverlay == const Color(0x33000000),
                        () => _saveOverlayColor(const Color(0x33000000)),
                      ),
                      const SizedBox(width: 12),
                      _colorDot(
                        const Color(0x4D000000),
                        warnaOverlay == const Color(0x4D000000),
                        () => _saveOverlayColor(const Color(0x4D000000)),
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
                        image: _previewImageProvider(),
                        fit: BoxFit.cover,
                      )
                    : null,
                color: gunakanBackground ? null : const Color(0xFF8C6A8E),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: warnaOverlay,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(16),
                child: Transform.scale(
                  scale: ukuranWidget,
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
                            'Kesehatan Mental',
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
                          'Aku boleh beristirahat tanpa merasa bersalah.',
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
            ),
          ],
        ),
      ),
    );
  }
}