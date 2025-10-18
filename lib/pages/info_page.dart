import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InfoPage extends StatefulWidget {
  const InfoPage({super.key});

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  int _currentPage = 0;
  PageController _pageController = PageController();

  final List<InfoSlide> _slides = [
    InfoSlide(
      icon: Icons.medical_services_rounded,
      title: "Apa itu DiagnoFuzzy?",
      content: "DiagnoFuzzy adalah aplikasi cerdas berbasis Fuzzy Inference System (FIS) dengan metode Tsukamoto yang dirancang untuk membantu pengguna memprediksi kemungkinan penyakit berdasarkan gejala yang dirasakan.",
      color: const Color(0xFF6366F1),
    ),
    InfoSlide(
      icon: Icons.psychology_rounded,
      title: "Cara Kerja Sistem",
      content: "Aplikasi ini bekerja dengan cara menanyakan serangkaian pertanyaan sederhana tentang kondisi tubuh pengguna — seperti demam, batuk, nyeri perut, mual, lemas, dan lainnya — kemudian sistem akan menganalisis jawabannya menggunakan logika fuzzy, sebuah pendekatan kecerdasan buatan yang mampu menilai kondisi tidak secara kaku.",
      color: const Color(0xFF8B5CF6),
    ),
    InfoSlide(
      icon: Icons.track_changes_rounded,
      title: "Tujuan Aplikasi",
      content: "• Memberikan prediksi awal terhadap kemungkinan penyakit berdasarkan gejala\n\n• Menjadi sarana edukatif tentang kesehatan dan penerapan logika fuzzy di dunia medis\n\n• Menunjukkan penerapan nyata metode Tsukamoto dalam bidang sistem pendukung keputusan (SPK)",
      color: const Color(0xFF10B981),
    ),
    InfoSlide(
      icon: Icons.settings_suggest_rounded,
      title: "Cara Kerja Singkat",
      content: "1. Pengguna mengisi kuisioner gejala dengan pilihan seperti \"tidak\", \"ringan\", \"sedang\", \"berat\", atau \"sangat berat\"\n\n2. Sistem mengubah jawaban tersebut menjadi nilai keanggotaan fuzzy (0–10)\n\n3. Setiap gejala diproses melalui aturan fuzzy Tsukamoto untuk menghasilkan nilai confidence\n\n4. Hasil akhir berupa skor kemungkinan (0–100) beserta penjelasan singkat dan rekomendasi tindakan",
      color: const Color(0xFFF59E0B),
    ),
    InfoSlide(
      icon: Icons.star_rounded,
      title: "Keunggulan DiagnoFuzzy",
      content: "• Menggunakan pendekatan Fuzzy Tsukamoto yang akurat dan adaptif\n\n• Antarmuka modern, sederhana, dan mudah digunakan\n\n• Bahasa yang edukatif dan mudah dipahami oleh pengguna awam\n\n• Hasil prediksi disertai tingkat keyakinan dan saran tindak lanjut\n\n• Dapat digunakan sebagai alat pembelajaran AI dan SPK di bidang kesehatan",
      color: const Color(0xFFEF4444),
    ),
    InfoSlide(
      icon: Icons.warning_rounded,
      title: "Disclaimer",
      content: "• Aplikasi ini bersifat edukatif dan pendukung keputusan, bukan alat diagnosis medis profesional\n\n• Hasil dari aplikasi hanya berupa indikasi kemungkinan penyakit dan bukan pengganti konsultasi dokter\n\n• Jika gejala tidak membaik atau semakin parah, segera hubungi fasilitas kesehatan terdekat",
      color: const Color(0xFFDC2626),
    ),
    InfoSlide(
      icon: Icons.person_rounded,
      title: "Dikembangkan oleh",
      content: "Muhammad Rifqy Saputra\n\nProgram Studi D4 Sistem Informasi Kota Cerdas (SIKC)\n\nPoliteknik Negeri Indramayu (POLINDRA)\n\nTahun 2025\n\nDikembangkan untuk memenuhi tugas akhir mata kuliah Kecerdasan Buatan",
      color: const Color(0xFF6366F1),
    ),
    ];

    @override
    void dispose() {
    _pageController.dispose();
    super.dispose();
    }

    @override
    Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          "Tentang DiagnoFuzzy",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: const Color(0xFF1E293B),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 2,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black12,
        toolbarHeight: 70,
      ),
      body: Column(
        children: [
          // Page indicator
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _slides.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 32 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? _slides[_currentPage].color
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
          
          // PageView dengan gesture
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: _slides.length,
              itemBuilder: (context, index) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: _buildSlide(_slides[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlide(InfoSlide slide) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: slide.color.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header dengan icon dan title
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    slide.color.withOpacity(0.15),
                    slide.color.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: slide.color.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  // Icon container
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: slide.color.withOpacity(0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        slide.icon,
                        size: 45,
                        color: slide.color,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Title
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: slide.color,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: slide.color.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      slide.title,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Content section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    slide.color.withOpacity(0.1),
                    slide.color.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: slide.color.withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(
                    color: slide.color.withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                slide.content,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: const Color(0xFF374151),
                  height: 1.6,
                ),
                textAlign: TextAlign.left,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class InfoSlide {
  final IconData icon;
  final String title;
  final String content;
  final Color color;

  InfoSlide({
    required this.icon,
    required this.title,
    required this.content,
    required this.color,
  });
}
