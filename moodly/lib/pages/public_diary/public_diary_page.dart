import 'package:flutter/material.dart';

import '../../models/diary_model.dart';
import '../../services/firestore_diary_service.dart';
import '../../services/report_diary_service.dart';
import 'comment_page.dart';

class PublicDiaryPage extends StatefulWidget {
  const PublicDiaryPage({super.key});

  @override
  State<PublicDiaryPage> createState() => _PublicDiaryPageState();
}

class _PublicDiaryPageState extends State<PublicDiaryPage> {
  final TextEditingController searchController = TextEditingController();

  final FirestoreDiaryService _service = FirestoreDiaryService();

  final List<String> reportCategories = [
    "Spam",
    "Kata Kasar",
    "Konten Tidak Pantas",
    "Bullying",
  ];

  List<DiaryModel> allDiaries = [];

  List<DiaryModel> filteredDiaries = [];

  // ================= SEARCH =================

  void searchDiary(String value) {
    final keyword = value.toLowerCase();

    setState(() {
      filteredDiaries = allDiaries.where((diary) {
        return diary.username.toLowerCase().contains(keyword) ||
            diary.content.toLowerCase().contains(keyword) ||
            diary.title.toLowerCase().contains(keyword);
      }).toList();
    });
  }

  // ================= FILTER =================

  void filterPopular() {
    setState(() {
      filteredDiaries.sort((a, b) => b.date.compareTo(a.date));
    });
  }

  void filterNewest() {
    setState(() {
      filteredDiaries.sort((a, b) => b.date.compareTo(a.date));
    });
  }

  // ================= SUCCESS DIALOG =================

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

  // ================= REPORT =================

  void showReportDialog(DiaryModel diary) {
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
                          reportedUser: diary.username,

                          reportedProfile: "",

                          reportCategory: category,

                          diaryText: diary.content,

                          reportedBy: "USER_LOGIN_ID",

                          diaryId: diary.id,
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

  // ================= FILTER DIALOG =================

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

  // ================= TOGGLE LIKE =================

  void toggleLike(DiaryModel diary) {
    setState(() {
      diary.isLiked = !diary.isLiked;

      if (diary.isLiked) {
        diary.likes++;
      } else {
        diary.likes--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8EBCF),

      body: SafeArea(
        child: Column(
          children: [
            // ================= HEADER =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),

              child: Column(
                children: [
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

            // ================= LIST DIARY =================
            Expanded(
              child: StreamBuilder<List<DiaryModel>>(
                stream: _service.getPublicDiaries(),

                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("Belum ada public diary"));
                  }

                  allDiaries = snapshot.data!;

                  if (searchController.text.isEmpty) {
                    filteredDiaries = allDiaries;
                  }

                  return ListView.builder(
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
                                const CircleAvatar(
                                  radius: 22,

                                  backgroundImage: AssetImage(
                                    "assets/profile_pic/PP_2.png",
                                  ),
                                ),

                                const SizedBox(width: 12),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,

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

                                          PopupMenuButton(
                                            icon: const Icon(Icons.more_horiz),

                                            itemBuilder: (context) {
                                              return [
                                                const PopupMenuItem(
                                                  value: "report",

                                                  child: Text("Laporkan"),
                                                ),
                                              ];
                                            },

                                            onSelected: (value) {
                                              if (value == "report") {
                                                showReportDialog(diary);
                                              }
                                            },
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 4),

                                      Text(
                                        diary.title,

                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),

                                      const SizedBox(height: 6),

                                      Text(
                                        diary.content,

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

                            const SizedBox(height: 16),

                            // ================= BUTTONS =================
                            Row(
                              children: [
                                // LIKE
                                Material(
                                  color: Colors.transparent,

                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(30),

                                    onTap: () {
                                      toggleLike(diary);
                                    },

                                    child: Padding(
                                      padding: const EdgeInsets.all(6),

                                      child: Row(
                                        children: [
                                          Icon(
                                            diary.isLiked
                                                ? Icons.favorite
                                                : Icons.favorite_border,

                                            color: diary.isLiked
                                                ? Colors.red
                                                : Colors.black,

                                            size: 24,
                                          ),

                                          const SizedBox(width: 6),

                                          Text("${diary.likes}"),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 18),

                                // COMMENT
                                Material(
                                  color: Colors.transparent,

                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(30),

                                    onTap: () {
                                      Navigator.push(
                                        context,

                                        MaterialPageRoute(
                                          builder: (context) =>
                                              CommentPage(diary: diary),
                                        ),
                                      );
                                    },

                                    child: Padding(
                                      padding: const EdgeInsets.all(6),

                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.mode_comment_outlined,

                                            size: 23,
                                          ),

                                          const SizedBox(width: 6),

                                          Text("${diary.comments}"),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            Text(
                              "${diary.time} - ${diary.date} ${diary.month} ${diary.year}",

                              style: TextStyle(
                                color: Colors.grey.shade700,

                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
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
