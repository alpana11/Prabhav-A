import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class LocationSelectionSection extends StatefulWidget {
  final LatLng? selectedLocation;
  final String selectedAddress;
  final Function(LatLng, String) onLocationChanged;

  const LocationSelectionSection({
    super.key,
    required this.selectedLocation,
    required this.selectedAddress,
    required this.onLocationChanged,
  });

  @override
  State<LocationSelectionSection> createState() =>
      _LocationSelectionSectionState();
}

class _LocationSelectionSectionState extends State<LocationSelectionSection> {
  GoogleMapController? _mapController;
  bool _isLoadingLocation = false;
  final TextEditingController _addressController = TextEditingController();

  // Default location (New Delhi, India)
  static const LatLng _defaultLocation = LatLng(28.6139, 77.2090);

  @override
  void initState() {
    super.initState();
    _addressController.text = widget.selectedAddress;
  }

  @override
  void dispose() {
    _addressController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    if (_isLoadingLocation) return;

    setState(() => _isLoadingLocation = true);

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showLocationServiceDialog();
        return;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showPermissionDialog();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showPermissionDialog();
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      final LatLng currentLocation =
          LatLng(position.latitude, position.longitude);

      // Move camera to current location
      if (_mapController != null) {
        await _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(currentLocation, 16.0),
        );
      }

      // Update location
      widget.onLocationChanged(currentLocation, 'Current Location');
      _addressController.text = 'Current Location';
    } catch (e) {
      _showErrorSnackBar(
          'Failed to get current location. Please try again or select manually.');
    } finally {
      setState(() => _isLoadingLocation = false);
    }
  }

  void _onMapTap(LatLng location) {
    widget.onLocationChanged(location, 'Selected Location');
    _addressController.text =
        'Lat: ${location.latitude.toStringAsFixed(6)}, Lng: ${location.longitude.toStringAsFixed(6)}';
  }

  void _onAddressSubmitted() {
    if (_addressController.text.trim().isNotEmpty) {
      // For demo purposes, we'll use the current selected location with the new address
      final location = widget.selectedLocation ?? _defaultLocation;
      widget.onLocationChanged(location, _addressController.text.trim());
    }
  }

  void _showLocationServiceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Services Disabled'),
        content:
            const Text('Please enable location services to use this feature.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Permission Required'),
        content: const Text(
            'Location permission is required to get your current location. Please enable it in settings.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Geolocator.openAppSettings();
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
            'Select Location',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Choose the location where the issue is occurring',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          SizedBox(height: 3.h),

          // Address Input Field
          TextFormField(
            controller: _addressController,
            decoration: InputDecoration(
              labelText: 'Address',
              hintText: 'Enter address or use map to select location',
              prefixIcon: Icon(
                Icons.location_on,
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              suffixIcon: IconButton(
                onPressed: _onAddressSubmitted,
                icon: Icon(
                  Icons.check,
                  color: colorScheme.primary,
                ),
              ),
            ),
            onFieldSubmitted: (_) => _onAddressSubmitted(),
          ),
          SizedBox(height: 2.h),

          // Current Location Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoadingLocation ? null : _getCurrentLocation,
              icon: _isLoadingLocation
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorScheme.onPrimary,
                      ),
                    )
                  : CustomIconWidget(
                      iconName: 'my_location',
                      color: colorScheme.onPrimary,
                      size: 20,
                    ),
              label: Text(_isLoadingLocation
                  ? 'Getting Location...'
                  : 'Use Current Location'),
            ),
          ),
          SizedBox(height: 3.h),

          // Map Container
          Container(
            height: 40.h,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: widget.selectedLocation ?? _defaultLocation,
                  zoom: 14.0,
                ),
                onMapCreated: (GoogleMapController controller) {
                  _mapController = controller;
                },
                onTap: _onMapTap,
                markers: widget.selectedLocation != null
                    ? {
                        Marker(
                          markerId: const MarkerId('selected_location'),
                          position: widget.selectedLocation!,
                          infoWindow: InfoWindow(
                            title: 'Complaint Location',
                            snippet: widget.selectedAddress.isNotEmpty
                                ? widget.selectedAddress
                                : 'Selected Location',
                          ),
                        ),
                      }
                    : {},
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: true,
                mapToolbarEnabled: false,
                compassEnabled: true,
                buildingsEnabled: true,
                trafficEnabled: false,
              ),
            ),
          ),
          SizedBox(height: 2.h),

          // Location Info Card
          if (widget.selectedLocation != null)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'location_on',
                    color: colorScheme.primary,
                    size: 24,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selected Location',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          widget.selectedAddress.isNotEmpty
                              ? widget.selectedAddress
                              : 'Lat: ${widget.selectedLocation!.latitude.toStringAsFixed(6)}, Lng: ${widget.selectedLocation!.longitude.toStringAsFixed(6)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          SizedBox(height: 2.h),

          // Instructions
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomIconWidget(
                  iconName: 'info',
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                  size: 20,
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    'Tap on the map to select a location, use current location button, or enter address manually.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
