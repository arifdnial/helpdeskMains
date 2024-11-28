import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminApprovalScreen extends StatefulWidget {
  @override
  _AdminApprovalScreenState createState() => _AdminApprovalScreenState();
}

class _AdminApprovalScreenState extends State<AdminApprovalScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _pendingAdmins = [];
  bool _isLoading = true;

  String _selectedLocation = '';

  Future<void> _approveAdmin(String adminId) async {
    await _firestore.collection('admins').doc(adminId).update({'approved': true});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Admin approved successfully!')),
    );
  }

  Future<void> _setLocation(String adminId) async {
    String selectedLocation = _selectedLocation;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Assign Location"),
          content: DropdownButton<String>(
            value: selectedLocation.isEmpty ? null : selectedLocation,
            hint: const Text("Select Location"),
            items: [
              'KUALA PILAH',
              'JEMPOL',
              'JOHOL',
              'NILAI',
              'PORT DICKSON',
              'JELEBU',
              'REMBAU',
              'TAMPIN',
              'GEMAS',
              'MENARA MAINS',
              'SENAWANG',
              'SEREMBAN 2',
            ].map((location) {
              return DropdownMenuItem<String>(
                value: location,
                child: Text(location),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedLocation = value ?? '';
              });
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedLocation.isNotEmpty) {
                  // Assign the location to the admin
                  await _firestore.collection('admins').doc(adminId).update({
                    'location': selectedLocation,
                  });

                  // Assign all pending submissions for this location to the new admin
                  QuerySnapshot pendingSubmissions = await _firestore
                      .collection('submissions')
                      .where('lokasi', isEqualTo: selectedLocation)
                      .where('assigned_to_admin', isEqualTo: null)
                      .get();

                  for (var submission in pendingSubmissions.docs) {
                    await submission.reference.update({
                      'assigned_to_admin': adminId,
                    });
                  }

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Location and submissions assigned to admin!')),
                  );

                  fetchPendingAdmins(); // Refresh the admin list
                }
              },
              child: const Text("Assign"),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    fetchPendingAdmins();
  }

  Future<void> fetchPendingAdmins() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('admins')
          .where('approved', isEqualTo: false)
          .get();

      setState(() {
        _pendingAdmins = snapshot.docs.map((doc) {
          return {
            'name': doc['name'],
            'email': doc['email'],
            'id': doc.id,
            'imageUrl': doc['imageUrl'],
          };
        }).toList();
      });
    } catch (e) {
      print("Error fetching pending admins: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching admins: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> approveAdmin(String adminId) async {
    try {
      await _firestore.collection('admins').doc(adminId).update({'approved': true});
      fetchPendingAdmins();
    } catch (e) {
      print("Error approving admin: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error approving admin: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Admin Approval')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _pendingAdmins.isEmpty
          ? Center(child: Text('No pending admins to approve.'))
          : ListView.builder(
        itemCount: _pendingAdmins.length,
        itemBuilder: (context, index) {
          final admin = _pendingAdmins[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(admin['imageUrl'] ?? ''),
              radius: 30,
            ),
            title: Text(admin['name']),
            subtitle: Text(admin['email']),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () => approveAdmin(admin['id']),
                  child: Text('Approve'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _setLocation(admin['id']),
                  child: Text('Set Location'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
