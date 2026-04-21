import 'dart:math';

class AfirmasiService {
  static final Random _random = Random();

  static final List<Map<String, String>> _afirmasiData = [
    {
      'kategori': 'Rasa Syukur',
      'teks': 'Aku bersyukur atas setiap hal kecil yang hadir dalam hidupku hari ini.',
    },
    {
      'kategori': 'Rasa Syukur',
      'teks': 'Aku menghargai hidupku dan segala kebaikan yang datang hari ini.',
    },
    {
      'kategori': 'Rasa Syukur',
      'teks': 'Aku bersyukur atas kesempatan untuk tumbuh dan berkembang.',
    },
    {
      'kategori': 'Meredakan Kecemasan',
      'teks': 'Aku memilih untuk tenang di saat ini.',
    },
    {
      'kategori': 'Meredakan Kecemasan',
      'teks': 'Aku mengatur napasku dan menenangkan pikiranku.',
    },
    {
      'kategori': 'Meredakan Kecemasan',
      'teks': 'Perasaan ini hanya sementara, aku akan melewatinya.',
    },
    {
      'kategori': 'Motivasi',
      'teks': 'Keberhasilan dimulai dengan keyakinan bahwa kamu bisa.',
    },
    {
      'kategori': 'Motivasi',
      'teks': 'Kesulitan bukan akhir dari perjalanan, tetapi awal dari sebuah kemenangan.',
    },
    {
      'kategori': 'Motivasi',
      'teks': 'Aku mampu melangkah maju satu langkah kecil setiap hari.',
    },
    {
      'kategori': 'Kesehatan Mental',
      'teks': 'Aku menerima semua perasaanku tanpa menghakimi.',
    },
    {
      'kategori': 'Kesehatan Mental',
      'teks': 'Aku merawat pikiranku dengan penuh kasih.',
    },
    {
      'kategori': 'Kesehatan Mental',
      'teks': 'Aku boleh beristirahat tanpa merasa bersalah.',
    },
    {
      'kategori': 'Cinta Diri',
      'teks': 'Aku berhak bahagia dalam hidupku.',
    },
    {
      'kategori': 'Cinta Diri',
      'teks': 'Aku menerima semua kekuatan dan kelemahan dalam diriku.',
    },
    {
      'kategori': 'Cinta Diri',
      'teks': 'Aku layak dicintai, terutama oleh diriku sendiri.',
    },
  ];

  static final List<Map<String, String>> _favoritItems = [];

  static List<Map<String, String>> getAfirmasiByCategories(
    List<String> categories,
  ) {
    return _afirmasiData
        .where((item) => categories.contains(item['kategori']))
        .toList();
  }

  static List<Map<String, String>> getFavoritItems() {
    return List<Map<String, String>>.from(_favoritItems);
  }

  static bool isFavorite(Map<String, String> item) {
    return _favoritItems.any(
      (fav) =>
          fav['kategori'] == item['kategori'] &&
          fav['teks'] == item['teks'],
    );
  }

  static void toggleFavorite(Map<String, String> item) {
    final index = _favoritItems.indexWhere(
      (fav) =>
          fav['kategori'] == item['kategori'] &&
          fav['teks'] == item['teks'],
    );

    if (index >= 0) {
      _favoritItems.removeAt(index);
    } else {
      _favoritItems.add(Map<String, String>.from(item));
    }
  }

  static void removeFavorite(Map<String, String> item) {
    _favoritItems.removeWhere(
      (fav) =>
          fav['kategori'] == item['kategori'] &&
          fav['teks'] == item['teks'],
    );
  }

  static void removeManyFavorites(List<Map<String, String>> items) {
    for (final item in items) {
      removeFavorite(item);
    }
  }

  static Map<String, String> getRandomWeightedAfirmasi(
    List<String> categories, {
    Map<String, String>? exclude,
  }) {
    final source = getAfirmasiByCategories(categories);

    if (source.isEmpty) {
      return {
        'kategori': 'Afirmasi',
        'teks': 'Belum ada afirmasi yang tersedia.',
      };
    }

    final List<Map<String, String>> weightedPool = [];

    for (final item in source) {
      final isExcluded = exclude != null &&
          item['kategori'] == exclude['kategori'] &&
          item['teks'] == exclude['teks'];

      if (isExcluded && source.length > 1) continue;

      weightedPool.add(item);

      if (isFavorite(item)) {
        weightedPool.add(item);
        weightedPool.add(item);
        weightedPool.add(item);
      }
    }

    return weightedPool[_random.nextInt(weightedPool.length)];
  }
}