import 'package:firebase_auth/firebase_auth.dart';
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
    _initStreak();
  }

  Future<void> _initStreak() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final streak = await _service.getStreak(uid);

    // Auto daily logic
    final now = DateTime.now();
    final last = streak.lastUpdate;

    if (!_isSameDay(now, last)) {
      final daysMissed = now.difference(last).inDays;
      if (daysMissed == 1) {
        // normal increment
        streak.currentDay = streak.currentDay < 7 ? streak.currentDay + 1 : 1;
        streak.completed = [false, false, false];
      } else if (daysMissed > 1) {
        // skipped more than 1 day
        if (streak.freezeLeft > 0) {
          streak.freezeLeft--;
          streak.freezeActive = false; // freeze consumed automatically
        } else {
          streak.currentDay = 1;
          streak.completed = [false, false, false];
        }
      }
      streak.lastUpdate = now;
      await _service.updateStreak(uid, streak);
    }

    setState(() {
      _streak = streak;
      _loading = false;
    });
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _completeQuest(int index) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    if (!_streak.completed[index]) {
      setState(() {
        _streak.completed[index] = true;
        _streak.totalPoints += _dailyPoints[_streak.currentDay - 1];
      });
      await _service.updateStreak(uid, _streak);
      _showPoinAnimation(_dailyPoints[_streak.currentDay - 1]);
    }
  }

  void _activateFreeze() async {
    if (_streak.freezeLeft > 0 && !_streak.freezeActive) {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Aktifkan Freeze"),
          content: const Text("Apakah kamu yakin ingin menggunakan satu kesempatan freeze hari ini?"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
            TextButton(
              onPressed: () async {
                setState(() {
                  _streak.freezeActive = true;
                  _streak.freezeLeft--;
                });
                await _service.updateStreak(uid, _streak);
                Navigator.pop(context);
              },
              child: const Text("Ya"),
            ),
          ],
        ),
      );
    }
  }

  void _tukarReward() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    if (_streak.totalPoints >= 300) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Tukar Poin"),
          content: const Text("Kamu bisa menukar 300 poin untuk Premium 1 bulan!"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
            TextButton(
              onPressed: () async {
                setState(() {
                  _streak.totalPoints -= 300;
                });
                await _service.updateStreak(uid, _streak);
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
          ],
        ),
      ),
    );
  }
}