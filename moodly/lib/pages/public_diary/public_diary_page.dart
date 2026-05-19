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

  final List<String> reportCategories = [
    "Spam",
    "Kata Kasar",
    "Konten Tidak Pantas",
    "Bullying",
  ];

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

  void filterNewest() {
    setState(() {
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

                  TextField(
                    controller: reasonController,
                    maxLines: 4,

                    decoration: const InputDecoration(
                      hintText: "Tulis alasan laporan...",
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,

                    child: ElevatedButton(
                      onPressed: () async {
                        await ReportDiaryService.createReport(
                          reportedUser: diary.username,

                          reportedProfile: diary.profileImage,

                          reportCategory: selectedCategories.join(", "),

                          diaryText: diary.content,

                          reportedBy:
                              FirebaseAuth.instance.currentUser?.uid ?? "",

                          diaryId: diary.id,
                        );

                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      },

                      child: const Text("Laporkan"),
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

          Expanded(
            child: StreamBuilder<List<DiaryModel>>(
              stream: FirestoreDiaryService.getPublicDiaries(),

              builder: (context, snapshot) {
                /// ERROR
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

                /// LOADING
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                /// EMPTY
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

                allDiaries = diaries;

                if (searchController.text.isEmpty) {
                  filteredDiaries = diaries;
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
                          Row(
                            children: [
                              MoodlyUserAvatar(
                                username: diary.username,

                                radius: 22,

                                placeholderAsset:
                                    'assets/profile_pic/PP_default.jpg',
                              ),

                              const SizedBox(width: 10),

                              Expanded(
                                child: Text(
                                  diary.username,

                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),

                              PopupMenuButton(
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

                          Text(
                            diary.title,

                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 6),

                          Text(
                            diary.content,

                            style: const TextStyle(height: 1.5),
                          ),

                          const SizedBox(height: 16),

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
