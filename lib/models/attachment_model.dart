import 'package:cloud_firestore/cloud_firestore.dart';

class AttachmentModel {
  final String id;
  final String name;
  final String type; // "image" or "pdf"
  final String fileExtension;
  final String downloadUrl;
  final String storagePath;
  final int sizeInBytes;
  final Timestamp createdAt;

  AttachmentModel({
    required this.id,
    required this.name,
    required this.type,
    required this.fileExtension,
    this.downloadUrl = '',
    this.storagePath = '',
    this.sizeInBytes = 0,
    required this.createdAt,
  });

  bool get isImage =>
      type == 'image' || ['jpg', 'jpeg', 'png'].contains(fileExtension.toLowerCase());
  bool get isPdf => type == 'pdf' || fileExtension.toLowerCase() == 'pdf';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'fileExtension': fileExtension,
      'downloadUrl': downloadUrl,
      'storagePath': storagePath,
      'sizeInBytes': sizeInBytes,
      'createdAt': createdAt,
    };
  }

  factory AttachmentModel.fromMap(Map<String, dynamic> map) {
    final rawExt = map['fileExtension'] ?? '';
    final rawName = map['name'] ?? 'Attachment';
    String ext = rawExt.toString().toLowerCase().replaceAll('.', '').trim();
    if (ext.isEmpty && rawName.toString().contains('.')) {
      ext = rawName.toString().split('.').last.toLowerCase().trim();
    }

    String detectedType = (map['type'] ?? '').toString().toLowerCase();
    if (detectedType != 'image' && detectedType != 'pdf') {
      if (['jpg', 'jpeg', 'png'].contains(ext)) {
        detectedType = 'image';
      } else if (ext == 'pdf') {
        detectedType = 'pdf';
      } else {
        detectedType = detectedType.isNotEmpty ? detectedType : 'file';
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

    return AttachmentModel(
      id: map['id'] ?? '',
      name: rawName.toString(),
      type: detectedType,
      fileExtension: ext,
      downloadUrl: map['downloadUrl'] ?? map['url'] ?? '',
      storagePath: map['storagePath'] ?? '',
      sizeInBytes: map['sizeInBytes'] is int
          ? map['sizeInBytes'] as int
          : (int.tryParse(map['sizeInBytes']?.toString() ?? '0') ?? 0),
      createdAt: parsedCreatedAt,
    );
  }
}
