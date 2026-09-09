import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/medical_record_model.dart';
import '../utils/app_constants.dart';
import 'storage_service.dart';

class MedicalRecordService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StorageService _storageService = StorageService();

  static const String collectionName = AppConstants.medicalRecordsCollection;

  /// Generate a unique document ID
  String newRecordId() {
    return _firestore.collection(collectionName).doc().id;
  }

  /// Add a new medical record
  Future<void> addRecord(MedicalRecordModel record) async {
    if (record.id.isNotEmpty) {
      await _firestore
          .collection(collectionName)
          .doc(record.id)
          .set(record.toMap());
    } else {
      await _firestore.collection(collectionName).add(record.toMap());
    }
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

  /// Get all records (for Doctor overview)
  Stream<List<MedicalRecordModel>> getAllRecords() {
    return _firestore
        .collection(collectionName)
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

  /// Delete a medical record and clean up attachments
  Future<void> deleteRecord(String recordId, [List<String>? storagePaths]) async {
    if (storagePaths != null) {
      for (final path in storagePaths) {
        if (path.isNotEmpty) {
          await _storageService.deleteAttachment(path);
        }
      }
    }
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

    if (!doc.exists || doc.data() == null) return null;

    return MedicalRecordModel.fromMap(
      doc.data()!,
      doc.id,
    );
  }
}
