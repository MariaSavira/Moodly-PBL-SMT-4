import 'package:flutter/material.dart';
import 'package:moodly/services/afirmasi/afirmasi_service.dart';

class AfirmasiFavoritPage extends StatefulWidget {
  const AfirmasiFavoritPage({super.key});

  @override
  State<AfirmasiFavoritPage> createState() => _AfirmasiFavoritPageState();
}

class _AfirmasiFavoritPageState extends State<AfirmasiFavoritPage> {
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, String>> _allItems = [];
  List<Map<String, String>> _filteredItems = [];

  bool _isEditMode = false;
  final Set<int> _selectedIndexes = {};

  @override
  void initState() {
    super.initState();
    _reloadItems();
    _searchController.addListener(_filterItems);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _reloadItems() {
    _allItems = AfirmasiService.getFavoritItems();
    _filteredItems = List<Map<String, String>>.from(_allItems);
    setState(() {});
  }

  void _filterItems() {
    final query = _searchController.text.toLowerCase().trim();

    setState(() {
      if (query.isEmpty) {
        _filteredItems = List<Map<String, String>>.from(_allItems);
      } else {
        _filteredItems = _allItems.where((item) {
          final teks = (item['teks'] ?? '').toLowerCase();
          final kategori = (item['kategori'] ?? '').toLowerCase();
          return teks.contains(query) || kategori.contains(query);
        }).toList();
      }
      _selectedIndexes.clear();
    });
  }

  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
      if (!_isEditMode) {
        _selectedIndexes.clear();
      }
    });
  }

  void _toggleSelected(int index) {
    setState(() {
      if (_selectedIndexes.contains(index)) {
        _selectedIndexes.remove(index);
      } else {
        _selectedIndexes.add(index);
      }
    });
  }

  void _selectAll() {
    setState(() {
      if (_filteredItems.isEmpty) return;

      if (_selectedIndexes.length == _filteredItems.length) {
        _selectedIndexes.clear();
      } else {
        _selectedIndexes
          ..clear()
          ..addAll(List.generate(_filteredItems.length, (i) => i));
      }
    });
  }

  void _deleteSelected() {
    if (_selectedIndexes.isEmpty) return;

    final itemsToDelete =
        _selectedIndexes.map((i) => _filteredItems[i]).toList();
    AfirmasiService.removeManyFavorites(itemsToDelete);

    _reloadItems();
    _selectedIndexes.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Afirmasi favorit dihapus')),
    );
  }

  Map<String, List<Map<String, String>>> _groupedByCategory() {
    final Map<String, List<Map<String, String>>> grouped = {};

    for (final item in _filteredItems) {
      final kategori = item['kategori'] ?? 'Tanpa Kategori';
      grouped.putIfAbsent(kategori, () => []);
      grouped[kategori]!.add(item);
    }

    return grouped;
  }

  Color _categoryColor(String kategori) {
    switch (kategori) {
      case 'Cinta Diri':
        return const Color(0xFFF5B2BC);
      case 'Motivasi':
        return const Color(0xFFD9ED84);
      case 'Rasa Syukur':
        return const Color(0xFF9BD18C);
      case 'Meredakan Kecemasan':
        return const Color(0xFFFFE0E2);
      case 'Kesehatan Mental':
        return const Color(0xFF9DDBF7);
      default:
        return const Color(0xFFD9E7C2);
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupedItems = _groupedByCategory();

    return Scaffold(
      backgroundColor: const Color(0xFFF1F4DE),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 24,
                      color: Colors.black,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Afirmasi Favorit',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                  ),
                  Image.asset(
                    'assets/icon/images/maskot_favorit.png',
                    width: 108,
                    height: 108,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              child: Container(
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Cari afirmasi',
                    prefixIcon: Icon(Icons.search),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  _ActionChip(
                    icon: Icons.edit_outlined,
                    label: 'Edit',
                    onTap: _toggleEditMode,
                  ),
                  const SizedBox(width: 10),
                  _ActionChip(
                    icon: Icons.check_box_outlined,
                    label: 'Pilih Semua',
                    onTap: _selectAll,
                  ),
                  const SizedBox(width: 10),
                  _ActionChip(
                    icon: Icons.delete_outline,
                    label: 'Hapus',
                    onTap: _deleteSelected,
                  ),
                ],
              ),
            ),
            Expanded(
              child: _filteredItems.isEmpty
                  ? Center(
                      child: Text(
                        'Belum ada afirmasi favorit',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(20, 6, 20, 20),
                      children: groupedItems.entries.map((entry) {
                        final kategori = entry.key;
                        final items = entry.value;
                        final categoryColor = _categoryColor(kategori);

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _CategoryHeader(
                              title: kategori,
                              color: categoryColor,
                            ),
                            const SizedBox(height: 8),
                            ...items.map((item) {
                              final index = _filteredItems.indexOf(item);
                              final isSelected =
                                  _selectedIndexes.contains(index);

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (_isEditMode) ...[
                                      GestureDetector(
                                        onTap: () => _toggleSelected(index),
                                        child: Container(
                                          width: 22,
                                          height: 22,
                                          margin: const EdgeInsets.only(top: 2),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: isSelected
                                                  ? const Color(0xFF7BAE67)
                                                  : Colors.grey.shade400,
                                              width: 2,
                                            ),
                                            color: isSelected
                                                ? const Color(0xFF7BAE67)
                                                : Colors.transparent,
                                          ),
                                          child: isSelected
                                              ? const Icon(
                                                  Icons.check,
                                                  size: 14,
                                                  color: Colors.white,
                                                )
                                              : null,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                    ],
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item['teks'] ?? '',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  color: Colors.black87,
                                                  fontSize: 14,
                                                ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Hari ini',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  color: Colors.grey.shade500,
                                                  fontSize: 11,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: categoryColor.withOpacity(0.9),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        kategori,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: Colors.black54,
                                              fontSize: 11,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                            const SizedBox(height: 8),
                          ],
                        );
                      }).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 34,
          decoration: BoxDecoration(
            color: const Color(0xFF9ED17B),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryHeader extends StatelessWidget {
  final String title;
  final Color color;

  const _CategoryHeader({
    required this.title,
    required this.color,
  });

  IconData _categoryIcon(String kategori) {
    switch (kategori) {
      case 'Cinta Diri':
        return Icons.favorite;
      case 'Motivasi':
        return Icons.sentiment_satisfied_alt;
      case 'Rasa Syukur':
        return Icons.eco_outlined;
      case 'Meredakan Kecemasan':
        return Icons.mood;
      case 'Kesehatan Mental':
        return Icons.self_improvement;
      default:
        return Icons.label;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            _categoryIcon(title),
            size: 14,
            color: Colors.black54,
          ),
          const SizedBox(width: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.black54,
                  fontSize: 12,
                ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Container(
              height: 1.2,
              color: Colors.black26,
            ),
          ),
        ],
      ),
    );
  }
}