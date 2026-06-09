import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/chat_service.dart';

const String _prefLanguageKey = 'moodly_settings_language_code';

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
  String _languageCode = 'id';

  static const Map<String, Map<String, String>> _copy = {
    'id': {
      'title': 'Pratinjau Foto',
      'normal': 'Biasa',
      'once': 'Sekali lihat',
      'twice': 'Dua kali lihat',
      'send': 'Kirim',
    },
    'en': {
      'title': 'Photo Preview',
      'normal': 'Normal',
      'once': 'View once',
      'twice': 'View twice',
      'send': 'Send',
    },
  };

  @override
  void initState() {
    super.initState();
    _loadLanguagePreference();
  }

  Future<void> _loadLanguagePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString(_prefLanguageKey);

    if (!mounted) return;
    setState(() {
      _languageCode = savedLanguage == 'en' ? 'en' : 'id';
    });
  }

  String _t(String key) => _copy[_languageCode]?[key] ?? _copy['id']![key] ?? key;

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
    if (viewMode == 'once') return _t('once');
    if (viewMode == 'twice') return _t('twice');
    return _t('normal');
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
    const bgColor = Color(0xFFF3FADC);
    const pinkSoft = Color(0xFFFFE6EA);
    const greenMain = Color(0xFF84C76A);
    const textDark = Color(0xFF2B2B2B);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: textDark,
          ),
        ),
        title: Text(
          _t('title'),
          style: const TextStyle(
            color: textDark,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFFF0D5DA),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  _getIcon(),
                  size: 20,
                  color: const Color(0xFFE05C75),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(color: bgColor),
          ),
          Positioned(
            top: -50,
            left: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: pinkSoft.withOpacity(0.45),
              ),
            ),
          ),
          Positioned(
            right: -35,
            bottom: 80,
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFBFE3AF).withOpacity(0.30),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                children: [
                  Expanded(
                    child: Center(
                      child: Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(maxWidth: 340),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.72),
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: AspectRatio(
                            aspectRatio: 9 / 16,
                            child: Image.file(
                              widget.imageFile,
                              fit: BoxFit.contain,
                              alignment: Alignment.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.88),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.07),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: pinkSoft,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _getIcon(),
                            color: const Color(0xFFE05C75),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _getLabel(),
                            style: const TextStyle(
                              fontSize: 14,
                              color: textDark,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _sendImage,
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: greenMain,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          icon: const Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          label: Text(
                            _t('send'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
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
        ],
      ),
    );
  }
}