import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';

class LaporanPage extends StatelessWidget {
  const LaporanPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('submissions').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No Reports Available'));
          }

          final submissions = snapshot.data!.docs;

          return ListView.builder(
            itemCount: submissions.length,
            itemBuilder: (context, index) {
              final submission = submissions[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text(submission['email']),
                  subtitle: Text('Date: ${submission['tarikh']}'),
                  trailing: ElevatedButton(
                    onPressed: () => _generateAndPrintPdf(submission),
                    child: const Text('View PDF'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _generateAndPrintPdf(QueryDocumentSnapshot submission) async {
    final pdf = pw.Document();
    final data = submission.data() as Map<String, dynamic>?;

    // Load the logo image
    final logoImage = pw.MemoryImage(
      (await rootBundle.load('assets/mains.png')).buffer.asUint8List(),
    );

    // Add content to the PDF document
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Center the logo at the top
            pw.Center(
              child: pw.Image(logoImage, width: 200), // Adjust width as necessary
            ),
            pw.Center(
              child: pw.Text(
                'Pejabat Setiausaha MAINS, ARAS14, MENARA MAINS,\n'
                    'Jalan Taman Bunga, 70100 Seremban Negeri Sembilan.\n'
                    'Tel: 06-765 1402 / 06-765 1405 FAKS: 06-762 0648\n'
                    'E-mel: info@mains.gov.my laman web: https://www.mains.gov.my/v1',
                textAlign: pw.TextAlign.center, // Center the text
                style: const pw.TextStyle(fontSize: 10), // Adjust font size as necessary
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Divider(height:3),
            pw.Container(
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                  left: pw.BorderSide(color: PdfColors.black, width: 1),
                  right: pw.BorderSide(color: PdfColors.black, width: 1),
                  bottom: pw.BorderSide(color: PdfColors.black, width: 1),
                ),
              ),
              padding: const pw.EdgeInsets.all(8), // Optional padding
              child: pw.Column(
                children: [
                  pw.Center(
                    child: pw.Text(
                      'BORANG ADUAN DAN PERKHIDMATAN TEKNOLOGI MAKLUMAT',
                      style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  pw.Divider(height: 3),
                ],
              ),
            ),
            pw.Text('Maklumat Pemohon', style: const pw.TextStyle(fontSize: 16)),
            pw.Divider(height:3),
            pw.SizedBox(height: 8),// Adds a line here
            // First row for Nama and Tempat Bertugas (aligned to the right)
            pw.Row(
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Tarikh Permohonan: ${data?['tarikh'] ?? 'N/A'}'),
                      pw.Text('Masa: ${data?['masa'] ?? 'N/A'}'),
                    ],
                  ),
                ),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Nama: ${data?['email'] ?? 'N/A'}'),
                      pw.Text('Tempat Bertugas: ${data?['tempat_bertugas'] ?? 'N/A'}'),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Divider(height:3),
            pw.Text('Jenis Kerosakan / Masalah', style: const pw.TextStyle(fontSize: 16)),
            pw.Divider(height:3),
            pw.SizedBox(height: 8),// Adds a line here
            // First row (3 columns: Perkakasan, Rangkaian, Perisian)
            pw.Row(
              children: [
                pw.Expanded(
                  child: pw.Row(
                    children: [
                      pw.Container(
                        width: 10,
                        height: 10,
                        decoration: pw.BoxDecoration(
                          shape: pw.BoxShape.circle,
                          border: pw.Border.all(),
                        ),
                        child: data?['jenis_kerosakan'] == 'Perkakasan'
                            ? pw.Center(child: pw.Text('✔', style: const pw.TextStyle(fontSize: 8)))
                            : pw.SizedBox(),
                      ),
                      pw.SizedBox(width: 5),
                      pw.Text('Perkakasan'),
                    ],
                  ),
                ),
                pw.Expanded(
                  child: pw.Row(
                    children: [
                      pw.Container(
                        width: 10,
                        height: 10,
                        decoration: pw.BoxDecoration(
                          shape: pw.BoxShape.circle,
                          border: pw.Border.all(),
                        ),
                        child: data?['jenis_kerosakan'] == 'Rangkaian'
                            ? pw.Center(child: pw.Text('✔', style: const pw.TextStyle(fontSize: 8)))
                            : pw.SizedBox(),
                      ),
                      pw.SizedBox(width: 5),
                      pw.Text('Rangkaian'),
                    ],
                  ),
                ),
                pw.Expanded(
                  child: pw.Row(
                    children: [
                      pw.Container(
                        width: 10,
                        height: 10,
                        decoration: pw.BoxDecoration(
                          shape: pw.BoxShape.circle,
                          border: pw.Border.all(),
                        ),
                        child: data?['jenis_kerosakan'] == 'Perisian'
                            ? pw.Center(child: pw.Text('✔', style: const pw.TextStyle(fontSize: 8)))
                            : pw.SizedBox(),
                      ),
                      pw.SizedBox(width: 5),
                      pw.Text('Perisian'),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 10),
            // Second row (3 columns: Pencetak, Sistem, Lain-lain)
            pw.Row(
              children: [
                pw.Expanded(
                  child: pw.Row(
                    children: [
                      pw.Container(
                        width: 10,
                        height: 10,
                        decoration: pw.BoxDecoration(
                          shape: pw.BoxShape.circle,
                          border: pw.Border.all(),
                        ),
                        child: data?['jenis_kerosakan'] == 'Pencetak'
                            ? pw.Center(child: pw.Text('✔', style: const pw.TextStyle(fontSize: 8)))
                            : pw.SizedBox(),
                      ),
                      pw.SizedBox(width: 5),
                      pw.Text('Pencetak'),
                    ],
                  ),
                ),
                pw.Expanded(
                  child: pw.Row(
                    children: [
                      pw.Container(
                        width: 10,
                        height: 10,
                        decoration: pw.BoxDecoration(
                          shape: pw.BoxShape.circle,
                          border: pw.Border.all(),
                        ),
                        child: data?['jenis_kerosakan'] == 'Sistem'
                            ? pw.Center(child: pw.Text('✔', style: const pw.TextStyle(fontSize: 8)))
                            : pw.SizedBox(),
                      ),
                      pw.SizedBox(width: 5),
                      pw.Text('Sistem'),
                    ],
                  ),
                ),
                pw.Expanded(
                  child: pw.Row(
                    children: [
                      pw.Container(
                        width: 10,
                        height: 10,
                        decoration: pw.BoxDecoration(
                          shape: pw.BoxShape.circle,
                          border: pw.Border.all(),
                        ),
                        child: data?['jenis_kerosakan'] == 'Lain-lain'
                            ? pw.Center(child: pw.Text('✔', style: const pw.TextStyle(fontSize: 8)))
                            : pw.SizedBox(),
                      ),
                      pw.SizedBox(width: 5),
                      pw.Text('Lain-lain'),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Divider(height:3),
            pw.Text('Perihal Kerosakan / Masalah:', style: const pw.TextStyle(fontSize: 16)),
            pw.Divider(height:3),
            pw.SizedBox(height: 8),// Adds a line here
            pw.Text('${data?['perihal_aduan'] ?? 'N/A'}'),
            pw.SizedBox(height: 20),
            pw.Divider(height:3),
            pw.Text('Laporan Tindakan', style: const pw.TextStyle(fontSize: 16)),
            pw.Divider(height: 3),
            pw.SizedBox(height: 8),// Adds a line here
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Pegawai Teknologi Maklumat Bertugas:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text('Nama: ${data?['pegawai_nama'] ?? 'N/A'}'),
                    pw.Text('Jawatan: ${data?['pegawai_jawatan'] ?? 'N/A'}'),
                    pw.Text('Tarikh: ${data?['pegawai_tarikh'] ?? 'N/A'}'),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Pemohon Yang Membuat Aduan:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text('Nama: ${data?['email'] ?? 'N/A'}'),
                    pw.Text('Jawatan: ${data?['tempat_bertugas'] ?? 'N/A'}'),
                    pw.Text('Tarikh: ${data?['tarikh'] ?? 'N/A'}'),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Divider(height:3),
            pw.Text('Pengesahan Ketua Unit / KPP ICT:'),
            pw.Divider(height:3),
            pw.SizedBox(height: 8),// Adds a line here
            pw.Text('NAMA: NORPISAH BINTI HJ.ZAKARIA ${data?['ketua_nama'] ?? 'N/A'}'),
            pw.Text('JAWATAN: KPP TEKNOLOGI MAKLUMAT ${data?['ketua_jawatan'] ?? 'N/A'}'),
            pw.Text('TARIKH: ${data?['ketua_tarikh'] ?? 'N/A'}'),
            pw.SizedBox(height: 20),
            pw.Divider(height:3),
            pw.Text('Status Tindakan:'),
            pw.Divider(height:3),
            pw.SizedBox(height: 8),// Adds a line here
            pw.Text('Aduan Selesai: ${data?['status'] == 'Completed' ? '✔' : '✘'}'),
            pw.Text('Tindakan Susulan: ${data?['status'] == 'In Progress' ? '✔' : '✘'}'),
          ],
        ),
      ),
    );
    // Print or save the generated PDF
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }
    // Print or save the generated PDF
}
