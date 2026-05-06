import 'package:flutter/material.dart';
import '../core/styles/app_text.dart';
import 'streak/streak_page.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  String moodHariIni = 'Marah';
  String tipMood = 'Pelan-pelan ya, semuanya bisa dibicarakan nanti 😉';
  int streakCount = 99;

  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6FF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.settings, color: Colors.green[700]),
                      const SizedBox(width: 16),
                      Icon(Icons.notifications, color: Colors.green[700]),
                    ],
                  ),
                  CircleAvatar(
                    radius: 28,
                    backgroundImage: AssetImage('assets/profile_pic/PP.png'), // contoh
                    child: Stack(
                      children: [
                        Positioned(
                          top: -4,
                          right: -4,
                          child: Image.asset(
                            'assets/maskot.png',
                            width: 24,
                            height: 24,
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Greeting
              Row(
                children: [
                  Text('Selamat pagi, ', style: AppText.subtitle(context)),
                  Text('Kucing Oren Imut', style: AppText.title(context)),
                ],
              ),
              const SizedBox(height: 16),
              // Mood + Streak Cards
              Row(
                children: [
                  // Streak card
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const StreakPage()),
                      );
                    },
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.red[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Streak', style: AppText.body(context)),
                          Text('$streakCount🔥', style: AppText.subtitle(context)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Mood hari ini
                  Expanded(
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFC1C1), Color(0xFFD6FFD6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Mood Hari ini : $moodHariIni', style: AppText.subtitle(context)),
                          const SizedBox(height: 4),
                          Text('Tip: $tipMood', style: AppText.body(context)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Calendar bar
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        selectedDate = selectedDate.subtract(const Duration(days: 1));
                      });
                    },
                    icon: const Icon(Icons.arrow_back_ios, size: 16),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(7, (index) {
                          final day = DateTime.now().subtract(Duration(days: 6 - index));
                          final selected = day.day == selectedDate.day;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedDate = day;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: selected ? Colors.green[300] : Colors.green[50],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  Text('${day.day}', style: AppText.body(context)),
                                  Text(
                                    ['Min','Sen','Sel','Rab','Kam','Jum','Sab'][day.weekday % 7],
                                    style: AppText.bodyAlt(context),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        selectedDate = selectedDate.add(const Duration(days: 1));
                      });
                    },
                    icon: const Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Pilih Tanggal'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Mood Harian cards
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Diary card
                      Container(
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            const Icon(Icons.beach_access, size: 36),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Bagaimana liburanmu?', style: AppText.subtitle(context)),
                                  const Spacer(),
                                  ElevatedButton(
                                    onPressed: () {},
                                    child: const Icon(Icons.add),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Mood Tracker & Reminder row
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(child: Text('Mood Terakhir Graph')),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(child: Text('Reminder')),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: Colors.green[700],
        unselectedItemColor: Colors.green[200],
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Diary'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Connect'),
          BottomNavigationBarItem(icon: Icon(Icons.local_florist), label: 'Afirmasi'),
        ],
      ),
    );
  }
}