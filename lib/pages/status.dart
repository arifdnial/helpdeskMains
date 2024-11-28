import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class StatusSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      body: user != null
          ? StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('submissions')
            .where('userId', isEqualTo: user.uid)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No submissions found.'));
          }
          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
              return _buildComplaintCard(context, document.id, data);
            }).toList(),
          );
        },
      )
          : const Center(child: Text('Please log in to see your submissions.')),
    );
  }
  Widget _buildComplaintCard(BuildContext context, String documentId, Map<String, dynamic> data) {
    final lokasi = data['lokasi'] ?? 'Unknown';
    final status = data['status'] ?? 'Pending';
    final comment = data['admin_comments'] ?? 'No comments';
    final perihalAduan = data['perihal_aduan'] ?? 'No details provided';
    final Timestamp? submittedAt = data['submitted_at'];
    final String submittedDate = submittedAt != null
        ? DateFormat('yyyy-MM-dd').format(submittedAt.toDate())
        : 'Unknown';
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Location: $lokasi', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Perihal Aduan: $perihalAduan'),
            const SizedBox(height: 8),
            StatusProgressIndicator(status: status),
            const SizedBox(height: 8),
            Text('Admin Comments: $comment'),
            const SizedBox(height: 8),
            Text('Submitted on: $submittedDate'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    _confirmDelete(context, documentId);
                  },
                  icon: const Icon(Icons.delete, color: Colors.white, size: 20),
                  label: const Text(
                    'Delete',
                    style: TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Set background color to red
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    shadowColor: Colors.redAccent.withOpacity(0.3),
                    elevation: 5,
                  ),
                ),

                const SizedBox(width: 8),ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditSubmissionScreen(
                          documentId: documentId, // Pass the document ID here
                          data: data, // Pass the submission data here
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                  label: const Text(
                    'Edit',
                    style: TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    shadowColor: Colors.blueAccent.withOpacity(0.3),
                    elevation: 5,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String documentId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this submission?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () async {
                await _deleteSubmission(documentId);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  Future<void> _deleteSubmission(String documentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('submissions')
          .doc(documentId)
          .delete();
    } catch (e) {
      print('Error deleting document: $e');
    }
  }
}
class EditSubmissionScreen extends StatefulWidget {
  final String documentId;
  final Map<String, dynamic> data;

  EditSubmissionScreen({required this.documentId, required this.data});

  @override
  _EditSubmissionScreenState createState() => _EditSubmissionScreenState();
}


class _EditSubmissionScreenState extends State<EditSubmissionScreen> {
  final TextEditingController _perihalAduanController = TextEditingController();
  final TextEditingController _lokasiController = TextEditingController();
  final TextEditingController _bahagianController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  final TextEditingController _seksyenController = TextEditingController();
  final TextEditingController _tempatBertugasController = TextEditingController();

  DateTime? _selectedDate;
  String _selectedOption = "Perkakasan";

  @override
  void initState() {
    super.initState();
    // Populate the controllers with existing data
    _perihalAduanController.text = widget.data['perihal_aduan'] ?? '';
    _lokasiController.text = widget.data['lokasi'] ?? '';
    _bahagianController.text = widget.data['bahagian'] ?? '';
    _unitController.text = widget.data['unit'] ?? '';
    _seksyenController.text = widget.data['seksyen'] ?? '';
    _tempatBertugasController.text = widget.data['tempat_bertugas'] ?? '';

    // Initialize date and option with existing data
    _selectedDate = widget.data['selected_date'] != null
        ? (widget.data['selected_date'] as Timestamp).toDate()
        : null;
    _selectedOption = widget.data['selected_option'] ?? "Perkakasan";
  }

  @override
  void dispose() {
    _perihalAduanController.dispose();
    _lokasiController.dispose();
    _bahagianController.dispose();
    _unitController.dispose();
    _seksyenController.dispose();
    _tempatBertugasController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    try {
      await FirebaseFirestore.instance.collection('submissions').doc(widget.documentId).update({
        'perihal_aduan': _perihalAduanController.text,
        'lokasi': _lokasiController.text,
        'bahagian': _bahagianController.text,
        'unit': _unitController.text,
        'seksyen': _seksyenController.text,
        'tempat_bertugas': _tempatBertugasController.text,
        'selected_date': _selectedDate != null ? Timestamp.fromDate(_selectedDate!) : null,
        'selected_option': _selectedOption,  // Ensure selected_option is updated
        'submitted_at': Timestamp.now(),
      });
      Navigator.of(context).pop();
    } catch (e) {
      print('Error updating document: $e');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Submission'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _bahagianController,
                decoration: const InputDecoration(labelText: 'Bahagian'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _unitController,
                decoration: const InputDecoration(labelText: 'Unit'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _seksyenController,
                decoration: const InputDecoration(labelText: 'Seksyen'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _tempatBertugasController,
                decoration: const InputDecoration(labelText: 'Tempat Bertugas'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _lokasiController,
                decoration: const InputDecoration(labelText: 'Lokasi'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _perihalAduanController,
                decoration: const InputDecoration(labelText: 'Perihal Aduan'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Date: '),
                  Text(_selectedDate != null
                      ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
                      : 'No date selected'),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedOption,
                onChanged: (value) {
                  setState(() {
                    _selectedOption = value!;
                  });
                },
                items: ["Perkakasan", "Perisian", "Lain-lain"].map((option) {
                  return DropdownMenuItem(
                    value: option,
                    child: Text(option),
                  );
                }).toList(),
                decoration: const InputDecoration(labelText: 'Option'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveChanges,
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class StatusProgressIndicator extends StatelessWidget {
  final String status;

  StatusProgressIndicator({required this.status});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStep('Belum Selesai', Icons.hourglass_empty, status == 'Pending' || status == 'In Progress' || status == 'Completed'),
        _buildLine(status == 'In Progress' || status == 'Completed'),
        _buildStep('Sedang Diproses', Icons.autorenew, status == 'In Progress' || status == 'Completed'),
        _buildLine(status == 'Completed'),
        _buildStep('Selesai', Icons.check_circle, status == 'Completed'),
      ],
    );
  }

  Widget _buildStep(String label, IconData icon, bool isActive) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: isActive
                ? const LinearGradient(colors: [Colors.blueAccent, Colors.blue])
                : LinearGradient(colors: [Colors.grey, Colors.grey.shade400]),
            boxShadow: isActive
                ? [BoxShadow(color: Colors.blueAccent.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))]
                : [],
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.blue : Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildLine(bool isActive) {
    return Expanded(
      child: Container(
        height: 2,
        decoration: BoxDecoration(
          gradient: isActive
              ? const LinearGradient(colors: [Colors.blueAccent, Colors.blue])
              : LinearGradient(colors: [Colors.grey, Colors.grey.shade400]),
        ),
      ),
    );
  }
}
