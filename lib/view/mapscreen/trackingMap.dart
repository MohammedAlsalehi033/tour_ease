import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tour_ease/model/userManagment/user.dart';

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

  void _updatePolyline() {
    // Create polyline only if both users' locations are available
    if (_markers.containsKey(myUserId) && _markers.containsKey(otherUserId)) {
      setState(() {
        _polylines = {
          Polyline(
            polylineId: PolylineId('user_connection'),
            points: [
              _markers[myUserId]!.position,
              _markers[otherUserId]!.position,
            ],
            color: Colors.blue,
            width: 5,
            patterns: [PatternItem.dash(20), PatternItem.gap(10)], // Dashed line
          )
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Location Tracking'),
        actions: [
          // Add debug button to manually check for inactivity
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              // Force check for user activity status
              if (_lastOtherUserUpdate != null) {
                final timeSinceLastUpdate = DateTime.now().difference(_lastOtherUserUpdate!).inSeconds;
                setState(() {
                  _isOtherUserActive = timeSinceLastUpdate <= 60;
                });
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('User activity status updated: ${_isOtherUserActive ? 'Active' : 'Inactive'}'),
                  duration: Duration(seconds: 2),
                ));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('No activity data received from other user'),
                  duration: Duration(seconds: 2),
                ));
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (!_isOtherUserActive)
            Container(
              color: Colors.amber.shade300,
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              width: double.infinity,
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.red),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Other user is not active',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(37.42796133580664, -122.085749655962),
                    zoom: 14,
                  ),
                  markers: _markers.values.toSet(),
                  polylines: _polylines,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
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
                // Legend in bottom-left corner
                Positioned(
                  left: 16,
                  bottom: 16,
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              color: Colors.blue,
                            ),
                            SizedBox(width: 8),
                            Text('My Car', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              color: Colors.red,
                            ),
                            SizedBox(width: 8),
                            Text('Other User', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              color: Colors.green,
                            ),
                            SizedBox(width: 8),
                            Text('Start Location', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _fitAllMarkers,
        child: Icon(Icons.my_location),
      ),
    );
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