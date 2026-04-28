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

  /// ================= TOOLBAR BUTTON =================
  Widget buildButton(IconData icon, VoidCallback onTap) {
    return IconButton(icon: Icon(icon, size: 20), onPressed: onTap);
  }

  /// ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDCE3C1),

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

              /// EDITOR AREA
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      /// TITLE
                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          hintText: "Judul",
                          border: InputBorder.none,
                        ),
                      ),

                      const Divider(),

                      /// EDITOR
                      Expanded(
                        child: quill.QuillEditor.basic(controller: _controller),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              /// 🔥 CUSTOM TOOLBAR (SCROLL)
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
                      /// BOLD
                      buildButton(Icons.format_bold, () {
                        _controller.formatSelection(quill.Attribute.bold);
                      }),

                      /// ITALIC
                      buildButton(Icons.format_italic, () {
                        _controller.formatSelection(quill.Attribute.italic);
                      }),

                      /// UNDERLINE
                      buildButton(Icons.format_underline, () {
                        _controller.formatSelection(quill.Attribute.underline);
                      }),

                      /// STRIKE
                      buildButton(Icons.format_strikethrough, () {
                        _controller.formatSelection(
                          quill.Attribute.strikeThrough,
                        );
                      }),

                      /// ALIGN LEFT
                      buildButton(Icons.format_align_left, () {
                        _controller.formatSelection(
                          quill.Attribute.leftAlignment,
                        );
                      }),

                      /// ALIGN CENTER
                      buildButton(Icons.format_align_center, () {
                        _controller.formatSelection(
                          quill.Attribute.centerAlignment,
                        );
                      }),

                      /// ALIGN RIGHT
                      buildButton(Icons.format_align_right, () {
                        _controller.formatSelection(
                          quill.Attribute.rightAlignment,
                        );
                      }),

                      /// BULLET LIST
                      buildButton(Icons.format_list_bulleted, () {
                        _controller.formatSelection(quill.Attribute.ul);
                      }),

                      /// NUMBER LIST
                      buildButton(Icons.format_list_numbered, () {
                        _controller.formatSelection(quill.Attribute.ol);
                      }),

                      /// INDENT +
                      buildButton(Icons.format_indent_increase, () {
                        _controller.formatSelection(quill.Attribute.indentL1);
                      }),

                      /// INDENT -
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
