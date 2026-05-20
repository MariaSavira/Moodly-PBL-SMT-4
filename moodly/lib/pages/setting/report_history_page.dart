import 'package:flutter/material.dart';

import '../../core/styles/moodly_colors.dart';

class ReportHistoryPage extends StatefulWidget {
  const ReportHistoryPage({super.key});

  @override
  State<ReportHistoryPage> createState() => _ReportHistoryPageState();
}

class _ReportHistoryPageState extends State<ReportHistoryPage> {
  String selectedTab = 'Semua';

  final List<Map<String, String>> reports = [
    {
      'title': 'Dia ngomong kasar dan mengancam saya di chat komentar.',
      'reason': 'Kata kasar',
      'date': '11 Apr 2025',
      'status': 'Diproses',
    },
    {
      'title': 'Komentar mengandung hinaan yang membuat tidak nyaman.',
      'reason': 'Pelecehan verbal',
      'date': '08 Apr 2025',
      'status': 'Selesai',
    },
    {
      'title': 'Laporan tidak memiliki bukti yang cukup untuk ditindak.',
      'reason': 'Bukti kurang',
      'date': '03 Apr 2025',
      'status': 'Ditolak',
    },
  ];

  List<Map<String, String>> get filteredReports {
    if (selectedTab == 'Semua') return reports;
    return reports.where((item) => item['status'] == selectedTab).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MoodlyColors.bgLight,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final isSmall = width < 380;
            final horizontalPadding = isSmall ? 22.0 : 28.0;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                16,
                horizontalPadding,
                32,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Header(
                    title: 'Riwayat Pelapor',
                    onBack: () => Navigator.pop(context),
                  ),

                  const SizedBox(height: 28),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          'Lihat status laporan yang\npernah kamu kirim',
                          style: TextStyle(
                            fontSize: isSmall ? 19 : 21,
                            height: 1.32,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: isSmall ? 54 : 60,
                        height: isSmall ? 54 : 60,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.45),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '🧠',
                            style: TextStyle(fontSize: isSmall ? 28 : 32),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 26),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.07),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        _TabButton(
                          label: 'Semua',
                          selected: selectedTab == 'Semua',
                          onTap: () => setState(() => selectedTab = 'Semua'),
                        ),
                        _TabButton(
                          label: 'Diproses',
                          selected: selectedTab == 'Diproses',
                          onTap: () => setState(() => selectedTab = 'Diproses'),
                        ),
                        _TabButton(
                          label: 'Selesai',
                          selected: selectedTab == 'Selesai',
                          onTap: () => setState(() => selectedTab = 'Selesai'),
                        ),
                        _TabButton(
                          label: 'Ditolak',
                          selected: selectedTab == 'Ditolak',
                          onTap: () => setState(() => selectedTab = 'Ditolak'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 26),

                  if (filteredReports.isEmpty)
                    const _EmptyReport()
                  else
                    ...filteredReports.map(
                      (report) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _ReportCard(
                          title: report['title']!,
                          reason: report['reason']!,
                          date: report['date']!,
                          status: report['status']!,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const _Header({
    required this.title,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: onBack,
          child: const Icon(
            Icons.arrow_back,
            color: MoodlyColors.green,
            size: 22,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(
            color: MoodlyColors.green,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        const Text(
          'Moodly',
          style: TextStyle(
            color: Color(0xFFC65F59),
            fontSize: 32,
            fontWeight: FontWeight.w800,
            letterSpacing: -1,
          ),
        ),
      ],
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.width < 380;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 40,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFDDEFCF) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: FittedBox(
              child: Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.black : MoodlyColors.green,
                  fontSize: isSmall ? 12 : 13,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final String title;
  final String reason;
  final String date;
  final String status;

  const _ReportCard({
    required this.title,
    required this.reason,
    required this.date,
    required this.status,
  });

  Color get statusBg {
    if (status == 'Selesai') return const Color(0xFFDDEFCF);
    if (status == 'Ditolak') return const Color(0xFFFFD8D0);
    return const Color(0xFFFFE9DD);
  }

  Color get statusFg {
    if (status == 'Selesai') return MoodlyColors.green;
    if (status == 'Ditolak') return const Color(0xFFC65F59);
    return const Color(0xFFFF8B61);
  }

  IconData get statusIcon {
    if (status == 'Selesai') return Icons.check_circle_rounded;
    if (status == 'Ditolak') return Icons.cancel_rounded;
    return Icons.refresh_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.width < 380;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
              decoration: BoxDecoration(
                color: statusBg,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    statusIcon,
                    size: 14,
                    color: statusFg,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    status,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          Text(
            title,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.black,
              fontSize: isSmall ? 17 : 18,
              height: 1.28,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 22),

          Wrap(
            spacing: 10,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _InfoPill(
                label: 'Alasan',
                value: reason,
                icon: Icons.flag_rounded,
              ),
              _InfoPill(
                label: 'Tanggal',
                value: date,
                icon: Icons.calendar_month_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoPill({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(11, 8, 12, 8),
      decoration: BoxDecoration(
        color: MoodlyColors.bgLight,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: MoodlyColors.green,
            size: 15,
          ),
          const SizedBox(width: 6),
          Text(
            '$label: ',
            style: const TextStyle(
              color: MoodlyColors.green,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyReport extends StatelessWidget {
  const _EmptyReport();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 34),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: const Column(
        children: [
          Icon(
            Icons.inbox_rounded,
            color: MoodlyColors.green,
            size: 42,
          ),
          SizedBox(height: 12),
          Text(
            'Belum ada laporan',
            style: TextStyle(
              color: Colors.black,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Riwayat laporan akan muncul di sini.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black54,
              fontSize: 13,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}