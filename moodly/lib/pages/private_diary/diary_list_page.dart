import 'package:flutter/material.dart';
import '../../Controllers/diary_controller.dart';
import '../../models/diary_model.dart';

class DiaryListPage extends StatefulWidget {
  final int? month;
  final int? year;
  final bool isPastMonth; // ✅ FIXED

  const DiaryListPage({
    super.key,
    this.month,
    this.year,
    this.isPastMonth = false, // ✅ FIXED
  });

  @override
  State<DiaryListPage> createState() => _DiaryListPageState();
}

class _DiaryListPageState extends State<DiaryListPage> {
  final DiaryController _ctrl = DiaryController();
  final List<String> _monthNames = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  @override
  void initState() {
    super.initState();
    _ctrl.loadData(widget.month, widget.year);
  }

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final isFuture =
        widget.month != null &&
        _ctrl.isFutureMonth(widget.month!, widget.year!);
    final isCurrent =
        widget.month != null &&
        _ctrl.isCurrentMonth(widget.month!, widget.year!);
    final monthName = widget.month != null
        ? _monthNames[widget.month! - 1]
        : 'Minggu Ini';

    return Scaffold(
      backgroundColor: const Color(0xFFF7FBF2),
      appBar: _buildAppBar(context, isCurrent),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                _buildSegmentedControl(),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    monthName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontFamily: 'Fredoka',
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(child: _buildContent(isFuture, isCurrent, monthName)),
        ],
      ),
      floatingActionButton:
          (!_ctrl.isSelectionMode && (isCurrent || widget.month == null))
          ? Container(
              margin: const EdgeInsets.only(bottom: 20),
              child: FloatingActionButton(
                onPressed: () {}, // Nanti sambung ke halaman input
                backgroundColor: const Color(0xFF8FD48F),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.add, color: Colors.black, size: 30),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isCurrent) {
    if (!_ctrl.isSelectionMode) {
      return AppBar(
        backgroundColor: const Color(0xFFF7FBF2),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Private Diary',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontFamily: 'Fredoka',
          ),
        ),
      );
    }

    return AppBar(
      backgroundColor: const Color(0xFFF7FBF2),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.close, size: 24, color: Colors.black),
        onPressed: () {
          _ctrl.toggleSelectionMode();
          _refresh();
        },
      ),
      title: Row(
        children: [
          Checkbox(
            value:
                _ctrl.selectedIds.length == _ctrl.diaries.length &&
                _ctrl.diaries.isNotEmpty,
            onChanged: (_) {
              _ctrl.selectAll();
              _refresh();
            },
            activeColor: const Color(0xFF8FD48F),
          ),
          const SizedBox(width: 8),
          Text(
            'Pilih Semua',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontFamily: 'Fredoka',
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.delete_outline, color: Color(0xFFF2B6B6)),
          onPressed: () => _deleteSelected(context),
        ),
      ],
    );
  }

  void _deleteSelected(BuildContext context) {
    if (_ctrl.selectedIds.isEmpty) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFF7FBF2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Hapus Diary?',
          style: TextStyle(fontFamily: 'Fredoka', fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Yakin ingin menghapus ${_ctrl.selectedIds.length} diary?',
          style: const TextStyle(fontFamily: 'OpenSans'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF2B6B6),
            ),
            onPressed: () {
              _ctrl.diaries.removeWhere(
                (d) => _ctrl.selectedIds.contains(d.id),
              );
              _ctrl.isSelectionMode = false;
              _ctrl.selectedIds.clear();
              _refresh();
              Navigator.pop(ctx);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentedControl() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF2B6B6),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                _ctrl.changeViewMode('month');
                _refresh();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _ctrl.viewMode == 'month'
                      ? Colors.white
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Bulan',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _ctrl.viewMode == 'month'
                        ? Colors.black
                        : Colors.white,
                    fontFamily: 'Fredoka',
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: GestureDetector(
              onTap: () {
                _ctrl.changeViewMode('week');
                _refresh();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _ctrl.viewMode == 'week'
                      ? Colors.white
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Pekan',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _ctrl.viewMode == 'week'
                        ? Colors.black
                        : Colors.white,
                    fontFamily: 'Fredoka',
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Color(0xFFF2B6B6),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.search, size: 18, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(bool isFuture, bool isCurrent, String monthName) {
    if (isFuture) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.hourglass_empty,
              size: 60,
              color: Color(0xFF8FD48F),
            ),
            const SizedBox(height: 16),
            Text(
              '⏳ $monthName Belum Tiba',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Fredoka',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Fokus di masa sekarang, ya!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
                fontFamily: 'OpenSans',
              ),
            ),
          ],
        ),
      );
    }

    if (_ctrl.diaries.isEmpty) {
      if (isCurrent || widget.month == null) {
        return Center(
          child: GestureDetector(
            onTap: () {}, // Nanti ke halaman input
            child: Container(
              padding: const EdgeInsets.all(20),
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.edit_note,
                    size: 40,
                    color: Color(0xFF8FD48F),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '✨ Tambahkan Diary',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Fredoka',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Ceritakan harimu di bulan ini',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                      fontFamily: 'OpenSans',
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.note_outlined, size: 60, color: Colors.black26),
            const SizedBox(height: 16),
            Text(
              '📭 Tidak ada diary di bulan $monthName',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Fredoka',
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _ctrl.diaries.length,
      itemBuilder: (context, index) {
        final diary = _ctrl.diaries[index];
        final prev = index > 0 ? _ctrl.diaries[index - 1] : null;
        final showHeader = prev == null || prev.date != diary.date;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showHeader) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        diary.date,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontFamily: 'Fredoka',
                        ),
                      ),
                      Text(
                        diary.dayName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          fontFamily: 'Fredoka',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            _buildDiaryCard(diary),
            const SizedBox(height: 12),
          ],
        );
      },
    );
  }

  Widget _buildDiaryCard(DiaryModel diary) {
    final isSelected = _ctrl.selectedIds.contains(diary.id);
    return GestureDetector(
      onLongPress: () {
        _ctrl.toggleSelectionMode();
        _refresh();
      },
      onTap: () {
        if (_ctrl.isSelectionMode) {
          _ctrl.toggleSelection(diary.id);
          _refresh();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFF2B6B6).withOpacity(0.3)
              : Colors.white,
          border: isSelected
              ? Border.all(color: const Color(0xFFF2B6B6), width: 2)
              : null,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    diary.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      fontFamily: 'Fredoka',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${diary.time} pm',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                      fontFamily: 'OpenSans',
                    ),
                  ),
                ],
              ),
            ),
            if (!_ctrl.isSelectionMode)
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.black54),
                onSelected: (val) {
                  if (val == 'delete') {
                    _ctrl.diaries.removeWhere((d) => d.id == diary.id);
                    _refresh();
                  }
                },
                itemBuilder: (ctx) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Text('✏️ Edit Diary'),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('🗑️ Hapus Diary'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
