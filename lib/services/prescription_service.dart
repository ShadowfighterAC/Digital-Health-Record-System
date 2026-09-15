import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/prescription_model.dart';
import '../utils/app_constants.dart';

class PrescriptionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String collectionName = AppConstants.prescriptionsCollection;

  /// Add a new prescription
  Future<void> addPrescription(PrescriptionModel prescription) async {
    await _firestore.collection(collectionName).add(prescription.toMap());
  }

  /// Get prescriptions for a specific patient
  Stream<List<PrescriptionModel>> getPatientPrescriptions(String patientId) {
    return _firestore
        .collection(collectionName)
        .where("patientId", isEqualTo: patientId)
        .orderBy("prescriptionDate", descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => PrescriptionModel.fromMap(
                  doc.data(),
                  doc.id,
                ),
              )
              .toList(),
        );
  }

  /// Get prescriptions for patients currently assigned to the logged-in doctor
  Stream<List<PrescriptionModel>> getAssignedPrescriptions() {
    final doctorId = _auth.currentUser?.uid;

    if (doctorId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection(AppConstants.usersCollection)
        .where("role", isEqualTo: AppConstants.rolePatient)
        .where("currentDoctorId", isEqualTo: doctorId)
        .snapshots()
        .asyncMap((patientSnapshot) async {
          final patientIds = patientSnapshot.docs.map((doc) => doc.id).toList();

          if (patientIds.isEmpty) {
            return <PrescriptionModel>[];
          }

          final prescriptionsSnapshot = await _firestore
              .collection(collectionName)
              .where("patientId", whereIn: patientIds)
              .get();

          final prescriptions = prescriptionsSnapshot.docs
              .map(
                (doc) => PrescriptionModel.fromMap(
                  doc.data(),
                  doc.id,
                ),
              )
              .toList();

          prescriptions.sort(
            (a, b) => b.prescriptionDate.compareTo(a.prescriptionDate),
          );

          return prescriptions;
        });
  }

  /// Get all prescriptions
  ///
  /// Kept for compatibility with existing code.
  /// Doctor screens should use getAssignedPrescriptions().
  Stream<List<PrescriptionModel>> getAllPrescriptions() {
    return _firestore
        .collection(collectionName)
        .orderBy("prescriptionDate", descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => PrescriptionModel.fromMap(
                  doc.data(),
                  doc.id,
                ),
              )
              .toList(),
        );
  }

  /// Delete a prescription
  Future<void> deletePrescription(String id) async {
    await _firestore.collection(collectionName).doc(id).delete();
  }

  /// Get a single prescription
  Future<PrescriptionModel?> getPrescription(String id) async {
    final doc = await _firestore.collection(collectionName).doc(id).get();

    if (!doc.exists || doc.data() == null) return null;

    return PrescriptionModel.fromMap(doc.data()!, doc.id);
  }
}