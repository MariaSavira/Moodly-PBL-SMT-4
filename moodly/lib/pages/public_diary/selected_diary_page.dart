import 'package:flutter/material.dart';

import '../private_diary/month_page.dart';
import 'public_diary_page.dart';

class SelectedDiaryPage extends StatelessWidget {
  const SelectedDiaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9ECD7),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              const SizedBox(height: 30),

              /// TITLE + IMAGE
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: [
                  const Text(
                    "Diary Entries",

                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),

                  Image.asset(
                    'assets/icon/images/maskot_favorit.png',
                    width: 110,
                  ),
                ],
              ),

              const SizedBox(height: 40),

              /// DESCRIPTION
              const Center(
                child: Text(
                  "Mau berbagi cerita atau\nmenyimpannya sendiri ?\nKamu yang tentukan",

                  textAlign: TextAlign.center,

                  style: TextStyle(fontSize: 18, color: Colors.black87),
                ),
              ),

              const SizedBox(height: 50),

              /// PUBLIC BUTTON
              _buildButton(
                title: "Public Diary",

                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PublicDiaryPage()),
                  );
                },
              ),

              const SizedBox(height: 35),

              /// PRIVATE BUTTON
              _buildButton(
                title: "Private Diary",

                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MonthPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton({required String title, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,

      child: Container(
        height: 75,
        width: double.infinity,

        decoration: BoxDecoration(
          color: const Color(0xFFB7DCA5),

          borderRadius: BorderRadius.circular(24),

          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 20,
              offset: const Offset(0, 15),
            ),
          ],
        ),

        child: Center(
          child: Text(
            title,

            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
