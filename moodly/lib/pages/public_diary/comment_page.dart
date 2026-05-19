// ===============================
// COMMENT PAGE FINAL REALTIME
// ===============================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/styles/moodly_colors.dart';
import '../../models/diary_model.dart';
import '../../services/comment_service.dart';
import '../../services/report_comment_service.dart';
import '../../widgets/shared/moodly_user_avatar.dart';

class CommentPage extends StatefulWidget {
  final DiaryModel diary;

  const CommentPage({super.key, required this.diary});

  @override
  State<CommentPage> createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  final TextEditingController commentController = TextEditingController();

  final List<String> reportCategories = [
    "Spam",
    "Kata Kasar",
    "Konten Tidak Pantas",
    "Bullying",
  ];

  String? replyingCommentId;

  // =========================
  // ADD COMMENT / REPLY
  // =========================

  Future<void> sendComment() async {
    if (commentController.text.trim().isEmpty) return;

    final text = commentController.text.trim();

    final user = FirebaseAuth.instance.currentUser;

    if (replyingCommentId != null) {
      await CommentService.addReply(
        diaryId: widget.diary.id,
        commentId: replyingCommentId!,
        username: "Kamu",
        profileImage: "",
        reply: text,
      );

      replyingCommentId = null;
    } else {
      await CommentService.addComment(
        diaryId: widget.diary.id,
        username: "Kamu",
        profileImage: "",
        comment: text,
      );
    }

    commentController.clear();
  }

  // =========================
  // REPORT COMMENT
  // =========================

  void showReportDialog(Map<String, dynamic> comment, String commentId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: MoodlyColors.greenLight,
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
                "Laporkan Komentar",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              ...reportCategories.map((category) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),

                  child: Material(
                    color: MoodlyColors.pinkLight,

                    borderRadius: BorderRadius.circular(18),

                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),

                      onTap: () async {
                        await ReportCommentService.createReport(
                          reportedUser: comment["username"],
                          reportedProfile: comment["profile_image"] ?? "",
                          reportCategory: category,
                          commentText: comment["comment"],
                          reportedBy:
                              FirebaseAuth.instance.currentUser?.uid ?? "",
                          diaryId: widget.diary.id,
                          commentId: commentId,
                        );

                        if (context.mounted) {
                          Navigator.pop(context);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Laporan berhasil dikirim"),
                            ),
                          );
                        }
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

                            Text(category),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MoodlyColors.bgLight,

      body: SafeArea(
        child: Column(
          children: [
            // ================= HEADER =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),

              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },

                    child: const Icon(
                      Icons.arrow_back_ios,
                      color: MoodlyColors.green,
                    ),
                  ),

                  const Spacer(),

                  const Text(
                    "Komentar",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: MoodlyColors.textDark,
                    ),
                  ),

                  const Spacer(),
                ],
              ),
            ),

            // ================= POST =================
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),

              padding: const EdgeInsets.all(18),

              decoration: BoxDecoration(
                color: MoodlyColors.greenLight,

                borderRadius: BorderRadius.circular(28),
              ),

              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  MoodlyUserAvatar(
                    username: widget.diary.username,
                    radius: 24,
                    placeholderAsset: 'assets/profile_pic/PP_default.jpg',
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(
                          widget.diary.username,

                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          widget.diary.content,

                          style: const TextStyle(fontSize: 13, height: 1.7),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ================= COMMENTS =================
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: CommentService.getComments(widget.diary.id),

                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs;

                  if (docs.isEmpty) {
                    return Center(
                      child: Text(
                        "Belum ada komentar",
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),

                    itemCount: docs.length,

                    itemBuilder: (context, index) {
                      final comment =
                          docs[index].data() as Map<String, dynamic>;

                      final commentId = docs[index].id;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),

                        padding: const EdgeInsets.all(16),

                        decoration: BoxDecoration(
                          color: MoodlyColors.greenLight,

                          borderRadius: BorderRadius.circular(24),
                        ),

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                MoodlyUserAvatar(
                                  username: comment["username"],
                                  radius: 22,
                                  placeholderAsset:
                                      'assets/profile_pic/PP_default.jpg',
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
                                              comment["username"],

                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),

                                          PopupMenuButton(
                                            itemBuilder: (context) {
                                              return const [
                                                PopupMenuItem(
                                                  value: "report",
                                                  child: Text("Laporkan"),
                                                ),
                                              ];
                                            },

                                            onSelected: (value) {
                                              if (value == "report") {
                                                showReportDialog(
                                                  comment,
                                                  commentId,
                                                );
                                              }
                                            },
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 6),

                                      Text(
                                        comment["comment"],

                                        style: const TextStyle(
                                          fontSize: 13,
                                          height: 1.7,
                                        ),
                                      ),

                                      const SizedBox(height: 10),

                                      Row(
                                        children: [
                                          InkWell(
                                            onTap: () async {
                                              await CommentService.likeComment(
                                                diaryId: widget.diary.id,
                                                commentId: commentId,
                                                isLiked: false,
                                              );
                                            },

                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.favorite_border,
                                                  size: 20,
                                                  color: MoodlyColors.textDark,
                                                ),

                                                const SizedBox(width: 4),

                                                Text(
                                                  "${comment["likes"] ?? 0}",
                                                ),
                                              ],
                                            ),
                                          ),

                                          const SizedBox(width: 20),

                                          InkWell(
                                            onTap: () {
                                              replyingCommentId = commentId;

                                              commentController.text =
                                                  "@${comment["username"]} ";
                                            },

                                            child: const Text("Balas"),
                                          ),
                                        ],
                                      ),
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

            // ================= INPUT =================
            Container(
              margin: const EdgeInsets.all(16),

              padding: const EdgeInsets.symmetric(horizontal: 16),

              decoration: BoxDecoration(
                color: MoodlyColors.greenLight,

                borderRadius: BorderRadius.circular(30),
              ),

              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: commentController,

                      decoration: InputDecoration(
                        border: InputBorder.none,

                        hintText: replyingCommentId != null
                            ? "Balas komentar..."
                            : "Tambahkan komentar...",
                      ),
                    ),
                  ),

                  IconButton(
                    onPressed: sendComment,

                    icon: const Icon(
                      Icons.send_rounded,
                      color: MoodlyColors.green,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
