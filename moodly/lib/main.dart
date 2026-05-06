import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'pages/admin/list_laporan_user_admin_page.dart';
// firebase
import 'package:moodly/pages/setting/settings_page.dart';

// firebase
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'firebase_options.dart';
import 'pages/afirmasi/afirmasi_page.dart';
import 'package:moodly/pages/private_diary/month_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moodly/pages/pages.dart';
import 'pages/splash_screen.dart';
import 'pages/mood/mood_year_calendar.dart';
import 'pages/mood/mood_analysis.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await MobileAds.instance.initialize();

  runApp(const MoodlyApp());
}

class MoodlyApp extends StatelessWidget {
  const MoodlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Moodly',

      localizationsDelegates: [
        quill.FlutterQuillLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      supportedLocales: const [Locale('en')],

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
        scaffoldBackgroundColor: const Color(0xFFF8F6FF),
        useMaterial3: true,
        textTheme: GoogleFonts.fredokaTextTheme().copyWith(
          headlineLarge: GoogleFonts.fredoka(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
          titleMedium: GoogleFonts.fredoka(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
          bodyMedium: GoogleFonts.openSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          bodySmall: GoogleFonts.fredoka(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          labelLarge: GoogleFonts.openSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color.fromARGB(255, 255, 255, 255),
          ),
        ),
      ),
      home: const ListLaporanUserAdminPage(),
    );
  }
}

class MainMenuPage extends StatelessWidget {
   MainMenuPage({super.key});

  final List<_FeatureItem> features = [
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
      title: 'OTP Verification',
      subtitle: 'Verifikasi kode OTP',
      icon: Icons.lock_clock,
      page: OtpVerificationPage(
        fullName: 'Test User',
        email: 'test@gmail.com',
        phoneNumber: '+6281234567890',
        password: '123456',
      ),
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
      page: MoodYearCalendar(),
    ),
    _FeatureItem(
      title: 'Diary Online',
      subtitle: 'Catatan pribadi pengguna',
      icon: Icons.menu_book_rounded,
      page: MonthPage(),
    ),
    _FeatureItem(
      title: 'Statistik Mood',
      subtitle: 'Lihat perkembangan mood',
      icon: Icons.bar_chart_rounded,
      page: MoodAnalysis(),
    ),
    _FeatureItem(
      title: 'Afirmasi Harian',
      subtitle: 'Pesan positif harian',
      icon: Icons.auto_awesome_rounded,
      page: AfirmasiPage(),
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
                            backgroundColor: Colors.purpleAccent,
                            child: Icon(
                              item.icon,
                              color: Colors.white,
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
                    backgroundColor: Colors.purpleAccent,
                    child: Icon(icon, size: 34, color: Colors.white),
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