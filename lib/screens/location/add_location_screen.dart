import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartreminders/models/saved_location.dart';
import 'package:smartreminders/services/auth_service.dart';
import 'package:smartreminders/services/location_service.dart';

class AddLocationScreen extends StatefulWidget {
  const AddLocationScreen({super.key});

  @override
  State<AddLocationScreen> createState() => _AddLocationScreenState();
}

class _AddLocationScreenState extends State<AddLocationScreen> {
  final _nameController = TextEditingController();
  final AuthService _authService = AuthService();
  final LocationService _locationService = LocationService();
  
  GoogleMapController? _mapController;
  LatLng _selectedPosition = const LatLng(37.7749, -122.4194); // San Francisco default
  double _radiusMeters = 100.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    final hasPermission = await _locationService.requestPermission();
    if (hasPermission) {
      final position = await _locationService.getCurrentLocation();
      if (position != null && mounted) {
        setState(() {
          _selectedPosition = LatLng(position.latitude, position.longitude);
          _isLoading = false;
        });
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(_selectedPosition, 15),
        );
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveLocation() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a location name')),
      );
      return;
    }

    final userId = _authService.currentUser?.uid;
    if (userId == null) return;

    final now = DateTime.now();
    final location = SavedLocation(
      id: FirebaseFirestore.instance.collection('locations').doc().id,
      userId: userId,
      name: _nameController.text.trim(),
      latitude: _selectedPosition.latitude,
      longitude: _selectedPosition.longitude,
      radiusMeters: _radiusMeters,
      createdAt: now,
      updatedAt: now,
    );

    await _locationService.saveLocation(location);

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Location'),
        actions: [
          TextButton(
            onPressed: _saveLocation,
            child: const Text('Save'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Location Name',
                      hintText: 'e.g., Home, Office, School',
                    ),
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: _selectedPosition,
                          zoom: 15,
                        ),
                        onMapCreated: (controller) => _mapController = controller,
                        onTap: (position) => setState(() => _selectedPosition = position),
                        circles: {
                          Circle(
                            circleId: const CircleId('geofence'),
                            center: _selectedPosition,
                            radius: _radiusMeters,
                            fillColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                            strokeColor: Theme.of(context).colorScheme.primary,
                            strokeWidth: 2,
                          ),
                        },
                        markers: {
                          Marker(
                            markerId: const MarkerId('selected'),
                            position: _selectedPosition,
                          ),
                        },
                      ),
                      Positioned(
                        top: 16,
                        right: 16,
                        child: FloatingActionButton.small(
                          onPressed: _initializeLocation,
                          child: const Icon(Icons.my_location),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Radius: ${_radiusMeters.toInt()}m',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            '${(_radiusMeters / 1000).toStringAsFixed(2)} km',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      Slider(
                        value: _radiusMeters,
                        min: 50,
                        max: 1000,
                        divisions: 19,
                        label: '${_radiusMeters.toInt()}m',
                        onChanged: (value) => setState(() => _radiusMeters = value),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
