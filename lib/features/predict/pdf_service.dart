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
            
            // Tingkat Kemungkinan Penyakit
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
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: pw.BorderRadius.circular(10),
        border: pw.Border.all(color: PdfColors.blue200),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'LAPORAN HASIL PEMERIKSAAN KESEHATAN',
            style: pw.TextStyle(
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Aplikasi Cerdas untuk Membantu Mengenali Gejala Penyakit',
            style: pw.TextStyle(
              fontSize: 14,
              color: PdfColors.blue700,
            ),
          ),
          pw.SizedBox(height: 15),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Nama Pasien:',
                    style: pw.TextStyle(fontSize: 12),
                  ),
                  pw.Text(
                    nama,
                    style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    'Tanggal & Waktu:',
                    style: pw.TextStyle(fontSize: 12),
                  ),
                  pw.Text(
                    tanggal,
                    style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
            ],
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
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: isHighRisk ? PdfColors.red50 : PdfColors.green50,
        borderRadius: pw.BorderRadius.circular(10),
        border: pw.Border.all(
          color: isHighRisk ? PdfColors.red200 : PdfColors.green200,
        ),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            children: [
              pw.Container(
                width: 4,
                height: 20,
                color: isHighRisk ? PdfColors.red500 : PdfColors.green500,
              ),
              pw.SizedBox(width: 10),
              pw.Text(
                'KEMUNGKINAN PENYAKIT BERDASARKAN GEJALA',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: isHighRisk ? PdfColors.red900 : PdfColors.green900,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 15),
          if (diagnosis != null) ...[
            pw.Text(
              '${diagnosis['penyakit']}',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
                color: isHighRisk ? PdfColors.red800 : PdfColors.green800,
              ),
            ),
            pw.SizedBox(height: 5),
            pw.Text(
              'Skor Kepercayaan: ${(diagnosis['skor'] as num).toStringAsFixed(1)}%',
              style: pw.TextStyle(
                fontSize: 14,
              ),
            ),
            pw.SizedBox(height: 8),
            // Tingkat Kepercayaan
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              decoration: pw.BoxDecoration(
                color: PdfColors.blue100,
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Text(
                'Tingkat Kepercayaan: ${((diagnosis['confidence'] as double? ?? 1.0) * 100).toStringAsFixed(0)}%',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue800,
                ),
              ),
            ),
            pw.SizedBox(height: 4),
            // Ketepatan
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              decoration: pw.BoxDecoration(
                color: _getCertaintyColor(diagnosis['certainty'] as String? ?? "Sedang"),
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Text(
                'Ketepatan: ${diagnosis['certainty'] as String? ?? "Sedang"}',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: _getCertaintyTextColor(diagnosis['certainty'] as String? ?? "Sedang"),
                ),
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
          pw.SizedBox(height: 15),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'REKOMENDASI:',
                  style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  result.rekomendasi,
                  style: pw.TextStyle(fontSize: 12),
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
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'TINGKAT KEMUNGKINAN SETIAP PENYAKIT',
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
                      'Urutan',
                      style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'Penyakit',
                      style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'Tingkat (%)',
                      style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                ],
              ),
              // Data rows
              ...sortedScores.asMap().entries.map((entry) {
                final index = entry.key;
                final scoreEntry = entry.value;
                return pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        '${index + 1}',
                        style: pw.TextStyle(fontSize: 12),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        scoreEntry.key,
                        style: pw.TextStyle(fontSize: 12),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        scoreEntry.value.toStringAsFixed(1),
                        style: pw.TextStyle(fontSize: 12),
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
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.orange50,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.orange200),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'CATATAN PENTING',
            style: pw.TextStyle(fontSize: 12, color: PdfColors.orange800),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            'Hasil diagnosa ini hanya untuk tujuan edukasi dan akademik. Bukan pengganti konsultasi medis profesional. '
            'Untuk diagnosa yang akurat dan penanganan yang tepat, silakan konsultasikan dengan tenaga kesehatan yang kompeten.',
            style: pw.TextStyle(fontSize: 10, color: PdfColors.orange700),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            'Dibuat dengan DiagnoFuzzy - ${DateTime.now().year}',
            style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
          ),
        ],
      ),
    );
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
