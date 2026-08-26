import 'package:cloud_firestore/cloud_firestore.dart';

class MedicineItem {
  final String medicineName;
  final String dosage;
  final String frequency;
  final String duration;
  final String instructions;

  MedicineItem({
    required this.medicineName,
    required this.dosage,
    required this.frequency,
    required this.duration,
    this.instructions = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'medicineName': medicineName,
      'dosage': dosage,
      'frequency': frequency,
      'duration': duration,
      'instructions': instructions,
    };
  }

  factory MedicineItem.fromMap(Map<String, dynamic> map) {
    return MedicineItem(
      medicineName: map['medicineName'] ?? '',
      dosage: map['dosage'] ?? '',
      frequency: map['frequency'] ?? '',
      duration: map['duration'] ?? '',
      instructions: map['instructions'] ?? '',
    );
  }
}

class PrescriptionModel {
  final String id;
  final String patientId;
  final String patientName;
  final String doctorName;
  final String doctorId;
  final List<MedicineItem> medicines;
  final DateTime prescriptionDate;
  final String notes;
  final Timestamp createdAt;

  PrescriptionModel({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.doctorName,
    required this.doctorId,
    required this.medicines,
    required this.prescriptionDate,
    this.notes = '',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'patientId': patientId,
      'patientName': patientName,
      'doctorName': doctorName,
      'doctorId': doctorId,
      'medicines': medicines.map((m) => m.toMap()).toList(),
      'prescriptionDate': Timestamp.fromDate(prescriptionDate),
      'notes': notes,
      'createdAt': createdAt,
    };
  }

  factory PrescriptionModel.fromMap(
    Map<String, dynamic> map,
    String id,
  ) {
    var rawMedicines = map['medicines'];
    List<MedicineItem> medicineList = [];

    if (rawMedicines is List) {
      medicineList = rawMedicines
          .whereType<Map<String, dynamic>>()
          .map((item) => MedicineItem.fromMap(item))
          .toList();
    }

    // Also support backward compatibility if single medicine was saved directly as top-level fields
    if (medicineList.isEmpty && map.containsKey('medicineName')) {
      medicineList.add(
        MedicineItem(
          medicineName: map['medicineName'] ?? '',
          dosage: map['dosage'] ?? '',
          frequency: map['frequency'] ?? '',
          duration: map['duration'] ?? '',
          instructions: map['instructions'] ?? '',
        ),
      );
    }

    DateTime parsedDate = DateTime.now();
    if (map['prescriptionDate'] != null) {
      if (map['prescriptionDate'] is Timestamp) {
        parsedDate = (map['prescriptionDate'] as Timestamp).toDate();
      } else if (map['prescriptionDate'] is String) {
        parsedDate = DateTime.tryParse(map['prescriptionDate']) ?? DateTime.now();
      }
    }

    return PrescriptionModel(
      id: id,
      patientId: map['patientId'] ?? '',
      patientName: map['patientName'] ?? '',
      doctorName: map['doctorName'] ?? '',
      doctorId: map['doctorId'] ?? '',
      medicines: medicineList,
      prescriptionDate: parsedDate,
      notes: map['notes'] ?? '',
      createdAt: map['createdAt'] is Timestamp
          ? map['createdAt']
          : Timestamp.now(),
    );
  }
}
