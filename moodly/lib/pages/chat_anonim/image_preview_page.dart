import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/chat_service.dart';

class ImagePreviewPage extends StatefulWidget {
  final File imageFile;
  final String roomId;

  const ImagePreviewPage({
    super.key,
    required this.imageFile,
    required this.roomId,
  });

  @override
  State<ImagePreviewPage> createState() => _ImagePreviewPageState();
}

class _ImagePreviewPageState extends State<ImagePreviewPage> {
  String viewMode = 'normal';
  final ChatService _chatService = ChatService();

  void _toggleMode() {
    setState(() {
      if (viewMode == 'normal') {
        viewMode = 'once';
      } else if (viewMode == 'once') {
        viewMode = 'twice';
      } else {
        viewMode = 'normal';
      }
    });
  }

  IconData _getIcon() {
    if (viewMode == 'once') return Icons.looks_one;
    if (viewMode == 'twice') return Icons.filter_2;
    return Icons.visibility;
  }

  String _getLabel() {
    if (viewMode == 'once') return 'Sekali lihat';
    if (viewMode == 'twice') return 'Dua kali lihat';
    return 'Biasa';
  }

  Future<void> _sendImage() async {
    await _chatService.sendImageMessage(
      roomId: widget.roomId,
      imageFile: widget.imageFile,
      viewMode: viewMode,
    );

    if (!mounted) return;

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: _toggleMode,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E2E2E),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white24,
                    width: 1,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black54,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  _getIcon(),
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
          )
        ],
      ),
      body: Stack(
        children: [
          Center(
            child: AspectRatio(
              aspectRatio: 9 / 16,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  widget.imageFile,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 30,
            left: 20,
            child: Row(
              children: [
                Icon(
                  _getIcon(),
                  color: Colors.white70,
                ),
                const SizedBox(width: 8),
                Text(
                  _getLabel(),
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),

          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: _sendImage,
              backgroundColor: const Color(0xFF25D366),
              child: const Icon(
                Icons.send,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}