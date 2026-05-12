import 'package:flutter/material.dart';

import '../../models/public_diary_model.dart';

class CommentPage extends StatefulWidget {
  final PublicDiaryModel diary;

  const CommentPage({super.key, required this.diary});

  @override
  State<CommentPage> createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  final TextEditingController commentController = TextEditingController();

  int? replyingIndex;

  final List<String> reportCategories = [
    "Spam",
    "Kata Kasar",
    "Konten Tidak Pantas",
    "Bullying",
  ];

  List<Map<String, dynamic>> comments = [
    {
      "username": "Jerapah Tinggi",

      "comment":
          "iyaa semoga kita semua dimudahkan dan mendapat hasil sesuai dengan usaha",

      "profile": "assets/profile_pic/PP_10.png",

      "time": "30 mnt",

      "likes": 3,

      "isLiked": false,

      "showReplies": false,

      "replies": [
        {
          "username": "Kupu Kupu",

          "reply": "Aamiin",

          "profile": "assets/profile_pic/PP_11.png",

          "time": "10 mnt",

          "likes": 1,

          "isLiked": false,
        },
      ],
    },

    {
      "username": "Mochi",

      "comment": "semoga semua proses berjalan dengan lancar yaaa",

      "profile": "assets/profile_pic/PP_5.png",

      "time": "15 mnt",

      "likes": 0,

      "isLiked": false,

      "showReplies": false,

      "replies": [],
    },
  ];

  // =========================
  // ADD COMMENT / REPLY
  // =========================

  void addComment() {
    if (commentController.text.trim().isEmpty) {
      return;
    }

    setState(() {
      // REPLY
      if (replyingIndex != null) {
        comments[replyingIndex!]["replies"].add({
          "username": "Kamu",

          "reply": commentController.text,

          "profile": "assets/profile_pic/PP_2.png",

          "time": "Baru saja",

          "likes": 0,

          "isLiked": false,
        });

        comments[replyingIndex!]["showReplies"] = true;

        replyingIndex = null;
      }
      // COMMENT
      else {
        comments.add({
          "username": "Kamu",

          "comment": commentController.text,

          "profile": "assets/profile_pic/PP_2.png",

          "time": "Baru saja",

          "likes": 0,

          "isLiked": false,

          "showReplies": false,

          "replies": [],
        });

        widget.diary.comments++;
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
  // SHOW / HIDE REPLIES
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

                      onTap: () {
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
                        CircleAvatar(
                          radius: 24,

                          backgroundImage: AssetImage(
                            widget.diary.profileImage,
                          ),
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
                                widget.diary.text,

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

                    // COMMENTS
                    Expanded(
                      child: ListView.builder(
                        itemCount: comments.length,

                        itemBuilder: (context, index) {
                          final comment = comments[index];

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 22),

                            child: Column(
                              children: [
                                // COMMENT
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,

                                  children: [
                                    CircleAvatar(
                                      radius: 22,

                                      backgroundImage: AssetImage(
                                        comment["profile"],
                                      ),
                                    ),

                                    const SizedBox(width: 12),

                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,

                                        children: [
                                          Text(
                                            comment["username"],

                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
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
                                                  color: Colors.grey.shade700,
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
                                                    color: Colors.grey.shade700,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
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
                                          showReportDialog(index);
                                        }
                                      },
                                    ),

                                    Padding(
                                      padding: const EdgeInsets.only(top: 30),

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

                                // BUTTON SHOW/HIDE
                                if (comment["replies"] != null &&
                                    comment["replies"].isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 55,
                                      top: 10,
                                    ),

                                    child: InkWell(
                                      onTap: () {
                                        toggleReplies(index);
                                      },

                                      child: Row(
                                        children: [
                                          Container(
                                            width: 45,
                                            height: 1,
                                            color: Colors.grey.shade600,
                                          ),

                                          const SizedBox(width: 10),

                                          Text(
                                            comment["showReplies"]
                                                ? "Sembunyikan"
                                                : "Lebih banyak",

                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey.shade700,
                                            ),
                                          ),

                                          Icon(
                                            comment["showReplies"]
                                                ? Icons.keyboard_arrow_up
                                                : Icons.keyboard_arrow_down,

                                            size: 16,

                                            color: Colors.grey.shade700,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                // REPLIES
                                if (comment["replies"] != null &&
                                    comment["replies"].isNotEmpty &&
                                    comment["showReplies"] == true)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 55,
                                      top: 14,
                                    ),

                                    child: Column(
                                      children: [
                                        ...List.generate(comment["replies"].length, (
                                          replyIndex,
                                        ) {
                                          final reply =
                                              comment["replies"][replyIndex];

                                          return Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 14,
                                            ),

                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,

                                              children: [
                                                CircleAvatar(
                                                  radius: 18,

                                                  backgroundImage: AssetImage(
                                                    reply["profile"],
                                                  ),
                                                ),

                                                const SizedBox(width: 10),

                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,

                                                    children: [
                                                      Text(
                                                        reply["username"],

                                                        style: const TextStyle(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),

                                                      const SizedBox(height: 2),

                                                      Text(
                                                        reply["reply"],

                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                        ),
                                                      ),

                                                      const SizedBox(height: 8),

                                                      Row(
                                                        children: [
                                                          Text(
                                                            reply["time"],

                                                            style: TextStyle(
                                                              fontSize: 10,
                                                              color: Colors
                                                                  .grey
                                                                  .shade700,
                                                            ),
                                                          ),

                                                          const SizedBox(
                                                            width: 18,
                                                          ),

                                                          InkWell(
                                                            onTap: () {
                                                              setState(() {
                                                                replyingIndex =
                                                                    index;
                                                              });

                                                              commentController
                                                                      .text =
                                                                  "@${reply["username"]} ";
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

                                                PopupMenuButton(
                                                  icon: const Icon(
                                                    Icons.more_horiz,
                                                    size: 18,
                                                  ),

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
                                                      showSuccessDialog();
                                                    }
                                                  },
                                                ),

                                                Column(
                                                  children: [
                                                    InkWell(
                                                      onTap: () {
                                                        toggleLikeReply(
                                                          index,
                                                          replyIndex,
                                                        );
                                                      },

                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets.only(
                                                              top: 20,
                                                            ),

                                                        child: Icon(
                                                          reply["isLiked"]
                                                              ? Icons.favorite
                                                              : Icons
                                                                    .favorite_border,

                                                          color:
                                                              reply["isLiked"]
                                                              ? Colors.red
                                                              : Colors.black,

                                                          size: 18,
                                                        ),
                                                      ),
                                                    ),

                                                    const SizedBox(height: 4),

                                                    Text(
                                                      "${reply["likes"]}",

                                                      style: TextStyle(
                                                        fontSize: 9,
                                                        color: Colors
                                                            .grey
                                                            .shade700,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          );
                                        }),
                                      ],
                                    ),
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
