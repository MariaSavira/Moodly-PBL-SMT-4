import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:permission_handler/permission_handler.dart';

import '../../services/firestore_diary_service.dart';
import '../../core/styles/moodly_colors.dart';

class AddDiaryPage extends StatefulWidget {
  const AddDiaryPage({super.key});

  @override
  State<AddDiaryPage> createState() => _AddDiaryPageState();
}

class _AddDiaryPageState extends State<AddDiaryPage> {
  final TextEditingController titleController = TextEditingController();

  final quill.QuillController _controller = quill.QuillController.basic();

  final FocusNode _focusNode = FocusNode();

  final ScrollController _scrollController = ScrollController();

  final ImagePicker _picker = ImagePicker();

  File? _image;

  bool isPressed = false;

  DateTime selectedDate = DateTime.now();

  @override
  void dispose() {
    titleController.dispose();
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();

    super.dispose();
  }

  /// ================= PERMISSION =================
  Future<void> requestPermission() async {
    await Permission.camera.request();
    await Permission.photos.request();
  }

  /// ================= PICK IMAGE =================
  Future<void> pickImage() async {
    await requestPermission();

    showModalBottomSheet(
      context: context,

      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera),

              title: const Text("Kamera"),

              onTap: () async {
                Navigator.pop(context);

                final picked = await _picker.pickImage(
                  source: ImageSource.camera,
                );

                await _cropImage(picked);
              },
            ),

            ListTile(
              leading: const Icon(Icons.photo),

              title: const Text("Galeri"),

              onTap: () async {
                Navigator.pop(context);

                final picked = await _picker.pickImage(
                  source: ImageSource.gallery,
                );

                await _cropImage(picked);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// ================= CROP IMAGE =================
  Future<void> _cropImage(XFile? picked) async {
    if (picked == null) return;

    try {
      final cropped = await ImageCropper().cropImage(
        sourcePath: picked.path,

        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Atur Gambar',
            toolbarColor: Colors.green,
            toolbarWidgetColor: Colors.white,
          ),

          IOSUiSettings(title: 'Atur Gambar'),
        ],
      );

      if (cropped != null) {
        setState(() {
          _image = File(cropped.path);
        });
      }
    } catch (e) {
      debugPrint("Crop error: $e");
    }
  }

  /// ================= SAVE DIARY =================
  Future<void> saveDiary(bool isPublic) async {
    final title = titleController.text.trim();

    final content = _controller.document.toPlainText().trim();

    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Judul dan isi wajib diisi")),
      );

      return;
    }

    final monthList = [
      "JAN",
      "FEB",
      "MAR",
      "APR",
      "MEI",
      "JUN",
      "JUL",
      "AGS",
      "SEP",
      "OKT",
      "NOV",
      "DES",
    ];

    await FirestoreDiaryService.addDiary(
      title: title,
      content: content,

      /// DATE
      time: "${selectedDate.hour}:${selectedDate.minute}",

      date: selectedDate.day,

      month: monthList[selectedDate.month - 1],

      year: selectedDate.year,

      /// TYPE
      isPublic: isPublic,
    );

    if (!mounted) return;

    Navigator.pop(context);
  }

  /// ================= SAVE OPTIONS =================
  void showSaveOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: MoodlyColors.bgLight,

      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),

      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),

          child: Column(
            mainAxisSize: MainAxisSize.min,

            children: [
              Text(
                "Simpan Diary",

                style: Theme.of(context).textTheme.titleMedium,
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        Navigator.pop(context);

                        await saveDiary(false);
                      },

                      child: Container(
                        padding: const EdgeInsets.all(16),

                        decoration: BoxDecoration(
                          color: MoodlyColors.pinkAccent,

                          borderRadius: BorderRadius.circular(20),
                        ),

                        child: const Column(
                          children: [
                            Icon(Icons.lock),

                            SizedBox(height: 5),

                            Text("Private"),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        Navigator.pop(context);

                        await saveDiary(true);
                      },

                      child: Container(
                        padding: const EdgeInsets.all(16),

                        decoration: BoxDecoration(
                          color: MoodlyColors.greenLight,

                          borderRadius: BorderRadius.circular(20),
                        ),

                        child: const Column(
                          children: [
                            Icon(Icons.public),

                            SizedBox(height: 5),

                            Text("Public"),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  /// ================= DATE PICKER =================
  Future<void> pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );

    if (date != null) {
      setState(() {
        selectedDate = date;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: MoodlyColors.bgLight,

      floatingActionButton: isKeyboardOpen
          ? null
          : GestureDetector(
              onTapDown: (_) => setState(() {
                isPressed = true;
              }),

              onTapUp: (_) {
                setState(() {
                  isPressed = false;
                });

                showSaveOptions();
              },

              onTapCancel: () => setState(() {
                isPressed = false;
              }),

              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),

                width: 55,
                height: 55,

                decoration: BoxDecoration(
                  color: isPressed
                      ? MoodlyColors.green
                      : MoodlyColors.pinkAccent,

                  borderRadius: BorderRadius.circular(18),
                ),

                child: const Icon(Icons.check),
              ),
            ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),

          child: Column(
            children: [
              const SizedBox(height: 10),

              /// HEADER
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),

                    child: const Icon(Icons.arrow_back),
                  ),

                  const SizedBox(width: 10),

                  Text(
                    "Buat Diary",

                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),

              const SizedBox(height: 15),

              /// DATE PICKER
              Align(
                alignment: Alignment.centerLeft,

                child: TextButton.icon(
                  onPressed: pickDate,

                  icon: const Icon(Icons.calendar_today),

                  label: Text(
                    "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                  ),
                ),
              ),

              const SizedBox(height: 10),

              /// IMAGE
              GestureDetector(
                onTap: pickImage,

                child: Container(
                  height: 120,
                  width: double.infinity,

                  decoration: BoxDecoration(
                    color: Colors.grey[300],

                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: _image != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(20),

                          child: Image.file(_image!, fit: BoxFit.cover),
                        )
                      : const Center(child: Icon(Icons.image)),
                ),
              ),

              const SizedBox(height: 15),

              /// CONTENT
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(15),

                  decoration: BoxDecoration(
                    color: Colors.white,

                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: Column(
                    children: [
                      TextField(
                        controller: titleController,

                        decoration: const InputDecoration(
                          hintText: "Judul",

                          border: InputBorder.none,
                        ),
                      ),

                      const Divider(),

                      Expanded(
                        child: quill.QuillEditor.basic(
                          controller: _controller,

                          focusNode: _focusNode,

                          scrollController: _scrollController,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
