import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

// pages
import 'package:moodly/pages/Login_page.dart';
import 'package:moodly/pages/register_page.dart';
import 'package:moodly/pages/Register_success_page.dart';
import 'package:moodly/pages/setting/settings_page.dart';

// firebase
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
      ),
      home: const MainMenuPage(),
    );
  }
}

class MainMenuPage extends StatelessWidget {
  const MainMenuPage({super.key});

  final List<_FeatureItem> features = const [
    _FeatureItem(
      title: 'Login',
      subtitle: 'Demo autentikasi login',
      icon: Icons.login_rounded,
      page: LoginPage(),
    ),
    _FeatureItem(
      title: 'Register',
      subtitle: 'Demo autentikasi register',
      icon: Icons.app_registration_rounded,
      page: RegisterPage(),
    ),
    _FeatureItem(
      title: 'Register Sukses',
      subtitle: 'Register Berhasil',
      icon: Icons.verified_rounded,
      page: RegisterSuccessPage(),
    ),

    // ✅ INI YANG KAMU BUTUH (SETTINGS)
    _FeatureItem(
      title: 'Settings',
      subtitle: 'Pengaturan aplikasi',
      icon: Icons.settings,
      page: SettingsPage(),
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
      page: AnonymousPage(),
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
              'Fitur yang tersedia',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Klik menu untuk membuka halaman.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: GridView.builder(
                itemCount: features.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
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
                        MaterialPageRoute(
                          builder: (_) => item.page,
                        ),
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
                          const SizedBox(height: 12),
                          Text(
                            item.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Expanded(
                            child: Text(
                              item.subtitle,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
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

// ================= DUMMY PAGES =================

class MoodPage extends StatelessWidget {
  const MoodPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Mood Page')),
    );
  }
}

class DiaryPage extends StatelessWidget {
  const DiaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Diary Page')),
    );
  }
}

class StatisticPage extends StatelessWidget {
  const StatisticPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Statistic Page')),
    );
  }
}

class AffirmationPage extends StatelessWidget {
  const AffirmationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Affirmation Page')),
    );
  }
}

class AnonymousPage extends StatelessWidget {
  const AnonymousPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Anonymous Page')),
    );
  }
}

class EmergencyPage extends StatelessWidget {
  const EmergencyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Emergency Page')),
    );
  }
}