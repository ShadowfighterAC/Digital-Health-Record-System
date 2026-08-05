import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/patient_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> getUser(String uid) async {
    DocumentSnapshot doc =
        await _firestore.collection('users').doc(uid).get();

    if (!doc.exists) return null;

    return doc.data() as Map<String, dynamic>;
  }

  Stream<List<PatientModel>> getPatients() {
    return _firestore
        .collection("users")
        .where("role", isEqualTo: "Patient")
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => PatientModel.fromMap(
                  doc.data(),
                  doc.id,
                ),
              )
              .toList(),
        );
  }
}