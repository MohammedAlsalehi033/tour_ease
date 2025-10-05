import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tour_ease/model/userManagment/user.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class LocationTrackingMap extends StatefulWidget {

  final String otherUserId;

  const LocationTrackingMap({super.key, required this.otherUserId});
  @override
  _LocationTrackingMapState createState() => _LocationTrackingMapState();
}

class _LocationTrackingMapState extends State<LocationTrackingMap> {
  GoogleMapController? _controller;
  final Map<String, Marker> _markers = {};
  Set<Polyline> _polylines = {};

  final String myUserId = UserModel().id;
   late String otherUserId;

  // For tracking start location
  LatLng? _startLocation;

  // For tracking other user's activity status
  bool _isOtherUserActive = false;
  DateTime? _lastOtherUserUpdate;
  Timer? _userActivityCheckTimer;

  final DatabaseReference _locationsRef = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: "https://tourease-544c3-default-rtdb.asia-southeast1.firebasedatabase.app/"
  ).ref('locations');
  StreamSubscription<Position>? _positionStreamSubscription;
  StreamSubscription<DatabaseEvent>? _firebaseListener;
  Timer? _locationUpdateTimer;

  // Custom icons for markers
  BitmapDescriptor _myCarIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
  BitmapDescriptor _otherCarIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
  BitmapDescriptor _startLocationIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);

  @override
  void initState() {
    super.initState();
    _loadCustomMarkerIcons();
    _requestLocationPermission();

    // Create location data upon entering the screen
    _initializeLocationData();

    // Check other user's activity status every 30 seconds
    _startUserActivityCheck();
    otherUserId = widget.otherUserId;
  }

  @override
  void dispose() {
    _deleteLocationData();

    _positionStreamSubscription?.cancel();
    _firebaseListener?.cancel();
    _locationUpdateTimer?.cancel();
    _userActivityCheckTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _loadCustomMarkerIcons() async {
    try {
      final ImageConfiguration imageConfig = ImageConfiguration(
        size: Size(48, 48),
        devicePixelRatio: MediaQuery.of(context).devicePixelRatio,
      );

      BitmapDescriptor.fromAssetImage(imageConfig, 'assets/my_car_icon.png')
          .then((icon) {
        if (icon != null && mounted) {
          setState(() => _myCarIcon = icon);
          _updateMyLocationMarker();
        }
      }).catchError((error) {
        print("Failed to load my car icon: $error");
      });

      // Try to load other car icon
      BitmapDescriptor.fromAssetImage(imageConfig, 'assets/other_car_icon.png')
          .then((icon) {
        if (icon != null && mounted) {
          setState(() => _otherCarIcon = icon);
          if (_markers.containsKey(otherUserId)) {
            _updateOtherUserMarker(_markers[otherUserId]!.position);
          }
        }
      }).catchError((error) {
        print("Failed to load other car icon: $error");
      });

      // Try to load start location icon
      BitmapDescriptor.fromAssetImage(imageConfig, 'assets/start_location_icon.png')
          .then((icon) {
        if (icon != null && mounted) {
          setState(() => _startLocationIcon = icon);
          _updateStartLocationMarker();
        }
      }).catchError((error) {
        print("Failed to load start location icon: $error");
      });
    } catch (e) {
      print("Error loading custom markers: $e");
      // Continue with default markers if loading fails
    }
  }

  void _initializeLocationData() async {
    Position position = await Geolocator.getCurrentPosition();

    // Set start location
    _startLocation = LatLng(position.latitude, position.longitude);

    // Add start location marker
    _updateStartLocationMarker();

    // Initialize my location in Firebase
    _locationsRef.child(myUserId).set({
      'latitude': position.latitude,
      'longitude': position.longitude,
      'timestamp': ServerValue.timestamp,
      'active': true,
    });
  }

  void _deleteLocationData() {
    // Delete my location data when leaving the screen
    _locationsRef.child(myUserId).remove().then((_) {
      print("Location data deleted successfully from Firebase");
    }).catchError((error) {
      print("Failed to delete location data: $error");
    });
  }

  void _startUserActivityCheck() {
    _userActivityCheckTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      if (_lastOtherUserUpdate != null) {
        // If last update was more than 60 seconds ago, consider user inactive
        if (DateTime.now().difference(_lastOtherUserUpdate!).inSeconds > 60) {
          setState(() {
            _isOtherUserActive = false;
          });
        }
      }
    });
  }

  Future<void> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location permissions are permanently denied')),
      );
      return;
    }

    if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
      _startLocationUpdates();
      _listenToOtherUserLocation();
    }
  }

  void _updateStartLocationMarker() {
    if (_startLocation == null) return;

    final marker = Marker(
      markerId: MarkerId('start_location'),
      position: _startLocation!,
      infoWindow: InfoWindow(title: 'Start Location'),
      icon: _startLocationIcon,
    );

    setState(() {
      _markers['start_location'] = marker;
    });
  }

  void _updateMyLocationMarker() {
    if (!_markers.containsKey(myUserId)) return;

    final currentMarker = _markers[myUserId]!;
    final updatedMarker = Marker(
      markerId: currentMarker.markerId,
      position: currentMarker.position,
      infoWindow: currentMarker.infoWindow,
      icon: _myCarIcon,
    );

    setState(() {
      _markers[myUserId] = updatedMarker;
    });
  }

  void _updateOtherUserMarker(LatLng position) {
    print(otherUserId);
    final marker = Marker(
      markerId: MarkerId(otherUserId),
      position: position,
      infoWindow: InfoWindow(title: 'Other User'),
      icon: _otherCarIcon,
    );

    setState(() {
      _markers[otherUserId] = marker;
    });
  }

  void _startLocationUpdates() {
    _positionStreamSubscription?.cancel();

    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      if (mounted) {
        _updateMyLocation(position);
      }
    });
  }

  void _updateMyLocation(Position position) {
    print("Updating my location: ${position.latitude}, ${position.longitude}");

    _locationsRef.child(myUserId).update({
      'latitude': position.latitude,
      'longitude': position.longitude,
      'timestamp': ServerValue.timestamp,
      'active': true,
    }).then((_) {
      print("Location updated successfully in Firebase!");
    }).catchError((error) {
      print("Failed to update location: $error");
    });

    final latLng = LatLng(position.latitude, position.longitude);
    final marker = Marker(
      markerId: MarkerId(myUserId),
      position: latLng,
      infoWindow: InfoWindow(title: 'My Location'),
      icon: _myCarIcon,
    );

    setState(() {
      _markers[myUserId] = marker;
      _updatePolyline();
    });
  }

  void _listenToOtherUserLocation() {
    _firebaseListener?.cancel();

    _firebaseListener = _locationsRef.child(otherUserId).onValue.listen((event) {
      print("Other user location update received:");
      print(event.snapshot.value);

      if (event.snapshot.value != null) {
        try {
          final data = Map<String, dynamic>.from(event.snapshot.value as Map);
          final latitude = data['latitude'];
          final longitude = data['longitude'];
          final bool? active = data['active'] as bool?;

          _lastOtherUserUpdate = DateTime.now();
          setState(() {
            _isOtherUserActive = active ?? false;
          });

          // Type-safe conversion to double
          final double? latDouble = latitude is double
              ? latitude
              : latitude is int
              ? latitude.toDouble()
              : latitude is String
              ? double.tryParse(latitude)
              : null;

          final double? lngDouble = longitude is double
              ? longitude
              : longitude is int
              ? longitude.toDouble()
              : longitude is String
              ? double.tryParse(longitude)
              : null;

          if (latDouble != null && lngDouble != null) {
            print("Other user coordinates: $latDouble, $lngDouble");

            final latLng = LatLng(latDouble, lngDouble);

            if (mounted) {
              _updateOtherUserMarker(latLng);
              _updatePolyline();
            }
          }
        } catch (e) {
          print("Error processing other user location data: $e");
          setState(() {
            _isOtherUserActive = false;
          });
        }
      } else {
        // If data is null, the other user is not active
        setState(() {
          _isOtherUserActive = false;
        });
      }
    }, onError: (error) {
      print("Error in Firebase listener: $error");
      setState(() {
        _isOtherUserActive = false;
      });
    });
  }

  void _updatePolyline() async {
    // Create polyline only if both users' locations are available
    if (_markers.containsKey(myUserId) && _markers.containsKey(otherUserId)) {
      final myLocation = _markers[myUserId]!.position;
      final otherLocation = _markers[otherUserId]!.position;
      
      // Fetch the actual route
      await _drawRoute(myLocation, otherLocation);
    }
  }

  Future<void> _drawRoute(LatLng origin, LatLng destination) async {
    try {
      final polylinePoints = PolylinePoints();
      
      // You'll need to add your Google Maps API key here
      // Get it from Google Cloud Console
      const String googleApiKey = 'AIzaSyAZz-3_lbGxmqlTXqNAYWVfLzV8O2J1bV0';
      
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleApiKey: googleApiKey,
        request: PolylineRequest(
          origin: PointLatLng(origin.latitude, origin.longitude),
          destination: PointLatLng(destination.latitude, destination.longitude),
          mode: TravelMode.driving,
        ),
      );

      if (result.points.isNotEmpty) {
        List<LatLng> polylineCoordinates = result.points
            .map((point) => LatLng(point.latitude, point.longitude))
            .toList();

        setState(() {
          _polylines = {
            Polyline(
              polylineId: PolylineId('route'),
              points: polylineCoordinates,
              color: Colors.blue,
              width: 5,
              geodesic: true,
            )
          };
        });
      } else {
        // Fallback to straight line if route fetching fails
        _drawStraightLine(origin, destination);
      }
    } catch (e) {
      print("Error drawing route: $e");
      // Fallback to straight line on error
      _drawStraightLine(origin, destination);
    }
  }

  void _drawStraightLine(LatLng origin, LatLng destination) {
    setState(() {
      _polylines = {
        Polyline(
          polylineId: PolylineId('user_connection'),
          points: [origin, destination],
          color: Colors.blue.withOpacity(0.6),
          width: 5,
          patterns: [PatternItem.dash(20), PatternItem.gap(10)],
        )
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Live Tracking'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.my_location),
            onPressed: _fitAllMarkers,
            tooltip: 'Show all locations',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(37.42796133580664, -122.085749655962),
              zoom: 14,
            ),
            markers: _markers.values.toSet(),
            polylines: _polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            onMapCreated: (GoogleMapController controller) {
              _controller = controller;

              // Once map is created, fit markers if we have any
              if (_markers.isNotEmpty) {
                Future.delayed(Duration(milliseconds: 300), () {
                  _fitAllMarkers();
                });
              }
            },
          ),

          // Status banner at top
          if (!_isOtherUserActive)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange.shade400, Colors.deepOrange.shade400],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.white, size: 24),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Other user is offline',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Last seen: ${_lastOtherUserUpdate != null ? _formatTimeSince(_lastOtherUserUpdate!) : 'Unknown'}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Info card at bottom
          Positioned(
            left: 16,
            right: 16,
            bottom: 80,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildInfoItem(
                        Icons.directions_car,
                        'You',
                        Colors.blue,
                      ),
                      Container(
                        width: 2,
                        height: 40,
                        color: Colors.grey.shade300,
                      ),
                      _buildInfoItem(
                        _isOtherUserActive ? Icons.directions_car : Icons.location_off,
                        _isOtherUserActive ? 'Driver' : 'Offline',
                        _isOtherUserActive ? Colors.red : Colors.grey,
                      ),
                      Container(
                        width: 2,
                        height: 40,
                        color: Colors.grey.shade300,
                      ),
                      _buildInfoItem(
                        Icons.location_on,
                        'Start',
                        Colors.green,
                      ),
                    ],
                  ),
                  if (_markers.containsKey(myUserId) && _markers.containsKey(otherUserId)) ...[
                    SizedBox(height: 12),
                    Divider(height: 1),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.route, color: Theme.of(context).colorScheme.primary, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Distance: ${_calculateDistance(
                            _markers[myUserId]!.position,
                            _markers[otherUserId]!.position,
                          ).toStringAsFixed(2)} km',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _fitAllMarkers,
        child: Icon(Icons.center_focus_strong),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  String _formatTimeSince(DateTime time) {
    final duration = DateTime.now().difference(time);
    if (duration.inMinutes < 1) return 'Just now';
    if (duration.inMinutes < 60) return '${duration.inMinutes}m ago';
    if (duration.inHours < 24) return '${duration.inHours}h ago';
    return '${duration.inDays}d ago';
  }

  double _calculateDistance(LatLng pos1, LatLng pos2) {
    return Geolocator.distanceBetween(
      pos1.latitude,
      pos1.longitude,
      pos2.latitude,
      pos2.longitude,
    ) / 1000; // Convert to kilometers
  }

  void _fitAllMarkers() {
    if (_controller == null || _markers.isEmpty) return;

    double minLat = double.infinity;
    double maxLat = -double.infinity;
    double minLng = double.infinity;
    double maxLng = -double.infinity;

    for (var marker in _markers.values) {
      final lat = marker.position.latitude;
      final lng = marker.position.longitude;
      minLat = lat < minLat ? lat : minLat;
      maxLat = lat > maxLat ? lat : maxLat;
      minLng = lng < minLng ? lng : minLng;
      maxLng = lng > maxLng ? lng : maxLng;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    _controller!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
  }
}