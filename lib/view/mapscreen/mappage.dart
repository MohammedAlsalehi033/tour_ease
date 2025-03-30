import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:flutter_polyline_points/flutter_polyline_points.dart'; // Add this package

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;
  Location location = Location();
  LatLng _currentPosition = const LatLng(33.65759035379694, 73.15763054167627);
  bool _locationServiceEnabled = false;
  PermissionStatus _permissionGranted = PermissionStatus.denied;
  LocationData? _locationData;

  Marker? _originMarker;
  Marker? _destinationMarker;

  // Route polylines
  Set<Polyline> _polylines = {};
  List<LatLng> _routeCoordinates = [];

  bool _selectingOrigin = true;

  String _originAddress = "No origin selected";
  String _originCoordinates = "";
  String _destinationAddress = "No destination selected";
  String _destinationCoordinates = "";
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    // Check if location service is enabled
    _locationServiceEnabled = await location.serviceEnabled();
    if (!_locationServiceEnabled) {
      _locationServiceEnabled = await location.requestService();
      if (!_locationServiceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();

    setState(() {
      _currentPosition =
          LatLng(_locationData!.latitude!, _locationData!.longitude!);
    });

    mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: _currentPosition,
          zoom: 15,
        ),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;

    if (_locationData != null) {
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: _currentPosition,
            zoom: 15,
          ),
        ),
      );
    }
  }

  Future<void> _setMarkerAndGetAddress(LatLng position) async {
    setState(() {
      _isLoading = true;

      if (_selectingOrigin) {
        _originMarker = Marker(
          markerId: MarkerId('origin'),
          position: position,
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(
            title: 'Origin',
            snippet: '${position.latitude}, ${position.longitude}',
          ),
        );
        _originCoordinates = '${position.latitude}, ${position.longitude}';
      } else {
        _destinationMarker = Marker(
          markerId: MarkerId('destination'),
          position: position,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
            title: 'Destination',
            snippet: '${position.latitude}, ${position.longitude}',
          ),
        );
        _destinationCoordinates = '${position.latitude}, ${position.longitude}';
      }
    });

    try {
      List<geocoding.Placemark> placemarks =
          await geocoding.placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        geocoding.Placemark place = placemarks[0];
        String address =
            '${place.street ?? ""} - ${place.subLocality ?? ""}, ${place.locality ?? ""}, ${place.administrativeArea ?? ""}, ${place.country ?? ""}';
        address = address.replaceAll(RegExp(r', ,'), ',');
        address = address.replaceAll(RegExp(r'^ - |, $'), '');

        setState(() {
          if (_selectingOrigin) {
            _originAddress = address;
            _selectingOrigin = false;
          } else {
            _destinationAddress = address;
            _getRoutePoints();
          }
          _isLoading = false;
        });
      } else {
        setState(() {
          if (_selectingOrigin) {
            _originAddress = "Address not found";
            _selectingOrigin = false;
          } else {
            _destinationAddress = "Address not found";
            _getRoutePoints();
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        if (_selectingOrigin) {
          _originAddress = "Error getting address: $e";
          _selectingOrigin = false;
        } else {
          _destinationAddress = "Error getting address: $e";
        }
        _isLoading = false;
      });
    }
  }

  // Get route between origin and destination
  Future<void> _getRoutePoints() async {
    if (_originMarker == null || _destinationMarker == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      PolylinePoints polylinePoints = PolylinePoints();
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleApiKey: 'AIzaSyAZz-3_lbGxmqlTXqNAYWVfLzV8O2J1bV0',
        request: PolylineRequest(
            origin: PointLatLng(_originMarker!.position.latitude,
                _originMarker!.position.longitude),
            destination: PointLatLng(_destinationMarker!.position.latitude, _destinationMarker!.position.longitude),
            mode: TravelMode.driving),
      );

      List<LatLng> routeCoordinates = [];
      if (result.points.isNotEmpty) {
        result.points.forEach((point) {
          routeCoordinates.add(LatLng(point.latitude, point.longitude));
        });
      }

      setState(() {
        _routeCoordinates = routeCoordinates;
        _polylines.clear();
        _polylines.add(Polyline(
          polylineId: PolylineId('route'),
          points: routeCoordinates,
          color: Colors.blue,
          width: 5,
        ));
        _isLoading = false;
      });

      // Adjust camera to show the entire route
      _fitRouteInView();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print("Error getting route: $e");
    }
  }

  void _fitRouteInView() {
    if (_originMarker == null || _destinationMarker == null) return;

    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(
        _originMarker!.position.latitude < _destinationMarker!.position.latitude
            ? _originMarker!.position.latitude
            : _destinationMarker!.position.latitude,
        _originMarker!.position.longitude <
                _destinationMarker!.position.longitude
            ? _originMarker!.position.longitude
            : _destinationMarker!.position.longitude,
      ),
      northeast: LatLng(
        _originMarker!.position.latitude > _destinationMarker!.position.latitude
            ? _originMarker!.position.latitude
            : _destinationMarker!.position.latitude,
        _originMarker!.position.longitude >
                _destinationMarker!.position.longitude
            ? _originMarker!.position.longitude
            : _destinationMarker!.position.longitude,
      ),
    );

    mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
  }

  // Reset selections
  void _resetSelections() {
    setState(() {
      _originMarker = null;
      _destinationMarker = null;
      _polylines.clear();
      _routeCoordinates = [];
      _originAddress = "No origin selected";
      _originCoordinates = "";
      _destinationAddress = "No destination selected";
      _destinationCoordinates = "";
      _selectingOrigin = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    Set<Marker> markers = {};
    if (_originMarker != null) markers.add(_originMarker!);
    if (_destinationMarker != null) markers.add(_destinationMarker!);

    return Scaffold(
      appBar: AppBar(
        title: Text('Route Finder'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _resetSelections,
            tooltip: 'Reset Selections',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _currentPosition,
                zoom: 15.0,
              ),
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              compassEnabled: true,
              mapToolbarEnabled: true,
              markers: markers,
              polylines: _polylines,
              onTap: _setMarkerAndGetAddress,
            ),
          ),
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.white,
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Route Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _selectingOrigin ? 'Select Origin' : 'Select Destination',
                      style: TextStyle(
                        color: _selectingOrigin ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Origin:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          Text(_originAddress),
                          Text(_originCoordinates,
                              style: TextStyle(fontSize: 12)),
                          SizedBox(height: 8),
                          Text(
                            'Destination:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          Text(_destinationAddress),
                          Text(_destinationCoordinates,
                              style: TextStyle(fontSize: 12)),
                        ],
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
