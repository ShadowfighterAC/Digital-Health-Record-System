import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/prescription_model.dart';
import '../utils/app_constants.dart';

class PrescriptionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  /// Get all prescriptions (for Doctor view)
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
