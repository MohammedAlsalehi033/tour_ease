import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:tour_ease/bloc/rideFilterBloc.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;
  final Location location = Location();
  LatLng? _origin;
  LatLng? _destination;
  String? _originAddress;
  String? _destinationAddress;
  bool _isLoading = false;
  bool _locationPermissionGranted = false;
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    // Check if location services are enabled
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    // Check if permission is granted
    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    setState(() {
      _locationPermissionGranted = true;
    });

    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final LocationData currentLocation = await location.getLocation();
      if (mounted) {
        setState(() {
          _moveCamera(LatLng(
            currentLocation.latitude!,
            currentLocation.longitude!,
          ));
        });
      }
    } catch (e) {
      debugPrint('Error getting current location: $e');
      // Show error message to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Unable to get current location: ${e.toString()}'),
                ),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  void _moveCamera(LatLng position) {
    mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: position,
          zoom: 15,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return BlocBuilder<RideFilterBloc, RideFilterState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            title: const Text(
              'Select Locations',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            backgroundColor: colorScheme.primary,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.my_location_rounded),
                tooltip: 'Go to current location',
                onPressed: _getCurrentLocation,
              ),
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Reset selections',
                onPressed: _resetSelections,
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Stack(
            children: [
              // Map
              GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: LatLng(37.42796133580664, -122.085749655962),
                  zoom: 14,
                ),
                myLocationEnabled: _locationPermissionGranted,
                myLocationButtonEnabled: false,
                compassEnabled: true,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                onMapCreated: (controller) {
                  setState(() {
                    mapController = controller;
                  });
                },
                onTap: _handleLocationSelection,
                markers: _markers,
                mapType: MapType.normal,
              ),
              
              // Zoom controls with modern design
              Positioned(
                right: 16,
                bottom: 240,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => mapController?.animateCamera(CameraUpdate.zoomIn()),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                          child: Container(
                            width: 48,
                            height: 48,
                            alignment: Alignment.center,
                            child: Icon(Icons.add_rounded, color: colorScheme.primary),
                          ),
                        ),
                      ),
                      Divider(height: 1, color: Colors.grey.shade300),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => mapController?.animateCamera(CameraUpdate.zoomOut()),
                          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                          child: Container(
                            width: 48,
                            height: 48,
                            alignment: Alignment.center,
                            child: Icon(Icons.remove_rounded, color: colorScheme.primary),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Instruction chip at top
              if (_origin == null || _destination == null)
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _origin == null ? Icons.location_searching : Icons.location_on,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _origin == null 
                              ? 'Tap on the map to select pickup location' 
                              : 'Now tap to select your destination',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              
              // Bottom panel with modern design
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Drag handle
                          Center(
                            child: Container(
                              width: 40,
                              height: 4,
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          
                          if (_isLoading)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: CircularProgressIndicator(),
                              ),
                            )
                          else ...[
                            if (_origin != null)
                              _buildLocationCard('Origin', _origin!, _originAddress, colorScheme.primary, Icons.trip_origin),
                            if (_destination != null)
                              _buildLocationCard('Destination', _destination!, _destinationAddress, colorScheme.secondary, Icons.location_on),
                          ],
                          
                          if (!_isLoading) const SizedBox(height: 16),
                          
                          // Confirm button
                          ElevatedButton(
                            onPressed: (_origin != null && _destination != null && !_isLoading) 
                              ? _confirmSelection 
                              : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                              disabledBackgroundColor: Colors.grey.shade300,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.check_circle_outline,
                                  size: 20,
                                  color: (_origin != null && _destination != null) 
                                    ? Colors.white 
                                    : Colors.grey.shade600,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Confirm Locations',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: (_origin != null && _destination != null) 
                                      ? Colors.white 
                                      : Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLocationCard(String label, LatLng position, String? address, Color color, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: color,
                      ),
                    ),
                    if (address != null && address.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          address,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.edit_location_alt_outlined, size: 22, color: color),
                tooltip: 'Change $label',
                onPressed: () => _editLocation(label),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleLocationSelection(LatLng position) async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (_origin == null) {
        // First tap sets origin
        String address = await _getAddressFromLatLng(position);
        setState(() {
          _origin = position;
          _originAddress = address;
          _updateMarkers();
        });
      } else if (_destination == null) {
        // Second tap sets destination
        String address = await _getAddressFromLatLng(position);
        setState(() {
          _destination = position;
          _destinationAddress = address;
          _updateMarkers();
        });
      } else {
        // If both are set, ask user which one to update
        _showSelectionDialog(position);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Error getting address: ${e.toString()}'),
              ),
            ],
          ),
          backgroundColor: Colors.orange.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSelectionDialog(LatLng position) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(Icons.edit_location, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            const Text('Update Location'),
          ],
        ),
        content: const Text(
          'Both locations are already set. Which one would you like to update?',
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _updateOrigin(position);
            },
            icon: const Icon(Icons.trip_origin),
            label: const Text('Origin'),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _updateDestination(position);
            },
            icon: const Icon(Icons.location_on),
            label: const Text('Destination'),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateOrigin(LatLng position) async {
    setState(() {
      _isLoading = true;
    });
    try {
      String address = await _getAddressFromLatLng(position);
      setState(() {
        _origin = position;
        _originAddress = address;
        _updateMarkers();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateDestination(LatLng position) async {
    setState(() {
      _isLoading = true;
    });
    try {
      String address = await _getAddressFromLatLng(position);
      setState(() {
        _destination = position;
        _destinationAddress = address;
        _updateMarkers();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _editLocation(String label) {
    final color = label == 'Origin' 
      ? Theme.of(context).colorScheme.primary 
      : Theme.of(context).colorScheme.secondary;
      
    if (label == 'Origin') {
      _moveCamera(_origin!);
    } else {
      _moveCamera(_destination!);
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              label == 'Origin' ? Icons.trip_origin : Icons.location_on,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text('Tap on map to update $label'),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<String> _getAddressFromLatLng(LatLng position) async {
    try {
      List<geo.Placemark> placemarks = await geo.placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        geo.Placemark place = placemarks.first;
        return _formatAddress(place);
      }
    } catch (e) {
      debugPrint('Error during geocoding: $e');
    }
    return 'Address not available';
  }

  String _formatAddress(geo.Placemark place) {
    List<String> addressParts = [
      if (place.name != null && place.name!.isNotEmpty) place.name!,
      if (place.street != null && place.street!.isNotEmpty) place.street!,
      if (place.subLocality != null && place.subLocality!.isNotEmpty) place.subLocality!,
      if (place.locality != null && place.locality!.isNotEmpty) place.locality!,
      if (place.postalCode != null && place.postalCode!.isNotEmpty) place.postalCode!,
      if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) place.administrativeArea!,
      if (place.country != null && place.country!.isNotEmpty) place.country!,
    ];

    return addressParts.where((part) => part.trim().isNotEmpty).join(', ');
  }

  void _updateMarkers() {
    _markers.clear();
    if (_origin != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('origin'),
          position: _origin!,
          infoWindow: InfoWindow(
            title: 'Origin',
            snippet: _originAddress,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      );
    }
    if (_destination != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('destination'),
          position: _destination!,
          infoWindow: InfoWindow(
            title: 'Destination',
            snippet: _destinationAddress,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    }
  }

  void _resetSelections() {
    setState(() {
      _origin = null;
      _destination = null;
      _originAddress = null;
      _destinationAddress = null;
      _markers.clear();
    });
  }

  void _confirmSelection() {
    if (_origin == null || _destination == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white),
              SizedBox(width: 12),
              Expanded(child: Text('Please select both origin and destination')),
            ],
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    // Update the RideFilterBloc with selected locations
    context.read<RideFilterBloc>().add(UpdateDestination(_destinationAddress!, _destination!));
    context.read<RideFilterBloc>().add(UpdatePickupLocation(_originAddress!, _origin!));

    // Show success feedback and navigate back
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text('Locations saved successfully!'),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
    
    // Navigate back to previous screen
    Navigator.of(context).pop();
  }
}