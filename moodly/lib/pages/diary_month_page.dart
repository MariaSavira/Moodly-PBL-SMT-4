import 'package:flutter/material.dart';
import '../controllers/diary_controller.dart';

class DiaryMonthPage extends StatefulWidget {
  const DiaryMonthPage({super.key});

  @override
  State<DiaryMonthPage> createState() => _DiaryMonthPageState();
}

class _DiaryMonthPageState extends State<DiaryMonthPage> {
  final DiaryController controller = DiaryController();

  @override
  Widget build(BuildContext context) {
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
                  itemCount: controller.months.length,
                  itemBuilder: (context, index) {
                    final month = controller.months[index];
                    return MonthGridItem(
                      monthName: month,
                      isSelected: month == controller.selectedMonth,
                      onTap: () {
                        setState(() {
                          controller.selectMonth(month);
                        });
                        _showSnackbar(context, 'Membuka bulan: $month');
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
          Text('Private Diary', style: Theme.of(context).textTheme.titleMedium),
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
            alignment: controller.isBulanView
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
                      controller.toggleViewMode();
                    });
                  },
                  child: Text(
                    'Bulan',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: controller.isBulanView
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
                      controller.toggleViewMode();
                    });
                  },
                  child: Text(
                    'Pekan',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: !controller.isBulanView
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
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold, // 👈 PAKSA TEBEL
          ),
        ),
      ),
    );
  }

  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFA8D5A2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}

class MonthGridItem extends StatelessWidget {
  final String monthName;
  final bool isSelected;
  final VoidCallback onTap;

  const MonthGridItem({
    super.key,
    required this.monthName,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFD5E5) : const Color(0xFFA8D5A2),
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
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold, // 👈 PAKSA TEBEL
            ),
          ),
        ),
      ),
    );
  }
}
