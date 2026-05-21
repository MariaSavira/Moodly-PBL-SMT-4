import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_storage/firebase_storage.dart';

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

  /// MULTIPLE IMAGE
  List<File> _images = [];

  bool isPressed = false;

  bool isLoading = false;

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

    final pickedFiles = await _picker.pickMultiImage(imageQuality: 50);

    if (pickedFiles.isNotEmpty) {
      /// MAX 4 FOTO
      if (_images.length + pickedFiles.length > 4) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Maksimal 4 foto")));

        return;
      }

      setState(() {
        _images.addAll(pickedFiles.map((e) => File(e.path)));
      });
    }
  }

  /// ================= UPLOAD IMAGE =================
  Future<List<String>> uploadImages() async {
    final futures = _images.map((image) async {
      final fileName =
          "${DateTime.now().millisecondsSinceEpoch}_${image.path.split('/').last}";

      final ref = FirebaseStorage.instance
          .ref()
          .child("diary_images")
          .child(fileName);

      await ref.putFile(image);

      return await ref.getDownloadURL();
    }).toList();

    return await Future.wait(futures);
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

    setState(() {
      isLoading = true;
    });

    final imageUrls = await uploadImages();

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

      /// SAVE IMAGE URL
      images: imageUrls,

      /// DATE
      time: "${selectedDate.hour}:${selectedDate.minute}",

      date: selectedDate.day,

      month: monthList[selectedDate.month - 1],

      year: selectedDate.year,

      /// TYPE
      isPublic: isPublic,
    );

    setState(() {
      isLoading = false;
    });

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
      resizeToAvoidBottomInset: true,

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

                child: isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(12),

                        child: CircularProgressIndicator(),
                      )
                    : const Icon(Icons.check),
              ),
            ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),

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

                /// IMAGE GRID
                Container(
                  width: double.infinity,

                  padding: const EdgeInsets.all(10),

                  decoration: BoxDecoration(
                    color: Colors.grey[300],

                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: _images.isEmpty
                      ? GestureDetector(
                          onTap: pickImage,

                          child: const SizedBox(
                            height: 120,

                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,

                                children: [
                                  Icon(Icons.add_a_photo, size: 35),

                                  SizedBox(height: 8),

                                  Text("Tambah Foto"),
                                ],
                              ),
                            ),
                          ),
                        )
                      : GridView.builder(
                          shrinkWrap: true,

                          physics: const NeverScrollableScrollPhysics(),

                          itemCount: _images.length < 4
                              ? _images.length + 1
                              : _images.length,

                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                              ),

                          itemBuilder: (context, index) {
                            /// ADD BUTTON
                            if (index == _images.length && _images.length < 4) {
                              return GestureDetector(
                                onTap: pickImage,

                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white70,

                                    borderRadius: BorderRadius.circular(20),

                                    border: Border.all(
                                      color: Colors.grey.shade400,
                                    ),
                                  ),

                                  child: const Center(
                                    child: Icon(
                                      Icons.add,
                                      size: 40,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              );
                            }

                            return Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(20),

                                  child: Image.file(
                                    _images[index],
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),

                                Positioned(
                                  top: 5,
                                  right: 5,

                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _images.removeAt(index);
                                      });
                                    },

                                    child: Container(
                                      padding: const EdgeInsets.all(5),

                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),

                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                ),

                const SizedBox(height: 15),

                /// CONTENT
                Container(
                  height: MediaQuery.of(context).size.height * 0.45,

                  padding: const EdgeInsets.all(15),

                  decoration: BoxDecoration(
                    color: Colors.white,

                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: Column(
                    children: [
                      TextField(
                        controller: titleController,

                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),

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

                          config: const quill.QuillEditorConfig(
                            placeholder: "Apa yang kamu rasakan hari ini...",

                            customStyles: quill.DefaultStyles(
                              paragraph: quill.DefaultTextBlockStyle(
                                TextStyle(
                                  fontSize: 15,
                                  color: Colors.black87,
                                  height: 1.5,
                                ),

                                quill.HorizontalSpacing(0, 0),

                                quill.VerticalSpacing(0, 0),

                                quill.VerticalSpacing(0, 0),

                                null,
                              ),

                              placeHolder: quill.DefaultTextBlockStyle(
                                TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey,
                                  height: 1.5,
                                ),

                                quill.HorizontalSpacing(0, 0),

                                quill.VerticalSpacing(0, 0),

                                quill.VerticalSpacing(0, 0),

                                null,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
