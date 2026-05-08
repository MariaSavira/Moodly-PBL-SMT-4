import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MoodInput extends StatefulWidget {
  final DateTime? selectedDate;

  const MoodInput({super.key, this.selectedDate});

  @override
  State<MoodInput> createState() => _MoodInputState();
}

class _MoodInputState extends State<MoodInput> {
  String? selectedMood;
  final TextEditingController _noteController = TextEditingController();
  bool _isSaving = false;

  static const String _documentId = 'BeZzql14Y8xGyoLUDb0L';

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

  String _getEmojiImagePath(String mood) {
    switch (mood) {
      case 'Senang': return 'assets/emoji/emoji_senang.png';
      case 'Netral': return 'assets/emoji/emoji_netral.png';
      case 'Sedih': return 'assets/emoji/emoji_sedih.png';
      case 'Marah': return 'assets/emoji/emoji_marah.png';
      default: return 'assets/emoji/emoji_netral.png';
    }
  }

  Color _getMoodCardColor(String mood) {
    switch (mood) {
      case 'Senang': return const Color(0xFFA8F4AB);
      case 'Netral': return const Color(0xFFFFECB3);
      case 'Sedih': return const Color(0xFFC8E6C9);
      case 'Marah': return const Color(0xFFEF9A9A);
      default: return Colors.white;
    }
  }

  Future<void> _saveMood({String? note}) async {
    if (selectedMood == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih mood terlebih dahulu!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final dateToSave = widget.selectedDate ?? DateTime.now();
    final dateKey = '${dateToSave.year}-${dateToSave.month.toString().padLeft(2, '0')}-${dateToSave.day.toString().padLeft(2, '0')}';

    setState(() => _isSaving = true);

    try {
      await FirebaseFirestore.instance
          .collection('moods')
          .doc(_documentId)
          .set({
        'entries.$dateKey': selectedMood,
        if (note != null && note.isNotEmpty) 'notes.$dateKey': note,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('mood_$dateKey', selectedMood!);
      if (note != null && note.isNotEmpty) {
        await prefs.setString('note_$dateKey', note);
      }

      print("✅ Mood saved to Firestore: $selectedMood on $dateKey");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Image.asset(
                  _getEmojiImagePath(selectedMood!),
                  width: 24,
                  height: 24,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Mood "$selectedMood" berhasil disimpan! ${note != null ? "+ Catatan" : ""}',
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

        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      print("❌ Error saving mood: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
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
              _saveMood();
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
              final note = _noteController.text.trim();
              Navigator.pop(context);
              _saveMood(note: note);
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
        actions: [
          if (_isSaving)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                ),
              ),
            ),
        ],
      ),
      body: _isSaving
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
            const SizedBox(height: 16),
            Text(
              'Menyimpan...',
              style: GoogleFonts.fredoka(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      )
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD1DB),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
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
                      top: -65,
                      right: -20,
                      child: Image.asset(
                        'assets/icons/login/image1.png',
                        width: 85,
                        height: 85,
                        fit: BoxFit.contain,
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
                            backgroundColor: const Color(0xFF7CB342),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey.shade400,
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
                          onPressed: selectedMood == null ? null : () => _saveMood(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7CB342),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey.shade400,
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
              ? [
            BoxShadow(
              color: Colors.green.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ]
              : [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              _getEmojiImagePath(moodValue),
              width: 80,
              height: 80,
              fit: BoxFit.contain,
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