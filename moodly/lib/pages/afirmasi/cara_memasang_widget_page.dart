import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CaraMemasangWidgetPage extends StatelessWidget {
  const CaraMemasangWidgetPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F4DE),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.black,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Cara Memasang\nwidget',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.fredoka(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          height: 1.0,
                          color: const Color(0xFF2F2F2F),
                        ),
                      ),
                    ),
                  ),
                  Image.asset(
                    'assets/icon/images/brain_mascot_tutorial.png',
                    width: 56,
                    height: 56,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const SizedBox(
                      width: 56,
                      height: 56,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              const _StepItem(
                imagePath: 'assets/icon/images/tutorial_step1.png',
                stepTitle: 'Step 1',
                description: 'Tekan dan tahan layar utama\n(Home Screen)',
                imageWidth: 145,
                imageHeight: 95,
              ),
              const SizedBox(height: 49),

              const _StepItem(
                imagePath: 'assets/icon/images/tutorial_step2.png',
                stepTitle: 'Step 2',
                description: 'Pilih menu “Widget”.',
                imageWidth: 145,
                imageHeight: 119,
              ),
              const SizedBox(height: 49),

              const _StepItem(
                imagePath: 'assets/icon/images/tutorial_step3.png',
                stepTitle: 'Step 3',
                description:
                    'Cari dan pilih widget Moodly\nyang ingin digunakan.',
                imageWidth: 145,
                imageHeight: 118,
              ),
              const SizedBox(height: 49),

              const _StepItem(
                imagePath: 'assets/icon/images/tutorial_step4.png',
                stepTitle: 'Step 4',
                description: 'Geser widget ke layar utama,\nlalu lepaskan.',
                imageWidth: 145,
                imageHeight: 146,
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  final String imagePath;
  final String stepTitle;
  final String description;
  final double imageWidth;
  final double imageHeight;

  const _StepItem({
    required this.imagePath,
    required this.stepTitle,
    required this.description,
    required this.imageWidth,
    required this.imageHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: imageWidth,
          height: imageHeight,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: const Color(0xFFE8E3EA),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.image_outlined,
                  color: Colors.grey,
                  size: 30,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stepTitle,
                  style: GoogleFonts.fredoka(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2F2F2F),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: GoogleFonts.openSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                    color: const Color(0xFF2F2F2F),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}