

import 'package:tour_ease/model/rideSharing/offer/offerModel.dart';
import 'package:tour_ease/model/rideSharing/rideListing/rideListingModel.dart';
import 'package:tour_ease/model/rideSharing/rideRequest/rideRequestModel.dart';
import 'package:tour_ease/model/userManagment/user.dart';

class ProviderBookingModel {
  final int id;
  final String travelerId;
  final int seatsBooked;
  final String? luggage;
  final String status;
  final double totalPrice;
  final DateTime createdAt;
  final String bookingSource;
  final int? transportationListingId;
  final int? transportationRequestId;
  final int? offerId;
  final RideListingModel? listing; // Assumes RideListingModel.fromJson handles missing 'provider'
  final TravelerRideRequestModel? request;
  final BookingTravelerInfoModel? traveler; // Included for Provider
  final OfferModel? offer; // Assumes OfferModel.fromJson handles missing nested objects

  ProviderBookingModel({
    required this.id,
    required this.travelerId,
    required this.seatsBooked,
    this.luggage,
    required this.status,
    required this.totalPrice,
    required this.createdAt,
    required this.bookingSource,
    this.transportationListingId,
    this.transportationRequestId,
    this.offerId,
    this.listing,
    this.request,
    this.traveler, // Included
    this.offer,
  });

  factory ProviderBookingModel.fromJson(Map<String, dynamic> json) {
    // --- Safe Parsing Logic for Nested Models ---
    RideListingModel? parsedListing;
    if (json['listing'] != null) {
      try {
        parsedListing = RideListingModel.fromJson(json['listing']);
      } catch (e) { print("Error parsing nested listing in ProviderBookingModel: $e"); }
    }

    OfferModel? parsedOffer;
    if (json['offer'] != null) {
      try {
        parsedOffer = OfferModel.fromJson(json['offer']);
      } catch (e) { print("Error parsing nested offer in ProviderBookingModel: $e"); }
    }
    // --- End Safe Parsing ---

    return ProviderBookingModel(
      id: json['id'],
      travelerId: json['travelerId'],
      seatsBooked: json['seatsBooked'] ?? 0,
      luggage: json['luggage'],
      status: json['status'] ?? 'unknown',
      totalPrice: double.tryParse(json['totalPrice']?.toString() ?? '0.0') ?? 0.0,
      createdAt: DateTime.parse(json['createdAt']),
      bookingSource: json['bookingSource'] ?? 'unknown',
      transportationListingId: json['transportationListingId'],
      transportationRequestId: json['transportationRequestId'],
      offerId: json['offerId'],
      listing: parsedListing,
      request: json['request'] != null
          ? TravelerRideRequestModel.fromJson(json['request'])
          : null,
      // Parse traveler since it's expected in this model
      traveler: json['traveler'] != null
          ? BookingTravelerInfoModel.fromJson(json['traveler'])
          : null,
      offer: parsedOffer,
    );
  }

  static List<ProviderBookingModel> parseBookingList(List<dynamic> list) {
    return list
        .map((item) => ProviderBookingModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'travelerId': travelerId,
      'seatsBooked': seatsBooked,
      'luggage': luggage,
      'status': status,
      'totalPrice': totalPrice.toString(),
      'createdAt': createdAt.toIso8601String(),
      'bookingSource': bookingSource,
      'transportationListingId': transportationListingId,
      'transportationRequestId': transportationRequestId,
      'offerId': offerId,
      'traveler': traveler?.toJson(), // Included
      'offer': offer?.toJson(),
    };
  }

  @override
  String toString() {
    return 'ProviderBookingModel{id: $id, travelerId: $travelerId, traveler: ${traveler?.id}, listing: ${listing?.id}, offer: ${offer?.id}}';
  }
}




class TravelerBookingModel {
  final int id;
  final String travelerId;
  final int seatsBooked;
  final String? luggage;
  final String status;
  final double totalPrice;
  final DateTime createdAt;
  final String bookingSource;
  final int? transportationListingId;
  final int? transportationRequestId;
  final int? offerId;
  final RideListingModel? listing;
  final TravelerRideRequestModel? request;
  final OfferModel? offer;

  TravelerBookingModel({
    required this.id,
    required this.travelerId,
    required this.seatsBooked,
    this.luggage,
    required this.status,
    required this.totalPrice,
    required this.createdAt,
    required this.bookingSource,
    this.transportationListingId,
    this.transportationRequestId,
    this.offerId,
    this.listing,
    this.request,
    this.offer,
  });

  factory TravelerBookingModel.fromJson(Map<String, dynamic> json) {
    RideListingModel? parsedListing;
    if (json['listing'] != null) {
      try {
        parsedListing = RideListingModel.fromJson(json['listing']);
      } catch (e) { print("Error parsing nested listing in TravelerBookingModel: $e"); }
    }

    OfferModel? parsedOffer;
    if (json['offer'] != null) {
      try {
        parsedOffer = OfferModel.fromJson(json['offer']);
      } catch (e) { print("Error parsing nested offer in TravelerBookingModel: $e"); }
    }

    print(json);
    return TravelerBookingModel(
      id: json['id'],
      travelerId: json['travelerId'],
      seatsBooked: json['seatsBooked'] ?? 0,
      luggage: json['luggage'],
      status: json['status'] ?? 'unknown',
      totalPrice: double.tryParse(json['totalPrice']?.toString() ?? '0.0') ?? 0.0,
      createdAt: DateTime.parse(json['createdAt']),
      bookingSource: json['bookingSource'] ?? 'unknown',
      transportationListingId: json['transportationListingId'],
      transportationRequestId: json['transportationRequestId'],
      offerId: json['offerId'],
      listing: parsedListing,
      request: json['request'] != null
          ? TravelerRideRequestModel.fromJson(json['request'])
          : null,
      offer: parsedOffer,
    );
  }

  static List<TravelerBookingModel> parseBookingList(List<dynamic> list) {
    return list
        .map((item) => TravelerBookingModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  String getProviderId (){

    print(listing);
    print(offer);

    if (listing != null){
      return listing!.providerId;
    }
    else if (offer != null){
      if (  offer!.senderId == UserModel().id){
        return offer!.recipientId;

      }
      return offer!.senderId;
    }
    return "";
  }

  Map<String, dynamic> toJson() {

    return {
      'id': id,
      'travelerId': travelerId,
      'seatsBooked': seatsBooked,
      'luggage': luggage,
      'status': status,
      'totalPrice': totalPrice.toString(),
      'createdAt': createdAt.toIso8601String(),
      'bookingSource': bookingSource,
      'transportationListingId': transportationListingId,
      'transportationRequestId': transportationRequestId,
      'offerId': offerId,

      // No traveler
      'offer': offer?.toJson(),
    };
  }

  @override
  String toString() {
    return 'TravelerBookingModel{id: $id, travelerId: $travelerId, seatsBooked: $seatsBooked, luggage: $luggage, status: $status, totalPrice: $totalPrice, createdAt: $createdAt, bookingSource: $bookingSource, transportationListingId: $transportationListingId, transportationRequestId: $transportationRequestId, offerId: $offerId, listing: $listing, request: $request, offer: $offer}';
  }
}


class BookingTravelerInfoModel {
  final String id;
  final String? username;
  final List<String> mediaUrls;

  BookingTravelerInfoModel({
    required this.id,
    this.username,
    required this.mediaUrls,
  });

  factory BookingTravelerInfoModel.fromJson(Map<String, dynamic> json) {
    return BookingTravelerInfoModel(
      id: json['id'] ?? '', // Add default value if id can be missing
      username: json['username'],
      mediaUrls: (json['mediaUrls'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'mediaUrls': mediaUrls,
    };
  }

  @override
  String toString() {
    return 'BookingTravelerInfoModel{id: $id, username: $username}';
  }
}