import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/styles/moodly_colors.dart';
import '../../models/diary_model.dart';
import '../../services/firestore_diary_service.dart';
import '../../services/report_diary_service.dart';
import '../../widgets/shared/moodly_app_bar.dart';
import '../../widgets/shared/moodly_user_avatar.dart';
import 'comment_page.dart';

class PublicDiaryPage extends StatefulWidget {
  const PublicDiaryPage({super.key});

  @override
  State<PublicDiaryPage> createState() => _PublicDiaryPageState();
}

class _PublicDiaryPageState extends State<PublicDiaryPage> {
  final TextEditingController searchController = TextEditingController();

  List<DiaryModel> allDiaries = [];
  List<DiaryModel> filteredDiaries = [];

  bool newestFirst = false;

  final List<String> reportCategories = [
    "Spam",
    "Kata Kasar",
    "Konten Tidak Pantas",
    "Bullying",
  ];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // ================= SEARCH =================

  void searchDiary(String value) {
    final keyword = value.toLowerCase();

    setState(() {
      filteredDiaries = allDiaries.where((diary) {
        return (diary.username).toLowerCase().contains(keyword) ||
            (diary.content).toLowerCase().contains(keyword) ||
            (diary.title).toLowerCase().contains(keyword);
      }).toList();

      if (newestFirst) {
        filteredDiaries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }
    });
  }

  // ================= FILTER =================

  void filterNewest() {
    setState(() {
      newestFirst = true;

      filteredDiaries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    });
  }

  void showFilterDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: MoodlyColors.greenLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Filter Diary",
                style: Theme.of(context).textTheme.titleMedium,
              ),

              const SizedBox(height: 20),

              ListTile(
                leading: const Icon(
                  Icons.access_time_rounded,
                  color: MoodlyColors.green,
                ),
                title: const Text("Terbaru"),
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

  // ================= REPORT DIARY =================

  void showReportDialog(DiaryModel diary) {
    final List<String> selectedCategories = [];

    final TextEditingController reasonController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: MoodlyColors.greenLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Laporkan Diary",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),

                  const SizedBox(height: 20),

                  /// CATEGORY
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: reportCategories.map((category) {
                      return FilterChip(
                        label: Text(category),
                        selected: selectedCategories.contains(category),
                        onSelected: (value) {
                          setModalState(() {
                            if (value) {
                              selectedCategories.add(category);
                            } else {
                              selectedCategories.remove(category);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

                  /// REASON
                  TextField(
                    controller: reasonController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: "Tulis alasan laporan...",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// BUTTON
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MoodlyColors.green,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      onPressed: () async {
                        if (selectedCategories.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Pilih minimal 1 kategori"),
                            ),
                          );
                          return;
                        }

                        if (reasonController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Alasan laporan wajib diisi"),
                            ),
                          );
                          return;
                        }

                        await ReportDiaryService.createReport(
                          type: "diary",

                          /// USER YANG DILAPORKAN
                          reportedUser: diary.username,
                          reportedProfile: diary.profileImage,
                          reportedUid: diary.uid,

                          /// PELAPOR
                          reportedByUid:
                              FirebaseAuth.instance.currentUser?.uid ?? "",

                          reportedByUsername:
                              FirebaseAuth.instance.currentUser?.displayName ??
                              "Unknown User",

                          /// REPORT
                          reportCategory: selectedCategories.join(", "),
                          reportReason: reasonController.text.trim(),

                          /// CONTENT
                          contentText: diary.content,

                          /// TARGET
                          diaryId: diary.id,
                        );

                        if (context.mounted) {
                          Navigator.pop(context);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Laporan berhasil dikirim ke admin",
                              ),
                            ),
                          );
                        }
                      },
                      child: const Text(
                        "Laporkan",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? "";

    return Scaffold(
      backgroundColor: MoodlyColors.bgLight,

      appBar: moodlyAppBar(context, "Diary Publik"),

      floatingActionButton: FloatingActionButton(
        backgroundColor: MoodlyColors.green,
        onPressed: showFilterDialog,
        child: const Icon(Icons.tune, color: Colors.white),
      ),

      body: Column(
        children: [
          /// SEARCH
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              onChanged: searchDiary,
              decoration: InputDecoration(
                hintText: "Cari diary...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          /// LIST DIARY
          Expanded(
            child: StreamBuilder<List<DiaryModel>>(
              stream: FirestoreDiaryService.getPublicDiaries(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        snapshot.error.toString(),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.menu_book_rounded,
                          size: 70,
                          color: MoodlyColors.textGray,
                        ),

                        const SizedBox(height: 16),

                        Text(
                          "Belum ada diary publik",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),

                        const SizedBox(height: 8),

                        Text(
                          "Diary publik akan muncul di sini ✨",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  );
                }

                final diaries = snapshot.data!;

                allDiaries = List.from(diaries);

                /// AUTO REFRESH SEARCH
                if (searchController.text.isEmpty) {
                  filteredDiaries = List.from(allDiaries);

                  if (newestFirst) {
                    filteredDiaries.sort(
                      (a, b) => b.createdAt.compareTo(a.createdAt),
                    );
                  }
                } else {
                  searchDiary(searchController.text);
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 100),
                  itemCount: filteredDiaries.length,
                  itemBuilder: (context, index) {
                    final diary = filteredDiaries[index];

                    final isLiked = diary.likedBy.contains(userId);

                    return Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),

                      padding: const EdgeInsets.all(16),

                      decoration: BoxDecoration(
                        color: MoodlyColors.greenLight,
                        borderRadius: BorderRadius.circular(24),
                      ),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// HEADER
                          Row(
                            children: [
                              MoodlyUserAvatar(
                                username: diary.username,
                                photoUrl: diary.profileImage,
                                radius: 22,
                                placeholderAsset:
                                    'assets/profile_pic/PP_default.jpg',
                              ),

                              const SizedBox(width: 10),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      diary.username,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),

                                    Text(
                                      "${diary.date} ${diary.month} ${diary.year}",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert),
                                itemBuilder: (context) => const [
                                  PopupMenuItem(
                                    value: "report",
                                    child: Text("Laporkan"),
                                  ),
                                ],
                                onSelected: (value) {
                                  if (value == "report") {
                                    showReportDialog(diary);
                                  }
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          /// ================= IMAGES =================
                          if (diary.images.isNotEmpty) ...[
                            SizedBox(
                              height: 200,

                              child: GridView.builder(
                                shrinkWrap: true,

                                physics: const NeverScrollableScrollPhysics(),

                                itemCount: diary.images.length > 4
                                    ? 4
                                    : diary.images.length,

                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 8,
                                      mainAxisSpacing: 8,
                                    ),

                                itemBuilder: (context, imageIndex) {
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(16),

                                    child: Image.network(
                                      diary.images[imageIndex],
                                      fit: BoxFit.cover,
                                    ),
                                  );
                                },
                              ),
                            ),

                            const SizedBox(height: 14),
                          ],

                          /// TITLE
                          Text(
                            diary.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 6),

                          /// CONTENT
                          Text(
                            diary.content,
                            style: const TextStyle(height: 1.5),
                          ),

                          const SizedBox(height: 16),

                          /// ACTION
                          Row(
                            children: [
                              InkWell(
                                onTap: () async {
                                  await FirestoreDiaryService.toggleDiaryLike(
                                    diaryId: diary.id,
                                    userId: userId,
                                  );
                                },

                                child: Row(
                                  children: [
                                    Icon(
                                      isLiked
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: isLiked ? Colors.red : Colors.grey,
                                    ),

                                    const SizedBox(width: 5),

                                    Text("${diary.likes}"),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 20),

                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => CommentPage(diary: diary),
                                    ),
                                  );
                                },

                                child: Row(
                                  children: [
                                    const Icon(Icons.comment),

                                    const SizedBox(width: 5),

                                    Text("${diary.comments}"),
                                  ],
                                ),
                              ),
                            ],
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
    );
  }
}
