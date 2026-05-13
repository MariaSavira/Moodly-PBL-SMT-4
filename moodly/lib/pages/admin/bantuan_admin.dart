import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class BantuanAdminPage extends StatefulWidget {
  const BantuanAdminPage({super.key});

  @override
  State<BantuanAdminPage> createState() => _BantuanAdminPageState();
}

class _BantuanAdminPageState extends State<BantuanAdminPage> {
  final _searchController = TextEditingController();
  bool _expandedIndex0 = false;
  bool _expandedIndex1 = false;
  bool _expandedIndex2 = false;
  bool _expandedIndex3 = false;
  bool _expandedIndex4 = false;

  final List<Map<String, String>> _faqItems = [
    {
      'question': 'Bagaimana cara memoderasi konten?',
      'answer':
      'Anda dapat memoderasi konten melalui halaman Moderasi. Pilih konten yang ingin direview, lalu pilih tindakan yang sesuai (Approve, Reject, atau Flag).',
    },
    {
      'question': 'Bagaimana cara menangani laporan user?',
      'answer':
      'Laporan user akan muncul di halaman Laporan. Review laporan tersebut, periksa konten yang dilaporkan, dan ambil tindakan yang sesuai (Hapus, Warning, atau Abaikan).',
    },
    {
      'question': 'Bagaimana cara mengelola banding?',
      'answer':
      'User dapat mengajukan banding untuk konten yang dihapus. Anda dapat melihat semua banding di halaman Banding, review alasan banding, dan putuskan apakah akan memulihkan konten atau menolak banding.',
    },
    {
      'question': 'Bagaimana cara menambahkan admin baru?',
      'answer':
      'Fitur penambahan admin baru hanya tersedia untuk Super Admin. Silakan hubungi Super Admin untuk permintaan penambahan akses admin.',
    },
    {
      'question': 'Bagaimana cara melihat statistik aplikasi?',
      'answer':
      'Anda dapat melihat statistik aplikasi di Dashboard, termasuk jumlah user aktif, konten yang dimoderasi, laporan yang ditangani, dan metrik penting lainnya.',
    },
  ];

  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@moodly.app',
      query: 'subject=Bantuan Admin Moodly&body=Halo, saya butuh bantuan dengan...',
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak dapat membuka email client')),
      );
    }
  }

  Future<void> _launchWhatsApp() async {
    final Uri whatsappUri = Uri.parse('https://wa.me/6281234567890');

    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak dapat membuka WhatsApp')),
      );
    }
  }

  void _showContactForm() {
    showDialog(
      context: context,
      builder: (_) => const ContactFormDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7E6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4A6B5D)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Bantuan',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Color(0xFF4A6B5D),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari bantuan...',
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF4A6B5D)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                onChanged: (value) {
                  setState(() {});
                },
              ),
            ),
            const SizedBox(height: 24),

            // Quick Actions
            const Text(
              'Kontak Kami',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF4A6B5D),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildContactButton(
                    icon: Icons.email_outlined,
                    title: 'Kirim Email',
                    subtitle: 'support@moodly.app',
                    color: const Color(0xFF1976D2),
                    onTap: _launchEmail,
                  ),
                  const Divider(height: 1),
                  _buildContactButton(
                    icon: Icons.chat_outlined,
                    title: 'WhatsApp',
                    subtitle: '+62 812-3456-7890',
                    color: const Color(0xFF25D366),
                    onTap: _launchWhatsApp,
                  ),
                  const Divider(height: 1),
                  _buildContactButton(
                    icon: Icons.message_outlined,
                    title: 'Kirim Pesan',
                    subtitle: 'Formulir kontak',
                    color: const Color(0xFF4A6B5D),
                    onTap: _showContactForm,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // FAQ Section
            const Text(
              'FAQ (Pertanyaan Umum)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF4A6B5D),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildExpansionTile(
                    index: 0,
                    question: _faqItems[0]['question']!,
                    answer: _faqItems[0]['answer']!,
                  ),
                  _buildExpansionTile(
                    index: 1,
                    question: _faqItems[1]['question']!,
                    answer: _faqItems[1]['answer']!,
                  ),
                  _buildExpansionTile(
                    index: 2,
                    question: _faqItems[2]['question']!,
                    answer: _faqItems[2]['answer']!,
                  ),
                  _buildExpansionTile(
                    index: 3,
                    question: _faqItems[3]['question']!,
                    answer: _faqItems[3]['answer']!,
                  ),
                  _buildExpansionTile(
                    index: 4,
                    question: _faqItems[4]['question']!,
                    answer: _faqItems[4]['answer']!,
                  ),
                ],
              ),
            ),
            // ✅ Card "Moodly Admin" sudah dihapus dari sini
          ],
        ),
      ),
    );
  }

  Widget _buildContactButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF333333),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 13, color: Colors.grey),
      ),
      trailing: const Icon(Icons.chevron_right, color: Color(0xFFAAAAAA)),
      onTap: onTap,
    );
  }

  Widget _buildExpansionTile({
    required int index,
    required String question,
    required String answer,
  }) {
    bool isExpanded;
    VoidCallback onToggle;

    switch (index) {
      case 0:
        isExpanded = _expandedIndex0;
        onToggle = () => setState(() => _expandedIndex0 = !isExpanded);
        break;
      case 1:
        isExpanded = _expandedIndex1;
        onToggle = () => setState(() => _expandedIndex1 = !isExpanded);
        break;
      case 2:
        isExpanded = _expandedIndex2;
        onToggle = () => setState(() => _expandedIndex2 = !isExpanded);
        break;
      case 3:
        isExpanded = _expandedIndex3;
        onToggle = () => setState(() => _expandedIndex3 = !isExpanded);
        break;
      case 4:
        isExpanded = _expandedIndex4;
        onToggle = () => setState(() => _expandedIndex4 = !isExpanded);
        break;
      default:
        isExpanded = false;
        onToggle = () {};
    }

    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: Text(
            question,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
          ),
          trailing: Icon(
            isExpanded ? Icons.expand_less : Icons.expand_more,
            color: const Color(0xFF4A6B5D),
          ),
          onTap: onToggle,
        ),
        if (isExpanded)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              answer,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                height: 1.5,
              ),
            ),
          ),
        if (isExpanded && index < 4) const Divider(height: 1, indent: 16, endIndent: 16),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class ContactFormDialog extends StatefulWidget {
  const ContactFormDialog({super.key});

  @override
  State<ContactFormDialog> createState() => _ContactFormDialogState();
}

class _ContactFormDialogState extends State<ContactFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pesan berhasil dikirim. Kami akan segera merespons.'),
          backgroundColor: Color(0xFF4CAF50),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Kirim Pesan'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Email tidak boleh kosong';
                  }
                  if (!value.contains('@')) {
                    return 'Email tidak valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _messageController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Pesan',
                  prefixIcon: Icon(Icons.message_outlined),
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Pesan tidak boleh kosong';
                  }
                  if (value.trim().length < 10) {
                    return 'Pesan minimal 10 karakter';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submitForm,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4A6B5D),
          ),
          child: _isLoading
              ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
              : const Text('Kirim'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }
}