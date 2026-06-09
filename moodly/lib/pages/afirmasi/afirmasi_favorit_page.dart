
import 'package:flutter/material.dart';
import 'package:moodly/pages/afirmasi/widgets/cute_top_popup.dart';
import 'package:moodly/pages/setting/moodly_settings_support.dart';
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

  static const Color _bg = Color(0xFFF3F7E8);
  static const Color _card = Colors.white;
  static const Color _green = Color(0xFF96D47E);
  static const Color _greenDark = Color(0xFF5E9E4F);
  static const Color _greenSoft = Color(0xFFE4F4D7);
  static const Color _pinkSoft = Color(0xFFFFEEF2);
  static const Color _pinkStrong = Color(0xFFF5B2BC);
  static const Color _textDark = Color(0xFF1F1F1F);
  static const Color _textSoft = Color(0xFF717968);
  static const Color _danger = Color(0xFFE48A98);

  static const Map<String, Map<String, String>> _copy = {
    'id': {
      'header': 'Afirmasi Favorit',
      'searchHint': 'Cari afirmasi favorit',
      'savedCount': '{count} afirmasi tersimpan',
      'savedBody': 'Simpan kalimat yang paling menenangkan buatmu.',
      'edit': 'Edit',
      'done': 'Selesai',
      'selectAll': 'Pilih Semua',
      'delete': 'Hapus',
      'editOnTitle': 'Mode edit aktif',
      'editOnBody': 'Pilih afirmasi yang ingin dihapus.',
      'editOffTitle': 'Mode edit dimatikan',
      'editOffBody': 'Pilihan afirmasi telah dibersihkan.',
      'mustEditTitle': 'Aktifkan edit dulu',
      'mustEditSelectBody': 'Masuk ke mode edit untuk memilih afirmasi.',
      'mustEditDeleteBody': 'Masuk ke mode edit untuk menghapus afirmasi.',
      'noneSelectedTitle': 'Belum ada pilihan',
      'noneSelectedBody': 'Pilih minimal satu afirmasi untuk dihapus.',
      'deletedTitle': 'Berhasil dihapus',
      'deletedBody': 'Afirmasi favorit berhasil dihapus.',
      'selectedCount': '{count} afirmasi dipilih',
      'allSelectedTitle': 'Semua dipilih',
      'allSelectedBody': 'Semua afirmasi favorit berhasil dipilih.',
      'selectionClearedTitle': 'Pilihan dibersihkan',
      'selectionClearedBody': 'Semua pilihan dibatalkan.',
      'emptyTitle': 'Belum ada afirmasi favorit',
      'emptyBody':
          'Simpan afirmasi yang paling menenangkan buatmu, nanti dia akan muncul di sini.',
      'defaultCategory': 'Tanpa Kategori',
      'selfLove': 'Cinta Diri',
      'motivation': 'Motivasi',
      'gratitude': 'Rasa Syukur',
      'anxiety': 'Meredakan Kecemasan',
      'mental': 'Kesehatan Mental',
    },
    'en': {
      'header': 'Favorite Affirmations',
      'searchHint': 'Search favorite affirmations',
      'savedCount': '{count} saved affirmations',
      'savedBody': 'Keep the lines that feel most calming for you.',
      'edit': 'Edit',
      'done': 'Done',
      'selectAll': 'Select All',
      'delete': 'Delete',
      'editOnTitle': 'Edit mode on',
      'editOnBody': 'Choose the affirmations you want to remove.',
      'editOffTitle': 'Edit mode off',
      'editOffBody': 'Your current selection has been cleared.',
      'mustEditTitle': 'Turn on edit first',
      'mustEditSelectBody': 'Enter edit mode to select affirmations.',
      'mustEditDeleteBody': 'Enter edit mode to delete affirmations.',
      'noneSelectedTitle': 'Nothing selected',
      'noneSelectedBody': 'Choose at least one affirmation to delete.',
      'deletedTitle': 'Deleted',
      'deletedBody': 'Favorite affirmations have been removed.',
      'selectedCount': '{count} affirmations selected',
      'allSelectedTitle': 'All selected',
      'allSelectedBody': 'All favorite affirmations have been selected.',
      'selectionClearedTitle': 'Selection cleared',
      'selectionClearedBody': 'All selections have been removed.',
      'emptyTitle': 'No favorite affirmations yet',
      'emptyBody':
          'Save the affirmations that feel most calming, and they will appear here.',
      'defaultCategory': 'No Category',
      'selfLove': 'Self Love',
      'motivation': 'Motivation',
      'gratitude': 'Gratitude',
      'anxiety': 'Ease Anxiety',
      'mental': 'Mental Health',
    },
  };

  @override
  void initState() {
    super.initState();
    _initializePage();
    _searchController.addListener(_filterItems);
  }

  Future<void> _initializePage() async {
    await AfirmasiService.loadFavoritesFromLocal();
    _reloadItems();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _t(String languageCode, String key) =>
      _copy[languageCode]?[key] ?? _copy['id']![key] ?? key;

  String _categoryLabel(String languageCode, String raw) {
    switch (raw) {
      case 'Cinta Diri':
        return _t(languageCode, 'selfLove');
      case 'Motivasi':
        return _t(languageCode, 'motivation');
      case 'Rasa Syukur':
        return _t(languageCode, 'gratitude');
      case 'Meredakan Kecemasan':
        return _t(languageCode, 'anxiety');
      case 'Kesehatan Mental':
        return _t(languageCode, 'mental');
      default:
        return raw.isEmpty ? _t(languageCode, 'defaultCategory') : raw;
    }
  }

  List<BoxShadow> get _softShadow => const [
        BoxShadow(
          color: Color.fromRGBO(0, 0, 0, 0.08),
          offset: Offset(0, 10),
          blurRadius: 24,
        ),
      ];

  void _reloadItems() {
    _allItems = AfirmasiService.getFavoritItems();
    _filteredItems = List<Map<String, String>>.from(_allItems);

    if (!mounted) return;
    setState(() {});
  }

  void _filterItems() {
    final query = _searchController.text.toLowerCase().trim();
    final languageCode = MoodlySettingsPrefs.currentLanguageCode;

    setState(() {
      if (query.isEmpty) {
        _filteredItems = List<Map<String, String>>.from(_allItems);
      } else {
        _filteredItems = _allItems.where((item) {
          final teks = (item['teks'] ?? '').toLowerCase();
          final kategoriRaw = (item['kategori'] ?? '').toLowerCase();
          final kategoriLocalized = _categoryLabel(
            languageCode,
            item['kategori'] ?? '',
          ).toLowerCase();

          return teks.contains(query) ||
              kategoriRaw.contains(query) ||
              kategoriLocalized.contains(query);
        }).toList();
      }

      if (_selectedIndexes.isNotEmpty) {
        _selectedIndexes.removeWhere((i) => i >= _filteredItems.length);
      }
    });
  }

  void _toggleEditMode(String languageCode) {
    setState(() {
      _isEditMode = !_isEditMode;
      if (!_isEditMode) {
        _selectedIndexes.clear();
      }
    });

    showCuteTopPopup(
      context,
      title: _isEditMode
          ? _t(languageCode, 'editOnTitle')
          : _t(languageCode, 'editOffTitle'),
      message: _isEditMode
          ? _t(languageCode, 'editOnBody')
          : _t(languageCode, 'editOffBody'),
      type: CutePopupType.info,
    );
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

  void _selectAll(String languageCode) {
    if (!_isEditMode) {
      showCuteTopPopup(
        context,
        title: _t(languageCode, 'mustEditTitle'),
        message: _t(languageCode, 'mustEditSelectBody'),
        type: CutePopupType.warning,
      );
      return;
    }

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

    showCuteTopPopup(
      context,
      title: _selectedIndexes.length == _filteredItems.length
          ? _t(languageCode, 'allSelectedTitle')
          : _t(languageCode, 'selectionClearedTitle'),
      message: _selectedIndexes.length == _filteredItems.length
          ? _t(languageCode, 'allSelectedBody')
          : _t(languageCode, 'selectionClearedBody'),
      type: CutePopupType.info,
    );
  }

  Future<void> _deleteSelected(String languageCode) async {
    if (!_isEditMode) {
      showCuteTopPopup(
        context,
        title: _t(languageCode, 'mustEditTitle'),
        message: _t(languageCode, 'mustEditDeleteBody'),
        type: CutePopupType.warning,
      );
      return;
    }

    if (_selectedIndexes.isEmpty) {
      showCuteTopPopup(
        context,
        title: _t(languageCode, 'noneSelectedTitle'),
        message: _t(languageCode, 'noneSelectedBody'),
        type: CutePopupType.warning,
      );
      return;
    }

    final itemsToDelete = _selectedIndexes.map((i) => _filteredItems[i]).toList();

    await AfirmasiService.removeManyFavorites(itemsToDelete);
    await AfirmasiService.loadFavoritesFromLocal();
    _reloadItems();

    setState(() {
      _selectedIndexes.clear();
      _isEditMode = false;
    });

    showCuteTopPopup(
      context,
      title: _t(languageCode, 'deletedTitle'),
      message: _t(languageCode, 'deletedBody'),
      type: CutePopupType.success,
    );
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

  IconData _categoryIcon(String kategori) {
    switch (kategori) {
      case 'Cinta Diri':
        return Icons.favorite_rounded;
      case 'Motivasi':
        return Icons.wb_sunny_outlined;
      case 'Rasa Syukur':
        return Icons.eco_rounded;
      case 'Meredakan Kecemasan':
        return Icons.air_rounded;
      case 'Kesehatan Mental':
        return Icons.self_improvement_rounded;
      default:
        return Icons.auto_awesome_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: MoodlySettingsPrefs.languageNotifier,
      builder: (context, languageCode, _) {
        final textTheme = Theme.of(context).textTheme;

        return Scaffold(
          backgroundColor: _bg,
          body: SafeArea(
            child: Stack(
              children: [
                Positioned(
                  top: -42,
                  right: -32,
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: _pinkSoft,
                    ),
                  ),
                ),
                Positioned(
                  left: -56,
                  bottom: 120,
                  child: Container(
                    width: 170,
                    height: 170,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _greenSoft.withOpacity(0.72),
                    ),
                  ),
                ),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                      child: Row(
                        children: [
                          Material(
                            color: Colors.white.withOpacity(0.94),
                            shape: const CircleBorder(),
                            child: InkWell(
                              onTap: () => Navigator.pop(context, true),
                              customBorder: const CircleBorder(),
                              child: const SizedBox(
                                width: 46,
                                height: 46,
                                child: Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  size: 22,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _t(languageCode, 'header'),
                              style: textTheme.headlineLarge?.copyWith(
                                color: _textDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                        decoration: BoxDecoration(
                          color: _card.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: _softShadow,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 52,
                                  height: 52,
                                  decoration: const BoxDecoration(
                                    color: _pinkSoft,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Image.asset(
                                      'assets/icon/images/maskot_favorit.png',
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, __, ___) =>
                                          const Icon(
                                        Icons.favorite_rounded,
                                        color: _pinkStrong,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _t(languageCode, 'savedCount')
                                            .replaceFirst(
                                          '{count}',
                                          '${_allItems.length}',
                                        ),
                                        style:
                                            textTheme.titleMedium?.copyWith(
                                          color: _textDark,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _t(languageCode, 'savedBody'),
                                        style:
                                            textTheme.bodyMedium?.copyWith(
                                          color: _textSoft,
                                          fontSize: 12.5,
                                          height: 1.45,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(
                                  color: const Color(0xFFE8EDD8),
                                ),
                              ),
                              child: TextField(
                                controller: _searchController,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: _textDark,
                                  fontSize: 13,
                                ),
                                decoration: InputDecoration(
                                  hintText: _t(languageCode, 'searchHint'),
                                  hintStyle:
                                      textTheme.bodyMedium?.copyWith(
                                    color: _textSoft,
                                    fontSize: 13,
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.search_rounded,
                                    color: _textSoft,
                                  ),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            if (_isEditMode) ...[
                              const SizedBox(height: 14),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: _greenSoft,
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Text(
                                  _t(languageCode, 'selectedCount')
                                      .replaceFirst(
                                    '{count}',
                                    '${_selectedIndexes.length}',
                                  ),
                                  style: textTheme.bodySmall?.copyWith(
                                    color: _greenDark,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: _filteredItems.isEmpty
                          ? Center(
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 26,
                                ),
                                padding: const EdgeInsets.all(22),
                                decoration: BoxDecoration(
                                  color: _card.withOpacity(0.94),
                                  borderRadius: BorderRadius.circular(28),
                                  boxShadow: _softShadow,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 58,
                                      height: 58,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: _greenSoft,
                                      ),
                                      child: const Icon(
                                        Icons.favorite_border_rounded,
                                        color: _greenDark,
                                        size: 30,
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    Text(
                                      _t(languageCode, 'emptyTitle'),
                                      style: textTheme.titleMedium?.copyWith(
                                        color: _textDark,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _t(languageCode, 'emptyBody'),
                                      textAlign: TextAlign.center,
                                      style: textTheme.bodyMedium?.copyWith(
                                        color: _textSoft,
                                        fontSize: 13,
                                        height: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : ListView.separated(
                              padding:
                                  const EdgeInsets.fromLTRB(20, 4, 20, 110),
                              itemCount: _filteredItems.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final item = _filteredItems[index];
                                final kategori =
                                    item['kategori'] ?? '';
                                final color = _categoryColor(kategori);
                                final isSelected =
                                    _selectedIndexes.contains(index);

                                return _FavoriteCard(
                                  color: color,
                                  category:
                                      _categoryLabel(languageCode, kategori),
                                  text: item['teks'] ?? '',
                                  isEditMode: _isEditMode,
                                  isSelected: isSelected,
                                  icon: _categoryIcon(kategori),
                                  onToggleSelected: () =>
                                      _toggleSelected(index),
                                );
                              },
                            ),
                    ),
                  ],
                ),
                if (_allItems.isNotEmpty)
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 18,
                    child: SafeArea(
                      top: false,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _card.withOpacity(0.96),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: _softShadow,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _DockButton(
                                label: _isEditMode
                                    ? _t(languageCode, 'done')
                                    : _t(languageCode, 'edit'),
                                icon: _isEditMode
                                    ? Icons.check_rounded
                                    : Icons.edit_outlined,
                                color: _green,
                                onTap: () => _toggleEditMode(languageCode),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _DockButton(
                                label: _t(languageCode, 'selectAll'),
                                icon: Icons.done_all_rounded,
                                color: _greenDark,
                                onTap: () => _selectAll(languageCode),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _DockButton(
                                label: _t(languageCode, 'delete'),
                                icon: Icons.delete_outline_rounded,
                                color: _danger,
                                onTap: () => _deleteSelected(languageCode),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DockButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _DockButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 46,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: Colors.white),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  final Color color;
  final String category;
  final String text;
  final bool isEditMode;
  final bool isSelected;
  final IconData icon;
  final VoidCallback onToggleSelected;

  const _FavoriteCard({
    required this.color,
    required this.category,
    required this.text,
    required this.isEditMode,
    required this.isSelected,
    required this.icon,
    required this.onToggleSelected,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isEditMode ? onToggleSelected : null,
        borderRadius: BorderRadius.circular(26),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF6DAB5B)
                  : color.withOpacity(0.95),
              width: isSelected ? 2 : 1.2,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.06),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              if (isEditMode)
                Positioned(
                  right: 0,
                  top: 0,
                  child: GestureDetector(
                    onTap: onToggleSelected,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? const Color(0xFF6DAB5B)
                            : Colors.white,
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF6DAB5B)
                              : const Color(0xFFC7CEBE),
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check_rounded,
                              size: 16,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ),
                ),
              Padding(
                padding: EdgeInsets.only(right: isEditMode ? 34 : 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            icon,
                            size: 15,
                            color: const Color(0xFF414141),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              category,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: const Color(0xFF414141),
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      text,
                      style: textTheme.titleMedium?.copyWith(
                        color: const Color(0xFF212121),
                        fontSize: 20,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
