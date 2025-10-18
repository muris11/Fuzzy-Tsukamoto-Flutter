import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'service.dart';
import 'models.dart';
import 'pdf_service.dart';
import '../../env.dart';
import 'package:google_fonts/google_fonts.dart';

// Global providers untuk menyimpan state form
final formDataProvider = StateNotifierProvider<FormDataNotifier, FormData>((ref) {
  return FormDataNotifier();
});

class FormData {
  final String nama;
  final Map<String, String> answers;
  final double ambang;

  FormData({
    required this.nama,
    required this.answers,
    required this.ambang,
  });

  FormData copyWith({
    String? nama,
    Map<String, String>? answers,
    double? ambang,
  }) {
    return FormData(
      nama: nama ?? this.nama,
      answers: answers ?? this.answers,
      ambang: ambang ?? this.ambang,
    );
  }
}

class FormDataNotifier extends StateNotifier<FormData> {
  FormDataNotifier() : super(FormData(
    nama: "Pengguna",
    answers: {
      "fever":"tidak","cough":"tidak","sore_throat":"tidak","headache":"tidak","body_ache":"tidak",
      "nausea_vomit":"tidak","diarrhea":"tidak","abdominal_pain":"tidak","rash":"tidak","fatigue":"tidak"
    },
    ambang: 60.0,
  ));

  void updateNama(String nama) {
    state = state.copyWith(nama: nama);
  }

  void updateAnswer(String key, String value) {
    final newAnswers = Map<String, String>.from(state.answers);
    newAnswers[key] = value;
    state = state.copyWith(answers: newAnswers);
  }

  void updateAmbang(double ambang) {
    state = state.copyWith(ambang: ambang);
  }
}

class PredictPage extends ConsumerStatefulWidget {
  const PredictPage({super.key});
  @override
  ConsumerState<PredictPage> createState() => _PredictPageState();
}

class _PredictPageState extends ConsumerState<PredictPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaCtrl;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final options = const ["tidak","ringan","sedang","berat","sangat berat","kadang","sering","ya"];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();

    // Initialize controller with saved data
    final formData = ref.read(formDataProvider);
    _namaCtrl = TextEditingController(text: formData.nama);

    // Listen to name changes
    _namaCtrl.addListener(() {
      ref.read(formDataProvider.notifier).updateNama(_namaCtrl.text);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _namaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          "DiagnoFuzzy",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: const Color(0xFF1E293B),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black12,
        toolbarHeight: 70,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _headerCard(),
              const SizedBox(height: 20),
              _modernFormCard(),
              const SizedBox(height: 20),
              _resultSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _headerCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.medical_services_rounded,
            size: 48,
            color: Colors.white,
          ),
          const SizedBox(height: 12),
          Text(
            "Diagnosa Fuzzy Tsukamoto",
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            "Aplikasi cerdas untuk membantu diagnosa kesehatan berdasarkan gejala yang Anda alami",
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _modernFormCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.assignment_rounded,
                    color: Color(0xFF6366F1),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Diagnosa Gejala",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      Text(
                        "Pilih gejala sesuai kondisi Anda saat ini",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _modernTextField(),
            const SizedBox(height: 20),
            _buildModernDropdowns(),
            const SizedBox(height: 24),
            _thresholdSlider(),
            const SizedBox(height: 24),
            _predictButton(),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _modernTextField() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextFormField(
        controller: _namaCtrl,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: "Nama Lengkap",
          labelStyle: GoogleFonts.poppins(
            color: const Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: const Icon(
            Icons.person_rounded,
            color: Color(0xFF6366F1),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(20),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Nama tidak boleh kosong';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildModernDropdowns() {
    final formData = ref.watch(formDataProvider);
    final symptoms = {
      "fever": {"label": "Demam", "icon": Icons.thermostat},
      "cough": {"label": "Batuk", "icon": Icons.sick},
      "sore_throat": {"label": "Sakit Tenggorokan", "icon": Icons.healing},
      "headache": {"label": "Sakit Kepala", "icon": Icons.psychology},
      "body_ache": {"label": "Nyeri Otot/Pegal", "icon": Icons.fitness_center},
      "nausea_vomit": {"label": "Mual/Muntah", "icon": Icons.restaurant_menu},
      "diarrhea": {"label": "Diare", "icon": Icons.local_hospital},
      "abdominal_pain": {"label": "Nyeri Perut", "icon": Icons.medication},
      "rash": {"label": "Ruam Kulit", "icon": Icons.colorize},
      "fatigue": {"label": "Lemas/Kelelahan", "icon": Icons.battery_2_bar},
    };

    return Column(
      children: symptoms.entries.map((entry) {
        final key = entry.key;
        final symptom = entry.value;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: formData.answers[key] != "tidak" 
                ? const Color(0xFF6366F1).withOpacity(0.3)
                : const Color(0xFFE2E8F0),
            ),
          ),
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: symptom["label"] as String,
              labelStyle: GoogleFonts.poppins(
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
              prefixIcon: Icon(
                symptom["icon"] as IconData,
                color: formData.answers[key] != "tidak" 
                  ? const Color(0xFF6366F1)
                  : const Color(0xFF94A3B8),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(20),
            ),
            value: formData.answers[key],
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1E293B),
            ),
            dropdownColor: Colors.white,
            items: options.map((option) => DropdownMenuItem(
              value: option,
              child: Text(
                option.toUpperCase(),
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                ),
              ),
            )).toList(),
            onChanged: (value) {
              if (value != null) {
                ref.read(formDataProvider.notifier).updateAnswer(key, value);
              }
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _thresholdSlider() {
    final formData = ref.watch(formDataProvider);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.tune_rounded,
                color: Color(0xFF6366F1),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                "Ambang Batas Peringatan",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Skor minimal untuk memicu peringatan: ${formData.ambang.round()}%",
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFF6366F1),
              inactiveTrackColor: const Color(0xFFE2E8F0),
              thumbColor: const Color(0xFF6366F1),
              overlayColor: const Color(0xFF6366F1).withOpacity(0.2),
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            ),
            child: Slider(
              value: formData.ambang,
              min: 0,
              max: 100,
              divisions: 20,
              label: "${formData.ambang.round()}%",
              onChanged: (value) {
                ref.read(formDataProvider.notifier).updateAmbang(value);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _predictButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _onPredict,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.psychology_rounded,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                "Analisis Gejala",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _resultSection() {
    return Consumer(builder: (context, ref, _) {
      final state = ref.watch(_predictStateProvider);
      return state.when(
        idle: () => const SizedBox.shrink(),
        loading: () => _modernLoadingCard(),
        data: (resp) => _modernResultCard(resp),
        error: (e) => _modernErrorCard(e),
      );
    });
  }

  Widget _modernLoadingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
            strokeWidth: 3,
          ),
          const SizedBox(height: 20),
          Text(
            "Sedang Menganalisis Gejala Anda...",
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Kami sedang memproses gejala yang Anda pilih untuk memberikan hasil terbaik",
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color(0xFF64748B),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _modernErrorCard(String error) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              color: Color(0xFFEF4444),
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Terjadi Kesalahan",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color(0xFF64748B),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _modernResultCard(PredictResponse resp) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.verified_rounded,
                  color: Color(0xFF10B981),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hasil Pemeriksaan",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      "Berdasarkan gejala yang Anda pilih",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (resp.diagnosaSementara != null) ...[
            _modernDiagnosisBadge(resp),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Text(
                resp.rekomendasi,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: const Color(0xFF374151),
                  height: 1.5,
                ),
              ),
            ),
          ] else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFBBF24).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: Color(0xFFD97706),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Belum dapat menentukan penyakit tertentu berdasarkan gejala yang dipilih",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: const Color(0xFFD97706),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 20),
          const Divider(color: Color(0xFFE2E8F0)),
          const SizedBox(height: 16),
          Text(
            "Tingkat Kemungkinan Setiap Penyakit",
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 12),
          ...((resp.skor.entries.toList()
                ..sort((a, b) => b.value.compareTo(a.value)))
              .map((e) => _modernScoreRow(e.key, e.value))),
          const SizedBox(height: 20),
          if (resp.overallConfidence != null || resp.activeRules != null) ...[
            _analysisStatsCard(resp),
            const SizedBox(height: 20),
          ],
          const Divider(color: Color(0xFFE2E8F0)),
          const SizedBox(height: 16),
          _pdfDownloadButton(resp),
        ],
      ),
    );
  }

  Widget _modernDiagnosisBadge(PredictResponse resp) {
    final formData = ref.watch(formDataProvider);
    final p = resp.diagnosaSementara!;
    final penyakit = p["penyakit"];
    final skor = (p["skor"] as num).toDouble();
    final confidence = p["confidence"] as double? ?? 1.0;
    final certainty = p["certainty"] as String? ?? "Sedang";
    final isHighRisk = skor >= formData.ambang;
    
    Color certaintyColor = const Color(0xFF10B981); // Default green
    if (certainty == "Rendah") certaintyColor = const Color(0xFFEF4444);
    else if (certainty == "Sedang") certaintyColor = const Color(0xFFF59E0B);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isHighRisk 
            ? [const Color(0xFFEF4444), const Color(0xFFDC2626)]
            : [const Color(0xFF3B82F6), const Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isHighRisk ? const Color(0xFFEF4444) : const Color(0xFF3B82F6))
                .withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                isHighRisk ? Icons.warning_rounded : Icons.info_rounded,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Kemungkinan Penyakit",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    Text(
                      penyakit,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "${skor.toStringAsFixed(1)}%",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            children: [
              // Tingkat Kepercayaan di atas
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.analytics_rounded,
                      color: Colors.white.withOpacity(0.8),
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        "Tingkat Kepercayaan: ${(confidence * 100).toStringAsFixed(0)}%",
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Ketepatan di bawah
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      certainty == "Tinggi" ? Icons.check_circle_rounded :
                      certainty == "Sedang" ? Icons.help_rounded : Icons.warning_rounded,
                      color: Colors.white.withOpacity(0.8),
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "Ketepatan: $certainty",
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.9),
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
  }

  Widget _modernScoreRow(String name, double score) {
    final percentage = score;
    final isHigh = percentage >= 50;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isHigh 
            ? const Color(0xFF6366F1).withOpacity(0.2)
            : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: percentage / 100,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isHigh 
                          ? const Color(0xFF6366F1)
                          : const Color(0xFF94A3B8),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isHigh 
                ? const Color(0xFF6366F1).withOpacity(0.1)
                : const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              "${percentage.toStringAsFixed(1)}%",
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isHigh 
                  ? const Color(0xFF6366F1)
                  : const Color(0xFF64748B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _analysisStatsCard(PredictResponse resp) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics_outlined,
                color: const Color(0xFF6366F1),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                "Informasi Analisis",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (resp.overallConfidence != null) 
                Expanded(
                  child: _statItem(
                    "Tingkat Kepercayaan Keseluruhan",
                    "${(resp.overallConfidence! * 100).toStringAsFixed(1)}%",
                    Icons.trending_up_rounded,
                    resp.overallConfidence! > 0.8 ? const Color(0xFF10B981) : 
                    resp.overallConfidence! > 0.6 ? const Color(0xFFF59E0B) : const Color(0xFFEF4444),
                  ),
                ),
              if (resp.overallConfidence != null && resp.activeRules != null)
                const SizedBox(width: 16),
              if (resp.activeRules != null)
                Expanded(
                  child: _statItem(
                    "Jumlah Pola yang Cocok",
                    "${resp.activeRules}",
                    Icons.rule_rounded,
                    const Color(0xFF6366F1),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 16,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _onPredict() async {
    if(!_formKey.currentState!.validate()) return;
    
    final formData = ref.read(formDataProvider);
    // Pastikan semua jawaban memiliki nilai yang valid
    final Map<String, String> safeAnswers = {};
    formData.answers.forEach((key, value) {
      safeAnswers[key] = value ?? 'tidak'; // Fallback ke 'tidak' jika null
    });
    
    final req = PredictRequest(
      nama: _namaCtrl.text.trim().isEmpty ? "Pengguna" : _namaCtrl.text.trim(),
      includeDetailRules: true,
      ambangPeringatan: formData.ambang,
      gejala: safeAnswers,
    );
    final notifier = ref.read(_predictStateProvider.notifier);
    await notifier.predict(req);
  }

  Widget _pdfDownloadButton(PredictResponse resp) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEF4444).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _generatePdf(resp),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.picture_as_pdf_rounded,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                "Unduh Laporan PDF",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _generatePdf(PredictResponse resp) async {
    try {
      final formData = ref.read(formDataProvider);
      
      final pdfBytes = await PdfService.generateReport(
        nama: _namaCtrl.text.trim().isEmpty ? "Pengguna" : _namaCtrl.text.trim(),
        jawaban: formData.answers,
        result: resp,
        ambangBatas: formData.ambang,
      );

      // Direct save to device storage
      final fileName = 'Laporan_Diagnosa_${DateTime.now().millisecondsSinceEpoch}.pdf';
      await PdfService.saveAndOpenPdf(pdfBytes, fileName);

      // Show success snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.download_done_rounded, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "PDF Berhasil Disimpan",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        "File: $fileName",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 4),
            margin: const EdgeInsets.all(16),
          ),
        );
      }

    } catch (e) {
      // Show error snackbar only
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Gagal Menyimpan PDF",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        "Error: $e",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 5),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

}

// ===== Riverpod state =====
final _predictStateProvider = StateNotifierProvider<_PredictNotifier, _PredictState>((ref) {
  final api = ref.read(predictServiceProvider);
  return _PredictNotifier(api);
});

class _PredictNotifier extends StateNotifier<_PredictState> {
  final PredictService _service;
  _PredictNotifier(this._service): super(_PredictState.idle());

  Future<void> predict(PredictRequest req) async {
    try {
      state = _PredictState.loading();
      final resp = await _service.predict(req);
      state = _PredictState.data(resp);
    } catch (e) {
      state = _PredictState.error(e.toString());
    }
  }
}

class _PredictState {
  final bool isLoading;
  final PredictResponse? resp;
  final String? err;
  _PredictState._(this.isLoading, this.resp, this.err);
  factory _PredictState.idle() => _PredictState._(false, null, null);
  factory _PredictState.loading() => _PredictState._(true, null, null);
  factory _PredictState.data(PredictResponse r) => _PredictState._(false, r, null);
  factory _PredictState.error(String e) => _PredictState._(false, null, e);

  T when<T>({
    required T Function() idle,
    required T Function() loading,
    required T Function(PredictResponse resp) data,
    required T Function(String err) error,
  }) {
    if (isLoading) return loading();
    if (resp != null) return data(resp!);
    if (err != null) return error(err!);
    return idle();
  }
}
