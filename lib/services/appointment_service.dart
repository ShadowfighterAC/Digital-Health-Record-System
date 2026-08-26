import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/appointment_model.dart';
import '../utils/app_constants.dart';

class AppointmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String collection = AppConstants.appointmentsCollection;

  /// Add Appointment
  Future<void> addAppointment(AppointmentModel appointment) async {
    await _firestore
        .collection(collection)
        .add(appointment.toMap());
  }

  /// Get Appointments for a Patient
  Stream<List<AppointmentModel>> getPatientAppointments(
    String patientId,
  ) {
    return _firestore
        .collection(collection)
        .where("patientId", isEqualTo: patientId)
        .orderBy("appointmentDate")
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            return AppointmentModel.fromMap(
              doc.data(),
              doc.id,
            );
          }).toList(),
        );
  }

  /// Get All Appointments (for Doctor management)
  Stream<List<AppointmentModel>> getAllAppointments() {
    return _firestore
        .collection(collection)
        .orderBy("appointmentDate", descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            return AppointmentModel.fromMap(
              doc.data(),
              doc.id,
            );
          }).toList(),
        );
  }

  /// Update Appointment Status (Scheduled, Completed, Cancelled)
  Future<void> updateAppointmentStatus(String id, String status) async {
    await _firestore.collection(collection).doc(id).update({
      'status': status,
    });
  }

  /// Update Appointment
  Future<void> updateAppointment(
    String id,
    AppointmentModel appointment,
  ) async {
    await _firestore
        .collection(collection)
        .doc(id)
        .update(appointment.toMap());
  }

  /// Delete Appointment
  Future<void> deleteAppointment(String id) async {
    await _firestore
        .collection(collection)
        .doc(id)
        .delete();
  }

  /// Get Single Appointment
  Future<AppointmentModel?> getAppointment(
    String id,
  ) async {
    final doc = await _firestore
        .collection(collection)
        .doc(id)
        .get();

    if (!doc.exists || doc.data() == null) return null;

    return AppointmentModel.fromMap(
      doc.data()!,
      doc.id,
    );
  }
}