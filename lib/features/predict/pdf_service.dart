import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'models.dart';

class PdfService {
  static Future<Uint8List> generateReport({
    required String nama,
    required Map<String, String> jawaban,
    required PredictResponse result,
    required double ambangBatas,
  }) async {
    final pdf = pw.Document();
    
    // Gunakan font bawaan PDF (tidak perlu load external font)
    // Font bawaan sudah mendukung Latin dan karakter dasar

    final DateTime now = DateTime.now();
    final String tanggal = "${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute.toString().padLeft(2, '0')}";

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return [
            // Header
            _buildHeader(nama, tanggal),
            pw.SizedBox(height: 20),
            
            // Kemungkinan Penyakit
            _buildDiagnosis(result, ambangBatas),
            pw.SizedBox(height: 20),
            
            // Saran Obat & Perawatan (if available)
            if (result.medicationRecommendations != null && 
                result.medicationRecommendations!.isNotEmpty) ...[
              _buildMedicationRecommendations(result.medicationRecommendations!),
              pw.SizedBox(height: 20),
            ],
            
            // Kemungkinan Penyakit Lainnya
            _buildScoreRanking(result),
            pw.SizedBox(height: 20),
            
            // Gejala yang Dipilih
            _buildQuestionnaire(jawaban),
            pw.SizedBox(height: 20),
            
            // Footer
            _buildFooter(),
          ];
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildHeader(String nama, String tanggal) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(24),
      decoration: pw.BoxDecoration(
        gradient: const pw.LinearGradient(
          colors: [PdfColors.indigo500, PdfColors.purple500],
          begin: pw.Alignment.topLeft,
          end: pw.Alignment.bottomRight,
        ),
        borderRadius: pw.BorderRadius.circular(16),
        boxShadow: [
          pw.BoxShadow(
            color: PdfColors.grey400,
            blurRadius: 8,
          ),
        ],
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'LAPORAN HASIL PEMERIKSAAN',
            style: pw.TextStyle(
              fontSize: 22,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
              letterSpacing: 0.5,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'DiagnoFuzzy - Sistem Cerdas Diagnosa Penyakit',
            style: pw.TextStyle(
              fontSize: 13,
              color: PdfColors.grey100,
            ),
          ),
          pw.SizedBox(height: 18),
          pw.Container(
            padding: const pw.EdgeInsets.all(14),
            decoration: pw.BoxDecoration(
              color: PdfColors.indigo100,
              borderRadius: pw.BorderRadius.circular(12),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Nama Pasien',
                      style: pw.TextStyle(
                        fontSize: 11,
                        color: PdfColors.grey100,
                      ),
                    ),
                    pw.SizedBox(height: 3),
                    pw.Text(
                      nama,
                      style: pw.TextStyle(
                        fontSize: 15,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'Tanggal & Waktu',
                      style: pw.TextStyle(
                        fontSize: 11,
                        color: PdfColors.grey100,
                      ),
                    ),
                    pw.SizedBox(height: 3),
                    pw.Text(
                      tanggal,
                      style: pw.TextStyle(
                        fontSize: 15,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildDiagnosis(PredictResponse result, double ambangBatas) {
    final diagnosis = result.diagnosaSementara;
    final isHighRisk = diagnosis != null && (diagnosis['skor'] as num).toDouble() >= ambangBatas;
    
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(24),
      decoration: pw.BoxDecoration(
        gradient: pw.LinearGradient(
          colors: isHighRisk 
            ? [PdfColors.red50, PdfColors.red100]
            : [PdfColors.green50, PdfColors.green100],
          begin: pw.Alignment.topLeft,
          end: pw.Alignment.bottomRight,
        ),
        borderRadius: pw.BorderRadius.circular(16),
        border: pw.Border.all(
          color: isHighRisk ? PdfColors.red300 : PdfColors.green300,
          width: 2,
        ),
        boxShadow: [
          pw.BoxShadow(
            color: isHighRisk 
              ? PdfColors.red200
              : PdfColors.green200,
            blurRadius: 12,
          ),
        ],
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: pw.BoxDecoration(
              color: isHighRisk ? PdfColors.red600 : PdfColors.green600,
              borderRadius: pw.BorderRadius.circular(10),
            ),
            child: pw.Text(
              'HASIL DIAGNOSA',
              style: pw.TextStyle(
                fontSize: 15,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
          pw.SizedBox(height: 18),
          if (diagnosis != null) ...[
            pw.Text(
              '${diagnosis['penyakit']}',
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
                color: isHighRisk ? PdfColors.red900 : PdfColors.green900,
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(10),
              ),
              child: pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Skor Kepercayaan',
                          style: pw.TextStyle(
                            fontSize: 11,
                            color: PdfColors.grey700,
                          ),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          '${(diagnosis['skor'] as num).toStringAsFixed(1)}%',
                          style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.indigo900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Tingkat Kepercayaan',
                          style: pw.TextStyle(
                            fontSize: 11,
                            color: PdfColors.grey700,
                          ),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          '${((diagnosis['confidence'] as double? ?? 1.0) * 100).toStringAsFixed(0)}%',
                          style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blue900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Ketepatan',
                          style: pw.TextStyle(
                            fontSize: 11,
                            color: PdfColors.grey700,
                          ),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          '${diagnosis['certainty'] as String? ?? "Sedang"}',
                          style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                            color: _getCertaintyTextColor(diagnosis['certainty'] as String? ?? "Sedang"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ] else
            pw.Text(
              'Belum ada bukti gejala spesifik yang terdeteksi',
              style: pw.TextStyle(
                fontSize: 14,
                color: PdfColors.orange700,
              ),
            ),
          pw.SizedBox(height: 16),
          pw.Container(
            padding: const pw.EdgeInsets.all(14),
            decoration: pw.BoxDecoration(
              color: PdfColors.indigo50,
              borderRadius: pw.BorderRadius.circular(12),
              border: pw.Border.all(color: PdfColors.indigo200),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  children: [
                    pw.Container(
                      width: 5,
                      height: 18,
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.indigo600,
                        borderRadius: pw.BorderRadius.all(pw.Radius.circular(3)),
                      ),
                    ),
                    pw.SizedBox(width: 10),
                    pw.Text(
                      'REKOMENDASI',
                      style: pw.TextStyle(
                        fontSize: 13,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.indigo900,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  result.rekomendasi,
                  style: pw.TextStyle(fontSize: 12, color: PdfColors.grey800),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildScoreRanking(PredictResponse result) {
    final sortedScores = result.skor.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        border: pw.Border.all(color: PdfColors.grey300, width: 1.5),
        borderRadius: pw.BorderRadius.circular(16),
        boxShadow: [
          pw.BoxShadow(
            color: PdfColors.grey300,
            blurRadius: 8,
          ),
        ],
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: pw.BoxDecoration(
              color: PdfColors.purple600,
              borderRadius: pw.BorderRadius.circular(10),
            ),
            child: pw.Text(
              'KEMUNGKINAN PENYAKIT LAINNYA',
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
          pw.SizedBox(height: 16),
          pw.Table(
            border: pw.TableBorder.all(
              color: PdfColors.grey400,
              width: 1,
            ),
            children: [
              // Header
              pw.TableRow(
                decoration: pw.BoxDecoration(
                  gradient: const pw.LinearGradient(
                    colors: [PdfColors.indigo100, PdfColors.purple100],
                  ),
                ),
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(10),
                    child: pw.Text(
                      'No',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.indigo900,
                      ),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(10),
                    child: pw.Text(
                      'Nama Penyakit',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.indigo900,
                      ),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(10),
                    child: pw.Text(
                      'Persentase',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.indigo900,
                      ),
                    ),
                  ),
                ],
              ),
              // Data rows
              ...sortedScores.asMap().entries.map((entry) {
                final index = entry.key;
                final scoreEntry = entry.value;
                final isEven = index % 2 == 0;
                
                return pw.TableRow(
                  decoration: pw.BoxDecoration(
                    color: isEven ? PdfColors.grey50 : PdfColors.white,
                  ),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(10),
                      child: pw.Text(
                        '${index + 1}',
                        style: pw.TextStyle(
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.indigo700,
                        ),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(10),
                      child: pw.Text(
                        scoreEntry.key,
                        style: const pw.TextStyle(
                          fontSize: 11,
                          color: PdfColors.grey900,
                        ),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(10),
                      child: pw.Text(
                        '${scoreEntry.value.toStringAsFixed(1)}%',
                        style: pw.TextStyle(
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue700,
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildQuestionnaire(Map<String, String> jawaban) {
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

    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'GEJALA YANG ANDA PILIH',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 15),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey400),
            children: [
              // Header
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'Gejala yang Anda Alami',
                      style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'Status',
                      style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                ],
              ),
              // Data rows
              ...gejalaBahasa.entries.map((entry) {
                final key = entry.key;
                final label = entry.value;
                final answer = jawaban[key] ?? 'tidak';
                
                return pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        label,
                        style: pw.TextStyle(fontSize: 12),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        answer.toUpperCase(),
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: answer != 'tidak' ? pw.FontWeight.bold : pw.FontWeight.normal,
                          color: answer != 'tidak' ? PdfColors.blue700 : PdfColors.black,
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(18),
      decoration: pw.BoxDecoration(
        gradient: const pw.LinearGradient(
          colors: [PdfColors.orange50, PdfColors.orange100],
          begin: pw.Alignment.topLeft,
          end: pw.Alignment.bottomRight,
        ),
        borderRadius: pw.BorderRadius.circular(12),
        border: pw.Border.all(color: PdfColors.orange300, width: 2),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            children: [
              pw.Container(
                width: 5,
                height: 18,
                decoration: const pw.BoxDecoration(
                  color: PdfColors.orange600,
                  borderRadius: pw.BorderRadius.all(pw.Radius.circular(3)),
                ),
              ),
              pw.SizedBox(width: 10),
              pw.Text(
                'DISCLAIMER & CATATAN PENTING',
                style: pw.TextStyle(
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.orange900,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            'Hasil diagnosa ini hanya untuk tujuan EDUKASI dan AKADEMIK. Bukan pengganti konsultasi medis profesional. '
            'Untuk diagnosa yang akurat dan penanganan yang tepat, silakan konsultasikan dengan dokter atau tenaga kesehatan yang kompeten.',
            style: pw.TextStyle(
              fontSize: 10,
              color: PdfColors.orange900,
              height: 1.4,
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 10),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'DiagnoFuzzy ${DateTime.now().year}',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.indigo700,
                  ),
                ),
                pw.Text(
                  'Powered by Fuzzy Tsukamoto System',
                  style: pw.TextStyle(
                    fontSize: 9,
                    color: PdfColors.grey700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildMedicationRecommendations(Map<String, dynamic> recommendations) {
    final medications = recommendations['medications'] as List?;
    final emergencySigns = recommendations['emergency_signs'] as List?;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Title
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: pw.BoxDecoration(
            gradient: const pw.LinearGradient(
              colors: [PdfColors.green600, PdfColors.teal600],
            ),
            borderRadius: pw.BorderRadius.circular(10),
          ),
          child: pw.Text(
            'SARAN OBAT & PERAWATAN',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
              letterSpacing: 0.5,
            ),
          ),
        ),
        pw.SizedBox(height: 14),

        // Medications Section
        if (medications != null && medications.isNotEmpty) ...[
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              gradient: const pw.LinearGradient(
                colors: [PdfColors.blue50, PdfColors.cyan50],
                begin: pw.Alignment.topLeft,
                end: pw.Alignment.bottomRight,
              ),
              border: pw.Border.all(color: PdfColors.blue300, width: 2),
              borderRadius: pw.BorderRadius.circular(12),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  children: [
                    pw.Container(
                      width: 5,
                      height: 16,
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.blue700,
                        borderRadius: pw.BorderRadius.all(pw.Radius.circular(3)),
                      ),
                    ),
                    pw.SizedBox(width: 8),
                    pw.Text(
                      'Obat yang Disarankan',
                      style: pw.TextStyle(
                        fontSize: 13,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue900,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 12),
                ...medications.map((med) {
                  if (med is Map) {
                    final name = med['name'] ?? '';
                    final dosage = med['dosage'] ?? '';
                    final explanation = _getSimpleMedicationExplanationPdf(name);
                    
                    return pw.Container(
                      margin: const pw.EdgeInsets.only(bottom: 10),
                      padding: const pw.EdgeInsets.all(12),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.white,
                        borderRadius: pw.BorderRadius.circular(8),
                        border: pw.Border.all(color: PdfColors.blue200),
                        boxShadow: [
                          pw.BoxShadow(
                            color: PdfColors.blue100,
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Row(
                            children: [
                              pw.Container(
                                width: 6,
                                height: 6,
                                decoration: const pw.BoxDecoration(
                                  color: PdfColors.blue600,
                                  shape: pw.BoxShape.circle,
                                ),
                              ),
                              pw.SizedBox(width: 6),
                              pw.Expanded(
                                child: pw.Text(
                                  name,
                                  style: pw.TextStyle(
                                    fontSize: 11,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColors.grey900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (explanation.isNotEmpty) ...[
                            pw.SizedBox(height: 4),
                            pw.Padding(
                              padding: const pw.EdgeInsets.only(left: 12),
                              child: pw.Text(
                                explanation,
                                style: const pw.TextStyle(
                                  fontSize: 9,
                                  color: PdfColors.green700,
                                ),
                              ),
                            ),
                          ],
                          if (dosage.isNotEmpty) ...[
                            pw.SizedBox(height: 4),
                            pw.Padding(
                              padding: const pw.EdgeInsets.only(left: 12),
                              child: pw.Text(
                                dosage,
                                style: const pw.TextStyle(
                                  fontSize: 10,
                                  color: PdfColors.grey700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  }
                  return pw.SizedBox();
                }).toList(),
              ],
            ),
          ),
          pw.SizedBox(height: 14),
        ],

        // Emergency Signs Section
        if (emergencySigns != null && emergencySigns.isNotEmpty) ...[
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              gradient: const pw.LinearGradient(
                colors: [PdfColors.red50, PdfColors.pink50],
                begin: pw.Alignment.topLeft,
                end: pw.Alignment.bottomRight,
              ),
              border: pw.Border.all(color: PdfColors.red400, width: 2),
              borderRadius: pw.BorderRadius.circular(12),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  children: [
                    pw.Container(
                      width: 5,
                      height: 16,
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.red700,
                        borderRadius: pw.BorderRadius.all(pw.Radius.circular(3)),
                      ),
                    ),
                    pw.SizedBox(width: 8),
                    pw.Text(
                      'Tanda Darurat - Segera ke RS!',
                      style: pw.TextStyle(
                        fontSize: 13,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.red900,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 10),
                ...emergencySigns.map((sign) {
                  return pw.Container(
                    margin: const pw.EdgeInsets.only(bottom: 6),
                    padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.white,
                      borderRadius: pw.BorderRadius.circular(6),
                      border: pw.Border.all(color: PdfColors.red200),
                    ),
                    child: pw.Row(
                      children: [
                        pw.Container(
                          width: 5,
                          height: 5,
                          decoration: const pw.BoxDecoration(
                            color: PdfColors.red600,
                            shape: pw.BoxShape.circle,
                          ),
                        ),
                        pw.SizedBox(width: 8),
                        pw.Expanded(
                          child: pw.Text(
                            sign.toString(),
                            style: const pw.TextStyle(
                              fontSize: 10,
                              color: PdfColors.red900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          pw.SizedBox(height: 14),
        ],

        // Warning
        pw.Container(
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            gradient: const pw.LinearGradient(
              colors: [PdfColors.amber50, PdfColors.orange50],
            ),
            border: pw.Border.all(color: PdfColors.orange400, width: 1.5),
            borderRadius: pw.BorderRadius.circular(10),
          ),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                width: 4,
                height: 40,
                decoration: const pw.BoxDecoration(
                  color: PdfColors.orange600,
                  borderRadius: pw.BorderRadius.all(pw.Radius.circular(2)),
                ),
              ),
              pw.SizedBox(width: 10),
              pw.Expanded(
                child: pw.Text(
                  'PENTING! Saran obat ini hanya untuk referensi awal. Pastikan konsultasi dengan dokter atau apoteker sebelum mengonsumsi obat apapun. Setiap orang memiliki kondisi kesehatan yang berbeda.',
                  style: pw.TextStyle(
                    fontSize: 9,
                    color: PdfColors.orange900,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static String _getSimpleMedicationExplanationPdf(String medName) {
    final nameLower = medName.toLowerCase();
    
    if (nameLower.contains('paracetamol') || nameLower.contains('acetaminophen')) {
      return '(Obat penurun panas dan pereda nyeri ringan)';
    } else if (nameLower.contains('ibuprofen')) {
      return '(Obat anti peradangan, penurun panas, dan pereda nyeri)';
    } else if (nameLower.contains('aspirin') || nameLower.contains('asetosal')) {
      return '(Obat pereda nyeri, penurun panas, dan pengencer darah)';
    } else if (nameLower.contains('amoxicillin') || nameLower.contains('amoksisilin')) {
      return '(Antibiotik untuk infeksi bakteri)';
    } else if (nameLower.contains('cefadroxil')) {
      return '(Antibiotik untuk infeksi kulit dan tenggorokan)';
    } else if (nameLower.contains('ciprofloxacin')) {
      return '(Antibiotik untuk infeksi saluran kemih dan pencernaan)';
    } else if (nameLower.contains('cetirizine') || nameLower.contains('cetirizin')) {
      return '(Obat anti alergi / anti gatal)';
    } else if (nameLower.contains('loratadine') || nameLower.contains('loratadin')) {
      return '(Obat anti alergi yang tidak menyebabkan kantuk)';
    } else if (nameLower.contains('omeprazole')) {
      return '(Obat maag / lambung)';
    } else if (nameLower.contains('ranitidine') || nameLower.contains('ranitidin')) {
      return '(Obat untuk mengurangi asam lambung)';
    } else if (nameLower.contains('loperamide')) {
      return '(Obat untuk menghentikan diare)';
    } else if (nameLower.contains('oralit') || nameLower.contains('ors')) {
      return '(Larutan untuk mencegah dehidrasi)';
    } else if (nameLower.contains('dextromethorphan')) {
      return '(Obat penekan batuk kering)';
    } else if (nameLower.contains('guaifenesin')) {
      return '(Obat pengencer dahak)';
    } else if (nameLower.contains('bromhexine') || nameLower.contains('bromheksin')) {
      return '(Obat pengencer dan pelancar dahak)';
    } else if (nameLower.contains('ambroxol')) {
      return '(Obat pengencer dahak)';
    } else if (nameLower.contains('vitamin c') || nameLower.contains('ascorbic')) {
      return '(Suplemen untuk meningkatkan daya tahan tubuh)';
    } else if (nameLower.contains('multivitamin')) {
      return '(Suplemen lengkap untuk kesehatan)';
    } else if (nameLower.contains('metoclopramide')) {
      return '(Obat anti mual dan muntah)';
    } else if (nameLower.contains('domperidone')) {
      return '(Obat anti mual dan memperlancar pencernaan)';
    } else {
      return '';
    }
  }

  static PdfColor _getCertaintyColor(String certainty) {
    switch (certainty) {
      case "Tinggi":
        return PdfColors.green100;
      case "Sedang":
        return PdfColors.orange100;
      case "Rendah":
        return PdfColors.red100;
      default:
        return PdfColors.grey100;
    }
  }

  static PdfColor _getCertaintyTextColor(String certainty) {
    switch (certainty) {
      case "Tinggi":
        return PdfColors.green800;
      case "Sedang":
        return PdfColors.orange800;
      case "Rendah":
        return PdfColors.red800;
      default:
        return PdfColors.grey800;
    }
  }

  static Future<void> saveAndOpenPdf(Uint8List pdfBytes, String fileName) async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
    );
  }

  static Future<String> savePdfToFile(Uint8List pdfBytes, String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(pdfBytes);
    return file.path;
  }
}
