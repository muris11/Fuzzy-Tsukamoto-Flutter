class PredictRequest {
  String nama;
  bool includeDetailRules;
  double ambangPeringatan;
  Map<String, String> gejala;

  PredictRequest({
    this.nama = "Pengguna",
    this.includeDetailRules = false, // Sesuaikan dengan default Python
    this.ambangPeringatan = 60,
    required this.gejala,
  });

  Map<String, dynamic> toJson() {
    // Pastikan semua nilai gejala tidak null dan bertipe String
    final Map<String, String> safeGejala = {};
    gejala.forEach((key, value) {
      safeGejala[key] = value ?? 'tidak'; // Fallback ke 'tidak' jika null
    });
    
    return {
      "nama": nama,
      "include_detail_rules": includeDetailRules,
      "ambang_peringatan": ambangPeringatan,
      // Expand gejala sebagai field individual sesuai API Python
      ...safeGejala,
    };
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
      timestamp: json["timestamp"] as String?,
      apiVersion: json["api_version"] as String?,
    );
  }
}
