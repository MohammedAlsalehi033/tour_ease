import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';


class LocationTrackingMap extends StatefulWidget {
  @override
  _LocationTrackingMapState createState() => _LocationTrackingMapState();
}

class _LocationTrackingMapState extends State<LocationTrackingMap> {
  GoogleMapController? _controller;
  final Map<String, Marker> _markers = {};

  final String myUserId = 'user_456';
  final String otherUserId = 'user_123';

  final DatabaseReference _locationsRef = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: "https://tourease-544c3-default-rtdb.asia-southeast1.firebasedatabase.app/"
  ).ref('locations');
  StreamSubscription<Position>? _positionStreamSubscription;
  StreamSubscription<DatabaseEvent>? _firebaseListener;
  Timer? _locationUpdateTimer;

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    _firebaseListener?.cancel();
    _locationUpdateTimer?.cancel();
    _controller?.dispose();
    super.dispose();
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
    print("Updating my location: ${position.latitude}, ${position.longitude}"); // Debug log

    _locationsRef.child(myUserId).set({
      'latitude': position.latitude,
      'longitude': position.longitude,
      'timestamp': ServerValue.timestamp,
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
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
    );

    setState(() {
      _markers[myUserId] = marker;
    });
  }

  void _listenToOtherUserLocation() {
    _firebaseListener?.cancel();

    _firebaseListener = _locationsRef.child(otherUserId).onValue.listen((event) {
      if (event.snapshot.value != null) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        final double? latitude = data['latitude']?.toDouble();
        final double? longitude = data['longitude']?.toDouble();

        if (latitude != null && longitude != null) {
          final latLng = LatLng(latitude, longitude);
          final marker = Marker(
            markerId: MarkerId(otherUserId),
            position: latLng,
            infoWindow: InfoWindow(title: 'Other User'),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          );

          if (mounted) {
            setState(() {
              _markers[otherUserId] = marker;
            });
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Location Tracking')),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(37.42796133580664, -122.085749655962),
          zoom: 14,
        ),
        markers: _markers.values.toSet(),
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        onMapCreated: (GoogleMapController controller) {
          _controller = controller;
        },
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
