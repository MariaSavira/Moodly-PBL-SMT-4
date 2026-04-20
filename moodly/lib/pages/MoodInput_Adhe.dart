import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MoodInput_Adhe extends StatefulWidget {
  const MoodInput_Adhe({super.key});

  @override
  State<MoodInput_Adhe> createState() => _MoodInput_AdheState();
}

class _MoodInput_AdheState extends State<MoodInput_Adhe> {
  String? selectedMood;
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _selectMood(String mood) {
    setState(() {
      selectedMood = mood;
    });
  }

  String _getEmojiForMood(String mood) {
    switch (mood) {
      case 'Senang': return '😊';
      case 'Netral': return '😐';
      case 'Sedih': return '😔';
      case 'Marah': return '😠';
      default: return '😐';
    }
  }

  Color _getMoodCardColor(String mood) {
    switch (mood) {
      case 'Senang': return const Color(0xFFCCFF90);
      case 'Netral': return const Color(0xFFFFECB3);
      case 'Sedih': return const Color(0xFFE0E0E0);
      case 'Marah': return const Color(0xFFEF9A9A);
      default: return Colors.white;
    }
  }

  Future<void> _saveMood({bool withNote = false}) async {
    if (selectedMood == null) return;

    await Future.delayed(const Duration(milliseconds: 300));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Text(_getEmojiForMood(selectedMood!), style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Mood "$selectedMood" berhasil disimpan! ${withNote ? "+ Catatan" : ""}',
                  style: GoogleFonts.openSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showAddNoteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          '✍️ Tambahkan Catatan',
          style: GoogleFonts.fredoka(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Apa yang membuatmu merasa $selectedMood hari ini?',
              style: GoogleFonts.fredoka(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _noteController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Tulis perasaanmu disini...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.all(12),
              ),
              style: GoogleFonts.openSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _noteController.clear();
              Navigator.pop(context);
              _saveMood(withNote: false);
            },
            child: Text(
              'Lewati',
              style: GoogleFonts.openSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.purple,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _saveMood(withNote: true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Simpan',
              style: GoogleFonts.openSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBE7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Mood Entry',
          style: GoogleFonts.fredoka(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔷 BOX PINK ATAS (Tetap)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDDDE3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bagaimana perasaanmu\nhari ini?',
                          style: GoogleFonts.fredoka(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Luangkan waktu sejenak untuk mengecek diri\nsendiri dan merasakan kedamaian.',
                          style: GoogleFonts.fredoka(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.pink.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.favorite_rounded, color: Colors.pink, size: 24),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFC5E1A5),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Grid Mood Selection
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.9,
                      children: [
                        _buildMoodCard('Senang', 'Senang'),
                        _buildMoodCard('Netral', 'Netral'),
                        _buildMoodCard('Sedih', 'Sedih'),
                        _buildMoodCard('Marah', 'Marah'),
                      ],
                    ),

                    const SizedBox(height: 32),

                    Text(
                      'Apakah kamu ingin cerita apa\nyang ada di balik perasaanmu\nhari ini?',
                      textAlign: TextAlign.left,
                      style: GoogleFonts.fredoka(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 32),

                    Center(
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: selectedMood == null ? null : () => _showAddNoteDialog(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF81C784),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey.shade300,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: Text(
                            'Ya',
                            style: GoogleFonts.openSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Center(
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: selectedMood == null ? null : () => _saveMood(withNote: false),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF81C784),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey.shade300,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: Text(
                            'Tidak',
                            style: GoogleFonts.openSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoodCard(String label, String moodValue) {
    final isSelected = selectedMood == moodValue;
    return GestureDetector(
      onTap: () => _selectMood(moodValue),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: _getMoodCardColor(moodValue),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.green.shade700 : Colors.transparent,
            width: 3,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))]
              : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _getEmojiForMood(moodValue),
              style: const TextStyle(fontSize: 52),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.fredoka(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.green.shade800 : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}