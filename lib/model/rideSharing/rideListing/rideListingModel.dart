import 'package:tour_ease/model/userManagment/transportationProvider.dart';

class RideListingModel {
  final int id;
  final String providerId;
  final double? startLocationLat;
  final double? startLocationLng;
  final String startLocationText;
  final double? endLocationLat;
  final double? endLocationLng;
  final String endLocationText;
  final DateTime departureTime;
  final double pricePerSeat;
  final int seatsAvailable;
  final String status;
  final List<String> mediaUrls;
  final DateTime createdAt;
  final double? distanceKm;
  final TransportationProviderModel? provider;

  RideListingModel({
    required this.id,
    required this.providerId,
    this.startLocationLat,
    this.startLocationLng,
    required this.startLocationText,
    this.endLocationLat,
    this.endLocationLng,
    required this.endLocationText,
    required this.departureTime,
    required this.pricePerSeat,
    required this.seatsAvailable,
    required this.status,
    required this.mediaUrls,
    required this.createdAt,
    this.distanceKm,
    this.provider,
  });

  factory RideListingModel.fromJson(Map<String, dynamic> json) {
    return RideListingModel(
      id: json['id'],
      providerId: json['providerId'],
      startLocationLat: json['startLocationLat']?.toDouble(),
      startLocationLng: json['startLocationLng']?.toDouble(),
      startLocationText: json['startLocationText'],
      endLocationLat: json['endLocationLat']?.toDouble(),
      endLocationLng: json['endLocationLng']?.toDouble(),
      endLocationText: json['endLocationText'],
      departureTime: DateTime.parse(json['departureTime']),
      pricePerSeat: double.parse(json['pricePerSeat'].toString()),
      seatsAvailable: json['seatsAvailable'],
      status: json['status'],
      mediaUrls: (json['mediaUrls'] as List<dynamic>).cast<String>(),
      createdAt: DateTime.parse(json['createdAt']),
      distanceKm: json['distance_km']?.toDouble(),
      provider: TransportationProviderModel.fromJson(json['provider']),
    );
  }


  static List<RideListingModel> parseApiResponse(Map<String, dynamic> response) {
    if (response['success'] == true && response['data'] != null) {
      return (response['data'] as List)
          .map((item) => RideListingModel.fromJson(item))
          .toList();
    }
    return [];
  }

  @override
  String toString() {
    return 'RideListingModel{id: $id, providerId: $providerId, startLocationLat: $startLocationLat, startLocationLng: $startLocationLng, startLocationText: $startLocationText, endLocationLat: $endLocationLat, endLocationLng: $endLocationLng, endLocationText: $endLocationText, departureTime: $departureTime, pricePerSeat: $pricePerSeat, seatsAvailable: $seatsAvailable, status: $status, mediaUrls: $mediaUrls, createdAt: $createdAt, distanceKm: $distanceKm, provider: ${provider.toString()}';
  }
}