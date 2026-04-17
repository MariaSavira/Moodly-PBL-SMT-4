import 'package:flutter/foundation.dart';

class DiaryController extends ChangeNotifier {
  // STATE
  String _selectedMonth = 'MAR';
  bool _isBulanView = true;
  int _navIndex = 1; // 0: Beranda, 1: Diary, 2: Connect, 3: Afirmasi

  // GETTER
  String get selectedMonth => _selectedMonth;
  bool get isBulanView => _isBulanView;
  int get navIndex => _navIndex;

  // DATA BULAN
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

  // LOGIC
  void selectMonth(String month) {
    if (_selectedMonth != month) {
      _selectedMonth = month;
      notifyListeners();
    }
  }

  void toggleViewMode() {
    _isBulanView = !_isBulanView;
    notifyListeners();
  }

  void changeNavIndex(int index) {
    if (_navIndex != index) {
      _navIndex = index;
      notifyListeners();
    }
  }
}
