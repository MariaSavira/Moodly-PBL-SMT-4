import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

class AddDiaryPage extends StatefulWidget {
  const AddDiaryPage({super.key});

  @override
  State<AddDiaryPage> createState() => _AddDiaryPageState();
}

class _AddDiaryPageState extends State<AddDiaryPage> {
  final TextEditingController titleController = TextEditingController();
  final quill.QuillController _controller = quill.QuillController.basic();

  final ImagePicker _picker = ImagePicker();
  File? _image;

  bool isPressed = false;

  @override
  void dispose() {
    titleController.dispose();
    _controller.dispose();
    super.dispose();
  }

  /// ================= PICK IMAGE =================
  Future<void> pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source);

    if (picked != null) {
      setState(() {
        _image = File(picked.path);
      });
    }
  }

  /// ================= BOTTOM SHEET =================
  void showImageOption() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text("Galeri"),
                onTap: () {
                  Navigator.pop(context);
                  pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Kamera"),
                onTap: () {
                  Navigator.pop(context);
                  pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// ================= POPUP SAVE =================
  void showSaveOption() {
    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// PINK = PRIVATE
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  saveDiary(true);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8BBD0),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      "Private Diary",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),

              /// GREEN = PUBLIC
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  saveDiary(false);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Color(0xFFC8E6C9),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(20),
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      "Public Diary",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// ================= SAVE =================
  void saveDiary(bool isPrivate) {
    final title = titleController.text;
    final content = _controller.document.toPlainText();

    debugPrint("TITLE: $title");
    debugPrint("CONTENT: $content");
    debugPrint("PRIVATE: $isPrivate");

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isPrivate
              ? "Disimpan sebagai Private Diary"
              : "Disimpan sebagai Public Diary",
        ),
      ),
    );
  }

  /// ================= TOOLBAR BUTTON =================
  Widget buildButton(IconData icon, VoidCallback onTap) {
    return IconButton(icon: Icon(icon, size: 20), onPressed: onTap);
  }

  /// ================= UI =================
  @override
  Widget build(BuildContext context) {
    /// 🔥 DETEKSI KEYBOARD
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: const Color(0xFFDCE3C1),

      /// 🔥 FAB (SMART)
      floatingActionButton: isKeyboardOpen
          ? null
          : Padding(
              padding: const EdgeInsets.only(
                bottom: 70,
              ), // biar ga nutup toolbar
              child: GestureDetector(
                onTapDown: (_) => setState(() => isPressed = true),
                onTapUp: (_) {
                  setState(() => isPressed = false);
                  showSaveOption();
                },
                onTapCancel: () => setState(() => isPressed = false),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 55,
                  height: 55,
                  decoration: BoxDecoration(
                    color: isPressed
                        ? Colors.green.shade400
                        : const Color(0xFFF8BBD0),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 6,
                        color: Colors.black12,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.check, color: Colors.black),
                ),
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
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// IMAGE
              GestureDetector(
                onTap: showImageOption,
                child: Container(
                  width: double.infinity,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: _image != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.file(_image!, fit: BoxFit.cover),
                        )
                      : const Center(child: Icon(Icons.image, size: 40)),
                ),
              ),

              const SizedBox(height: 20),

              /// EDITOR
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
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
                        child: quill.QuillEditor.basic(controller: _controller),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              /// 🔥 TOOLBAR SCROLL
              Container(
                height: 55,
                decoration: BoxDecoration(
                  color: const Color(0xFFE9A7A7),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      buildButton(Icons.format_bold, () {
                        _controller.formatSelection(quill.Attribute.bold);
                      }),
                      buildButton(Icons.format_italic, () {
                        _controller.formatSelection(quill.Attribute.italic);
                      }),
                      buildButton(Icons.format_underline, () {
                        _controller.formatSelection(quill.Attribute.underline);
                      }),
                      buildButton(Icons.format_strikethrough, () {
                        _controller.formatSelection(
                          quill.Attribute.strikeThrough,
                        );
                      }),
                      buildButton(Icons.format_align_left, () {
                        _controller.formatSelection(
                          quill.Attribute.leftAlignment,
                        );
                      }),
                      buildButton(Icons.format_align_center, () {
                        _controller.formatSelection(
                          quill.Attribute.centerAlignment,
                        );
                      }),
                      buildButton(Icons.format_align_right, () {
                        _controller.formatSelection(
                          quill.Attribute.rightAlignment,
                        );
                      }),
                      buildButton(Icons.format_list_bulleted, () {
                        _controller.formatSelection(quill.Attribute.ul);
                      }),
                      buildButton(Icons.format_list_numbered, () {
                        _controller.formatSelection(quill.Attribute.ol);
                      }),
                      buildButton(Icons.format_indent_increase, () {
                        _controller.formatSelection(quill.Attribute.indentL1);
                      }),
                      buildButton(Icons.format_indent_decrease, () {
                        _controller.formatSelection(
                          quill.Attribute.clone(quill.Attribute.indent, 0),
                        );
                      }),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
