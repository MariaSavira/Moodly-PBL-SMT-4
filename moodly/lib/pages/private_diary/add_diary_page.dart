import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:permission_handler/permission_handler.dart';

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
    await Permission.storage.request();
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

  /// ================= CROP (FIX FOR V8) =================
  Future<void> _cropImage(XFile? picked) async {
    if (picked == null) return;

    final cropped = await ImageCropper().cropImage(
      sourcePath: picked.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Atur Gambar',
          toolbarColor: Colors.pink,
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
  }

  /// ================= SAVE =================
  void saveDiary() {
    final title = titleController.text;
    final content = _controller.document.toPlainText();

    debugPrint("TITLE: $title");
    debugPrint("CONTENT: $content");
  }

  /// ================= TOOLBAR BUTTON (WORD STYLE) =================
  Widget buildButton(IconData icon, quill.Attribute attribute) {
    final currentStyle = _controller.getSelectionStyle();
    final isActive = currentStyle.attributes.containsKey(attribute.key);

    return GestureDetector(
      onTap: () {
        final currentStyle = _controller.getSelectionStyle();
        final isActive = currentStyle.attributes.containsKey(attribute.key);

        if (isActive) {
          _controller.formatSelection(quill.Attribute.clone(attribute, null));
        } else {
          _controller.formatSelection(attribute);
        }

        setState(() {});
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFF8BBD0) : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isActive ? Colors.black : Colors.black54,
        ),
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
                  saveDiary();
                },
                onTapCancel: () => setState(() => isPressed = false),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 55,
                  height: 55,
                  decoration: BoxDecoration(
                    color: isPressed ? Colors.green : const Color(0xFFF8BBD0),
                    borderRadius: BorderRadius.circular(18),
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

              const SizedBox(height: 10),

              /// TOOLBAR
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
