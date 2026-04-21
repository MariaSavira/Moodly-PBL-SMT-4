import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:moodly/pages/private_diary/month_selection_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moodly/pages/pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MoodlyApp());
}

class MoodlyApp extends StatelessWidget {
  const MoodlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Moodly',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
        scaffoldBackgroundColor: const Color(0xFFF8F6FF),
        useMaterial3: true,

        textTheme: GoogleFonts.fredokaTextTheme().copyWith(
          // TITLE
          headlineLarge: GoogleFonts.fredoka(
            fontSize: 24,
            fontWeight: FontWeight.w600, // semi-bold
            color: Colors.black,
          ),

          // SUB TITLE
          titleMedium: GoogleFonts.fredoka(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),

          // NORMAL TEXT (Open Sans)
          bodyMedium: GoogleFonts.openSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),

          // NORMAL TEXT 2 (Fredoka)
          bodySmall: GoogleFonts.fredoka(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),

          // BUTTON TEXT 1 (Open Sans)
          labelLarge: GoogleFonts.openSans(
            fontSize: 14,
            fontWeight: FontWeight.w600, // semi-bold
            color: const Color.fromARGB(255, 255, 255, 255),
          ),
        ),
      ),
      home: const MainMenuPage(),
    );
  }
}

class MainMenuPage extends StatelessWidget {
  const MainMenuPage({super.key});

  final List<_FeatureItem> features = const [
    _FeatureItem(
      title: 'Login & Register',
      subtitle: 'Demo autentikasi pengguna',
      icon: Icons.login_rounded,
      page: AuthPage(),
    ),
    _FeatureItem(
      title: 'Mood Harian',
      subtitle: 'Input mood harian pengguna',
      icon: Icons.emoji_emotions_rounded,
      page: MoodPage(),
    ),
    _FeatureItem(
      title: 'Diary Online',
      subtitle: 'Catatan pribadi pengguna',
      icon: Icons.menu_book_rounded,
      page: DiaryPage(),
    ),
    _FeatureItem(
      title: 'Statistik Mood',
      subtitle: 'Lihat perkembangan mood',
      icon: Icons.bar_chart_rounded,
      page: StatisticPage(),
    ),
    _FeatureItem(
      title: 'Afirmasi Harian',
      subtitle: 'Pesan positif harian',
      icon: Icons.auto_awesome_rounded,
      page: AffirmationPage(),
    ),
    _FeatureItem(
      title: 'Curhat Anonim',
      subtitle: 'Ruang berbagi anonim',
      icon: Icons.forum_rounded,
      page: HomeChatAnonim(),
    ),
    _FeatureItem(
      title: 'Bantuan Darurat',
      subtitle: 'Hotline dan dukungan awal',
      icon: Icons.warning_amber_rounded,
      page: EmergencyPage(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Moodly Progress Demo'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Fitur yang sudah/disediakan untuk demo',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Klik salah satu menu untuk melihat progres tiap fitur.',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                itemCount: features.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.05,
                ),
                itemBuilder: (context, index) {
                  final item = features[index];
                  return InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => item.page),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            blurRadius: 10,
                            color: Color(0x14000000),
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.purple.shade50,
                            child: Icon(
                              item.icon,
                              color: Colors.purple,
                              size: 28,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            item.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.subtitle,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget page;

  const _FeatureItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.page,
  });
}

class DemoPageTemplate extends StatelessWidget {
  final String title;
  final IconData icon;
  final String description;
  final List<String> progressItems;
  final void Function(int index, String title)? onProgressTap; // ✅ TAMBAH

  const DemoPageTemplate({
    super.key,
    required this.title,
    required this.icon,
    required this.description,
    required this.progressItems,
    this.onProgressTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), backgroundColor: Colors.transparent),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.purple.shade50,
                    child: Icon(icon, size: 34, color: Colors.purple),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: progressItems.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 0,
                    color: Colors.white,
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: const Icon(Icons.check_circle_outline_rounded),
                      title: Text(progressItems[index]),
                      onTap: onProgressTap != null
                          ? () => onProgressTap!(index, progressItems[index])
                          : null,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const DemoPageTemplate(
      title: 'Login & Register',
      icon: Icons.login_rounded,
      description: 'Halaman demo untuk autentikasi pengguna Moodly.',
      progressItems: [
        'UI login sederhana',
        'UI register sederhana',
        'Navigasi antar halaman auth',
        'Siap dihubungkan ke Firebase Auth',
      ],
    );
  }
}

class MoodPage extends StatelessWidget {
  const MoodPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const DemoPageTemplate(
      title: 'Mood Harian',
      icon: Icons.emoji_emotions_rounded,
      description: 'Fitur pencatatan mood harian pengguna.',
      progressItems: [
        'Pilih mood harian',
        'Tambahkan catatan singkat',
        'Simpan mood berdasarkan tanggal',
        'Nantinya terhubung ke statistik mood',
      ],
    );
  }
}

class DiaryPage extends StatelessWidget {
  const DiaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DemoPageTemplate(
      title: 'Diary Online',
      icon: Icons.menu_book_rounded,
      description: 'Fitur diary untuk refleksi diri pengguna.',
      progressItems: const [
        'Tulis diary harian',
        'Mode private/public',
        'Edit dan hapus diary',
        'Nantinya bisa tambah foto',
      ],
      onProgressTap: (index, title) {
        if (title == 'Mode private/public') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MonthSelectionPage()),
          );
        }
      },
    );
  }
}

class StatisticPage extends StatelessWidget {
  const StatisticPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const DemoPageTemplate(
      title: 'Statistik Mood',
      icon: Icons.bar_chart_rounded,
      description: 'Visualisasi perkembangan mood pengguna.',
      progressItems: [
        'Tampilan statistik mingguan/bulanan',
        'Placeholder grafik mood',
        'Ringkasan pola emosi',
        'Siap dihubungkan ke data mood',
      ],
    );
  }
}

class AffirmationPage extends StatelessWidget {
  const AffirmationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const DemoPageTemplate(
      title: 'Afirmasi Harian',
      icon: Icons.auto_awesome_rounded,
      description: 'Pesan positif untuk dukungan emosional harian.',
      progressItems: [
        'Tampilkan afirmasi harian',
        'Kategori afirmasi',
        'Simpan afirmasi favorit',
        'Bisa disesuaikan dengan mood pengguna',
      ],
    );
  }
}

class AnonymousPage extends StatelessWidget {
  const AnonymousPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const DemoPageTemplate(
      title: 'Curhat Anonim',
      icon: Icons.forum_rounded,
      description: 'Ruang berbagi cerita tanpa identitas.',
      progressItems: [
        'Tulis curhatan anonim',
        'Lihat curhatan pengguna lain',
        'Fitur report konten',
        'Moderasi admin di tahap berikutnya',
      ],
    );
  }
}

class EmergencyPage extends StatelessWidget {
  const EmergencyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const DemoPageTemplate(
      title: 'Bantuan Darurat',
      icon: Icons.warning_amber_rounded,
      description: 'Akses cepat ke dukungan awal dan hotline.',
      progressItems: [
        'Tombol darurat',
        'Popup dukungan emosional',
        'Daftar hotline bantuan',
        'Arahan ke layanan profesional',
      ],
    );
  }
}
