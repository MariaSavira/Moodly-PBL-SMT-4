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
  void initState() {
    super.initState();

    /// update toolbar realtime
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    titleController.dispose();
    _controller.dispose();
    super.dispose();
  }

  /// ================= IMAGE =================
  Future<void> pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source);

    if (picked != null) {
      setState(() {
        _image = File(picked.path);
      });
    }
  }

  /// ================= SAVE =================
  void saveDiary(bool isPrivate) {
    final title = titleController.text;
    final content = _controller.document.toPlainText();

    debugPrint("TITLE: $title");
    debugPrint("CONTENT: $content");
    debugPrint("PRIVATE: $isPrivate");
  }

  /// ================= 🔥 TOOLBAR BUTTON =================
  Widget buildButton(IconData icon, quill.Attribute attribute) {
    final currentStyle = _controller.getSelectionStyle();

    final isActive = currentStyle.attributes[attribute.key] == attribute.value;

    return GestureDetector(
      onTap: () {
        final selection = _controller.selection;

        final isCurrentlyActive =
            _controller.getSelectionStyle().attributes[attribute.key] ==
            attribute.value;

        final newAttr = isCurrentlyActive
            ? quill.Attribute.clone(attribute, null)
            : attribute;

        /// 🔥 FIX ALIGNMENT TANPA formatLine
        if (attribute.key == quill.Attribute.align.key) {
          final text = _controller.document.toPlainText();

          /// cari batas baris sekarang
          int start = selection.baseOffset;
          int end = selection.baseOffset;

          while (start > 0 && text[start - 1] != '\n') {
            start--;
          }

          while (end < text.length && text[end] != '\n') {
            end++;
          }

          _controller.formatText(start, end - start, newAttr);
        } else {
          /// INLINE STYLE
          _controller.formatSelection(newAttr);

          /// biar lanjut ngetik di mobile
          if (selection.isCollapsed) {
            _controller.formatText(selection.baseOffset, 0, newAttr);
          }
        }

        setState(() {});
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          /// 🔥 PINK MUDA (SESUAI FIGMA)
          color: isActive
              ? const Color(0xFFF8BBD0).withOpacity(0.6)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(icon, size: 20, color: Colors.black),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: const Color(0xFFDCE3C1),

      floatingActionButton: isKeyboardOpen
          ? null
          : Padding(
              padding: const EdgeInsets.only(bottom: 70),
              child: GestureDetector(
                onTapDown: (_) => setState(() => isPressed = true),
                onTapUp: (_) {
                  setState(() => isPressed = false);
                  saveDiary(true);
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
                onTap: () => pickImage(ImageSource.gallery),
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

              /// 🔥 TOOLBAR (TETAP)
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
                      buildButton(Icons.format_bold, quill.Attribute.bold),
                      buildButton(Icons.format_italic, quill.Attribute.italic),
                      buildButton(
                        Icons.format_underline,
                        quill.Attribute.underline,
                      ),
                      buildButton(
                        Icons.format_strikethrough,
                        quill.Attribute.strikeThrough,
                      ),
                      buildButton(
                        Icons.format_list_bulleted,
                        quill.Attribute.ul,
                      ),
                      buildButton(
                        Icons.format_list_numbered,
                        quill.Attribute.ol,
                      ),
                      buildButton(
                        Icons.format_align_left,
                        quill.Attribute.leftAlignment,
                      ),
                      buildButton(
                        Icons.format_align_center,
                        quill.Attribute.centerAlignment,
                      ),
                      buildButton(
                        Icons.format_align_right,
                        quill.Attribute.rightAlignment,
                      ),
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
