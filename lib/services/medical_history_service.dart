import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/medical_history_model.dart';
import '../utils/app_constants.dart';

class MedicalHistoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String collectionName = AppConstants.medicalHistoryCollection;

  String newHistoryId() {
    return _firestore.collection(collectionName).doc().id;
  }

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

  Stream<List<MedicalHistoryModel>> getPatientHistory(String patientId) {
    return _firestore
        .collection(collectionName)
        .where("patientId", isEqualTo: patientId)
        .orderBy("historyDate", descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => MedicalHistoryModel.fromMap(
                  doc.data(),
                  doc.id,
                ),
              )
              .toList(),
        );
  }

  Future<List<MedicalHistoryModel>> getPatientHistoryOnce(
    String patientId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection(collectionName)
          .where("patientId", isEqualTo: patientId)
          .orderBy("historyDate", descending: true)
          .get();

      return snapshot.docs
          .map(
            (doc) => MedicalHistoryModel.fromMap(
              doc.data(),
              doc.id,
            ),
          )
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get medical history for patients currently assigned to the logged-in doctor
  Stream<List<MedicalHistoryModel>> getAssignedHistory() {
    final doctorId = _auth.currentUser?.uid;

    if (doctorId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection(AppConstants.usersCollection)
        .where("role", isEqualTo: AppConstants.rolePatient)
        .where("currentDoctorId", isEqualTo: doctorId)
        .snapshots()
        .asyncMap((patientsSnapshot) async {
      final patientIds =
          patientsSnapshot.docs.map((doc) => doc.id).toList();

      if (patientIds.isEmpty) {
        return <MedicalHistoryModel>[];
      }

      final historySnapshot = await _firestore
          .collection(collectionName)
          .where("patientId", whereIn: patientIds)
          .get();

      final history = historySnapshot.docs
          .map(
            (doc) => MedicalHistoryModel.fromMap(
              doc.data(),
              doc.id,
            ),
          )
          .toList();

      history.sort(
        (a, b) => b.historyDate.compareTo(a.historyDate),
      );

      return history;
    });
  }

  Stream<List<MedicalHistoryModel>> getAllHistory() {
    return _firestore
        .collection(collectionName)
        .orderBy("historyDate", descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => MedicalHistoryModel.fromMap(
                  doc.data(),
                  doc.id,
                ),
              )
              .toList(),
        );
  }

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