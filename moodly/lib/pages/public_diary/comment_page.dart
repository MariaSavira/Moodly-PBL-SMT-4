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

  List<Map<String, dynamic>> comments = [
    {
      "username": "Jerapah Tinggi",

      "comment":
          "iyaa semoga kita semua dimudahkan dan mendapat hasil sesuai dengan usaha",

      "profile": "assets/profile_pic/PP_10.png",

      "time": "30 mnt",

      "isLiked": false,

      "showReplies": true,

      "replies": [
        {
          "username": "Kupu Kupu",

          "reply": "Aamiin",

          "profile": "assets/profile_pic/PP_11.png",

          "time": "10 mnt",

          "isLiked": false,
        },
      ],
    },

    {
      "username": "Mochi",

      "comment": "semoga semua proses berjalan dengan lancar yaaa",

      "profile": "assets/profile_pic/PP_5.png",

      "time": "15 mnt",

      "isLiked": false,

      "showReplies": false,

      "replies": [],
    },
  ];

  // =========================
  // ADD COMMENT
  // =========================

  void addComment() {
    if (commentController.text.trim().isEmpty) {
      return;
    }

    setState(() {
      comments.add({
        "username": "Kamu",

        "comment": commentController.text,

        "profile": "assets/profile_pic/PP_2.png",

        "time": "Baru saja",

        "isLiked": false,

        "showReplies": false,

        "replies": [],
      });

      widget.diary.comments++;
    });

    commentController.clear();
  }

  // =========================
  // LIKE COMMENT
  // =========================

  void toggleLikeComment(int index) {
    setState(() {
      comments[index]["isLiked"] = !comments[index]["isLiked"];
    });
  }

  // =========================
  // LIKE REPLY
  // =========================

  void toggleLikeReply(int commentIndex, int replyIndex) {
    setState(() {
      comments[commentIndex]["replies"][replyIndex]["isLiked"] =
          !comments[commentIndex]["replies"][replyIndex]["isLiked"];
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8EBCF),

      body: SafeArea(
        child: Column(
          children: [
            // =========================
            // HEADER
            // =========================
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

            // =========================
            // CONTENT
            // =========================
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
                    // =========================
                    // POSTINGAN
                    // =========================
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

                    // =========================
                    // LIST COMMENT
                    // =========================
                    Expanded(
                      child: ListView.builder(
                        itemCount: comments.length,

                        itemBuilder: (context, index) {
                          final comment = comments[index];

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 22),

                            child: Column(
                              children: [
                                // =========================
                                // COMMENT
                                // =========================
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

                                              Text(
                                                "Balas",

                                                style: TextStyle(
                                                  fontSize: 10,

                                                  color: Colors.grey.shade700,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(width: 8),

                                    Padding(
                                      padding: const EdgeInsets.only(top: 40),

                                      child: InkWell(
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
                                    ),
                                  ],
                                ),

                                // =========================
                                // REPLIES
                                // =========================
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
                                        ...List.generate(
                                          comment["replies"].length,

                                          (replyIndex) {
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

                                                          style:
                                                              const TextStyle(
                                                                fontSize: 13,

                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                        ),

                                                        const SizedBox(
                                                          height: 2,
                                                        ),

                                                        Text(
                                                          reply["reply"],

                                                          style:
                                                              const TextStyle(
                                                                fontSize: 12,
                                                              ),
                                                        ),

                                                        const SizedBox(
                                                          height: 8,
                                                        ),

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

                                                            Text(
                                                              "Balas",

                                                              style: TextStyle(
                                                                fontSize: 10,

                                                                color: Colors
                                                                    .grey
                                                                    .shade700,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),

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
                                                            top: 32,
                                                          ),

                                                      child: Icon(
                                                        reply["isLiked"]
                                                            ? Icons.favorite
                                                            : Icons
                                                                  .favorite_border,

                                                        color: reply["isLiked"]
                                                            ? Colors.red
                                                            : Colors.black,

                                                        size: 18,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),

                                        InkWell(
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

                                              Row(
                                                children: [
                                                  Text(
                                                    "Sembunyikan",

                                                    style: TextStyle(
                                                      fontSize: 10,

                                                      color:
                                                          Colors.grey.shade700,
                                                    ),
                                                  ),

                                                  Icon(
                                                    Icons.keyboard_arrow_up,

                                                    size: 16,

                                                    color: Colors.grey.shade700,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                // =========================
                                // SHOW MORE
                                // =========================
                                if (comment["replies"] != null &&
                                    comment["replies"].isNotEmpty &&
                                    comment["showReplies"] == false)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 55,
                                      top: 12,
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

                                          Row(
                                            children: [
                                              Text(
                                                "Lebih banyak",

                                                style: TextStyle(
                                                  fontSize: 10,

                                                  color: Colors.grey.shade700,
                                                ),
                                              ),

                                              Icon(
                                                Icons.keyboard_arrow_down,

                                                size: 16,

                                                color: Colors.grey.shade700,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    // =========================
                    // INPUT COMMENT
                    // =========================
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

                              decoration: const InputDecoration(
                                hintText: "Tambahkan Komentar....",

                                hintStyle: TextStyle(fontSize: 12),

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
