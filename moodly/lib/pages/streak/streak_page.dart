import 'package:flutter/material.dart';
import '../../core/models/streak_model.dart';
import '../../core/services/streak_service.dart';
import '../../core/styles/app_text.dart';

class StreakPage extends StatefulWidget {
  const StreakPage({super.key});

  @override
  State<StreakPage> createState() => _StreakPageState();
}

class _StreakPageState extends State<StreakPage> with SingleTickerProviderStateMixin {
  final StreakService _service = StreakService();
  late StreakModel _streak;
  bool _loading = true;

  final List<int> _dailyPoints = [10, 10, 10, 10, 25, 50, 100];

  @override
  void initState() {
    super.initState();
    _loadStreak();
  }

  Future<void> _loadStreak() async {
    final streak = await _service.getStreak('USER_UID'); // ganti dengan uid dari Auth
    setState(() {
      _streak = streak;
      _loading = false;
    });
  }

  void _completeQuest(int index) {
    if (!_streak.completed[index]) {
      setState(() {
        _streak.completed[index] = true;
        _streak.totalPoints += _dailyPoints[_streak.currentDay - 1];
      });
      _service.updateStreak('USER_UID', _streak);
      _showPoinAnimation(_dailyPoints[_streak.currentDay - 1]);
    }
  }

  void _activateFreeze() {
    if (_streak.freezeLeft > 0 && !_streak.freezeActive) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Aktifkan Freeze"),
          content: const Text("Apakah kamu yakin ingin menggunakan satu kesempatan freeze hari ini?"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
            TextButton(
              onPressed: () {
                setState(() {
                  _streak.freezeActive = true;
                  _streak.freezeLeft--;
                });
                _service.updateStreak('USER_UID', _streak);
                Navigator.pop(context);
              },
              child: const Text("Ya"),
            ),
          ],
        ),
      );
    }
  }

  void _nextDay() {
    setState(() {
      if (_streak.currentDay < 7) {
        _streak.currentDay++;
      } else {
        _streak.currentDay = 1;
        _streak.completed = [false, false, false];
      }
      _streak.freezeActive = false;
    });
    _service.updateStreak('USER_UID', _streak);
  }

  void _tukarReward() {
    if (_streak.totalPoints >= 300) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Tukar Poin"),
          content: const Text("Kamu bisa menukar 300 poin untuk Premium 1 bulan!"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
            TextButton(
              onPressed: () {
                setState(() {
                  _streak.totalPoints -= 300;
                });
                _service.updateStreak('USER_UID', _streak);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Selamat! Premium 1 bulan aktif.")),
                );
              },
              child: const Text("Tukar"),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Poin tidak cukup untuk menukar.")),
      );
    }
  }

  void _showPoinAnimation(int poin) {
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(builder: (_) {
      return Positioned(
        top: 100,
        left: MediaQuery.of(context).size.width / 2 - 50,
        child: AnimatedOpacity(
          opacity: 0.0,
          duration: const Duration(seconds: 1),
          child: Text(
            '+$poin',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
          ),
        ),
      );
    });
    overlay?.insert(entry);
    Future.delayed(const Duration(seconds: 1), () => entry.remove());
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      appBar: AppBar(
        title: Text('Streak', style: AppText.title(context)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Animated Progress Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (index) {
                bool done = _streak.currentDay > index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: done ? Colors.green[300] : Colors.pink[100],
                    shape: BoxShape.circle,
                  ),
                  child: Text('+${_dailyPoints[index]}', style: AppText.body(context)),
                );
              }),
            ),
            const SizedBox(height: 20),
            // Quest list
            ...List.generate(_streak.completed.length, (index) {
              return Card(
                color: _streak.completed[index] ? Colors.green[100] : Colors.white,
                child: ListTile(
                  title: Text('Quest ${index + 1}', style: AppText.subtitle(context)),
                  trailing: IconButton(
                    icon: Icon(_streak.completed[index] ? Icons.check_circle : Icons.circle_outlined, color: Colors.green),
                    onPressed: () => _completeQuest(index),
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),
            // Freeze button
            ElevatedButton(
              onPressed: _activateFreeze,
              child: Text('Aktifkan Freeze (${_streak.freezeLeft} tersisa)'),
            ),
            const SizedBox(height: 8),
            // Reward button
            ElevatedButton(
              onPressed: _tukarReward,
              child: const Text("Tukar Poin Reward"),
            ),
            const SizedBox(height: 12),
            // Premium CTA
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.purple[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star, color: Colors.purple),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Dapatkan poin tambahan dengan berlangganan Moodly Premium!",
                      style: AppText.body(context),
                    ),
                  ),
                  ElevatedButton(onPressed: () {}, child: const Text("Upgrade"))
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Next day button (testing)
            ElevatedButton(
              onPressed: _nextDay,
              child: const Text("Next Day (Simulasi)"),
            ),
          ],
        ),
      ),
    );
  }
}