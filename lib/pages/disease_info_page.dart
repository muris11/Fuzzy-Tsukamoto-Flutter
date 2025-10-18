import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DiseaseInfoPage extends StatefulWidget {
  const DiseaseInfoPage({super.key});

  @override
  State<DiseaseInfoPage> createState() => _DiseaseInfoPageState();
}

class _DiseaseInfoPageState extends State<DiseaseInfoPage> {
  int _currentPage = 0;
  PageController _pageController = PageController();

  final List<DiseaseInfo> _diseases = [
    DiseaseInfo(
      emoji: "🦠",
      name: "Influenza (Flu)",
      nickname: "Flu / Masuk angin berat",
      description: "Flu disebabkan oleh virus yang menyerang saluran pernapasan bagian atas.\n\nBiasanya ditandai dengan demam, batuk, pilek, sakit tenggorokan, nyeri badan, dan lemas.\n\nKebanyakan flu sembuh sendiri dalam beberapa hari, tapi bisa lebih lama kalau daya tahan tubuh sedang turun.",
      tips: "💡 Tips: Banyak istirahat, minum air hangat, dan hindari udara dingin atau minuman es.",
      resultMessage: "Kamu kemungkinan sedang flu. Istirahat cukup dan perbanyak minum air ya.",
      color: const Color(0xFF3B82F6),
    ),
    DiseaseInfo(
      emoji: "🩸",
      name: "Demam Berdarah Dengue (DBD)",
      nickname: "DBD / Demam berdarah",
      description: "Penyakit ini disebabkan oleh gigitan nyamuk Aedes aegypti.\n\nGejalanya meliputi demam tinggi, sakit kepala hebat, nyeri otot dan sendi, mual, serta muncul bintik merah di kulit (ruam).\n\nDBD bisa berbahaya kalau tidak ditangani dengan cepat.",
      tips: "⚠️ Segera ke dokter kalau mengalami nyeri perut hebat, muntah terus-menerus, atau perdarahan.",
      resultMessage: "Gejalamu mirip demam berdarah. Sebaiknya segera periksa ke dokter atau puskesmas.",
      color: const Color(0xFFEF4444),
    ),
    DiseaseInfo(
      emoji: "🤒",
      name: "Demam Tifoid (Tifus / Tipes)",
      nickname: "Tifus / Tipes",
      description: "Tifus disebabkan oleh bakteri Salmonella typhi yang menular lewat makanan atau minuman yang tidak bersih.\n\nGejalanya berupa demam naik-turun, sakit kepala, lemas, nyeri perut, mual, dan bisa juga diare atau sembelit.",
      tips: "💡 Tips: Istirahat total, makan makanan lembut, dan jaga kebersihan makanan.",
      resultMessage: "Kamu kemungkinan kena tifus. Banyak istirahat dan segera cek ke dokter, ya.",
      color: const Color(0xFFF59E0B),
    ),
    DiseaseInfo(
      emoji: "🤢",
      name: "Gastroenteritis",
      nickname: "Muntaber / Masuk angin perut",
      description: "Terjadi karena infeksi virus atau bakteri di saluran pencernaan.\n\nGejalanya mual, muntah, diare, dan nyeri perut, kadang disertai demam ringan.\n\nBahaya utama penyakit ini adalah dehidrasi, jadi penting untuk tetap minum cairan.",
      tips: "⚠️ Bahaya utama penyakit ini adalah dehidrasi, jadi penting untuk tetap minum cairan.",
      resultMessage: "Kamu mungkin kena infeksi pencernaan (muntaber). Banyak minum air putih dan hindari makanan berminyak dulu.",
      color: const Color(0xFF10B981),
    ),
    DiseaseInfo(
      emoji: "😷",
      name: "Infeksi Saluran Pernapasan Atas (ISPA)",
      nickname: "Pilek / Radang tenggorokan / Batuk berat",
      description: "ISPA disebabkan oleh virus atau bakteri yang menyerang hidung, tenggorokan, atau paru bagian atas.\n\nBiasanya disertai batuk, demam, sakit tenggorokan, hidung tersumbat, dan tubuh terasa lemas.",
      tips: "💡 Tips: Minum air hangat, jangan begadang, dan hindari paparan debu atau asap rokok.",
      resultMessage: "Kamu sepertinya kena ISPA, kayak pilek atau radang tenggorokan. Jaga daya tahan tubuh ya.",
      color: const Color(0xFF8B5CF6),
    ),
    DiseaseInfo(
      emoji: "🧍‍♂️",
      name: "Netral / Tidak Spesifik",
      nickname: "Tidak ada tanda penyakit tertentu",
      description: "Dari jawabanmu, belum ada gejala yang cukup kuat mengarah ke penyakit tertentu.\n\nKemungkinan tubuhmu cuma kelelahan, kurang tidur, atau daya tahan sedang turun.",
      tips: "💡 Tips: Istirahat cukup, makan teratur, dan minum air putih yang banyak.",
      resultMessage: "Belum ada tanda penyakit tertentu, tapi tetap jaga kesehatan dan pola tidurmu.",
      color: const Color(0xFF6B7280),
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
          "Info Penyakit",
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
                _diseases.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 32 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? _diseases[_currentPage].color
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
              itemCount: _diseases.length,
              itemBuilder: (context, index) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: _buildDiseaseSlide(_diseases[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiseaseSlide(DiseaseInfo disease) {
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
            color: disease.color.withOpacity(0.1),
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
            // Header dengan emoji dan nama
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    disease.color.withOpacity(0.15),
                    disease.color.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: disease.color.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  // Emoji container yang sederhana
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: disease.color.withOpacity(0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        disease.emoji,
                        style: const TextStyle(fontSize: 45),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Disease name sederhana
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: disease.color,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: disease.color.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      disease.name,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Nickname
                  Text(
                    disease.nickname,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: disease.color.withOpacity(0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Content section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Penjelasan section
                _buildSimpleInfoCard(
                  title: "Penjelasan",
                  content: disease.description,
                  color: const Color(0xFF3B82F6),
                ),
                const SizedBox(height: 20),
                
                // Tips section
                _buildSimpleInfoCard(
                  title: "Tips & Saran",
                  content: disease.tips,
                  color: disease.color,
                ),
                const SizedBox(height: 20),
                
                // Pesan aplikasi section
                _buildSimpleInfoCard(
                  title: "Pesan di Aplikasi",
                  content: "\"${disease.resultMessage}\"",
                  color: Colors.purple.shade600,
                  isQuote: true,
                ),
                const SizedBox(height: 20),
                
                // Disclaimer section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.orange.withOpacity(0.1),
                        Colors.orange.withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            color: Colors.orange.shade600,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "💡 Saran Umum",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.orange.shade600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Semua hasil dari DiagnoFuzzy hanyalah indikasi awal dan bukan diagnosis pasti.\n\nKalau gejala tidak kunjung membaik atau malah semakin parah, segera periksa ke dokter atau fasilitas kesehatan terdekat.",
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.orange.shade700,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleInfoCard({
    required String title,
    required String content,
    required Color color,
    bool isQuote = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 12),
          
          if (isQuote)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: color.withOpacity(0.1)),
              ),
              child: Text(
                content,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: color,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          else
            Text(
              content,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: const Color(0xFF374151),
                height: 1.6,
              ),
            ),
        ],
      ),
    );
  }
}

class DiseaseInfo {
  final String emoji;
  final String name;
  final String nickname;
  final String description;
  final String tips;
  final String resultMessage;
  final Color color;

  DiseaseInfo({
    required this.emoji,
    required this.name,
    required this.nickname,
    required this.description,
    required this.tips,
    required this.resultMessage,
    required this.color,
  });
}
