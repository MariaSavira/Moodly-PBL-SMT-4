import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'pages/admin/moderasi_admin.dart';
import 'pages/admin/list_laporan_user_admin_page.dart';
import 'pages/admin/list_ajuan_banding_admin_page.dart';

// firebase
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter/foundation.dart' show kIsWeb;

import 'firebase_options.dart';
import 'pages/onboarding_page.dart';
import 'pages/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (!kIsWeb) {
    await MobileAds.instance.initialize();
  }

  runApp(const MoodlyApp());
}

class MoodlyApp extends StatelessWidget {
  const MoodlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Moodly',
      localizationsDelegates: const [
        quill.FlutterQuillLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
      ],
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
            color: const Color.fromARGB(255, 255, 255, 255),
          ),
        ),
      ),
      home: const RootPage(),
      routes: {
      '/admin-moderasi': (context) => const ModerasiAdminPage(),
      '/admin-laporan': (context) => const ListLaporanUserAdminPage(),
      '/admin-banding': (context) => const ListAjuanBandingAdminPage(),
},
    );
    
  }
}

class RootPage extends StatelessWidget {
  const RootPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final user = snapshot.data;

        if (user == null) {
          return const OnboardingPage();
        }

        return const SplashScreenMoodly();
      },
    );
  }
}