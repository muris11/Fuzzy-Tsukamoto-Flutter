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
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
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
      "fever": {"label": "Demam", "icon": Icons.thermostat_rounded, "color": const Color(0xFFEF4444)},
      "cough": {"label": "Batuk", "icon": Icons.air_rounded, "color": const Color(0xFF06B6D4)},
      "sore_throat": {"label": "Sakit Tenggorokan", "icon": Icons.record_voice_over_rounded, "color": const Color(0xFFF59E0B)},
      "headache": {"label": "Sakit Kepala", "icon": Icons.psychology_rounded, "color": const Color(0xFF8B5CF6)},
      "body_ache": {"label": "Nyeri Otot/Pegal", "icon": Icons.fitness_center_rounded, "color": const Color(0xFF10B981)},
      "nausea_vomit": {"label": "Mual/Muntah", "icon": Icons.sentiment_dissatisfied_rounded, "color": const Color(0xFFEC4899)},
      "diarrhea": {"label": "Diare", "icon": Icons.water_drop_rounded, "color": const Color(0xFF14B8A6)},
      "abdominal_pain": {"label": "Nyeri Perut", "icon": Icons.medication_rounded, "color": const Color(0xFF3B82F6)},
      "rash": {"label": "Ruam Kulit", "icon": Icons.healing_rounded, "color": const Color(0xFFF97316)},
      "fatigue": {"label": "Lemas/Kelelahan", "icon": Icons.battery_2_bar_rounded, "color": const Color(0xFF6366F1)},
    };

    return Column(
      children: symptoms.entries.map((entry) {
        final key = entry.key;
        final symptom = entry.value;
        final isActive = formData.answers[key] != "tidak";
        final symptomColor = symptom["color"] as Color;
        
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            gradient: isActive
              ? LinearGradient(
                  colors: [
                    symptomColor.withOpacity(0.05),
                    symptomColor.withOpacity(0.02),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
            color: isActive ? null : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isActive 
                ? symptomColor.withOpacity(0.4)
                : const Color(0xFFE2E8F0),
              width: isActive ? 2 : 1,
            ),
            boxShadow: isActive
              ? [
                  BoxShadow(
                    color: symptomColor.withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
          ),
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: symptom["label"] as String,
              labelStyle: GoogleFonts.poppins(
                color: isActive ? symptomColor : const Color(0xFF64748B),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              prefixIcon: Container(
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isActive 
                    ? symptomColor.withOpacity(0.15)
                    : const Color(0xFFE2E8F0).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  symptom["icon"] as IconData,
                  color: isActive ? symptomColor : const Color(0xFF94A3B8),
                  size: 22,
                ),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            ),
            value: formData.answers[key],
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isActive ? symptomColor.withOpacity(0.9) : const Color(0xFF1E293B),
            ),
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(16),
            icon: Icon(
              Icons.arrow_drop_down_circle_rounded,
              color: isActive ? symptomColor : const Color(0xFF94A3B8),
            ),
            items: options.map((option) => DropdownMenuItem(
              value: option,
              child: Row(
                children: [
                  if (option != "tidak") ...[
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _getOptionColor(option),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Text(
                    option.toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: _getOptionColor(option),
                    ),
                  ),
                ],
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

  Color _getOptionColor(String option) {
    switch (option) {
      case "sangat berat":
        return const Color(0xFFDC2626);
      case "berat":
        return const Color(0xFFEF4444);
      case "sedang":
        return const Color(0xFFF59E0B);
      case "ringan":
        return const Color(0xFF10B981);
      case "sering":
        return const Color(0xFFEF4444);
      case "kadang":
        return const Color(0xFF10B981);
      case "ya":
        return const Color(0xFF3B82F6);
      default:
        return const Color(0xFF64748B);
    }
  }

  Widget _thresholdSlider() {
    final formData = ref.watch(formDataProvider);
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6366F1).withOpacity(0.05),
            const Color(0xFF8B5CF6).withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF6366F1).withOpacity(0.2),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.tune_rounded,
                  color: Color(0xFF6366F1),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Ambang Batas Peringatan",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      "Sesuaikan tingkat sensitifitas",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Skor minimal:",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "${formData.ambang.round()}%",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFF6366F1),
              inactiveTrackColor: const Color(0xFFE2E8F0),
              thumbColor: Colors.white,
              overlayColor: const Color(0xFF6366F1).withOpacity(0.2),
              trackHeight: 8,
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 14,
                elevation: 4,
              ),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
              activeTickMarkColor: Colors.transparent,
              inactiveTickMarkColor: Colors.transparent,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "0%",
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF10B981),
                ),
              ),
              Text(
                "50%",
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFF59E0B),
                ),
              ),
              Text(
                "100%",
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFEF4444),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _predictButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFF7C3AED)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _onPredict,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.psychology_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      "Analisis Gejala Sekarang",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
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
          if (resp.medicationRecommendations != null && resp.medicationRecommendations!.isNotEmpty) ...[
            _medicationRecommendationsCard(resp),
            const SizedBox(height: 20),
          ],
          const Divider(color: Color(0xFFE2E8F0)),
          const SizedBox(height: 16),
          Text(
            "Kemungkinan Penyakit Lainnya",
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
    
    final req = PredictRequest(
      nama: _namaCtrl.text.trim().isEmpty ? "Pengguna" : _namaCtrl.text.trim(),
      symptoms: formData.answers, // Use string values directly as per API documentation
      includeDetailRules: true,
      ambangPeringatan: formData.ambang,
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

  Widget _medicationRecommendationsCard(PredictResponse resp) {
    final recommendations = resp.medicationRecommendations;
    
    // Validasi data rekomendasi obat
    if (recommendations == null || recommendations.isEmpty) {
      return const SizedBox.shrink();
    }

    // Extract medications and emergency_signs from the API response
    final medications = recommendations['medications'] as List?;
    final emergencySigns = recommendations['emergency_signs'] as List?;

    // If both are empty, don't show the card
    if ((medications == null || medications.isEmpty) && 
        (emergencySigns == null || emergencySigns.isEmpty)) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF059669)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
                child: const Icon(
                  Icons.medical_services_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "💊 Saran Obat & Perawatan",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      "Untuk referensi awal saja",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Medications Section
          if (medications != null && medications.isNotEmpty) ...[
            _buildMedicationSection(medications),
            const SizedBox(height: 16),
          ],
          
          // Emergency Signs Section
          if (emergencySigns != null && emergencySigns.isNotEmpty) ...[
            _buildEmergencySignsSection(emergencySigns),
            const SizedBox(height: 16),
          ],
          
          // Warning Section - Modern Design
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.orange.shade50,
                  Colors.amber.shade50,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.orange.shade400,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Single warning icon
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.orange.shade600,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.shade600.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.warning_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "PENTING!",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.orange.shade900,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Saran obat ini hanya untuk referensi awal. Pastikan konsultasi dengan dokter atau apoteker sebelum minum obat apapun. Setiap orang punya kondisi kesehatan yang berbeda.",
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.orange.shade900,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationSection(List medications) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFF3B82F6).withOpacity(0.5),
                  ),
                ),
                child: const Icon(
                  Icons.medication_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "💊 Obat yang Disarankan",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...medications.map((med) {
            if (med is Map) {
              final name = med['name'] ?? '';
              final dosage = med['dosage'] ?? '';
              final explanation = _getSimpleMedicationExplanation(name);
              
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF3B82F6),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            name,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (explanation.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Padding(
                        padding: const EdgeInsets.only(left: 18),
                        child: Text(
                          explanation,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: const Color(0xFF059669),
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.italic,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                    if (dosage.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Padding(
                        padding: const EdgeInsets.only(left: 18),
                        child: Text(
                          dosage,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: const Color(0xFF64748B),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }).toList(),
        ],
      ),
    );
  }

  String _getSimpleMedicationExplanation(String medName) {
    final nameLower = medName.toLowerCase();
    
    // Paracetamol / Acetaminophen
    if (nameLower.contains('paracetamol') || nameLower.contains('acetaminophen')) {
      return '(Obat penurun panas dan pereda nyeri ringan)';
    }
    // Ibuprofen
    else if (nameLower.contains('ibuprofen')) {
      return '(Obat anti peradangan, penurun panas, dan pereda nyeri)';
    }
    // Aspirin
    else if (nameLower.contains('aspirin') || nameLower.contains('asetosal')) {
      return '(Obat pereda nyeri, penurun panas, dan pengencer darah)';
    }
    // Amoxicillin
    else if (nameLower.contains('amoxicillin') || nameLower.contains('amoksisilin')) {
      return '(Antibiotik untuk infeksi bakteri)';
    }
    // Cefadroxil
    else if (nameLower.contains('cefadroxil')) {
      return '(Antibiotik untuk infeksi kulit dan tenggorokan)';
    }
    // Ciprofloxacin
    else if (nameLower.contains('ciprofloxacin')) {
      return '(Antibiotik untuk infeksi saluran kemih dan pencernaan)';
    }
    // Dexamethasone
    else if (nameLower.contains('dexamethasone') || nameLower.contains('deksametason')) {
      return '(Obat anti peradangan kuat)';
    }
    // Prednisone
    else if (nameLower.contains('prednisone')) {
      return '(Obat anti peradangan dan alergi)';
    }
    // Cetirizine
    else if (nameLower.contains('cetirizine') || nameLower.contains('cetirizin')) {
      return '(Obat anti alergi / anti gatal)';
    }
    // Loratadine
    else if (nameLower.contains('loratadine') || nameLower.contains('loratadin')) {
      return '(Obat anti alergi yang tidak menyebabkan kantuk)';
    }
    // Diphenhydramine
    else if (nameLower.contains('diphenhydramine')) {
      return '(Obat anti alergi dan batuk)';
    }
    // Omeprazole
    else if (nameLower.contains('omeprazole')) {
      return '(Obat maag / lambung)';
    }
    // Ranitidine
    else if (nameLower.contains('ranitidine') || nameLower.contains('ranitidin')) {
      return '(Obat untuk mengurangi asam lambung)';
    }
    // Antasida
    else if (nameLower.contains('antasida') || nameLower.contains('antacid')) {
      return '(Obat untuk menetralkan asam lambung)';
    }
    // Loperamide
    else if (nameLower.contains('loperamide')) {
      return '(Obat untuk menghentikan diare)';
    }
    // Zinc
    else if (nameLower.contains('zinc') || nameLower.contains('seng')) {
      return '(Suplemen untuk mempercepat penyembuhan diare)';
    }
    // Oralit
    else if (nameLower.contains('oralit') || nameLower.contains('ors')) {
      return '(Larutan untuk mencegah dehidrasi)';
    }
    // Dextromethorphan
    else if (nameLower.contains('dextromethorphan')) {
      return '(Obat penekan batuk kering)';
    }
    // Guaifenesin
    else if (nameLower.contains('guaifenesin')) {
      return '(Obat pengencer dahak)';
    }
    // Bromhexine
    else if (nameLower.contains('bromhexine') || nameLower.contains('bromheksin')) {
      return '(Obat pengencer dan pelancar dahak)';
    }
    // Ambroxol
    else if (nameLower.contains('ambroxol')) {
      return '(Obat pengencer dahak)';
    }
    // Salbutamol
    else if (nameLower.contains('salbutamol')) {
      return '(Obat untuk melegakan sesak napas)';
    }
    // Pseudoephedrine
    else if (nameLower.contains('pseudoephedrine')) {
      return '(Obat untuk hidung tersumbat)';
    }
    // Vitamin C
    else if (nameLower.contains('vitamin c') || nameLower.contains('ascorbic')) {
      return '(Suplemen untuk meningkatkan daya tahan tubuh)';
    }
    // Vitamin B Complex
    else if (nameLower.contains('vitamin b')) {
      return '(Suplemen untuk metabolisme dan energi)';
    }
    // Multivitamin
    else if (nameLower.contains('multivitamin')) {
      return '(Suplemen lengkap untuk kesehatan)';
    }
    // Metoclopramide
    else if (nameLower.contains('metoclopramide')) {
      return '(Obat anti mual dan muntah)';
    }
    // Domperidone
    else if (nameLower.contains('domperidone')) {
      return '(Obat anti mual dan memperlancar pencernaan)';
    }
    else {
      return '';
    }
  }

  Widget _buildEmergencySignsSection(List emergencySigns) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.red.withOpacity(0.4),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.red.withOpacity(0.5),
                  ),
                ),
                child: const Icon(
                  Icons.emergency_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "🚨 Tanda Darurat",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "Segera ke rumah sakit jika mengalami:",
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.95),
            ),
          ),
          const SizedBox(height: 10),
          ...emergencySigns.map((sign) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.circle,
                    size: 8,
                    color: Colors.red,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      sign.toString(),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF1E293B),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  List<Widget> _buildMedicationCategories(Map<String, dynamic> recommendations) {
    List<Widget> categoryWidgets = [];

    // Iterate through each category in the medication recommendations
    recommendations.forEach((category, meds) {
      if (meds is List && meds.isNotEmpty) {
        final simpleCategoryName = _getSimpleCategoryName(category);
        final categoryIcon = _getCategoryIcon(category);
        final categoryColor = _getCategoryColor(category);
        
        categoryWidgets.add(
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: categoryColor.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: categoryColor.withOpacity(0.5),
                        ),
                      ),
                      child: Icon(
                        categoryIcon,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        simpleCategoryName,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                
                // Medications Chips
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: meds.map((med) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: categoryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          med.toString(),
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
                ),
              ],
            ),
          ),
        );
      }
    });

    // If no categories found, show a friendly message
    if (categoryWidgets.isEmpty) {
      categoryWidgets.add(
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            "Tidak ada rekomendasi obat khusus untuk kondisi ini. Istirahat yang cukup dan hidrasi yang baik sangat dianjurkan.",
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
              height: 1.5,
            ),
          ),
        ),
      );
    }

    return categoryWidgets;
  }

  Color _getCategoryColor(String category) {
    final categoryLower = category.toLowerCase();
    
    if (categoryLower.contains('antibiotik') || categoryLower.contains('antibiotic')) {
      return const Color(0xFF3B82F6); // Blue
    } else if (categoryLower.contains('analgesik') || categoryLower.contains('pain') || categoryLower.contains('nyeri')) {
      return const Color(0xFFEF4444); // Red
    } else if (categoryLower.contains('antipiretik') || categoryLower.contains('fever') || categoryLower.contains('demam')) {
      return const Color(0xFFF59E0B); // Orange
    } else if (categoryLower.contains('antihistamin') || categoryLower.contains('allergy') || categoryLower.contains('alergi')) {
      return const Color(0xFF8B5CF6); // Purple
    } else if (categoryLower.contains('vitamin') || categoryLower.contains('supplement')) {
      return const Color(0xFF10B981); // Green
    } else if (categoryLower.contains('batuk') || categoryLower.contains('cough')) {
      return const Color(0xFF06B6D4); // Cyan
    } else if (categoryLower.contains('maag') || categoryLower.contains('lambung')) {
      return const Color(0xFFEC4899); // Pink
    } else if (categoryLower.contains('diare') || categoryLower.contains('diarrhea')) {
      return const Color(0xFF14B8A6); // Teal
    } else if (categoryLower.contains('pilek') || categoryLower.contains('flu')) {
      return const Color(0xFF6366F1); // Indigo
    } else {
      return const Color(0xFF64748B); // Slate
    }
  }

  String _getSimpleCategoryName(String category) {
    final categoryLower = category.toLowerCase();

    // Map medical terms to simple Indonesian
    if (categoryLower.contains('antibiotik') || categoryLower.contains('antibiotic')) {
      return '💊 Obat Antibiotik';
    } else if (categoryLower.contains('analgesik') || categoryLower.contains('pain') || categoryLower.contains('nyeri')) {
      return '💊 Obat Pereda Nyeri';
    } else if (categoryLower.contains('antipiretik') || categoryLower.contains('fever') || categoryLower.contains('demam')) {
      return '🌡️ Obat Penurun Demam';
    } else if (categoryLower.contains('antihistamin') || categoryLower.contains('allergy') || categoryLower.contains('alergi')) {
      return '🤧 Obat Alergi';
    } else if (categoryLower.contains('vitamin') || categoryLower.contains('supplement')) {
      return '💚 Vitamin & Suplemen';
    } else if (categoryLower.contains('batuk') || categoryLower.contains('cough')) {
      return '🫁 Obat Batuk';
    } else if (categoryLower.contains('maag') || categoryLower.contains('lambung') || categoryLower.contains('gastric')) {
      return '🍽️ Obat Maag';
    } else if (categoryLower.contains('diare') || categoryLower.contains('diarrhea')) {
      return '💧 Obat Diare';
    } else if (categoryLower.contains('pilek') || categoryLower.contains('flu') || categoryLower.contains('cold')) {
      return '❄️ Obat Pilek & Flu';
    } else if (categoryLower.contains('mual') || categoryLower.contains('nausea')) {
      return '🤢 Obat Mual';
    } else if (categoryLower.contains('tenggorokan') || categoryLower.contains('throat')) {
      return '🗣️ Obat Tenggorokan';
    } else {
      // Return original with emoji prefix
      return '💊 $category';
    }
  }

  IconData _getCategoryIcon(String category) {
    final categoryLower = category.toLowerCase();
    
    if (categoryLower.contains('antibiotik') || categoryLower.contains('antibiotic')) {
      return Icons.science_rounded;
    } else if (categoryLower.contains('analgesik') || categoryLower.contains('pain') || categoryLower.contains('nyeri')) {
      return Icons.healing_rounded;
    } else if (categoryLower.contains('antipiretik') || categoryLower.contains('fever') || categoryLower.contains('demam')) {
      return Icons.thermostat_rounded;
    } else if (categoryLower.contains('antihistamin') || categoryLower.contains('allergy') || categoryLower.contains('alergi')) {
      return Icons.sick_rounded;
    } else if (categoryLower.contains('vitamin') || categoryLower.contains('supplement')) {
      return Icons.favorite_rounded;
    } else if (categoryLower.contains('batuk') || categoryLower.contains('cough')) {
      return Icons.air_rounded;
    } else if (categoryLower.contains('maag') || categoryLower.contains('lambung') || categoryLower.contains('gastric')) {
      return Icons.restaurant_rounded;
    } else if (categoryLower.contains('diare') || categoryLower.contains('diarrhea')) {
      return Icons.water_drop_rounded;
    } else if (categoryLower.contains('pilek') || categoryLower.contains('flu') || categoryLower.contains('cold')) {
      return Icons.ac_unit_rounded;
    } else if (categoryLower.contains('mual') || categoryLower.contains('nausea')) {
      return Icons.sentiment_very_dissatisfied_rounded;
    } else if (categoryLower.contains('tenggorokan') || categoryLower.contains('throat')) {
      return Icons.record_voice_over_rounded;
    } else {
      return Icons.medication_rounded;
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
