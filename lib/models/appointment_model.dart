import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentModel {
  final String id;
  final String patientId;
  final String patientName;
  final String doctorName;
  final DateTime appointmentDate;
  final String appointmentTime;
  final String reason;
  final String status;
  final Timestamp createdAt;

  AppointmentModel({
    required this.id,
    required this.patientId,
    this.patientName = "",
    required this.doctorName,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.reason,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      "patientId": patientId,
      "patientName": patientName,
      "doctorName": doctorName,
      "appointmentDate": Timestamp.fromDate(appointmentDate),
      "appointmentTime": appointmentTime,
      "reason": reason,
      "status": status,
      "createdAt": createdAt,
    };
  }

  factory AppointmentModel.fromMap(
    Map<String, dynamic> map,
    String id,
  ) {
    return AppointmentModel(
      id: id,
      patientId: map["patientId"] ?? "",
      patientName: map["patientName"] ?? "",
      doctorName: map["doctorName"] ?? "",
      appointmentDate:
          (map["appointmentDate"] as Timestamp).toDate(),
      appointmentTime: map["appointmentTime"] ?? "",
      reason: map["reason"] ?? "",
      status: map["status"] ?? "",
      createdAt: map["createdAt"] ?? Timestamp.now(),
    );
  }
}