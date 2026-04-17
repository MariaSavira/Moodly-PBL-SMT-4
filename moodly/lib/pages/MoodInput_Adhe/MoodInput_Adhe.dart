import 'package:flutter/material.dart';

void main() {
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        scaffoldBackgroundColor: const Color(0xFFEFF7E6),
        useMaterial3: true,
      ),
      home: const MoodEntryPage(),
    );
  }
}

class MoodEntryPage extends StatefulWidget {
  const MoodEntryPage({super.key});

  @override
  State<MoodEntryPage> createState() => _MoodEntryPageState();
}

class _MoodEntryPageState extends State<MoodEntryPage> {
  String? selectedMood;

  void _selectMood(String mood) {
    setState(() {
      selectedMood = mood;
    });
  }

  // Helper untuk mapping mood ke emoji unicode
  String _getEmojiForMood(String mood) {
    switch (mood) {
      case 'Senang':
        return '😊';
      case 'Netral':
        return '😐';
      case 'Sedih':
        return '😔';
      case 'Marah':
        return '😠';
      default:
        return '😐';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF7E6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Mood Entry',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //  Header Pink
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDDDE3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Bagaimana perasaanmu\nhari ini?',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Icon(Icons.favorite, color: Colors.pink, size: 32),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Luangkan waktu sejenak untuk mengecek diri\nsendiri dan merasakan kedamaian.',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 🟡 Grid Pilihan Mood (2x2)
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
                children: [
                  _buildMoodCard('Senang', 'Senang', const Color(0xFFD4F4D0), const Color(0xFFFFE082)),
                  _buildMoodCard('Netral', 'Netral', const Color(0xFFFBE8C2), const Color(0xFFFFE082)),
                  _buildMoodCard('Sedih', 'Sedih', const Color(0xFFDDEEE5), const Color(0xFFFFE082)),
                  _buildMoodCard('Marah', 'Marah', const Color(0xFFFAC2C2), const Color(0xFFFFCDD2)),
                ],
              ),

              const SizedBox(height: 32),

              //  Pertanyaan Bawah
              const Text(
                'Apakah kamu ingin cerita apa yang ada di balik perasaanmu hari ini?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              // ✅ Tombol Ya
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: selectedMood == null ? null : () {
                    print("User memilih Ya - Mood: $selectedMood");
                    // TODO: Navigasi ke halaman cerita/diary
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8BC34A),
                    disabledBackgroundColor: Colors.grey.shade300,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Ya',
                    style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ❌ Tombol Tidak
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: selectedMood == null ? null : () {
                    print("User memilih Tidak - Mood: $selectedMood");
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Mood $selectedMood berhasil disimpan!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7CB342),
                    disabledBackgroundColor: Colors.grey.shade300,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Tidak',
                    style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🎨 Widget Kartu Mood dengan Emoji Unicode
  Widget _buildMoodCard(String label, String moodValue, Color cardColor, Color emojiBgColor) {
    final isSelected = selectedMood == moodValue;

    return GestureDetector(
      onTap: () => _selectMood(moodValue),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? Colors.green.shade700 : Colors.transparent,
            width: 3,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Lingkaran Emoji
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: emojiBgColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  _getEmojiForMood(moodValue),
                  style: const TextStyle(fontSize: 45),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}