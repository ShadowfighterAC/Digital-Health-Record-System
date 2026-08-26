import 'package:cloud_firestore/cloud_firestore.dart';

class LabReportModel {
  final String id;
  final String patientId;
  final String patientName;
  final String doctorName;
  final String doctorId;
  final String testName;
  final String result;
  final String referenceRange;
  final String remarks;
  final DateTime reportDate;
  final Timestamp createdAt;

  LabReportModel({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.doctorName,
    required this.doctorId,
    required this.testName,
    required this.result,
    this.referenceRange = '',
    this.remarks = '',
    required this.reportDate,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'patientId': patientId,
      'patientName': patientName,
      'doctorName': doctorName,
      'doctorId': doctorId,
      'testName': testName,
      'result': result,
      'referenceRange': referenceRange,
      'remarks': remarks,
      'reportDate': Timestamp.fromDate(reportDate),
      'createdAt': createdAt,
    };
  }

  factory LabReportModel.fromMap(
    Map<String, dynamic> map,
    String id,
  ) {
    DateTime parsedDate = DateTime.now();
    if (map['reportDate'] != null) {
      if (map['reportDate'] is Timestamp) {
        parsedDate = (map['reportDate'] as Timestamp).toDate();
      } else if (map['reportDate'] is String) {
        parsedDate = DateTime.tryParse(map['reportDate']) ?? DateTime.now();
      }
    }

    return LabReportModel(
      id: id,
      patientId: map['patientId'] ?? '',
      patientName: map['patientName'] ?? '',
      doctorName: map['doctorName'] ?? '',
      doctorId: map['doctorId'] ?? '',
      testName: map['testName'] ?? '',
      result: map['result'] ?? '',
      referenceRange: map['referenceRange'] ?? '',
      remarks: map['remarks'] ?? '',
      reportDate: parsedDate,
      createdAt: map['createdAt'] is Timestamp
          ? map['createdAt']
          : Timestamp.now(),
    );
  }
}
