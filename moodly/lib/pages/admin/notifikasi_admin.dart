import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotifikasiAdmin extends StatefulWidget {
  const NotifikasiAdmin({super.key});

  @override
  State<NotifikasiAdmin> createState() => _NotifikasiAdminState();
}

class _NotifikasiAdminState extends State<NotifikasiAdmin> {
  bool _notifLaporanBaru = true;
  bool _notifBandingBaru = true;
  bool _notifUserBaru = true;
  bool _notifSystem = true;
  bool _notifEmail = false;
  bool _notifSound = true;
  bool _notifVibrate = true;

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
          'Notifikasi',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Color(0xFF4A6B5D),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _markAllAsRead,
            child: const Text(
              'Tandai Semua Dibaca',
              style: TextStyle(color: Color(0xFF4A6B5D)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionCard(
              title: 'Jenis Notifikasi',
              children: [
                _buildSwitchTile(
                  icon: Icons.report_outlined,
                  title: 'Laporan Baru',
                  subtitle: 'Ada laporan konten baru',
                  value: _notifLaporanBaru,
                  onChanged: (val) => setState(() => _notifLaporanBaru = val),
                ),
                const Divider(height: 20, thickness: 1, color: Color(0xFFEEEEEE)),
                _buildSwitchTile(
                  icon: Icons.swap_horiz,
                  title: 'Banding Baru',
                  subtitle: 'Ada pengajuan banding baru',
                  value: _notifBandingBaru,
                  onChanged: (val) => setState(() => _notifBandingBaru = val),
                ),
                const Divider(height: 20, thickness: 1, color: Color(0xFFEEEEEE)),
                _buildSwitchTile(
                  icon: Icons.person_add_outlined,
                  title: 'User Baru',
                  subtitle: 'Ada pengguna baru terdaftar',
                  value: _notifUserBaru,
                  onChanged: (val) => setState(() => _notifUserBaru = val),
                ),
                const Divider(height: 20, thickness: 1, color: Color(0xFFEEEEEE)),
                _buildSwitchTile(
                  icon: Icons.settings_outlined,
                  title: 'Notifikasi Sistem',
                  subtitle: 'Update dan pengumuman sistem',
                  value: _notifSystem,
                  onChanged: (val) => setState(() => _notifSystem = val),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _buildSectionCard(
              title: 'Pengiriman Notifikasi',
              children: [
                _buildSwitchTile(
                  icon: Icons.email_outlined,
                  title: 'Notifikasi Email',
                  subtitle: 'Kirim notifikasi via email',
                  value: _notifEmail,
                  onChanged: (val) => setState(() => _notifEmail = val),
                ),
                const Divider(height: 20, thickness: 1, color: Color(0xFFEEEEEE)),
                _buildSwitchTile(
                  icon: Icons.notifications_active_outlined,
                  title: 'Notifikasi Push',
                  subtitle: 'Tampilkan notifikasi push',
                  value: true,
                  onChanged: (val) {},
                ),
              ],
            ),
            const SizedBox(height: 16),

            _buildSectionCard(
              title: 'Suara & Getaran',
              children: [
                _buildSwitchTile(
                  icon: Icons.volume_up_outlined,
                  title: 'Suara Notifikasi',
                  subtitle: 'Putar suara saat ada notifikasi',
                  value: _notifSound,
                  onChanged: (val) => setState(() => _notifSound = val),
                ),
                const Divider(height: 20, thickness: 1, color: Color(0xFFEEEEEE)),
                _buildSwitchTile(
                  icon: Icons.vibration,
                  title: 'Getar',
                  subtitle: 'Getar saat ada notifikasi',
                  value: _notifVibrate,
                  onChanged: (val) => setState(() => _notifVibrate = val),
                ),
              ],
            ),
            const SizedBox(height: 24),

            const Text(
              'Notifikasi Terbaru',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF4A6B5D),
              ),
            ),
            const SizedBox(height: 12),
            _buildNotificationList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required List<Widget> children}) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF4A6B5D),
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F7E6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: const Color(0xFF4A6B5D), size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Color(0xFF333333),
        ),
      ),
      subtitle: subtitle != null
          ? Text(
        subtitle,
        style: const TextStyle(fontSize: 13, color: Colors.grey),
      )
          : null,
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF4CAF50),
      ),
    );
  }

  Widget _buildNotificationList() {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text(
            'Silakan login terlebih dahulu',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('notifications')
          .where('adminId', isEqualTo: currentUser.uid)
          .orderBy('createdAt', descending: true)
          .limit(10)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                'Terjadi kesalahan: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Column(
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 48,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Belum ada notifikasi',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }

        return Container(
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
            children: snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return _buildNotificationItem(
                title: data['title'] ?? '',
                message: data['message'] ?? '',
                time: _formatTime(data['createdAt']),
                isRead: data['isRead'] ?? false,
                type: data['type'] ?? 'info',
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildNotificationItem({
    required String title,
    required String message,
    required String time,
    required bool isRead,
    required String type,
  }) {
    Color iconColor;
    IconData icon;

    switch (type) {
      case 'laporan':
        icon = Icons.report_outlined;
        iconColor = const Color(0xFFD32F2F);
        break;
      case 'banding':
        icon = Icons.swap_horiz;
        iconColor = const Color(0xFF1976D2);
        break;
      case 'user':
        icon = Icons.person_add_outlined;
        iconColor = const Color(0xFF388E3C);
        break;
      default:
        icon = Icons.notifications_none;
        iconColor = const Color(0xFF4A6B5D);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
        color: isRead ? Colors.white : const Color(0xFFF5F7E6),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isRead ? FontWeight.w500 : FontWeight.w700,
                    color: const Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          if (!isRead)
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFF4CAF50),
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }

  String _formatTime(dynamic timestamp) {
    if (timestamp == null) {
      return '';
    }

    try {
      DateTime date;

      if (timestamp is Timestamp) {
        date = timestamp.toDate();
      }
      else if (timestamp is DateTime) {
        date = timestamp;
      }
      else if (timestamp is String) {
        date = DateTime.parse(timestamp);
      }
      else {
        return '';
      }

      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inMinutes < 1) return 'Baru saja';
      if (diff.inMinutes < 60) return '${diff.inMinutes} menit yang lalu';
      if (diff.inHours < 24) return '${diff.inHours} jam yang lalu';
      if (diff.inDays < 7) return '${diff.inDays} hari yang lalu';
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return '';
    }
  }

  void _markAllAsRead() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan login terlebih dahulu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final batch = FirebaseFirestore.instance.batch();
      final snapshot = await FirebaseFirestore.instance
          .collection('notifications')
          .where('adminId', isEqualTo: currentUser.uid)
          .where('isRead', isEqualTo: false)
          .get();

      if (snapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak ada notifikasi yang belum dibaca'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
        return;
      }

      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Semua notifikasi ditandai sebagai dibaca'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}