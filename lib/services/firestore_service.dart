import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/patient_model.dart';
import '../models/user_model.dart';
import '../utils/app_constants.dart';

class PatientDashboardStats {
  final int recordsCount;
  final int appointmentsCount;
  final int prescriptionsCount;
  final int labReportsCount;

  PatientDashboardStats({
    this.recordsCount = 0,
    this.appointmentsCount = 0,
    this.prescriptionsCount = 0,
    this.labReportsCount = 0,
  });
}

class DoctorDashboardStats {
  final int totalPatients;
  final int totalAppointments;
  final int totalRecords;
  final int totalPrescriptions;

  DoctorDashboardStats({
    this.totalPatients = 0,
    this.totalAppointments = 0,
    this.totalRecords = 0,
    this.totalPrescriptions = 0,
  });
}

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Map<String, dynamic>?> getUser(String uid) async {
    DocumentSnapshot doc =
        await _firestore.collection(AppConstants.usersCollection).doc(uid).get();

    if (!doc.exists) return null;

    return doc.data() as Map<String, dynamic>?;
  }

  Future<UserModel?> getUserModel(String uid) async {
    DocumentSnapshot doc =
        await _firestore.collection(AppConstants.usersCollection).doc(uid).get();

    if (!doc.exists || doc.data() == null) return null;

    return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  Stream<List<PatientModel>> getPatients() {
    return _firestore
        .collection(AppConstants.usersCollection)
        .where("role", isEqualTo: AppConstants.rolePatient)
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

  /// Get all registered doctors for patient doctor selection
  Stream<List<UserModel>> getDoctors() {
    return _firestore
        .collection(AppConstants.usersCollection)
        .where("role", isEqualTo: AppConstants.roleDoctor)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => UserModel.fromMap(
                  doc.data(),
                  doc.id,
                ),
              )
              .toList(),
        );
  }

  /// Get patients currently assigned to a specific doctor
  Stream<List<PatientModel>> getAssignedPatients(String doctorId) {
    return _firestore
        .collection(AppConstants.usersCollection)
        .where("role", isEqualTo: AppConstants.rolePatient)
        .where("currentDoctorId", isEqualTo: doctorId)
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

  /// Update the current doctor assigned to a patient
  Future<void> updateCurrentDoctor(
    String patientId,
    String doctorId,
  ) async {
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(patientId)
        .update({
      'currentDoctorId': doctorId,
    });
  }

  /// Update user profile details safely (never altering role)
  Future<void> updateUserProfile(
    String uid, {
    required String name,
  }) async {
    await _firestore.collection(AppConstants.usersCollection).doc(uid).update({
      'name': name.trim(),
    });
  }

  /// Stream of patient dashboard stats
  Stream<PatientDashboardStats> getPatientStats(String patientId) {
    final recordsStream = _firestore
        .collection(AppConstants.medicalRecordsCollection)
        .where("patientId", isEqualTo: patientId)
        .snapshots();

    final appointmentsStream = _firestore
        .collection(AppConstants.appointmentsCollection)
        .where("patientId", isEqualTo: patientId)
        .snapshots();

    final prescriptionsStream = _firestore
        .collection(AppConstants.prescriptionsCollection)
        .where("patientId", isEqualTo: patientId)
        .snapshots();

    final labReportsStream = _firestore
        .collection(AppConstants.labReportsCollection)
        .where("patientId", isEqualTo: patientId)
        .snapshots();

    return recordsStream.asyncMap((recordsSnap) async {
      final apptSnap = await appointmentsStream.first;
      final rxSnap = await prescriptionsStream.first;
      final labSnap = await labReportsStream.first;

      return PatientDashboardStats(
        recordsCount: recordsSnap.docs.length,
        appointmentsCount: apptSnap.docs.length,
        prescriptionsCount: rxSnap.docs.length,
        labReportsCount: labSnap.docs.length,
      );
    });
  }

  /// Stream of doctor dashboard stats
  Stream<DoctorDashboardStats> getDoctorStats() {
    final currentDoctorId = _auth.currentUser?.uid;

    if (currentDoctorId == null) {
      return Stream.value(DoctorDashboardStats());
    }

    final patientsStream = _firestore
        .collection(AppConstants.usersCollection)
        .where("role", isEqualTo: AppConstants.rolePatient)
        .where("currentDoctorId", isEqualTo: currentDoctorId)
        .snapshots();

    final appointmentsStream =
        _firestore.collection(AppConstants.appointmentsCollection).snapshots();

    final recordsStream =
        _firestore.collection(AppConstants.medicalRecordsCollection).snapshots();

    final prescriptionsStream =
        _firestore.collection(AppConstants.prescriptionsCollection).snapshots();

    return patientsStream.asyncMap((patientsSnap) async {
      final apptSnap = await appointmentsStream.first;
      final recSnap = await recordsStream.first;
      final rxSnap = await prescriptionsStream.first;

      return DoctorDashboardStats(
        totalPatients: patientsSnap.docs.length,
        totalAppointments: apptSnap.docs.length,
        totalRecords: recSnap.docs.length,
        totalPrescriptions: rxSnap.docs.length,
      );
    });
  }
}