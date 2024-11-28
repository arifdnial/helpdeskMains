import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';

class SubmissionDetailsPage extends StatefulWidget {
  final QueryDocumentSnapshot submission;
  final List<String> _statusOptions = ['Pending', 'In Progress', 'Completed'];

  SubmissionDetailsPage({Key? key, required this.submission}) : super(key: key);
  @override
  _SubmissionDetailsPageState createState() => _SubmissionDetailsPageState();
}
class _SubmissionDetailsPageState extends State<SubmissionDetailsPage> {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final TextEditingController _commentController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final data = widget.submission.data() as Map<String, dynamic>?;
// Retrieve fields, using the correct Firestore keys
    final email = data?['email'] ?? 'N/A';
    final userId = data?['userId'] ?? '';
    final tarikh = data?['selected_date'] != null
        ? (data!['selected_date'] as Timestamp).toDate().toString() // Convert Timestamp to Date
        : 'N/A';
    final jenisKerosakan = data?['jenis_kerosakan'] ?? 'N/A';
    final lokasi = data? ['lokasi'] ?? 'N/A';
    final perihalAduan = data?['perihal_aduan'] ?? 'N/A';
    final bahagian = data?['bahagian'] ?? 'N/A';
    final seksyen = data?['seksyen'] ?? 'N/A';
    final tempatBertugas = data?['tempat_bertugas'] ?? 'N/A';
    final unit = data?['unit'] ?? 'N/A';
    final status = data?['status'] ?? widget._statusOptions[0];
    final adminComments = data?['admin_comments'] ?? 'No comments yet';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Submission Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Add the logo at the top
              const SizedBox(height: 20),
              Row(
                children: [
                  _buildProfileImage(userId),
                  const SizedBox(width: 20),
                  Text(
                    'User: $email',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text('Date: $tarikh', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 20),
              Text('Jenis Kerosakan: $jenisKerosakan',
                  style: const TextStyle(fontSize: 16)),
              Text('Lokasi: $lokasi', style: const TextStyle(fontSize: 16)),
              Text('Bahagian: $bahagian', style: const TextStyle(fontSize: 16)),
              Text('Perihal Aduan: $perihalAduan',
                  style: const TextStyle(fontSize: 16)),
              Text('Seksyen: $seksyen', style: const TextStyle(fontSize: 16)),
              Text('Tempat Bertugas: $tempatBertugas',
                  style: const TextStyle(fontSize: 16)),
              Text('Unit: $unit', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 20),
              Text('Status: $status',
                  style: const TextStyle(fontSize: 16, color: Colors.blue)),
              const SizedBox(height: 20),
              DropdownButton<String>(
                value: status,
                icon: const Icon(Icons.arrow_downward),
                items: widget._statusOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newStatus) {
                  if (newStatus != null) {
                    _updateStatus(context, newStatus);
                  }
                },
              ),
              const SizedBox(height: 20),
              const Text('Admin Comments:', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              Text(adminComments,
                  style: const TextStyle(fontSize: 16, color: Colors.black87)),
              const SizedBox(height: 20),
              TextField(
                controller: _commentController,
                maxLines: 3,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter your comment',
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => _submitComment(context),
                child: const Text('Submit Comment'),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Print to PDF'),
                onPressed: () => _generateAndPrintPdf(),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildProfileImage(String userId) {
    return FutureBuilder<DocumentSnapshot>(
      future: _firestore.collection('users').doc(userId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircleAvatar(
            radius: 30,
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError ||
            !snapshot.hasData ||
            !snapshot.data!.exists) {
          return const CircleAvatar(
            radius: 30,
            backgroundImage: AssetImage('assets/default_profile.png'),
          );
        } else {
          final data = snapshot.data!.data() as Map<String, dynamic>?;
          final profileImageUrl = data?['profileImageUrl'];
          if (profileImageUrl == null || profileImageUrl.isEmpty) {
            return const CircleAvatar(
              radius: 30,
              backgroundImage: AssetImage('assets/default_profile.png'),
            );
          } else {
            return CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(profileImageUrl),
            );
          }
        }
      },
    );
  }
  Future<void> _generateAndPrintPdf() async {
    final pdf = pw.Document();
    final data = widget.submission.data() as Map<String, dynamic>?;

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
                      pw.Text('Tarikh Permohonan: ${data?['selected_date'] ?? 'N/A'}'),
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

  void _updateStatus(BuildContext context, String newStatus) async {
    await FirebaseFirestore.instance
        .collection('submissions')
        .doc(widget.submission.id)
        .update({'status': newStatus});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Status updated to $newStatus')),
    );
    setState(() {});
  }
  void _submitComment(BuildContext context) async {
    final comment = _commentController.text.trim();
    if (comment.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('submissions')
          .doc(widget.submission.id)
          .update({'admin_comments': comment});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comment submitted')),
      );

      setState(() {
        _commentController.clear();
      });
    }
  }
}