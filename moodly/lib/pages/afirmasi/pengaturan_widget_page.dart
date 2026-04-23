import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moodly/pages/afirmasi/cara_memasang_widget_page.dart';

class PengaturanWidgetPage extends StatefulWidget {
  const PengaturanWidgetPage({super.key});

  @override
  State<PengaturanWidgetPage> createState() => _PengaturanWidgetPageState();
}

class _PengaturanWidgetPageState extends State<PengaturanWidgetPage> {
  bool tampilkanKategori = true;
  bool tampilkanQuote = true;
  bool gunakanBackground = true;
  bool autoRefresh = false;

  double ukuranWidget = 1.0;

  Color warnaTeks = Colors.white;
  Color warnaOverlay = const Color(0x33000000);

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
                  fontWeight: FontWeight.w400,
                  color: Colors.black54,
                ),
              ),
        trailing: trailing,
      ),
    );
  }

  Widget _colorDot(Color color, bool selected, VoidCallback onTap) {
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
                onChanged: (value) {
                  setState(() {
                    tampilkanKategori = value;
                  });
                },
              ),
            ),
            _settingTile(
              title: 'Tampilkan isi afirmasi',
              subtitle: 'Menampilkan kutipan afirmasi di widget',
              trailing: Switch(
                value: tampilkanQuote,
                activeColor: const Color(0xFF99D28F),
                onChanged: (value) {
                  setState(() {
                    tampilkanQuote = value;
                  });
                },
              ),
            ),
            _settingTile(
              title: 'Gunakan background gambar',
              subtitle: 'Memakai latar belakang afirmasi pada widget',
              trailing: Switch(
                value: gunakanBackground,
                activeColor: const Color(0xFF99D28F),
                onChanged: (value) {
                  setState(() {
                    gunakanBackground = value;
                  });
                },
              ),
            ),
            _settingTile(
              title: 'Refresh otomatis',
              subtitle: 'Widget mengganti afirmasi secara berkala',
              trailing: Switch(
                value: autoRefresh,
                activeColor: const Color(0xFF99D28F),
                onChanged: (value) {
                  setState(() {
                    autoRefresh = value;
                  });
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
                    onChanged: (value) {
                      setState(() {
                        ukuranWidget = value;
                      });
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
                    'Warna teks',
                    style: GoogleFonts.openSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _colorDot(Colors.white, warnaTeks == Colors.white, () {
                        setState(() {
                          warnaTeks = Colors.white;
                        });
                      }),
                      const SizedBox(width: 12),
                      _colorDot(Colors.black87, warnaTeks == Colors.black87, () {
                        setState(() {
                          warnaTeks = Colors.black87;
                        });
                      }),
                      const SizedBox(width: 12),
                      _colorDot(
                        const Color(0xFFFFF1F1),
                        warnaTeks == const Color(0xFFFFF1F1),
                        () {
                          setState(() {
                            warnaTeks = const Color(0xFFFFF1F1);
                          });
                        },
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
                        () {
                          setState(() {
                            warnaOverlay = const Color(0x1A000000);
                          });
                        },
                      ),
                      const SizedBox(width: 12),
                      _colorDot(
                        const Color(0x33000000),
                        warnaOverlay == const Color(0x33000000),
                        () {
                          setState(() {
                            warnaOverlay = const Color(0x33000000);
                          });
                        },
                      ),
                      const SizedBox(width: 12),
                      _colorDot(
                        const Color(0x4D000000),
                        warnaOverlay == const Color(0x4D000000),
                        () {
                          setState(() {
                            warnaOverlay = const Color(0x4D000000);
                          });
                        },
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
                image: const DecorationImage(
                  image: AssetImage('assets/icon/images/bg_afirmasi.jpg'),
                  fit: BoxFit.cover,
                ),
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