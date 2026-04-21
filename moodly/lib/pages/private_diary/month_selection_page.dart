import 'package:flutter/material.dart';
import 'diary_list_page.dart';

class MonthSelectionPage extends StatefulWidget {
  const MonthSelectionPage({super.key});

  @override
  State<MonthSelectionPage> createState() => _MonthSelectionPageState();
}

class _MonthSelectionPageState extends State<MonthSelectionPage> {
  final List<String> months = [
    'JAN',
    'FEB',
    'MAR',
    'APR',
    'MEI',
    'JUN',
    'JUL',
    'AGS',
    'SEP',
    'OKT',
    'NOV',
    'DES',
  ];

  String? selectedMonth;
  bool isBulanView = true;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final currentMonthIndex = now.month - 1;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9E6),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildToolbar(context),
            _buildYearLabel(context),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.35,
                  ),
                  itemCount: months.length,
                  itemBuilder: (context, index) {
                    final month = months[index];
                    final isCurrentMonth = index == currentMonthIndex;
                    final isPastMonth = index < currentMonthIndex;
                    final isSelected = month == selectedMonth;

                    return MonthGridItem(
                      monthName: month,
                      isSelected: isSelected,
                      isCurrentMonth: isCurrentMonth,
                      isPastMonth: isPastMonth,
                      onTap: () {
                        setState(() {
                          selectedMonth = month;
                        });

                        if (!isPastMonth && !isCurrentMonth) {
                          _showFutureMonthDialog(context, month);
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DiaryListPage(
                                month: index + 1,
                                year: now.year,
                                isPastMonth: isPastMonth,
                              ),
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF2D2D2D)),
            onPressed: () => Navigator.pop(context),
          ),
          const Text(
            'Private Diary',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              fontFamily: 'Fredoka',
              color: Color(0xFF2D2D2D),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _buildIconBtn(Icons.tune, () {}),
          const SizedBox(width: 12),
          Expanded(child: _buildToggle(context)),
          const SizedBox(width: 12),
          _buildIconBtn(Icons.search, () {}),
        ],
      ),
    );
  }

  Widget _buildIconBtn(IconData icon, VoidCallback onTap) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFF8B8C3).withOpacity(0.5),
        borderRadius: BorderRadius.circular(22),
      ),
      child: IconButton(
        icon: Icon(icon, color: const Color(0xFF2D2D2D), size: 20),
        onPressed: onTap,
      ),
    );
  }

  Widget _buildToggle(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFF8B8C3).withOpacity(0.4),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            alignment: isBulanView
                ? Alignment.centerLeft
                : Alignment.centerRight,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.28,
              height: 40,
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: const Color(0xFFF8B8C3),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      isBulanView = true;
                    });
                  },
                  child: Text(
                    'Bulan',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isBulanView
                          ? const Color(0xFF2D2D2D)
                          : Colors.black.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      isBulanView = false;
                    });
                  },
                  child: Text(
                    'Pekan',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: !isBulanView
                          ? const Color(0xFF2D2D2D)
                          : Colors.black.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildYearLabel(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 0, 16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          '2025',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'Fredoka',
            color: Color(0xFF2D2D2D),
          ),
        ),
      ),
    );
  }

  void _showFutureMonthDialog(BuildContext context, String month) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFF5F9E6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          '⏳ Bulan Belum Tiba',
          style: TextStyle(fontFamily: 'Fredoka', fontWeight: FontWeight.bold),
        ),
        content: Text(
          '$month belum tiba. Fokus di bulan sekarang dulu ya!',
          style: const TextStyle(fontFamily: 'OpenSans'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Oke',
              style: TextStyle(
                color: Color(0xFFA8D5A2),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MonthGridItem extends StatelessWidget {
  final String monthName;
  final bool isSelected;
  final bool isCurrentMonth;
  final bool isPastMonth;
  final VoidCallback onTap;

  const MonthGridItem({
    super.key,
    required this.monthName,
    required this.isSelected,
    required this.isCurrentMonth,
    required this.isPastMonth,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    if (isSelected) {
      backgroundColor = const Color(0xFFFFD5E5);
    } else if (isCurrentMonth) {
      backgroundColor = const Color(0xFFFFD5E5);
    } else if (isPastMonth) {
      backgroundColor = const Color(0xFFA8D5A2);
    } else {
      backgroundColor = const Color(0xFFA8D5A2);
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            monthName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Fredoka',
              color: Color(0xFF2D2D2D),
            ),
          ),
        ),
      ),
    );
  }
}
