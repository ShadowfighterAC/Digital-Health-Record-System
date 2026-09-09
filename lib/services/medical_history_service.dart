import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/medical_history_model.dart';
import '../utils/app_constants.dart';

/// Firestore service for managing medical history records.
///
/// Collection: `medical_history`
///
/// Authorization:
/// - Doctors: create, read (all), update, delete.
/// - Patients: read only their own records (`patientId == request.auth.uid`).
class MedicalHistoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Firestore collection name
  static const String collectionName = AppConstants.medicalHistoryCollection;

  /// Generates a unique document ID before writing to Firestore
  /// (useful for associating storage paths prior to saving metadata).
  String newHistoryId() {
    return _firestore.collection(collectionName).doc().id;
  }

  /// 1. CREATE
  /// Adds a new [MedicalHistoryModel] record to the `medical_history` collection.
  /// All model fields (patientId, doctorId, doctorName, category, title,
  /// description, historyDate, notes, attachments, createdAt) are serialized.
  ///
  /// Returns the document ID.
  Future<String> addHistory(MedicalHistoryModel history) async {
    try {
      if (history.id.isNotEmpty) {
        await _firestore
            .collection(collectionName)
            .doc(history.id)
            .set(history.toMap());
        return history.id;
      } else {
        final docRef = await _firestore
            .collection(collectionName)
            .add(history.toMap());
        return docRef.id;
      }
    } catch (e) {
      rethrow;
    }
  }

  /// 2. READ PATIENT HISTORY
  /// Retrieves a stream of [MedicalHistoryModel] records for a specific patient.
  ///
  /// Query: `patientId == patientId`, ordered by `historyDate` descending.
  Stream<List<MedicalHistoryModel>> getPatientHistory(String patientId) {
    return _firestore
        .collection(collectionName)
        .where("patientId", isEqualTo: patientId)
        .orderBy("historyDate", descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => MedicalHistoryModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  /// Retrieves a one-time list of [MedicalHistoryModel] records for a specific patient.
  Future<List<MedicalHistoryModel>> getPatientHistoryOnce(
      String patientId) async {
    try {
      final snapshot = await _firestore
          .collection(collectionName)
          .where("patientId", isEqualTo: patientId)
          .orderBy("historyDate", descending: true)
          .get();

      return snapshot.docs
          .map((doc) => MedicalHistoryModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Retrieves a stream of all medical history records (for doctor overview).
  Stream<List<MedicalHistoryModel>> getAllHistory() {
    return _firestore
        .collection(collectionName)
        .orderBy("historyDate", descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => MedicalHistoryModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  /// 3. GET SINGLE RECORD
  /// Retrieves a single medical-history document by its document ID.
  /// Returns `null` if the document does not exist.
  Future<MedicalHistoryModel?> getHistory(String historyId) async {
    try {
      final doc =
          await _firestore.collection(collectionName).doc(historyId).get();
      if (!doc.exists || doc.data() == null) {
        return null;
      }
      return MedicalHistoryModel.fromMap(doc.data()!, doc.id);
    } catch (e) {
      rethrow;
    }
  }

  /// 4. UPDATE
  /// Updates an existing medical-history document.
  /// All fields including updated attachments are serialized.
  Future<void> updateHistory(
    String historyId,
    MedicalHistoryModel history,
  ) async {
    try {
      await _firestore
          .collection(collectionName)
          .doc(historyId)
          .update(history.toMap());
    } catch (e) {
      rethrow;
    }
  }

  /// 5. DELETE
  /// Deletes a medical-history document by ID or Model instance.
  ///
  /// IMPORTANT: Deleting the Firestore document does NOT automatically delete
  /// Supabase Storage files yet (Storage cleanup is handled separately).
  Future<void> deleteHistory(dynamic historyOrId) async {
    try {
      final String historyId = historyOrId is MedicalHistoryModel
          ? historyOrId.id
          : historyOrId.toString();

      if (historyId.isEmpty) {
        throw ArgumentError('historyId cannot be empty');
      }

      await _firestore.collection(collectionName).doc(historyId).delete();
    } catch (e) {
      rethrow;
    }
  }
}
