import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../l10n/app_localizations.dart';
import '../services/storage_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Data model for a locally-staged (not-yet-uploaded) attachment
// ─────────────────────────────────────────────────────────────────────────────

class PendingAttachment {
  /// A stable, app-owned copy of the file — safe to read at upload time.
  final File file;

  /// The display name shown in the UI and stored as metadata.
  final String originalName;

  /// 'image' or 'pdf'
  final String type;

  /// File size in bytes (measured at pick time on the cached copy).
  final int sizeInBytes;

  PendingAttachment({
    required this.file,
    required this.originalName,
    required this.type,
    required this.sizeInBytes,
  });

  bool get isImage => type == 'image';
  bool get isPdf => type == 'pdf';

  String get formattedSize {
    if (sizeInBytes < 1024) return '$sizeInBytes B';
    if (sizeInBytes < 1024 * 1024) {
      return '${(sizeInBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(sizeInBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widget
// ─────────────────────────────────────────────────────────────────────────────

class AttachmentPickerWidget extends StatefulWidget {
  final List<PendingAttachment> initialAttachments;
  final ValueChanged<List<PendingAttachment>> onAttachmentsChanged;

  const AttachmentPickerWidget({
    super.key,
    this.initialAttachments = const [],
    required this.onAttachmentsChanged,
  });

  @override
  State<AttachmentPickerWidget> createState() => _AttachmentPickerWidgetState();
}

class _AttachmentPickerWidgetState extends State<AttachmentPickerWidget> {
  final ImagePicker _imagePicker = ImagePicker();
  final List<PendingAttachment> _attachments = [];

  @override
  void initState() {
    super.initState();
    _attachments.addAll(widget.initialAttachments);
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Copy [src] to the app's temporary directory so we hold a stable reference
  /// that cannot be cleared by the OS or the picker framework.
  ///
  /// Returns the cached [File] or throws on failure.
  Future<File> _copyToCache(File src, String name, String ext) async {
    final cacheDir = await getTemporaryDirectory();
    final ts = DateTime.now().millisecondsSinceEpoch;
    final safeName = name.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    final destPath = '${cacheDir.path}/ehr_pick_${ts}_$safeName.$ext';
    return src.copy(destPath);
  }

  // ── Image picking ─────────────────────────────────────────────────────────

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
      );
      if (picked == null) return;

      final srcFile = File(picked.path);

      // Validate using StorageService rules (JPG/JPEG/PNG, <= 10MB)
      try {
        StorageService.validateFile(srcFile, isPdf: false);
      } catch (e) {
        _showError(e.toString().replaceAll('Exception: ', ''));
        return;
      }

      final ext = p.extension(picked.path).toLowerCase().replaceAll('.', '');

      // Copy to stable app cache immediately — prevents temp-file invalidation.
      final cachedFile = await _copyToCache(srcFile, picked.name, ext);
      final cachedSize = cachedFile.lengthSync();

      if (!mounted) return;
      setState(() {
        _attachments.add(PendingAttachment(
          file: cachedFile,
          originalName: picked.name,
          type: 'image',
          sizeInBytes: cachedSize,
        ));
      });
      widget.onAttachmentsChanged(_attachments);
    } catch (e) {
      _showError('Failed to pick image: $e');
    }
  }

  Future<void> _showImageSourceDialog() async {
    final l10n = context.l10n;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.attachPhoto,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.camera_alt, color: Colors.white),
                ),
                title: Text(l10n.takePhotoCamera),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.purple,
                  child: Icon(Icons.photo_library, color: Colors.white),
                ),
                title: Text(l10n.chooseFromGallery),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── PDF picking ───────────────────────────────────────────────────────────

  Future<void> _pickPdf() async {
    final l10n = context.l10n;
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) return;

      final pickedFile = result.files.first;
      if (pickedFile.path == null) {
        _showError(l10n.unableToAccessPdf);
        return;
      }

      final srcFile = File(pickedFile.path!);

      // Validate using StorageService rules (PDF, <= 20MB)
      try {
        StorageService.validateFile(srcFile, isPdf: true);
      } catch (e) {
        _showError(e.toString().replaceAll('Exception: ', ''));
        return;
      }

      // Copy to stable app cache immediately.
      final cachedFile = await _copyToCache(srcFile, pickedFile.name, 'pdf');
      final cachedSize = cachedFile.lengthSync();

      if (!mounted) return;
      setState(() {
        _attachments.add(PendingAttachment(
          file: cachedFile,
          originalName: pickedFile.name,
          type: 'pdf',
          sizeInBytes: cachedSize,
        ));
      });
      widget.onAttachmentsChanged(_attachments);
    } catch (e) {
      _showError('Failed to pick PDF: $e');
    }
  }

  // ── Remove ────────────────────────────────────────────────────────────────

  void _removeAttachment(int index) {
    setState(() {
      _attachments.removeAt(index);
    });
    widget.onAttachmentsChanged(_attachments);
  }

  // ── UI ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.documentAttachments,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            if (_attachments.isNotEmpty)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  l10n.attachedCount(_attachments.length),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),

        // Action buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.add_a_photo, size: 18),
                label: Text(l10n.photoLimit),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  foregroundColor: Colors.blue,
                ),
                onPressed: _showImageSourceDialog,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.picture_as_pdf, size: 18),
                label: Text(l10n.pdfLimit),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  foregroundColor: Colors.deepOrange,
                ),
                onPressed: _pickPdf,
              ),
            ),
          ],
        ),

        // Preview list
        if (_attachments.isNotEmpty) ...[
          const SizedBox(height: 14),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _attachments.length,
            itemBuilder: (context, index) {
              final item = _attachments[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  leading: item.isImage
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            item.file,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.broken_image, size: 40),
                          ),
                        )
                      : Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.picture_as_pdf,
                            color: Colors.red,
                            size: 28,
                          ),
                        ),
                  title: Text(
                    item.originalName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    '${item.type.toUpperCase()} • ${item.formattedSize}',
                    style:
                        TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    tooltip: l10n.removeAttachment,
                    onPressed: () => _removeAttachment(index),
                  ),
                ),
              );
            },
          ),
        ],
      ],
    );
  }
}
