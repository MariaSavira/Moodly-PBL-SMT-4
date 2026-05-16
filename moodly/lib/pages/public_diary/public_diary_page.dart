import 'package:flutter/material.dart';

import '../../models/public_diary_model.dart';
import '../../services/report_diary_service.dart';
import 'comment_page.dart';

class PublicDiaryPage extends StatefulWidget {
  const PublicDiaryPage({super.key});

  @override
  State<PublicDiaryPage> createState() => _PublicDiaryPageState();
}

class _PublicDiaryPageState extends State<PublicDiaryPage> {
  final TextEditingController searchController = TextEditingController();

  final List<String> reportCategories = [
    "Spam",
    "Kata Kasar",
    "Konten Tidak Pantas",
    "Bullying",
  ];

  List<PublicDiaryModel> diaries = [
    PublicDiaryModel(
      id: "1",
      username: "Kucing Oren Imut",
      text: "Semoga PBL berjalan dengan lancar dan mendapatkan hasil terbaik",
      profileImage: "assets/profile_pic/PP_2.png",
      hasImage: false,
      likes: 30,
      comments: 4,
      createdAt: DateTime.now(),
    ),

    PublicDiaryModel(
      id: "2",
      username: "SigmaCat67",
      text: "semoga semua proses PBL dimudahkan dan berjalan lancar",
      profileImage: "assets/profile_pic/PP_8.png",
      hasImage: false,
      likes: 10,
      comments: 2,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),

    PublicDiaryModel(
      id: "3",
      username: "King Dove Jr.",
      text: "Semoga semua mendapatkan hasil terbaik dan dilancarkan",
      profileImage: "assets/profile_pic/PP_14.png",
      hasImage: true,
      likes: 99,
      comments: 4,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  List<PublicDiaryModel> filteredDiaries = [];

  @override
  void initState() {
    super.initState();

    filteredDiaries = diaries;
  }

  // SEARCH
  void searchDiary(String value) {
    final keyword = value.toLowerCase();

    setState(() {
      filteredDiaries = diaries.where((diary) {
        return diary.username.toLowerCase().contains(keyword) ||
            diary.text.toLowerCase().contains(keyword);
      }).toList();
    });
  }

  // FILTER POPULAR
  void filterPopular() {
    setState(() {
      filteredDiaries.sort((a, b) => b.likes.compareTo(a.likes));
    });
  }

  // FILTER NEWEST
  void filterNewest() {
    setState(() {
      filteredDiaries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    });
  }

  // LIKE
  void toggleLike(int index) {
    setState(() {
      filteredDiaries[index].isLiked = !filteredDiaries[index].isLiked;

      if (filteredDiaries[index].isLiked) {
        filteredDiaries[index].likes++;
      } else {
        filteredDiaries[index].likes--;
      }
    });
  }

  // SUCCESS DIALOG
  void showSuccessDialog() {
    showDialog(
      context: context,

      builder: (context) {
        return Dialog(
          backgroundColor: const Color(0xFFDDE6B8),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),

          child: Padding(
            padding: const EdgeInsets.all(24),

            child: Column(
              mainAxisSize: MainAxisSize.min,

              children: [
                Container(
                  height: 70,
                  width: 70,

                  decoration: const BoxDecoration(
                    color: Color(0xFFF1D1D7),
                    shape: BoxShape.circle,
                  ),

                  child: const Icon(Icons.check, size: 40),
                ),

                const SizedBox(height: 18),

                const Text(
                  "Laporan Terkirim",

                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),

                const Text(
                  "Laporan akan diproses admin",

                  textAlign: TextAlign.center,

                  style: TextStyle(fontSize: 12),
                ),

                const SizedBox(height: 18),

                SizedBox(
                  width: double.infinity,

                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF1D1D7),

                      foregroundColor: Colors.black,

                      elevation: 0,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),

                    child: const Text("OK"),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // REPORT
  void showReportDialog(int index) {
    showModalBottomSheet(
      context: context,

      backgroundColor: const Color(0xFFDDE6B8),

      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),

      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),

          child: Column(
            mainAxisSize: MainAxisSize.min,

            children: [
              const Text(
                "Laporkan Postingan",

                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              ...reportCategories.map((category) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),

                  child: Material(
                    color: const Color(0xFFF1D1D7),

                    borderRadius: BorderRadius.circular(18),

                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),

                      onTap: () async {
                        await ReportDiaryService.createReport(
                          reportedUser: filteredDiaries[index].username,

                          reportedProfile: filteredDiaries[index].profileImage,

                          reportCategory: category,

                          diaryText: filteredDiaries[index].text,

                          reportedBy: "USER_LOGIN_ID",

                          diaryId: filteredDiaries[index].id,
                        );

                        Navigator.pop(context);

                        showSuccessDialog();
                      },

                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 15,
                        ),

                        child: Row(
                          children: [
                            const Icon(Icons.flag_rounded),

                            const SizedBox(width: 10),

                            Text(
                              category,

                              style: const TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  // FILTER DIALOG
  void showFilterDialog() {
    showModalBottomSheet(
      context: context,

      backgroundColor: const Color(0xFFDDE6B8),

      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),

      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),

          child: Column(
            mainAxisSize: MainAxisSize.min,

            children: [
              const Text(
                "Filter Diary",

                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              ListTile(
                tileColor: const Color(0xFFF1D1D7),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),

                leading: const Icon(Icons.local_fire_department),

                title: const Text("Terpopuler", style: TextStyle(fontSize: 13)),

                onTap: () {
                  Navigator.pop(context);

                  filterPopular();
                },
              ),

              const SizedBox(height: 12),

              ListTile(
                tileColor: const Color(0xFFF1D1D7),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),

                leading: const Icon(Icons.access_time),

                title: const Text("Terbaru", style: TextStyle(fontSize: 13)),

                onTap: () {
                  Navigator.pop(context);

                  filterNewest();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8EBCF),

      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),

              child: Column(
                children: [
                  // ATAS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                    children: [
                      const Text(
                        "Public Diary",

                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const CircleAvatar(
                        radius: 24,

                        backgroundImage: AssetImage(
                          "assets/profile_pic/PP_2.png",
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // FILTER + SEARCH
                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          showFilterDialog();
                        },

                        child: Container(
                          padding: const EdgeInsets.all(12),

                          decoration: BoxDecoration(
                            color: const Color(0xFFF1D1D7),

                            borderRadius: BorderRadius.circular(16),
                          ),

                          child: const Icon(Icons.tune_rounded, size: 22),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1D1D7),

                            borderRadius: BorderRadius.circular(18),
                          ),

                          child: TextField(
                            controller: searchController,

                            onChanged: searchDiary,

                            style: const TextStyle(fontSize: 13),

                            decoration: const InputDecoration(
                              hintText: "Cari diary...",

                              hintStyle: TextStyle(fontSize: 13),

                              border: InputBorder.none,

                              prefixIcon: Icon(Icons.search),

                              contentPadding: EdgeInsets.symmetric(
                                vertical: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // LIST DIARY
            Expanded(
              child: ListView.builder(
                itemCount: filteredDiaries.length,

                itemBuilder: (context, index) {
                  final diary = filteredDiaries[index];

                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),

                    padding: const EdgeInsets.all(16),

                    decoration: BoxDecoration(
                      color: const Color(0xFFDDE6B8),

                      borderRadius: BorderRadius.circular(24),

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
                            CircleAvatar(
                              radius: 22,

                              backgroundImage: AssetImage(diary.profileImage),
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,

                                    children: [
                                      Expanded(
                                        child: Text(
                                          diary.username,

                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),

                                      IconButton(
                                        onPressed: () {
                                          showReportDialog(index);
                                        },

                                        icon: const Icon(Icons.more_horiz),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 4),

                                  Text(
                                    diary.text,

                                    style: const TextStyle(
                                      fontSize: 12,
                                      height: 1.6,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        if (diary.hasImage) ...[
                          const SizedBox(height: 14),

                          Center(
                            child: Container(
                              height: 120,
                              width: 120,

                              decoration: BoxDecoration(
                                color: const Color(0xFF1D2238),

                                borderRadius: BorderRadius.circular(14),
                              ),

                              child: const Center(
                                child: Text(
                                  "prayer circle",

                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 16),

                        Row(
                          children: [
                            InkWell(
                              onTap: () {
                                toggleLike(index);
                              },

                              child: Icon(
                                diary.isLiked
                                    ? Icons.favorite
                                    : Icons.favorite_border,

                                color: diary.isLiked
                                    ? Colors.red
                                    : Colors.black,

                                size: 24,
                              ),
                            ),

                            const SizedBox(width: 18),

                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,

                                  MaterialPageRoute(
                                    builder: (_) => CommentPage(diary: diary),
                                  ),
                                );
                              },

                              child: const Icon(
                                Icons.mode_comment_outlined,
                                size: 23,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,

                          children: [
                            Text(
                              "${diary.likes} suka - ${diary.comments} komentar",

                              style: TextStyle(
                                color: Colors.grey.shade700,

                                fontSize: 11,
                              ),
                            ),

                            Text(
                              "19.57 - 09 Apr 26",

                              style: TextStyle(
                                color: Colors.grey.shade700,

                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
