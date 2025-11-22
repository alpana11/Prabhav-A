import 'package:permission_handler/permission_handler.dart';
import '../services/api_service.dart';

class PermissionsService {
  static final PermissionsService _instance = PermissionsService._internal();
  final _apiService = ApiService();

  factory PermissionsService() {
    return _instance;
  }

  PermissionsService._internal();

  /// Request location permission
  Future<bool> requestLocationPermission() async {
    final status = await Permission.location.request();
    await _updatePermissionOnBackend('location', status);
    return status.isGranted;
  }

  /// Request camera permission
  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    await _updatePermissionOnBackend('camera', status);
    return status.isGranted;
  }

  /// Request gallery/photos permission
  Future<bool> requestGalleryPermission() async {
    final status = await Permission.photos.request();
    await _updatePermissionOnBackend('gallery', status);
    return status.isGranted;
  }

  /// Request microphone permission
  Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    await _updatePermissionOnBackend('microphone', status);
    return status.isGranted;
  }

  /// Request file access permission
  Future<bool> requestFilePermission() async {
    final status = await Permission.storage.request();
    await _updatePermissionOnBackend('files', status);
    return status.isGranted;
  }

  /// Check if permission is granted
  Future<bool> isPermissionGranted(Permission permission) async {
    final status = await permission.status;
    return status.isGranted;
  }

  /// Get all permissions status
  Future<Map<String, bool>> getAllPermissionStatus() async {
    return {
      'location': await Permission.location.isGranted,
      'camera': await Permission.camera.isGranted,
      'gallery': await Permission.photos.isGranted,
      'microphone': await Permission.microphone.isGranted,
      'files': await Permission.storage.isGranted,
    };
  }

  /// Request multiple permissions at once
  Future<Map<Permission, PermissionStatus>> requestMultiplePermissions(
    List<Permission> permissions,
  ) async {
    final result = await permissions.request();
    
    for (var entry in result.entries) {
      String permType = _getPermissionType(entry.key);
      await _updatePermissionOnBackend(permType, entry.value);
    }

    return result;
  }

  /// Update permission status on backend
  Future<void> _updatePermissionOnBackend(
    String permissionType,
    PermissionStatus status,
  ) async {
    try {
      final statusStr = status.isGranted
          ? 'granted'
          : status.isDenied
              ? 'denied'
              : 'pending';

      await _apiService.updatePermissions(
        location: permissionType == 'location' ? statusStr : null,
        camera: permissionType == 'camera' ? statusStr : null,
        gallery: permissionType == 'gallery' ? statusStr : null,
        microphone: permissionType == 'microphone' ? statusStr : null,
        files: permissionType == 'files' ? statusStr : null,
      );
    } catch (e) {
      print('Error updating permission on backend: $e');
    }
  }

  /// Get permission type from Permission enum
  String _getPermissionType(Permission permission) {
    if (permission == Permission.location) return 'location';
    if (permission == Permission.camera) return 'camera';
    if (permission == Permission.photos) return 'gallery';
    if (permission == Permission.microphone) return 'microphone';
    if (permission == Permission.storage) return 'files';
    return 'unknown';
  }

  /// Open app settings
  Future<void> openAppSettings() async {
    await openAppSettings();
  }

  /// Check if should show permission rationale
  Future<bool> shouldShowPermissionRationale(Permission permission) async {
    return await permission.shouldShowRequestRationale;
  }
}
