import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localizations.dart';
import '../models/attachment_model.dart';
import '../services/storage_service.dart';

/// In-memory cache for temporary signed URLs to prevent redundant network calls
/// while scrolling or reopening attachments within the same session.
class _SignedUrlCache {
  static final Map<String, ({String url, DateTime expiresAt})> _cache = {};

  static String? get(String storagePath) {
    final entry = _cache[storagePath];
    if (entry != null &&
        entry.expiresAt
            .isAfter(DateTime.now().add(const Duration(minutes: 5)))) {
      return entry.url;
    }
    return null;
  }

  static void set(String storagePath, String url, int expiresInSeconds) {
    _cache[storagePath] = (
      url: url,
      expiresAt: DateTime.now().add(Duration(seconds: expiresInSeconds)),
    );
  }
}

/// Resolves a usable URL for an [AttachmentModel]:
/// 1. If [storagePath] is present (private Supabase Storage), requests a fresh signed URL
///    (or retrieves an unexpired one from the in-memory cache).
/// 2. If [storagePath] is empty but [downloadUrl] is present (legacy data), falls back to [downloadUrl].
Future<String> _resolveAttachmentUrl(AttachmentModel attachment) async {
  if (attachment.storagePath.isNotEmpty) {
    final cached = _SignedUrlCache.get(attachment.storagePath);
    if (cached != null) {
      return cached;
    }

    final storageService = StorageService();
    final freshUrl = await storageService.createSignedUrl(
      attachment.storagePath,
      expiresInSeconds: 3600,
    );

    _SignedUrlCache.set(attachment.storagePath, freshUrl, 3600);
    return freshUrl;
  }

  if (attachment.downloadUrl.isNotEmpty) {
    return attachment.downloadUrl;
  }

  throw Exception("No storage path or download URL found for this attachment.");
}

class AttachmentViewWidget extends StatelessWidget {
  final List<AttachmentModel> attachments;
  final String? title;

  const AttachmentViewWidget({
    super.key,
    required this.attachments,
    this.title,
  });

  void _openImageViewer(BuildContext context, AttachmentModel attachment) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => _ImageViewerDialog(attachment: attachment),
    );
  }

  Future<void> _openPdf(BuildContext context, AttachmentModel attachment) async {
    final l10n = context.l10n;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Text(l10n.openingPdf),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );

    try {
      final url = await _resolveAttachmentUrl(attachment);
      final uri = Uri.parse(url);

      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.couldNotLaunchPdf),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "${l10n.isMarathi ? 'पीडीएफ उघडताना त्रुटी' : 'Error opening PDF'}: ${e.toString().replaceAll("Exception: ", "")}",
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatSize(int bytes) {
    if (bytes <= 0) return "";
    if (bytes < 1024) return "$bytes B";
    if (bytes < 1024 * 1024) {
      return "${(bytes / 1024).toStringAsFixed(1)} KB";
    }
    return "${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB";
  }

  @override
  Widget build(BuildContext context) {
    if (attachments.isEmpty) {
      return const SizedBox.shrink();
    }

    final images = attachments.where((a) => a.isImage).toList();
    final pdfs = attachments.where((a) => a.isPdf).toList();

    final l10n = context.l10n;
    final effectiveTitle = title ?? l10n.documentAttachments;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Row(
          children: [
            const Icon(Icons.attach_file, size: 16, color: Colors.blue),
            const SizedBox(width: 6),
            Text(
              "$effectiveTitle (${attachments.length})",
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Image attachments (thumbnails)
        if (images.isNotEmpty) ...[
          SizedBox(
            height: 72,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              itemBuilder: (context, index) {
                final img = images[index];
                return _ImageThumbnail(
                  image: img,
                  onTap: () => _openImageViewer(context, img),
                );
              },
            ),
          ),
          if (pdfs.isNotEmpty) const SizedBox(height: 8),
        ],

        // PDF attachments
        if (pdfs.isNotEmpty) ...[
          Column(
            children: pdfs.map((pdf) {
              final sizeText = _formatSize(pdf.sizeInBytes);
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.red.shade50.withAlpha(120),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.picture_as_pdf,
                      color: Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pdf.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (sizeText.isNotEmpty)
                            Text(
                              sizeText,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade600,
                              ),
                            ),
                        ],
                      ),
                    ),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        visualDensity: VisualDensity.compact,
                        foregroundColor: Colors.red.shade800,
                      ),
                      icon: const Icon(Icons.open_in_new, size: 14),
                      label: Text(
                        l10n.openPdf,
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () => _openPdf(context, pdf),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}

/// Thumbnail card for image attachments with lazy signed-URL loading and cached lookup.
class _ImageThumbnail extends StatefulWidget {
  final AttachmentModel image;
  final VoidCallback onTap;

  const _ImageThumbnail({
    required this.image,
    required this.onTap,
  });

  @override
  State<_ImageThumbnail> createState() => _ImageThumbnailState();
}

class _ImageThumbnailState extends State<_ImageThumbnail> {
  String? _url;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadThumbnailUrl();
  }

  Future<void> _loadThumbnailUrl() async {
    // Check in-memory cache synchronously first
    if (widget.image.storagePath.isNotEmpty) {
      final cached = _SignedUrlCache.get(widget.image.storagePath);
      if (cached != null) {
        setState(() {
          _url = cached;
        });
        return;
      }
    } else if (widget.image.downloadUrl.isNotEmpty) {
      setState(() {
        _url = widget.image.downloadUrl;
      });
      return;
    }

    // Lazy load signed URL for private Supabase Storage object
    if (widget.image.storagePath.isNotEmpty) {
      if (!mounted) return;
      setState(() {
        _isLoading = true;
      });

      try {
        final url = await _resolveAttachmentUrl(widget.image);
        if (mounted) {
          setState(() {
            _url = url;
            _isLoading = false;
          });
        }
      } catch (_) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: 72,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.blue.shade200),
          color: Colors.grey.shade100,
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: SizedBox(
                width: 72,
                height: 72,
                child: _buildThumbnailContent(),
              ),
            ),
            Positioned(
              right: 4,
              bottom: 4,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(
                  Icons.zoom_in,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnailContent() {
    if (_url != null && _url!.isNotEmpty) {
      return Image.network(
        _url!,
        width: 72,
        height: 72,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const Center(
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(Icons.broken_image, color: Colors.grey, size: 24),
        ),
      );
    }

    if (_isLoading) {
      return const Center(
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    return Center(
      child: Icon(
        Icons.image_outlined,
        color: Colors.blue.shade300,
        size: 28,
      ),
    );
  }
}

/// Full-screen dialog viewer for images. Resolves a signed URL on-demand with a loading
/// indicator, zoom/pan capability, and clear error state with retry.
class _ImageViewerDialog extends StatefulWidget {
  final AttachmentModel attachment;

  const _ImageViewerDialog({required this.attachment});

  @override
  State<_ImageViewerDialog> createState() => _ImageViewerDialogState();
}

class _ImageViewerDialogState extends State<_ImageViewerDialog> {
  String? _resolvedUrl;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUrl();
  }

  Future<void> _loadUrl() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final url = await _resolveAttachmentUrl(widget.attachment);
      if (mounted) {
        setState(() {
          _resolvedUrl = url;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll("Exception: ", "");
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.attachment.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.75,
                minHeight: 200,
                minWidth: double.infinity,
              ),
              color: Colors.black54,
              child: _buildViewerContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewerContent() {
    final l10n = context.l10n;

    if (_isLoading) {
      return SizedBox(
        height: 250,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: Colors.white),
              const SizedBox(height: 16),
              Text(
                l10n.loadingSecureImage,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null || _resolvedUrl == null) {
      return Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
            const SizedBox(height: 12),
            Text(
              l10n.failedToLoadImage,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _errorMessage ?? (l10n.isMarathi ? "वैध प्रवेश URL तयार करता आले नाही." : "Could not generate a valid access URL."),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white24,
                foregroundColor: Colors.white,
              ),
              onPressed: _loadUrl,
              icon: const Icon(Icons.refresh, size: 16),
              label: Text(l10n.retry),
            ),
          ],
        ),
      );
    }

    return InteractiveViewer(
      minScale: 0.5,
      maxScale: 4.0,
      child: Image.network(
        _resolvedUrl!,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const SizedBox(
            height: 250,
            child: Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 200,
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Text(
                l10n.failedToRenderImage,
                style: const TextStyle(color: Colors.white70),
              ),
            ),
          );
        },
      ),
    );
  }
}
