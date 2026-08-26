import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/lab_report_model.dart';
import '../utils/app_constants.dart';

class LabReportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String collectionName = AppConstants.labReportsCollection;

  /// Add a new lab report
  Future<void> addLabReport(LabReportModel report) async {
    await _firestore.collection(collectionName).add(report.toMap());
  }

  /// Get all lab reports for a specific patient
  Stream<List<LabReportModel>> getPatientLabReports(String patientId) {
    return _firestore
        .collection(collectionName)
        .where("patientId", isEqualTo: patientId)
        .orderBy("reportDate", descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => LabReportModel.fromMap(
                  doc.data(),
                  doc.id,
                ),
              )
              .toList(),
        );
  }

  /// Get all lab reports (for Doctor overview)
  Stream<List<LabReportModel>> getAllLabReports() {
    return _firestore
        .collection(collectionName)
        .orderBy("reportDate", descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => LabReportModel.fromMap(
                  doc.data(),
                  doc.id,
                ),
              )
              .toList(),
        );
  }

  /// Delete a lab report
  Future<void> deleteLabReport(String id) async {
    await _firestore.collection(collectionName).doc(id).delete();
  }

  /// Get a single lab report
  Future<LabReportModel?> getLabReport(String id) async {
    final doc = await _firestore.collection(collectionName).doc(id).get();
    if (!doc.exists || doc.data() == null) return null;
    return LabReportModel.fromMap(doc.data()!, doc.id);
  }
}
