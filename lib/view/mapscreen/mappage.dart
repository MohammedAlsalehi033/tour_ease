import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:tour_ease/bloc/rideFilterBloc.dart';
import 'package:tour_ease/model/rideSharing/rideModel.dart';

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
            content: Text('Unable to get current location: ${e.toString()}'),
            backgroundColor: Colors.red,
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
    return BlocBuilder<RideFilterBloc, RideFilterState>(
  builder: (context, state) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Locations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            tooltip: 'Go to current location',
            onPressed: _getCurrentLocation,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset selections',
            onPressed: _resetSelections,
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(37.42796133580664, -122.085749655962), // Default: Google HQ
              zoom: 14,
            ),
            myLocationEnabled: _locationPermissionGranted,
            myLocationButtonEnabled: false, // We'll add our own button
            compassEnabled: true,
            zoomControlsEnabled: false, // We'll position them better
            mapToolbarEnabled: true,
            onMapCreated: (controller) {
              setState(() {
                mapController = controller;
              });
            },
            onTap: _handleLocationSelection,
            markers: _markers,
            mapType: MapType.normal,
          ),
          // Zoom controls positioned for better accessibility
          Positioned(
            right: 16,
            bottom: 200,
            child: Column(
              children: [
                FloatingActionButton.small(
                  heroTag: "zoomIn",
                  onPressed: () => mapController?.animateCamera(CameraUpdate.zoomIn()),
                  tooltip: 'Zoom in',
                  child: const Icon(Icons.add),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: "zoomOut",
                  onPressed: () => mapController?.animateCamera(CameraUpdate.zoomOut()),
                  tooltip: 'Zoom out',
                  child: const Icon(Icons.remove),
                ),
              ],
            ),
          ),
          // Location information panel
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.white,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Tap the map to select origin and destination',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      if (_isLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      if (_origin != null)
                        _buildLocationCard('Origin', _origin!, _originAddress, Colors.green),
                      if (_destination != null)
                        _buildLocationCard('Destination', _destination!, _destinationAddress, Colors.red),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: (_origin != null && _destination != null) ? _confirmSelection : null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                            : const Text(
                          'Confirm Selection',
                          style: TextStyle(fontSize: 16),
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

  Widget _buildLocationCard(String label, LatLng position, String? address, Color color) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: color.withOpacity(0.5), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  label == 'Origin' ? Icons.trip_origin : Icons.location_on,
                  color: color,
                ),
                const SizedBox(width: 8),
                Text(
                  '$label:',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.edit_location_alt, size: 20),
                  tooltip: 'Change $label',
                  onPressed: () => _editLocation(label),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const Divider(),
            if (address != null && address.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  address,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            Text(
              'Coordinates: ${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
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
          content: Text('Error getting address: ${e.toString()}'),
          backgroundColor: Colors.red,
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
        title: const Text('Update Location'),
        content: const Text('Which location would you like to update?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _updateOrigin(position);
            },
            child: const Text('Origin'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _updateDestination(position);
            },
            child: const Text('Destination'),
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
    if (label == 'Origin') {
      _moveCamera(_origin!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tap on map to update Origin'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      _moveCamera(_destination!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tap on map to update Destination'),
          duration: Duration(seconds: 2),
        ),
      );
    }
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
        const SnackBar(content: Text('Please select both origin and destination')),
      );
      return;
    }

    context.read<RideFilterBloc>().add(UpdateDestination(_destinationAddress!, _destination!));
    context.read<RideFilterBloc>().add(UpdatePickupLocation(_originAddress!,_origin!));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Confirmed'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildConfirmationInfo('Origin', _origin!, _originAddress),
              const SizedBox(height: 16),
              _buildConfirmationInfo('Destination', _destination!, _destinationAddress),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Here you would navigate to the next screen or use the data
              // For example:
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => ResultScreen(
              //       origin: _origin!,
              //       destination: _destination!,
              //       originAddress: _originAddress!,
              //       destinationAddress: _destinationAddress!,
              //     ),
              //   ),
              // );
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationInfo(String label, LatLng position, String? address) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label:',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 4),
        if (address != null)
          Text(
            address,
            style: const TextStyle(fontSize: 14),
          ),
        const SizedBox(height: 4),
        Text(
          'Latitude: ${position.latitude.toStringAsFixed(6)}',
          style: const TextStyle(fontSize: 14),
        ),
        Text(
          'Longitude: ${position.longitude.toStringAsFixed(6)}',
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }
}