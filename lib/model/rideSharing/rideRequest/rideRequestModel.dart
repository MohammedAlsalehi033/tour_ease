import 'dart:convert';

class TravelerRideRequestModel {
  final int id;
  final String travelerId;
  final DateTime departureTime;
  final int seatsNeeded;
  final double budget; // Parsed from String
  final DateTime createdAt;
  final double? endLocationLat;
  final double? endLocationLng;
  final String endLocationText;
  final double? startLocationLat;
  final double? startLocationLng;
  final String startLocationText;
  final double? distanceKm;

  TravelerRideRequestModel({
    required this.id,
    required this.travelerId,
    required this.departureTime,
    required this.seatsNeeded,
    required this.budget,
    required this.createdAt,
    this.endLocationLat,
    this.endLocationLng,
    required this.endLocationText,
    this.startLocationLat,
    this.startLocationLng,
    required this.startLocationText,
    this.distanceKm,
  });

  factory TravelerRideRequestModel.fromJson(Map<String, dynamic> json) {
    return TravelerRideRequestModel(
      id: json['id'],
      travelerId: json['travelerId'],
      departureTime: DateTime.parse(json['departureTime']),
      seatsNeeded: json['seatsNeeded'],
      budget: double.parse(json['budget'].toString()), // Parse budget string to double
      createdAt: DateTime.parse(json['createdAt']),
      endLocationLat: json['endLocationLat']?.toDouble(),
      endLocationLng: json['endLocationLng']?.toDouble(),
      endLocationText: json['endLocationText'],
      startLocationLat: json['startLocationLat']?.toDouble(),
      startLocationLng: json['startLocationLng']?.toDouble(),
      startLocationText: json['startLocationText'],
      distanceKm: json['distance_km']?.toDouble(),
    );
  }

  static List<TravelerRideRequestModel> parseApiResponse(dynamic responseBody) {
    // Handles both a direct list or a map with a 'data' key containing the list
    List<dynamic> dataList = [];
    if (responseBody is List) {
      dataList = responseBody;
    } else if (responseBody is Map<String, dynamic> && responseBody['success'] == true && responseBody['data'] is List) {
      dataList = responseBody['data'];
    } else if (responseBody is Map<String, dynamic> && responseBody.containsKey('id') ) {
      return [TravelerRideRequestModel.fromJson(responseBody)];
    }

    if (dataList.isNotEmpty) {
      try {
        return dataList
            .map((item) => TravelerRideRequestModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } catch (e) {
        // Handle potential parsing errors if item is not a valid map
        print('Error parsing TravelerRideRequestModel list: $e');
        return [];
      }
    }
    return []; // Return empty list if data is not in expected format or empty
  }


  @override
  String toString() {
    return 'TravelerRideRequestModel{id: $id, travelerId: $travelerId, departureTime: $departureTime, seatsNeeded: $seatsNeeded, budget: $budget, createdAt: $createdAt, endLocationLat: $endLocationLat, endLocationLng: $endLocationLng, endLocationText: $endLocationText, startLocationLat: $startLocationLat, startLocationLng: $startLocationLng, startLocationText: $startLocationText, distanceKm: $distanceKm}';
  }
}