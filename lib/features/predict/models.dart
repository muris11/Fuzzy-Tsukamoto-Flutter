class PredictRequest {
  String nama;
  Map<String, String> symptoms;
  bool includeDetailRules;
  double ambangPeringatan;

  PredictRequest({
    this.nama = "Pengguna",
    required this.symptoms,
    this.includeDetailRules = false,
    this.ambangPeringatan = 60.0,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      "nama": nama,
      "include_detail_rules": includeDetailRules,
      "ambang_peringatan": ambangPeringatan,
    };

    // Add symptoms as direct properties with string values
    symptoms.forEach((key, value) {
      data[key] = value;
    });

    return data;
  }
}

class PredictResponse {
  final String nama;
  final Map<String, dynamic>? diagnosaSementara;
  final Map<String, double> skor;
  final Map<String, double>? confidencePerDisease;
  final double? overallConfidence;
  final int? activeRules;
  final Map<String, double> inputSkala;
  final Map<String, dynamic>? detailRule;
  final String rekomendasi;
  final Map<String, dynamic>? medicationRecommendations;
  final String? htmlReport;
  final String? timestamp;
  final String? apiVersion;

  // Getter untuk kompatibilitas dengan kode lama
  Map<String, dynamic> get gejala {
    final Map<String, dynamic> result = {};
    inputSkala.forEach((key, value) {
      final gejalaBahasa = {
        "fever": "Demam",
        "cough": "Batuk",
        "sore_throat": "Sakit Tenggorokan",
        "headache": "Sakit Kepala",
        "body_ache": "Nyeri Otot/Pegal",
        "nausea_vomit": "Mual/Muntah",
        "diarrhea": "Diare",
        "abdominal_pain": "Nyeri Perut",
        "rash": "Ruam Kulit",
        "fatigue": "Lemas/Kelelahan",
      };

      String label = gejalaBahasa[key] ?? key;
      String status = value > 0 ? "ya" : "tidak";
      result[label] = status;
    });
    return result;
  }

  PredictResponse({
    required this.nama,
    required this.diagnosaSementara,
    required this.skor,
    this.confidencePerDisease,
    this.overallConfidence,
    this.activeRules,
    required this.inputSkala,
    required this.detailRule,
    required this.rekomendasi,
    this.medicationRecommendations,
    this.htmlReport,
    this.timestamp,
    this.apiVersion,
  });

  factory PredictResponse.fromJson(Map<String, dynamic> json) {
    Map<String,double> mapDouble(Map<String,dynamic>? m){
      final r=<String,double>{};
      if (m != null) {
        m.forEach((k,v){
          if (v != null) {
            r[k]=(v as num).toDouble();
          }
        });
      }
      return r;
    }

    // Handle API response structure as per documentation
    return PredictResponse(
      nama: json["nama"] as String? ?? "Pengguna",
      diagnosaSementara: json["diagnosa_sementara"] as Map<String, dynamic>?,
      skor: mapDouble(json["skor"] as Map<String,dynamic>?),
      confidencePerDisease: mapDouble(json["confidence_per_disease"] as Map<String,dynamic>?),
      overallConfidence: (json["overall_confidence"] as num?)?.toDouble(),
      activeRules: json["active_rules"] as int?,
      inputSkala: mapDouble(json["masukan_skala_0_10"] as Map<String,dynamic>?),
      detailRule: json["detail_aturan"] as Map<String, dynamic>?,
      rekomendasi: json["rekomendasi"] as String? ?? "",
      medicationRecommendations: json["rekomendasi_obat"] as Map<String, dynamic>?,
      htmlReport: json["html_report"] as String?,
      timestamp: json["timestamp"] as String?,
      apiVersion: json["api_version"] as String?,
    );
  }
}
