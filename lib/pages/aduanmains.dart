import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class AddSubmissionScreen extends StatefulWidget {
  @override
  _AddSubmissionScreenState createState() => _AddSubmissionScreenState();
}

class _AddSubmissionScreenState extends State<AddSubmissionScreen> {
  final TextEditingController _perihalAduanController = TextEditingController();
  final TextEditingController _bahagianController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  final TextEditingController _seksyenController = TextEditingController();
  final TextEditingController _tempatBertugasController = TextEditingController();
  String? _selectedLokasi;
  DateTime? _selectedDate;
  String _selectedOption = "Perkakasan";
  String? userEmail;
  String? currentUserId;

  // List of locations
  final List<String> _locations = [
    'MENARA MAINS',
    'SENAWANG',
    'SEREMBAN 2',
    'PORT DICKSON',
    'KUALA PILAH',
    'TAMPIN',
    'JELEBU',
    'JEMPOL',
    'REMBAU',
    'GEMAS',
    'NILAI',
    'JOHOL',
  ];

  @override
  void initState() {
    super.initState();
    _fetchCurrentUser();
  }

  Future<void> _fetchCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      userEmail = user?.email;
      currentUserId = user?.uid;
    });
  }

  /// Submits the form data to Firestore
  Future<void> _submitForm(String location, String email, String userId, Timestamp selectedDate) async {
    try {
      final submissionData = {
        'lokasi': location,
        'email': email,
        'userId': userId,
        'perihal_aduan': _perihalAduanController.text,
        'bahagian': _bahagianController.text,
        'unit': _unitController.text,
        'seksyen': _seksyenController.text,
        'tempat_bertugas': _tempatBertugasController.text,
        'selected_date': selectedDate,
        'selected_option': _selectedOption,
        'submitted_at': FieldValue.serverTimestamp(),
        'status': 'Pending',
        'assigned_to_admin': null, // Initially, no admin assigned
      };

      // Save submission to Firestore
      await FirebaseFirestore.instance.collection('submissions').add(submissionData);

      // Notify user of successful submission
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Form submitted successfully!')),
      );

      // Navigate back
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting form: $e')),
      );
    }
  }

  Future<void> _saveSubmission() async {
    if (userEmail == null || currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in')),
      );
      return;
    }

    if (_selectedLokasi == null || _selectedDate == null || _perihalAduanController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out all required fields.')),
      );
      return;
    }

    // Call the _submitForm method
    await _submitForm(
      _selectedLokasi!,
      userEmail!,
      currentUserId!,
      Timestamp.fromDate(_selectedDate!),
    );
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
        title: const Text('Add Aduan'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildCardInputField(_bahagianController, 'Bahagian', Icons.business),
            _buildCardInputField(_unitController, 'Unit', Icons.business_center),
            _buildCardInputField(_seksyenController, 'Seksyen', Icons.category),
            _buildCardInputField(_tempatBertugasController, 'Tempat Bertugas', Icons.work),

            // Replace Lokasi TextField with a Dropdown
            _buildDropdownInputField(
              label: 'Lokasi',
              value: _selectedLokasi,
              items: _locations,
              onChanged: (value) {
                setState(() {
                  _selectedLokasi = value;
                });
              },
            ),

            _buildCardInputField(_perihalAduanController, 'Perihal Aduan', Icons.report_problem),

            const SizedBox(height: 16),

            _buildDatePickerRow(),

            const SizedBox(height: 16),

            _buildOptionDropdown(),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _saveSubmission,
              child: const Text('Submit'),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCardInputField(TextEditingController controller, String label, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.blueAccent),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: label,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownInputField({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Card(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.location_on, color: Colors.blueAccent),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: value,
                onChanged: onChanged,
                items: items.map((location) {
                  return DropdownMenuItem<String>(
                    value: location,
                    child: Text(location),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: label,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePickerRow() {
    return Row(
      children: [
        const Icon(Icons.calendar_today, color: Colors.blueAccent),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () => _selectDate(context),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blueAccent),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedDate != null
                        ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
                        : 'No date selected',
                    style: TextStyle(color: _selectedDate == null ? Colors.grey : Colors.black),
                  ),
                  const Icon(Icons.arrow_drop_down, color: Colors.blueAccent),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionDropdown() {
    return Card(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.more_horiz, color: Colors.blueAccent),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
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
                decoration: InputDecoration(
                  labelText: 'Option',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
