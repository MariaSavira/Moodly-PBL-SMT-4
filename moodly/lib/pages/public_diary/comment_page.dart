import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/shared/moodly_user_avatar.dart';

import '../../models/diary_model.dart';
import '../../services/report_comment_service.dart';

class CommentPage extends StatefulWidget {
  final DiaryModel diary;

  const CommentPage({super.key, required this.diary});

  @override
  State<CommentPage> createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  final TextEditingController commentController = TextEditingController();

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  int? replyingIndex;

  final List<String> reportCategories = [
    "Spam",
    "Kata Kasar",
    "Konten Tidak Pantas",
    "Bullying",
  ];

  // =========================
  // COMMENTS
  // =========================

  List<Map<String, dynamic>> comments = [];

  // =========================
  // ADD COMMENT
  // =========================

  void addComment() {
    if (commentController.text.trim().isEmpty) {
      return;
    }

    setState(() {
      if (replyingIndex != null) {
        comments[replyingIndex!]["replies"].add({
          "username": "Kamu",
          "uid": FirebaseAuth.instance.currentUser?.uid,
          "reply": commentController.text,
          "profile": "",
          "time": "Baru saja",
          "likes": 0,
          "isLiked": false,
        });

        comments[replyingIndex!]["showReplies"] = true;

        replyingIndex = null;
      } else {
        comments.add({
          "username": "Kamu",
          "uid": FirebaseAuth.instance.currentUser?.uid,
          "comment": commentController.text,
          "profile": "",
          "time": "Baru saja",
          "likes": 0,
          "isLiked": false,
          "showReplies": false,
          "replies": [],
        });
      }
    });

    commentController.clear();
  }

  // =========================
  // LIKE COMMENT
  // =========================

  void toggleLikeComment(int index) {
    setState(() {
      comments[index]["isLiked"] = !comments[index]["isLiked"];

      if (comments[index]["isLiked"]) {
        comments[index]["likes"]++;
      } else {
        comments[index]["likes"]--;
      }
    });
  }

  // =========================
  // LIKE REPLY
  // =========================

  void toggleLikeReply(int commentIndex, int replyIndex) {
    setState(() {
      comments[commentIndex]["replies"][replyIndex]["isLiked"] =
          !comments[commentIndex]["replies"][replyIndex]["isLiked"];

      if (comments[commentIndex]["replies"][replyIndex]["isLiked"]) {
        comments[commentIndex]["replies"][replyIndex]["likes"]++;
      } else {
        comments[commentIndex]["replies"][replyIndex]["likes"]--;
      }
    });
  }

  // =========================
  // TOGGLE REPLIES
  // =========================

  void toggleReplies(int index) {
    setState(() {
      comments[index]["showReplies"] = !comments[index]["showReplies"];
    });
  }

  // =========================
  // SUCCESS DIALOG
  // =========================

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

  // =========================
  // REPORT COMMENT
  // =========================

  void showReportDialog(Map<String, dynamic> commentData) {
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
                "Laporkan Komentar",

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
                        await ReportCommentService.createReport(
                          reportedUser: commentData["username"],

                          reportedProfile: commentData["profile"],

                          reportCategory: category,

                          commentText: commentData["comment"],

                          reportedBy: "USER_LOGIN_ID",

                          diaryId: widget.diary.id,

                          commentId: "comment_id",
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

  // =========================
  // REPORT REPLY
  // =========================

  void showReplyReportDialog(Map<String, dynamic> replyData) {
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
                "Laporkan Balasan",

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
                        await ReportCommentService.createReport(
                          reportedUser: replyData["username"],

                          reportedProfile: replyData["profile"],

                          reportCategory: category,

                          commentText: replyData["reply"],

                          reportedBy: "USER_LOGIN_ID",

                          diaryId: widget.diary.id,

                          commentId: "reply_comment",
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8EBCF),

      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),

              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },

                    child: const Icon(Icons.arrow_back, size: 26),
                  ),

                  const Spacer(),

                  const Text(
                    "Komentar",

                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  const Spacer(),
                ],
              ),
            ),

            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),

                padding: const EdgeInsets.all(16),

                decoration: BoxDecoration(
                  color: const Color(0xFFDDE6B8),

                  borderRadius: BorderRadius.circular(28),
                ),

                child: Column(
                  children: [
                    // POST
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        MoodlyUserAvatar(
                          username: widget.diary.username,
                          radius: 24,
                          placeholderAsset:
                              'assets/profile_pic/PP_default.jpg', // <- GANTI PLACEHOLDER POST UTAMA KOMENTAR DI SINI
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              Text(
                                widget.diary.username,

                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                widget.diary.content,

                                style: const TextStyle(
                                  fontSize: 12,
                                  height: 1.7,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    Divider(color: Colors.black.withOpacity(0.4)),

                    const SizedBox(height: 12),

                    // ================= COMMENTS =================
                    Expanded(
                      child: comments.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,

                                children: [
                                  Icon(
                                    Icons.mode_comment_outlined,
                                    size: 55,
                                    color: Colors.grey.shade600,
                                  ),

                                  const SizedBox(height: 14),

                                  Text(
                                    "Belum ada komentar",

                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),

                                  const SizedBox(height: 6),

                                  Text(
                                    "Jadilah yang pertama berkomentar ✨",

                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: comments.length,

                              itemBuilder: (context, index) {
                                final comment = comments[index];

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 22),

                                  child: Column(
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,

                                        children: [
                                          MoodlyUserAvatar(
                                            uid: comment["uid"] as String?,
                                            username:
                                                comment["username"] as String?,
                                            avatarAsset:
                                                comment["profile"] as String?,
                                            radius: 22,
                                            placeholderAsset:
                                                'assets/profile_pic/PP_default.jpg', // <- placeholder komentar
                                          ),

                                          const SizedBox(width: 12),

                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,

                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,

                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        comment["username"],

                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),

                                                    PopupMenuButton(
                                                      icon: const Icon(
                                                        Icons.more_horiz,
                                                      ),

                                                      itemBuilder: (context) {
                                                        return [
                                                          const PopupMenuItem(
                                                            value: "report",
                                                            child: Text(
                                                              "Laporkan",
                                                            ),
                                                          ),
                                                        ];
                                                      },

                                                      onSelected: (value) {
                                                        if (value == "report") {
                                                          showReportDialog(
                                                            comment,
                                                          );
                                                        }
                                                      },
                                                    ),
                                                  ],
                                                ),

                                                const SizedBox(height: 4),

                                                Text(
                                                  comment["comment"],

                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    height: 1.7,
                                                  ),
                                                ),

                                                const SizedBox(height: 10),

                                                Row(
                                                  children: [
                                                    Text(
                                                      comment["time"],

                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        color: Colors
                                                            .grey
                                                            .shade700,
                                                      ),
                                                    ),

                                                    const SizedBox(width: 18),

                                                    InkWell(
                                                      onTap: () {
                                                        setState(() {
                                                          replyingIndex = index;
                                                        });

                                                        commentController.text =
                                                            "@${comment["username"]} ";
                                                      },

                                                      child: Text(
                                                        "Balas",

                                                        style: TextStyle(
                                                          fontSize: 10,
                                                          color: Colors
                                                              .grey
                                                              .shade700,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),

                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 30,
                                            ),

                                            child: Column(
                                              children: [
                                                InkWell(
                                                  onTap: () {
                                                    toggleLikeComment(index);
                                                  },

                                                  child: Icon(
                                                    comment["isLiked"]
                                                        ? Icons.favorite
                                                        : Icons.favorite_border,

                                                    color: comment["isLiked"]
                                                        ? Colors.red
                                                        : Colors.black,

                                                    size: 20,
                                                  ),
                                                ),

                                                const SizedBox(height: 4),

                                                Text(
                                                  "${comment["likes"]}",

                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.grey.shade700,
                                                  ),
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
                            ),
                    ),

                    // INPUT
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),

                      decoration: BoxDecoration(
                        color: const Color(0xFFF1D1D7),

                        borderRadius: BorderRadius.circular(30),
                      ),

                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: commentController,

                              style: const TextStyle(fontSize: 12),

                              decoration: InputDecoration(
                                hintText: replyingIndex != null
                                    ? "Balas komentar..."
                                    : "Tambahkan Komentar....",

                                hintStyle: const TextStyle(fontSize: 12),

                                border: InputBorder.none,
                              ),
                            ),
                          ),

                          IconButton(
                            onPressed: addComment,

                            icon: const Icon(Icons.send, size: 22),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),
          ],
        ),
      ),
    );
  }
}
