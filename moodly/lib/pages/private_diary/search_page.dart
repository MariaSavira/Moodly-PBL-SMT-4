import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();

  /// 🔥 DATA SEMENTARA (besok diganti database)
  final List<String> diaryTitles = [
    "Hari Pertama Kuliah",
    "Sedih Banget Hari Ini",
    "Ketemu Dia Lagi",
    "Healing Sendiri",
    "Overthinking Malam",
    "Bahagia Sederhana",
  ];

  List<String> results = [];
  List<String> history = [];

  /// 🔍 SEARCH
  void search(String query) {
    if (query.isEmpty) {
      setState(() => results = []);
      return;
    }

    final filtered = diaryTitles
        .where((title) => title.toLowerCase().contains(query.toLowerCase()))
        .toList();

    setState(() => results = filtered);
  }

  /// 🕘 HISTORY
  void addHistory(String text) {
    if (text.isEmpty) return;

    setState(() {
      history.remove(text);
      history.insert(0, text);
    });
  }

  /// ❌ CLEAR
  void clearHistory() {
    setState(() => history.clear());
  }

  /// 🔁 PAKAI HISTORY
  void useHistory(String text) {
    _controller.text = text;
    search(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDDE3C3),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              /// HEADER
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios_new, size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "Search",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// SEARCH BAR
              Container(
                height: 45,
                decoration: BoxDecoration(
                  color: const Color(0xFFF4CFCF),
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        onChanged: search,
                        onSubmitted: addHistory,
                        style: const TextStyle(fontFamily: 'Poppins'),
                        decoration: const InputDecoration(
                          hintText: "Search...",
                          hintStyle: TextStyle(
                            fontFamily: 'Poppins',
                            color: Colors.black54,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const Icon(Icons.search, size: 20),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// HISTORY
              if (history.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "History",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    GestureDetector(
                      onTap: clearHistory,
                      child: const Text(
                        "Clear All",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                ...history.map(
                  (item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: GestureDetector(
                      onTap: () => useHistory(item),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 18,
                            color: Colors.black54,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            item,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 10),

              /// RESULT
              Expanded(
                child: _controller.text.isEmpty
                    ? const SizedBox()
                    : results.isEmpty
                    ? Center(
                        child: Text(
                          "Tidak ada diary dengan judul \"${_controller.text}\"",
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.builder(
                        itemCount: results.length,
                        itemBuilder: (_, i) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              results[i],
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}