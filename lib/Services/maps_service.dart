import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart';

class MapsService {
  MapsService._internal();
  static final MapsService _instance = MapsService._internal();
  factory MapsService() => _instance;

  /// Opens Google Maps with the given location address
  /// [address] - The location address to search for
  /// [label] - Optional label for the location pin
  Future<bool> openLocation(String address, {String? label}) async {
    try {
      final String encodedAddress = Uri.encodeComponent(address);
      late Uri mapsUrl;

      if (Platform.isIOS) {
        // For iOS, use Apple Maps or Google Maps
        mapsUrl = Uri.parse('https://maps.apple.com/?q=$encodedAddress');
        
        // Try Apple Maps first, then fallback to Google Maps
        if (!await launchUrl(mapsUrl, mode: LaunchMode.externalApplication)) {
          mapsUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$encodedAddress');
          return await launchUrl(mapsUrl, mode: LaunchMode.externalApplication);
        }
        return true;
      } else {
        // For Android and other platforms, use Google Maps
        mapsUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$encodedAddress');
        return await launchUrl(mapsUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error opening maps: $e');
      }
      return false;
    }
  }

  /// Opens Google Maps with coordinates (latitude and longitude)
  /// [latitude] - The latitude coordinate
  /// [longitude] - The longitude coordinate  
  /// [label] - Optional label for the location pin
  Future<bool> openCoordinates(double latitude, double longitude, {String? label}) async {
    try {
      late Uri mapsUrl;
      
      if (Platform.isIOS) {
        // For iOS, use Apple Maps or Google Maps
        mapsUrl = Uri.parse('https://maps.apple.com/?ll=$latitude,$longitude');
        
        if (label != null) {
          final encodedLabel = Uri.encodeComponent(label);
          mapsUrl = Uri.parse('https://maps.apple.com/?ll=$latitude,$longitude&q=$encodedLabel');
        }
        
        // Try Apple Maps first, then fallback to Google Maps
        if (!await launchUrl(mapsUrl, mode: LaunchMode.externalApplication)) {
          mapsUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');
          return await launchUrl(mapsUrl, mode: LaunchMode.externalApplication);
        }
        return true;
      } else {
        // For Android and other platforms, use Google Maps
        mapsUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');
        return await launchUrl(mapsUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error opening maps with coordinates: $e');
      }
      return false;
    }
  }

  /// Opens Google Maps with directions from start to end location
  /// [startAddress] - The starting location address
  /// [endAddress] - The destination location address
  Future<bool> openDirections(String startAddress, String endAddress) async {
    try {
      final String encodedStart = Uri.encodeComponent(startAddress);
      final String encodedEnd = Uri.encodeComponent(endAddress);
      late Uri mapsUrl;

      if (Platform.isIOS) {
        // For iOS, use Apple Maps or Google Maps
        mapsUrl = Uri.parse('https://maps.apple.com/?saddr=$encodedStart&daddr=$encodedEnd');
        
        // Try Apple Maps first, then fallback to Google Maps
        if (!await launchUrl(mapsUrl, mode: LaunchMode.externalApplication)) {
          mapsUrl = Uri.parse('https://www.google.com/maps/dir/?api=1&origin=$encodedStart&destination=$encodedEnd');
          return await launchUrl(mapsUrl, mode: LaunchMode.externalApplication);
        }
        return true;
      } else {
        // For Android and other platforms, use Google Maps
        mapsUrl = Uri.parse('https://www.google.com/maps/dir/?api=1&origin=$encodedStart&destination=$encodedEnd');
        return await launchUrl(mapsUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error opening directions: $e');
      }
      return false;
    }
  }

  /// Opens Google Maps with directions using coordinates
  /// [startLat] - Starting latitude
  /// [startLng] - Starting longitude  
  /// [endLat] - Destination latitude
  /// [endLng] - Destination longitude
  Future<bool> openDirectionsWithCoordinates(
    double startLat, 
    double startLng, 
    double endLat, 
    double endLng
  ) async {
    try {
      late Uri mapsUrl;

      if (Platform.isIOS) {
        // For iOS, use Apple Maps or Google Maps
        mapsUrl = Uri.parse('https://maps.apple.com/?saddr=$startLat,$startLng&daddr=$endLat,$endLng');
        
        // Try Apple Maps first, then fallback to Google Maps
        if (!await launchUrl(mapsUrl, mode: LaunchMode.externalApplication)) {
          mapsUrl = Uri.parse('https://www.google.com/maps/dir/?api=1&origin=$startLat,$startLng&destination=$endLat,$endLng');
          return await launchUrl(mapsUrl, mode: LaunchMode.externalApplication);
        }
        return true;
      } else {
        // For Android and other platforms, use Google Maps
        mapsUrl = Uri.parse('https://www.google.com/maps/dir/?api=1&origin=$startLat,$startLng&destination=$endLat,$endLng');
        return await launchUrl(mapsUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error opening directions with coordinates: $e');
      }
      return false;
    }
  }

  /// Checks if maps application can be launched
  Future<bool> canLaunchMaps() async {
    try {
      late Uri testUrl;
      
      if (Platform.isIOS) {
        testUrl = Uri.parse('https://maps.apple.com/');
      } else {
        testUrl = Uri.parse('https://www.google.com/maps/');
      }
      
      return await canLaunchUrl(testUrl);
    } catch (e) {
      if (kDebugMode) {
        print('Error checking if maps can be launched: $e');
      }
      return false;
    }
  }
}