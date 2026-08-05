import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/medical_record_model.dart';

class MedicalRecordService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String collectionName = "medical_records";

  /// Add a new medical record
  Future<void> addRecord(MedicalRecordModel record) async {
    await _firestore
        .collection(collectionName)
        .add(record.toMap());
  }

  /// Get all records for a patient
  Stream<List<MedicalRecordModel>> getPatientRecords(
    String patientId,
  ) {
    return _firestore
        .collection(collectionName)
        .where("patientId", isEqualTo: patientId)
        .orderBy("visitDate", descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            return MedicalRecordModel.fromMap(
              doc.data(),
              doc.id,
            );
          }).toList(),
        );
  }

  /// Update an existing medical record
  Future<void> updateRecord(
    String recordId,
    MedicalRecordModel record,
  ) async {
    await _firestore
        .collection(collectionName)
        .doc(recordId)
        .update(record.toMap());
  }

  /// Delete a medical record
  Future<void> deleteRecord(String recordId) async {
    await _firestore
        .collection(collectionName)
        .doc(recordId)
        .delete();
  }

  /// Get a single record
  Future<MedicalRecordModel?> getRecord(
    String recordId,
  ) async {
    final doc = await _firestore
        .collection(collectionName)
        .doc(recordId)
        .get();

    if (!doc.exists) return null;

    return MedicalRecordModel.fromMap(
      doc.data()!,
      doc.id,
    );
  }
}