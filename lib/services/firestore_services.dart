import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> submitComplaint(String jenisKerosakan, String bahagian, String unit, String seksyen, String tempatBertugas, String perihalAduan) async {
    await _firestore.collection('aduan').add({
      'jenis_kerosakan': jenisKerosakan,
      'bahagian': bahagian,
      'unit': unit,
      'seksyen': seksyen,
      'tempat_bertugas': tempatBertugas,
      'tarikh': DateTime.now().toString(),
      'perihal_aduan': perihalAduan,
    });
  }

  Stream<QuerySnapshot> getComplaints() {
    return _firestore.collection('aduan').snapshots();
  }
}
