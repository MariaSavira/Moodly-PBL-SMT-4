import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Public Diary',
      theme: ThemeData(
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: const Color(0xFFF2F4DA),
      ),
      home: const PublicDiaryPage(),
    );
  }
}

class PublicDiaryPage extends StatelessWidget {
  const PublicDiaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),

            // HEADER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(Icons.arrow_back_ios_new_rounded),
                  ),

                  const SizedBox(width: 10),

                  const Text(
                    "Public Diary",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),

                  const Spacer(),

                  const CircleAvatar(
                    radius: 22,
                    backgroundImage: NetworkImage(
                      'https://i.pravatar.cc/150?img=3',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // SEARCH BAR
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8B8BE),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.tune_rounded),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2D0D6),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "Search...",
                              ),
                            ),
                          ),
                          Icon(Icons.search),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // LIST POST
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                children: const [
                  DiaryCard(
                    username: "Kucing Oren Imut",
                    text:
                        "Semoga PBL berjalan dengan lancar, dimudahkan dalam setiap prosesnya, dan mendapatkan hasil yang terbaik",
                    image: false,
                  ),

                  SizedBox(height: 18),

                  DiaryCard(
                    username: "SigmaCat67",
                    text:
                        "semoga PBL berjalan dengan lancar dan mendapatkan hasil yang terbaik",
                    image: false,
                  ),

                  SizedBox(height: 18),

                  DiaryCard(
                    username: "King Dove Jr.",
                    text:
                        "Semoga PBL berjalan dengan lancar, dimudahkan dalam setiap prosesnya, dan mendapatkan hasil yang terbaik",
                    image: true,
                  ),

                  SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DiaryCard extends StatelessWidget {
  final String username;
  final String text;
  final bool image;

  const DiaryCard({
    super.key,
    required this.username,
    required this.text,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),

      decoration: BoxDecoration(
        color: const Color(0xFFDDE6B8),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              const CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(
                  'https://i.pravatar.cc/150?img=5',
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      username,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      text,
                      style: const TextStyle(fontSize: 16, height: 1.4),
                    ),
                  ],
                ),
              ),

              const Icon(Icons.more_horiz),
            ],
          ),

          if (image) ...[
            const SizedBox(height: 12),

            Container(
              height: 120,
              width: 110,
              color: Colors.black87,

              child: const Center(
                child: Text("GIF", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],

          const SizedBox(height: 15),

          const Row(
            children: [
              Icon(Icons.favorite_border, size: 30),

              SizedBox(width: 15),

              Icon(Icons.mode_comment_outlined, size: 28),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              Text(
                "30 Suka - 4 Komentar",
                style: TextStyle(color: Colors.grey.shade700),
              ),

              const Spacer(),

              Text(
                "19.57 - 09 Apr 26",
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
