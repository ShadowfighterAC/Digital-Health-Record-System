import 'package:cloud_firestore/cloud_firestore.dart';

class MedicalRecordModel {
  final String id;
  final String patientId;
  final String doctorName;
  final String diagnosis;
  final String prescription;
  final String notes;
  final DateTime visitDate;
  final Timestamp createdAt;

  MedicalRecordModel({
    required this.id,
    required this.patientId,
    required this.doctorName,
    required this.diagnosis,
    required this.prescription,
    required this.notes,
    required this.visitDate,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      "patientId": patientId,
      "doctorName": doctorName,
      "diagnosis": diagnosis,
      "prescription": prescription,
      "notes": notes,
      "visitDate": Timestamp.fromDate(visitDate),
      "createdAt": createdAt,
    };
  }

  factory MedicalRecordModel.fromMap(
    Map<String, dynamic> map,
    String id,
  ) {
    return MedicalRecordModel(
      id: id,
      patientId: map["patientId"] ?? "",
      doctorName: map["doctorName"] ?? "",
      diagnosis: map["diagnosis"] ?? "",
      prescription: map["prescription"] ?? "",
      notes: map["notes"] ?? "",
      visitDate: (map["visitDate"] as Timestamp).toDate(),
      createdAt: map["createdAt"] ?? Timestamp.now(),
    );
  }
}