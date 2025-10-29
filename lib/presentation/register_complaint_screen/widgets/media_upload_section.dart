import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class MediaUploadSection extends StatefulWidget {
  final List<XFile> selectedMedia;
  final Function(List<XFile>) onMediaChanged;

  const MediaUploadSection({
    super.key,
    required this.selectedMedia,
    required this.onMediaChanged,
  });

  @override
  State<MediaUploadSection> createState() => _MediaUploadSectionState();
}

class _MediaUploadSectionState extends State<MediaUploadSection> {
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  Future<bool> _requestPermission() async {
    if (kIsWeb) return true;

    final cameraStatus = await Permission.camera.request();
    final storageStatus = await Permission.photos.request();

    return cameraStatus.isGranted && storageStatus.isGranted;
  }

  Future<void> _pickFromCamera() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final hasPermission = await _requestPermission();
      if (!hasPermission) {
        _showPermissionDialog();
        return;
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        final updatedMedia = List<XFile>.from(widget.selectedMedia)..add(image);
        widget.onMediaChanged(updatedMedia);
      }
    } catch (e) {
      _showErrorSnackBar('Failed to capture photo. Please try again.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickFromGallery() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final hasPermission = await _requestPermission();
      if (!hasPermission) {
        _showPermissionDialog();
        return;
      }

      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (images.isNotEmpty) {
        final updatedMedia = List<XFile>.from(widget.selectedMedia)
          ..addAll(images);
        widget.onMediaChanged(updatedMedia);
      }
    } catch (e) {
      _showErrorSnackBar('Failed to select photos. Please try again.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickVideo() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final hasPermission = await _requestPermission();
      if (!hasPermission) {
        _showPermissionDialog();
        return;
      }

      final XFile? video = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 2),
      );

      if (video != null) {
        final updatedMedia = List<XFile>.from(widget.selectedMedia)..add(video);
        widget.onMediaChanged(updatedMedia);
      }
    } catch (e) {
      _showErrorSnackBar('Failed to select video. Please try again.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _removeMedia(int index) {
    final updatedMedia = List<XFile>.from(widget.selectedMedia)
      ..removeAt(index);
    widget.onMediaChanged(updatedMedia);
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Required'),
        content: const Text(
            'Camera and storage permissions are required to upload media. Please enable them in settings.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Settings'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upload Media',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Add photos or videos to support your complaint (optional)',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          SizedBox(height: 3.h),

          // Upload Buttons
          Row(
            children: [
              Expanded(
                child: _buildUploadButton(
                  icon: 'camera_alt',
                  label: 'Camera',
                  onTap: _pickFromCamera,
                  color: colorScheme.primary,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildUploadButton(
                  icon: 'photo_library',
                  label: 'Gallery',
                  onTap: _pickFromGallery,
                  color: colorScheme.secondary,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildUploadButton(
                  icon: 'videocam',
                  label: 'Video',
                  onTap: _pickVideo,
                  color: colorScheme.tertiary,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),

          // Selected Media Grid
          if (widget.selectedMedia.isNotEmpty) ...[
            Text(
              'Selected Media (${widget.selectedMedia.length})',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 2.h),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 2.w,
                mainAxisSpacing: 2.w,
                childAspectRatio: 1,
              ),
              itemCount: widget.selectedMedia.length,
              itemBuilder: (context, index) {
                return _buildMediaThumbnail(widget.selectedMedia[index], index);
              },
            ),
          ] else ...[
            Container(
              width: double.infinity,
              height: 20.h,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.3),
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconWidget(
                    iconName: 'cloud_upload',
                    color: colorScheme.onSurface.withValues(alpha: 0.4),
                    size: 48,
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'No media selected',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  Text(
                    'Tap buttons above to add photos or videos',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (_isLoading) ...[
            SizedBox(height: 2.h),
            Center(
              child: CircularProgressIndicator(
                color: colorScheme.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUploadButton({
    required String icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: _isLoading ? null : onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 2.w),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          children: [
            CustomIconWidget(
              iconName: icon,
              color: color,
              size: 24,
            ),
            SizedBox(height: 0.5.h),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaThumbnail(XFile media, int index) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isVideo = media.path.toLowerCase().contains('.mp4') ||
        media.path.toLowerCase().contains('.mov') ||
        media.path.toLowerCase().contains('.avi');

    return GestureDetector(
      onLongPress: () => _showDeleteDialog(index),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (kIsWeb)
                Container(
                  color: colorScheme.surface,
                  child: Center(
                    child: CustomIconWidget(
                      iconName: isVideo ? 'videocam' : 'image',
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                      size: 32,
                    ),
                  ),
                )
              else
                Image.file(
                  File(media.path),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: colorScheme.surface,
                      child: Center(
                        child: CustomIconWidget(
                          iconName: isVideo ? 'videocam' : 'image',
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                          size: 32,
                        ),
                      ),
                    );
                  },
                ),
              if (isVideo)
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: CustomIconWidget(
                      iconName: 'play_arrow',
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () => _removeMedia(index),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: colorScheme.error,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: CustomIconWidget(
                      iconName: 'close',
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Media'),
        content: const Text('Are you sure you want to remove this media?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _removeMedia(index);
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}
