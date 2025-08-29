
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FileAttachmentWidget extends StatefulWidget {
  final List<Map<String, dynamic>> attachments;
  final Function(Map<String, dynamic>) onFileAdded;
  final Function(int) onFileRemoved;

  const FileAttachmentWidget({
    super.key,
    required this.attachments,
    required this.onFileAdded,
    required this.onFileRemoved,
  });

  @override
  State<FileAttachmentWidget> createState() => _FileAttachmentWidgetState();
}

class _FileAttachmentWidgetState extends State<FileAttachmentWidget> {
  final ImagePicker _imagePicker = ImagePicker();
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Attachments',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 2.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${widget.attachments.length}/5',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        _buildAttachmentOptions(),
        SizedBox(height: 2.h),
        _buildAttachmentsList(),
      ],
    );
  }

  Widget _buildAttachmentOptions() {
    return Row(
      children: [
        Expanded(
          child: _buildAttachmentButton(
            icon: 'camera_alt',
            label: 'Camera',
            onTap: _captureFromCamera,
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: _buildAttachmentButton(
            icon: 'photo_library',
            label: 'Gallery',
            onTap: _selectFromGallery,
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: _buildAttachmentButton(
            icon: 'attach_file',
            label: 'Files',
            onTap: _selectFiles,
          ),
        ),
      ],
    );
  }

  Widget _buildAttachmentButton({
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final isDisabled = widget.attachments.length >= 5 || _isUploading;

    return InkWell(
      onTap: isDisabled ? null : onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 1.5.h),
        decoration: BoxDecoration(
          border: Border.all(
            color: isDisabled
                ? AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3)
                : AppTheme.lightTheme.colorScheme.outline,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            CustomIconWidget(
              iconName: icon,
              color: isDisabled
                  ? AppTheme.lightTheme.colorScheme.onSurfaceVariant
                      .withValues(alpha: 0.5)
                  : AppTheme.lightTheme.colorScheme.primary,
              size: 24,
            ),
            SizedBox(height: 0.5.h),
            Text(
              label,
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: isDisabled
                    ? AppTheme.lightTheme.colorScheme.onSurfaceVariant
                        .withValues(alpha: 0.5)
                    : AppTheme.lightTheme.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentsList() {
    if (widget.attachments.isEmpty && !_isUploading) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          children: [
            CustomIconWidget(
              iconName: 'cloud_upload',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 32,
            ),
            SizedBox(height: 1.h),
            Text(
              'No attachments added',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 0.5.h),
            Text(
              'Tap the buttons above to add files',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        if (_isUploading) _buildUploadingIndicator(),
        ...widget.attachments.asMap().entries.map((entry) {
          final index = entry.key;
          final attachment = entry.value;
          return _buildAttachmentItem(attachment, index);
        }).toList(),
      ],
    );
  }

  Widget _buildUploadingIndicator() {
    return Container(
      margin: EdgeInsets.only(bottom: 1.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppTheme.lightTheme.colorScheme.primary,
              ),
            ),
          ),
          SizedBox(width: 3.w),
          Text(
            'Uploading file...',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentItem(Map<String, dynamic> attachment, int index) {
    final fileName = attachment['name'] as String;
    final fileSize = attachment['size'] as int;
    final fileType = attachment['type'] as String;
    final isImage = fileType.startsWith('image/');

    return Container(
      margin: EdgeInsets.only(bottom: 1.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              color: _getFileTypeColor(fileType).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: _getFileTypeIcon(fileType),
                color: _getFileTypeColor(fileType),
                size: 20,
              ),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 0.5.h),
                Text(
                  _formatFileSize(fileSize),
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => widget.onFileRemoved(index),
            icon: CustomIconWidget(
              iconName: 'close',
              color: AppTheme.lightTheme.colorScheme.error,
              size: 20,
            ),
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _captureFromCamera() async {
    if (widget.attachments.length >= 5) {
      _showMaxFilesError();
      return;
    }

    try {
      // Request camera permission
      if (!kIsWeb) {
        final permission = await Permission.camera.request();
        if (!permission.isGranted) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                    'Camera permission is required to capture photos'),
                backgroundColor: AppTheme.lightTheme.colorScheme.error,
              ),
            );
          }
          return;
        }
      }

      setState(() => _isUploading = true);

      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        await _processSelectedFile(image);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to capture photo. Please try again.'),
            backgroundColor: AppTheme.lightTheme.colorScheme.error,
          ),
        );
      }
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _selectFromGallery() async {
    if (widget.attachments.length >= 5) {
      _showMaxFilesError();
      return;
    }

    try {
      setState(() => _isUploading = true);

      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        await _processSelectedFile(image);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to select image. Please try again.'),
            backgroundColor: AppTheme.lightTheme.colorScheme.error,
          ),
        );
      }
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _selectFiles() async {
    if (widget.attachments.length >= 5) {
      _showMaxFilesError();
      return;
    }

    try {
      setState(() => _isUploading = true);

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'jpg', 'jpeg', 'png'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        // Check file size (max 10MB)
        if (file.size > 10 * 1024 * 1024) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('File size must be less than 10MB'),
                backgroundColor: AppTheme.lightTheme.colorScheme.error,
              ),
            );
          }
          return;
        }

        final attachment = {
          'name': file.name,
          'size': file.size,
          'type': _getFileTypeFromExtension(file.extension ?? ''),
          'path': kIsWeb ? null : file.path,
          'bytes': kIsWeb ? file.bytes : null,
          'uploadedAt': DateTime.now(),
        };

        widget.onFileAdded(attachment);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to select file. Please try again.'),
            backgroundColor: AppTheme.lightTheme.colorScheme.error,
          ),
        );
      }
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _processSelectedFile(XFile file) async {
    try {
      final fileSize = await file.length();

      // Check file size (max 10MB)
      if (fileSize > 10 * 1024 * 1024) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('File size must be less than 10MB'),
              backgroundColor: AppTheme.lightTheme.colorScheme.error,
            ),
          );
        }
        return;
      }

      final attachment = {
        'name': file.name,
        'size': fileSize,
        'type': file.mimeType ?? 'image/jpeg',
        'path': kIsWeb ? null : file.path,
        'bytes': kIsWeb ? await file.readAsBytes() : null,
        'uploadedAt': DateTime.now(),
      };

      widget.onFileAdded(attachment);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to process file. Please try again.'),
            backgroundColor: AppTheme.lightTheme.colorScheme.error,
          ),
        );
      }
    }
  }

  void _showMaxFilesError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Maximum 5 files allowed'),
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
      ),
    );
  }

  String _getFileTypeFromExtension(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return 'application/pdf';
      case 'doc':
      case 'docx':
        return 'application/msword';
      case 'txt':
        return 'text/plain';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      default:
        return 'application/octet-stream';
    }
  }

  String _getFileTypeIcon(String mimeType) {
    if (mimeType.startsWith('image/')) return 'image';
    if (mimeType.contains('pdf')) return 'picture_as_pdf';
    if (mimeType.contains('word') || mimeType.contains('document'))
      return 'description';
    if (mimeType.contains('text')) return 'text_snippet';
    return 'attach_file';
  }

  Color _getFileTypeColor(String mimeType) {
    if (mimeType.startsWith('image/')) return const Color(0xFF4CAF50);
    if (mimeType.contains('pdf')) return const Color(0xFFE53935);
    if (mimeType.contains('word') || mimeType.contains('document'))
      return const Color(0xFF1976D2);
    if (mimeType.contains('text')) return const Color(0xFF757575);
    return AppTheme.lightTheme.colorScheme.primary;
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}
