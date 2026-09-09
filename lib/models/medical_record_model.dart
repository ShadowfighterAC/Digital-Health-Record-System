import 'package:cloud_firestore/cloud_firestore.dart';
import 'attachment_model.dart';

class MedicalRecordModel {
  final String id;
  final String patientId;
  final String doctorName;
  final String diagnosis;
  final String prescription;
  final String notes;
  final DateTime visitDate;
  final List<AttachmentModel> attachments;
  final Timestamp createdAt;

  MedicalRecordModel({
    required this.id,
    required this.patientId,
    required this.doctorName,
    required this.diagnosis,
    required this.prescription,
    required this.notes,
    required this.visitDate,
    this.attachments = const [],
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
      "attachments": attachments.map((a) => a.toMap()).toList(),
      "createdAt": createdAt,
    };
  }

  factory MedicalRecordModel.fromMap(
    Map<String, dynamic> map,
    String id,
  ) {
    DateTime parsedVisitDate = DateTime.now();
    if (map["visitDate"] != null) {
      if (map["visitDate"] is Timestamp) {
        parsedVisitDate = (map["visitDate"] as Timestamp).toDate();
      } else if (map["visitDate"] is String) {
        parsedVisitDate = DateTime.tryParse(map["visitDate"]) ?? DateTime.now();
      }
    }

    final rawAttachments = map["attachments"] as List<dynamic>? ?? [];
    final parsedAttachments = rawAttachments
        .map((item) => AttachmentModel.fromMap(Map<String, dynamic>.from(item)))
        .toList();

    return MedicalRecordModel(
      id: id,
      patientId: map["patientId"] ?? "",
      doctorName: map["doctorName"] ?? "",
      diagnosis: map["diagnosis"] ?? "",
      prescription: map["prescription"] ?? "",
      notes: map["notes"] ?? "",
      visitDate: parsedVisitDate,
      attachments: parsedAttachments,
      createdAt:
          map["createdAt"] is Timestamp ? map["createdAt"] : Timestamp.now(),
    );
  }
}
