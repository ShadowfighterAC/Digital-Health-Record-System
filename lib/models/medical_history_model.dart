import 'package:cloud_firestore/cloud_firestore.dart';
import 'attachment_model.dart';

class MedicalHistoryModel {
  final String id;
  final String patientId;
  final String doctorId;
  final String doctorName;
  final String category;
  final String title;
  final String description;
  final DateTime historyDate;
  final String notes;
  final List<AttachmentModel> attachments;
  final Timestamp createdAt;

  MedicalHistoryModel({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.doctorName,
    required this.category,
    required this.title,
    required this.description,
    required this.historyDate,
    required this.notes,
    this.attachments = const [],
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'patientId': patientId,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'category': category,
      'title': title,
      'description': description,
      'historyDate': Timestamp.fromDate(historyDate),
      'notes': notes,
      'attachments': attachments.map((a) => a.toMap()).toList(),
      'createdAt': createdAt,
    };
  }

  factory MedicalHistoryModel.fromMap(
    Map<String, dynamic> map,
    String id,
  ) {
    DateTime parsedDate = DateTime.now();
    if (map['historyDate'] != null) {
      if (map['historyDate'] is Timestamp) {
        parsedDate = (map['historyDate'] as Timestamp).toDate();
      } else if (map['historyDate'] is String) {
        parsedDate = DateTime.tryParse(map['historyDate']) ?? DateTime.now();
      }
    }

    final rawAttachments = map['attachments'] as List<dynamic>? ?? [];
    final List<AttachmentModel> parsedAttachments = [];
    for (final item in rawAttachments) {
      if (item is Map) {
        parsedAttachments.add(
          AttachmentModel.fromMap(Map<String, dynamic>.from(item)),
        );
      }
    }

    Timestamp parsedCreatedAt;
    if (map['createdAt'] is Timestamp) {
      parsedCreatedAt = map['createdAt'] as Timestamp;
    } else if (map['createdAt'] is String) {
      final dt = DateTime.tryParse(map['createdAt'] as String) ?? DateTime.now();
      parsedCreatedAt = Timestamp.fromDate(dt);
    } else {
      parsedCreatedAt = Timestamp.now();
    }

    return MedicalHistoryModel(
      id: id,
      patientId: map['patientId'] ?? '',
      doctorId: map['doctorId'] ?? '',
      doctorName: map['doctorName'] ?? '',
      category: map['category'] ?? 'Other History',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      historyDate: parsedDate,
      notes: map['notes'] ?? '',
      attachments: parsedAttachments,
      createdAt: parsedCreatedAt,
    );
  }
}
