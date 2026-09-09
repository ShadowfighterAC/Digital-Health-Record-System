import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/attachment_model.dart';
import '../utils/app_constants.dart';

/// Service for managing file attachments in the private Supabase Storage bucket.
///
/// Authentication:
/// All requests use the Supabase client initialized with dynamic Firebase Auth ID tokens.
/// Authorization is strictly enforced by PostgreSQL Row-Level Security (RLS) policies
/// in Supabase using the verified `app_role` ("Doctor" or "Patient") and `sub` (UID) claims.
class StorageService {
  /// Name of the private Supabase Storage bucket
  static const String bucketName = AppConstants.supabaseStorageBucket;

  /// Supabase client instance (authenticates via current Firebase ID token)
  final SupabaseClient _client = Supabase.instance.client;

  // ─────────────────────────────────────────────────────────────────────────
  // Validation Helpers
  // ─────────────────────────────────────────────────────────────────────────

  /// Checks whether an extension is a supported image format (jpg, jpeg, png).
  static bool isImageExtension(String ext) {
    final cleanExt = ext.toLowerCase().replaceAll('.', '').trim();
    return ['jpg', 'jpeg', 'png'].contains(cleanExt);
  }

  /// Checks whether an extension is a supported PDF format.
  static bool isPdfExtension(String ext) {
    final cleanExt = ext.toLowerCase().replaceAll('.', '').trim();
    return cleanExt == 'pdf';
  }

  /// Checks whether a given file extension is supported (image or PDF).
  static bool isSupportedExtension(String ext) {
    return isImageExtension(ext) || isPdfExtension(ext);
  }

  /// Resolves the appropriate MIME content-type for an extension.
  static String getContentType(String ext) {
    final cleanExt = ext.toLowerCase().replaceAll('.', '').trim();
    switch (cleanExt) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'pdf':
        return 'application/pdf';
      default:
        return 'application/octet-stream';
    }
  }

  /// Validates file existence, extension, and size limit before upload.
  ///
  /// Limits:
  /// - Images (JPG, JPEG, PNG): Maximum 10 MB
  /// - PDFs (PDF): Maximum 20 MB
  ///
  /// Throws an [Exception] if validation fails.
  static void validateFile(File file, {bool? isPdf}) {
    if (!file.existsSync()) {
      throw Exception('The selected file does not exist: ${file.path}');
    }

    final fileSize = file.lengthSync();
    final ext = p.extension(file.path).toLowerCase().replaceAll('.', '').trim();

    if (!isSupportedExtension(ext)) {
      throw Exception(
        'Unsupported file format (.$ext). Only JPG, JPEG, PNG, and PDF files are permitted.',
      );
    }

    final expectingPdf = isPdf ?? isPdfExtension(ext);

    if (expectingPdf) {
      if (!isPdfExtension(ext)) {
        throw Exception('Invalid file type: expected a PDF file (.pdf).');
      }
      if (fileSize > AppConstants.maxPdfSizeBytes) {
        final sizeMb = (fileSize / (1024 * 1024)).toStringAsFixed(1);
        throw Exception(
          'PDF file size ($sizeMb MB) exceeds the maximum allowed limit of 20 MB.',
        );
      }
    } else {
      if (!isImageExtension(ext)) {
        throw Exception(
          'Invalid image format: only JPG, JPEG, and PNG are supported.',
        );
      }
      if (fileSize > AppConstants.maxImageSizeBytes) {
        final sizeMb = (fileSize / (1024 * 1024)).toStringAsFixed(1);
        throw Exception(
          'Image size ($sizeMb MB) exceeds the maximum allowed limit of 10 MB.',
        );
      }
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Upload Methods
  // ─────────────────────────────────────────────────────────────────────────

  /// Uploads a file to the private Supabase Storage bucket and returns its [AttachmentModel].
  ///
  /// Path format: `patients/{patientId}/{category}/{recordId}/{filename}`
  ///
  /// The canonical, persistent reference is stored in [AttachmentModel.storagePath].
  /// Expiring signed URLs are NOT stored; call [createSignedUrl] on-demand when opening/viewing files.
  Future<AttachmentModel> uploadAttachment({
    required String patientId,
    required String category, // 'medical_records' | 'medical_history' | 'lab_reports'
    required String recordId,
    required File file,
    required String originalName,
    required String type, // 'image' | 'pdf'
  }) async {
    final isPdf = type == 'pdf';

    // 1. Validate file format and size
    validateFile(file, isPdf: isPdf);

    final ext = p.extension(file.path).toLowerCase().replaceAll('.', '').trim();
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    // 2. Build a safe, unique filename
    final sanitizedOriginal =
        originalName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    final baseSanitized = sanitizedOriginal.endsWith('.$ext')
        ? sanitizedOriginal.substring(
            0, sanitizedOriginal.length - ext.length - 1)
        : sanitizedOriginal;
    final storageFilename = '${timestamp}_$baseSanitized.$ext';

    // 3. Build storage path according to convention:
    // patients/{patientId}/{category}/{recordId}/{filename}
    final storagePath =
        'patients/$patientId/$category/$recordId/$storageFilename';

    final contentType = getContentType(ext);

    // 4. Upload to private Supabase Storage bucket
    await _client.storage.from(bucketName).upload(
          storagePath,
          file,
          fileOptions: FileOptions(
            contentType: contentType,
            upsert: false,
          ),
        );

    final fileSize = file.lengthSync();

    // 5. Return AttachmentModel with persistent storagePath (no expiring signed URL stored)
    return AttachmentModel(
      id: '${timestamp}_$baseSanitized',
      name: originalName,
      type: type,
      fileExtension: ext,
      downloadUrl: '',
      storagePath: storagePath,
      sizeInBytes: fileSize,
      createdAt: Timestamp.now(),
    );
  }

  /// Low-level upload method returning the raw storage path.
  Future<String> uploadFile({
    required String patientId,
    required String category,
    required String recordId,
    required File file,
    required String originalName,
  }) async {
    validateFile(file);

    final ext = p.extension(file.path).toLowerCase().replaceAll('.', '').trim();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final sanitizedOriginal =
        originalName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    final baseSanitized = sanitizedOriginal.endsWith('.$ext')
        ? sanitizedOriginal.substring(
            0, sanitizedOriginal.length - ext.length - 1)
        : sanitizedOriginal;
    final storageFilename = '${timestamp}_$baseSanitized.$ext';

    final storagePath =
        'patients/$patientId/$category/$recordId/$storageFilename';

    await _client.storage.from(bucketName).upload(
          storagePath,
          file,
          fileOptions: FileOptions(
            contentType: getContentType(ext),
            upsert: false,
          ),
        );

    return storagePath;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Private File Access Methods (No Public URLs)
  // ─────────────────────────────────────────────────────────────────────────

  /// Generates a time-limited signed URL to access a private file.
  ///
  /// Because the bucket is private, files cannot be accessed via public URLs.
  /// This method requests a cryptographically signed URL from Supabase Storage
  /// authorizing access for the duration specified by [expiresInSeconds] (default: 1 hour).
  Future<String> createSignedUrl(
    String storagePath, {
    int expiresInSeconds = 3600,
  }) async {
    if (storagePath.isEmpty) {
      throw Exception('Storage path cannot be empty.');
    }

    return await _client.storage.from(bucketName).createSignedUrl(
          storagePath,
          expiresInSeconds,
        );
  }

  /// Downloads the raw binary bytes of a private file directly.
  ///
  /// The request is authenticated using the current Firebase ID token and
  /// authorized by Supabase Storage RLS policies.
  Future<Uint8List> downloadFile(String storagePath) async {
    if (storagePath.isEmpty) {
      throw Exception('Storage path cannot be empty.');
    }

    return await _client.storage.from(bucketName).download(storagePath);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Deletion Method
  // ─────────────────────────────────────────────────────────────────────────

  /// Deletes a file from the private Supabase Storage bucket by its storage path.
  ///
  /// Authorized only if the caller satisfies the "Doctors can delete patient files"
  /// RLS policy.
  Future<void> deleteAttachment(String storagePath) async {
    try {
      if (storagePath.isNotEmpty) {
        await _client.storage.from(bucketName).remove([storagePath]);
      }
    } catch (_) {
      // Silently ignore or log if the file is already deleted or inaccessible
    }
  }
}
