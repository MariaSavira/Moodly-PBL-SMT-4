class AfirmasiService {
  static final Map<String, List<String>> dataAfirmasi = {
    'Rasa Syukur': [
      'Aku bersyukur atas setiap hal kecil yang hadir dalam hidupku hari ini.',
      'Hidupku dipenuhi banyak kebaikan yang layak aku syukuri.',
      'Aku memilih melihat sisi baik dari setiap proses yang aku jalani.',
    ],
    'Meredakan Kecemasan': [
      'Aku aman, aku tenang, dan aku mampu melewati ini satu langkah demi satu langkah.',
      'Aku melepaskan rasa takut dan memberi ruang bagi ketenangan di dalam diriku.',
      'Aku bernapas perlahan, dan setiap tarikan napas membawaku pada rasa damai.',
    ],
    'Motivasi': [
      'Aku percaya bahwa setiap proses yang aku jalani hari ini sedang membentuk versi terbaik dari diriku di masa depan. Meskipun jalannya tidak selalu mudah, aku tetap melangkah dengan penuh keyakinan dan keberanian.',
      'Aku memiliki kekuatan untuk terus mencoba, bahkan ketika keadaan terasa sulit.',
      'Setiap langkah kecil yang aku ambil hari ini membawaku lebih dekat pada tujuan besarku.',
    ],
    'Kesehatan Mental': [
      'Perasaanku valid, dan aku berhak memberi waktu untuk diriku sendiri.',
      'Aku tidak harus selalu kuat. Aku boleh beristirahat dan memulihkan diri.',
      'Kesehatan mentalku penting, dan aku layak menjaganya dengan penuh kasih.',
    ],
    'Cinta Diri': [
      'Aku menerima diriku apa adanya, dengan segala kelebihan dan kekuranganku.',
      'Aku layak dicintai, dihargai, dan diperlakukan dengan lembut, terutama oleh diriku sendiri.',
      'Aku cukup, dan keberadaanku memiliki nilai yang berarti.',
    ],
  };

  static List<String> getAfirmasiByKategori(String kategori) {
    return dataAfirmasi[kategori] ?? [];
  }
}