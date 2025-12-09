import 'package:google_maps_flutter/google_maps_flutter.dart';

// ============================================================================
// HELPER FUNCTIONS
// ============================================================================

/// Safely converts a dynamic value to double, handling various input types
double _toDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0; // For Maps or other unexpected types, return 0
}

/// Safely converts a dynamic value to int, handling various input types including Maps (extracting id)
int _toInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  if (value is Map) {
    // If it's a map, try to find an 'id' field
    return _toInt(value['id']);
  }
  return 0;
}

/// Safely converts a dynamic value to nullable int
int? _toNullableInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value);
  if (value is Map) {
    return _toNullableInt(value['id']);
  }
  return null;
}

// ============================================================================
// SEARCH REQUEST MODELS
// ============================================================================

class TripSearchParams {
  final String startLocation;
  final String endLocation;
  final DateTime startTime;
  final DateTime endTime;
  final int numberOfTravelers;
  final double budget;
  final List<String> interests;
  final bool needsReturnTransport;
  final LatLng? detailedStartLocation;

  TripSearchParams({
    required this.startLocation,
    required this.endLocation,
    required this.startTime,
    required this.endTime,
    required this.numberOfTravelers,
    required this.budget,
    required this.interests,
    this.needsReturnTransport = true,
    this.detailedStartLocation,
  });

  Map<String, dynamic> toJson() => {
        'startLocation': startLocation,
        'endLocation': endLocation,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
        'numberOfTravelers': numberOfTravelers,
        'budget': budget,
        'interests': interests,
        'needsReturnTransport': needsReturnTransport,
        if (detailedStartLocation != null)
          'detailedStartLocation': {
            'lat': detailedStartLocation!.latitude,
            'lng': detailedStartLocation!.longitude,
          },
      };
}

// ============================================================================
// RESPONSE MODELS
// ============================================================================

class TransportOption {
  final int id;
  final int listingId;
  final String providerName;
  final String vehicleType;
  final double pricePerSeat;
  final int seatsAvailable;
  final DateTime departureTime;
  final DateTime? arrivalTime;
  final double avgRating;
  final double totalCost;
  final String? pickupLocation;
  final String? dropoffLocation;
  final int? totalReviews;
  final List<String>? amenities;

  TransportOption({
    required this.id,
    required this.listingId,
    required this.providerName,
    required this.vehicleType,
    required this.pricePerSeat,
    required this.seatsAvailable,
    required this.departureTime,
    this.arrivalTime,
    required this.avgRating,
    required this.totalCost,
    this.pickupLocation,
    this.dropoffLocation,
    this.totalReviews,
    this.amenities,
  });

  factory TransportOption.fromJson(Map<String, dynamic> json) {
    return TransportOption(
      id: _toInt(json['id']),
      listingId: _toInt(json['listingId']),
      providerName: json['providerName'] ?? '',
      vehicleType: json['vehicleType'] ?? '',
      pricePerSeat: _toDouble(json['pricePerSeat']),
      seatsAvailable: _toInt(json['seatsAvailable']),
      departureTime: json['departureTime'] != null
          ? DateTime.parse(json['departureTime'])
          : DateTime.now(),
      arrivalTime: json['arrivalTime'] != null ? DateTime.parse(json['arrivalTime']) : null,
      avgRating: _toDouble(json['avgRating']),
      totalCost: _toDouble(json['totalCost']),
      pickupLocation: json['pickupLocation'],
      dropoffLocation: json['dropoffLocation'],
      totalReviews: _toNullableInt(json['totalReviews']),
      amenities: json['amenities'] != null ? List<String>.from(json['amenities']) : null,
    );
  }
}

class RoomInfo {
  final int roomId;
  final String roomType;
  final int capacity;
  final double pricePerNight;
  final List<String>? amenities;

  RoomInfo({
    required this.roomId,
    required this.roomType,
    required this.capacity,
    required this.pricePerNight,
    this.amenities,
  });

  factory RoomInfo.fromJson(Map<String, dynamic> json) {
    return RoomInfo(
      roomId: _toInt(json['roomId']),
      roomType: json['roomType'] ?? '',
      capacity: _toInt(json['capacity']),
      pricePerNight: _toDouble(json['pricePerNight']),
      amenities: json['amenities'] != null ? List<String>.from(json['amenities']) : null,
    );
  }
}

class RoomAllocation {
  final int roomId;
  final String roomType;
  final double pricePerNight;
  final int capacity;
  final int numberOfRooms;
  final int guestsAllocated;
  final double totalCost;
  final List<String>? amenities;

  RoomAllocation({
    required this.roomId,
    required this.roomType,
    required this.pricePerNight,
    required this.capacity,
    required this.numberOfRooms,
    required this.guestsAllocated,
    required this.totalCost,
    this.amenities,
  });

  factory RoomAllocation.fromJson(Map<String, dynamic> json) {
    return RoomAllocation(
      roomId: _toInt(json['roomId']),
      roomType: json['roomType'] ?? '',
      pricePerNight: _toDouble(json['pricePerNight']),
      capacity: _toInt(json['capacity']),
      numberOfRooms: _toInt(json['numberOfRooms']),
      guestsAllocated: _toInt(json['guestsAllocated']),
      totalCost: _toDouble(json['totalCost']),
      amenities: json['amenities'] != null ? List<String>.from(json['amenities']) : null,
    );
  }
}

class AccommodationOption {
  final int id;
  final int accommodationId;
  final String name;
  final String location;
  final double avgRating;
  final double totalCost;
  final int numberOfNights;
  final List<RoomAllocation> roomAllocations;
  final List<RoomInfo>? availableRooms;
  final List<String>? amenities;
  final List<String>? images;
  final String? description;
  final DateTime? checkInDate;
  final DateTime? checkOutDate;
  final int? totalGuests;
  final int? totalReviews;
  
  // Alias for backward compatibility
  List<String>? get mediaUrls => images;

  AccommodationOption({
    required this.id,
    required this.accommodationId,
    required this.name,
    required this.location,
    required this.avgRating,
    required this.totalCost,
    required this.numberOfNights,
    required this.roomAllocations,
    this.availableRooms,
    this.amenities,
    this.images,
    this.description,
    this.checkInDate,
    this.checkOutDate,
    this.totalGuests,
    this.totalReviews,
  });

  factory AccommodationOption.fromJson(Map<String, dynamic> json) {
    return AccommodationOption(
      id: _toInt(json['id']),
      accommodationId: _toInt(json['accommodationId']),
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      avgRating: _toDouble(json['avgRating']),
      totalCost: _toDouble(json['totalCost']),
      numberOfNights: _toInt(json['numberOfNights']),
      roomAllocations: (json['roomAllocations'] as List?)
              ?.map((e) => RoomAllocation.fromJson(e))
              .toList() ??
          [],
      availableRooms: (json['availableRooms'] as List?)
          ?.map((e) => RoomInfo.fromJson(e))
          .toList(),
      amenities: json['amenities'] != null ? List<String>.from(json['amenities']) : null,
      images: json['images'] != null ? List<String>.from(json['images']) : null,
      description: json['description'],
      checkInDate: json['checkInDate'] != null ? DateTime.parse(json['checkInDate']) : null,
      checkOutDate: json['checkOutDate'] != null ? DateTime.parse(json['checkOutDate']) : null,
      totalGuests: _toNullableInt(json['totalGuests']),
      totalReviews: _toNullableInt(json['totalReviews']),
    );
  }
}

class Activity {
  final String id;
  final String title;
  final String description;
  final String location;
  final double estimatedCost;
  final int duration;
  final String category;

  Activity({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.estimatedCost,
    required this.duration,
    required this.category,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      estimatedCost: _toDouble(json['estimatedCost']),
      duration: _toInt(json['duration']),
      category: json['category'] ?? '',
    );
  }
}

class PlanCosts {
  final double transportation;
  final double accommodation;
  final double? activities;
  final double total;

  PlanCosts({
    required this.transportation,
    required this.accommodation,
    this.activities,
    required this.total,
  });

  factory PlanCosts.fromJson(Map<String, dynamic> json) {
    return PlanCosts(
      transportation: _toDouble(json['transportation']),
      accommodation: _toDouble(json['accommodation']),
      activities: json['activities'] != null ? _toDouble(json['activities']) : null,
      total: _toDouble(json['total']),
    );
  }
}

class RecommendedPlan {
  final String optionId;
  final String planName;
  final String description;
  final bool isOptimal;
  final double? optimizationScore;
  final TransportOption? outboundTransport;
  final TransportOption? returnTransport;
  final AccommodationOption? accommodation;
  final List<Activity> activities;
  final PlanCosts costs;
  final List<String> warnings;

  RecommendedPlan({
    required this.optionId,
    required this.planName,
    required this.description,
    required this.isOptimal,
    this.optimizationScore,
    this.outboundTransport,
    this.returnTransport,
    this.accommodation,
    required this.activities,
    required this.costs,
    required this.warnings,
  });

  factory RecommendedPlan.fromJson(Map<String, dynamic> json) {
    return RecommendedPlan(
      optionId: json['optionId']?.toString() ?? '',
      planName: json['planName'] ?? '',
      description: json['description'] ?? '',
      isOptimal: json['isOptimal'] ?? false,
      optimizationScore: json['optimizationScore'] != null
          ? _toDouble(json['optimizationScore'])
          : null,
      outboundTransport: json['outboundTransport'] != null
          ? TransportOption.fromJson(json['outboundTransport'])
          : null,
      returnTransport: json['returnTransport'] != null
          ? TransportOption.fromJson(json['returnTransport'])
          : null,
      accommodation: json['accommodation'] != null
          ? AccommodationOption.fromJson(json['accommodation'])
          : null,
      activities: (json['activities'] as List?)
              ?.map((e) => Activity.fromJson(e))
              .toList() ??
          [],
      costs: PlanCosts.fromJson(json['costs'] ?? {}),
      warnings: json['warnings'] != null ? List<String>.from(json['warnings']) : [],
    );
  }
}

class LocationCoordinates {
  final double lat;
  final double lng;

  LocationCoordinates({required this.lat, required this.lng});

  factory LocationCoordinates.fromJson(Map<String, dynamic> json) {
    return LocationCoordinates(
      lat: _toDouble(json['lat']),
      lng: _toDouble(json['lng']),
    );
  }
}

class ActivityLocation {
  final String name;
  final String? address;
  final LocationCoordinates coordinates;

  ActivityLocation({
    required this.name,
    this.address,
    required this.coordinates,
  });

  factory ActivityLocation.fromJson(Map<String, dynamic> json) {
    return ActivityLocation(
      name: json['name'] ?? '',
      address: json['address'],
      coordinates: LocationCoordinates.fromJson(json['coordinates'] ?? {}),
    );
  }
}

class PlaceDetails {
  final double? rating;
  final int? userRatingsTotal;
  final int? priceLevel;
  final String? website;
  final String? phoneNumber;
  final List<String>? photos;

  PlaceDetails({
    this.rating,
    this.userRatingsTotal,
    this.priceLevel,
    this.website,
    this.phoneNumber,
    this.photos,
  });

  factory PlaceDetails.fromJson(Map<String, dynamic> json) {
    return PlaceDetails(
      rating: json['rating'] != null ? _toDouble(json['rating']) : null,
      userRatingsTotal: json['userRatingsTotal'],
      priceLevel: json['priceLevel'],
      website: json['website'],
      phoneNumber: json['phoneNumber'],
      photos: json['photos'] != null ? List<String>.from(json['photos']) : null,
    );
  }
}

class ActivityItem {
  final String time;
  final String type;
  final String title;
  final String description;
  final double estimatedCost;
  final ActivityLocation? location;
  final String? tips;
  final PlaceDetails? placeDetails;
  final int? duration; // Duration in minutes
  
  // Alias for backward compatibility
  String get category => type;

  ActivityItem({
    required this.time,
    required this.type,
    required this.title,
    required this.description,
    required this.estimatedCost,
    this.location,
    this.tips,
    this.placeDetails,
    this.duration,
  });

  factory ActivityItem.fromJson(Map<String, dynamic> json) {
    return ActivityItem(
      time: json['time'] ?? '',
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      estimatedCost: _toDouble(json['estimatedCost']),
      location: json['location'] != null
          ? ActivityLocation.fromJson(json['location'])
          : null,
      tips: json['tips'],
      duration: json['duration'],
      placeDetails: json['placeDetails'] != null
          ? PlaceDetails.fromJson(json['placeDetails'])
          : null,
    );
  }
}

class ItineraryDay {
  final int day;
  final String date;
  final String dayOfWeek;
  final String theme;
  final double totalEstimatedCost;
  final List<ActivityItem> activities;
  final int? totalDuration; // Duration in minutes
  
  ItineraryDay({
    required this.day,
    required this.date,
    required this.dayOfWeek,
    required this.theme,
    required this.totalEstimatedCost,
    required this.activities,
    this.totalDuration,
  });

  factory ItineraryDay.fromJson(Map<String, dynamic> json) {
    return ItineraryDay(
      day: json['day'] ?? 0,
      date: json['date'] ?? '',
      dayOfWeek: json['dayOfWeek'] ?? '',
      theme: json['theme'] ?? '',
      totalEstimatedCost: _toDouble(json['totalEstimatedCost']),
      activities: (json['activities'] as List?)
              ?.map((e) => ActivityItem.fromJson(e))
              .toList() ??
          [],
      totalDuration: json['totalDuration'],
    );
  }
}

class TripSummary {
  final int totalDays;
  final int totalNights;
  final double estimatedTotalCost;
  final double remainingBudget;
  final String budgetStatus;

  TripSummary({
    required this.totalDays,
    required this.totalNights,
    required this.estimatedTotalCost,
    required this.remainingBudget,
    required this.budgetStatus,
  });

  factory TripSummary.fromJson(Map<String, dynamic> json) {
    return TripSummary(
      totalDays: json['totalDays'] ?? 0,
      totalNights: json['totalNights'] ?? 0,
      estimatedTotalCost: _toDouble(json['estimatedTotalCost']),
      remainingBudget: _toDouble(json['remainingBudget']),
      budgetStatus: json['budgetStatus'] ?? 'unknown',
    );
  }
}

class RequestSummary {
  final String startLocation;
  final String endLocation;
  final DateTime startTime;
  final DateTime endTime;
  final int numberOfTravelers;
  final double budget;
  final List<String> interests;

  RequestSummary({
    required this.startLocation,
    required this.endLocation,
    required this.startTime,
    required this.endTime,
    required this.numberOfTravelers,
    required this.budget,
    required this.interests,
  });

  factory RequestSummary.fromJson(Map<String, dynamic> json) {
    return RequestSummary(
      startLocation: json['startLocation'] ?? '',
      endLocation: json['endLocation'] ?? '',
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'])
          : DateTime.now(),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'])
          : DateTime.now(),
      numberOfTravelers: json['numberOfTravelers'] ?? 0,
      budget: _toDouble(json['budget']),
      interests: json['interests'] != null
          ? List<String>.from(json['interests'])
          : [],
    );
  }
}

class AvailableOptions {
  final List<TransportOption> outboundTransportation;
  final List<TransportOption> returnTransportation;
  final List<AccommodationOption> accommodations;
  final List<Activity> activities;

  AvailableOptions({
    required this.outboundTransportation,
    required this.returnTransportation,
    required this.accommodations,
    required this.activities,
  });

  factory AvailableOptions.fromJson(Map<String, dynamic> json) {
    return AvailableOptions(
      outboundTransportation: (json['outboundTransportation'] as List?)
              ?.map((e) => TransportOption.fromJson(e))
              .toList() ??
          [],
      returnTransportation: (json['returnTransportation'] as List?)
              ?.map((e) => TransportOption.fromJson(e))
              .toList() ??
          [],
      accommodations: (json['accommodations'] as List?)
              ?.map((e) => AccommodationOption.fromJson(e))
              .toList() ??
          [],
      activities: (json['activities'] as List?)
              ?.map((e) => Activity.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class TripPlannerResponse {
  final RequestSummary requestSummary;
  final AvailableOptions availableOptions;
  final List<RecommendedPlan> recommendedPlans;
  final RecommendedPlan? optimalPlan;
  final List<ItineraryDay>? itinerary;
  final TripSummary? tripSummary;

  TripPlannerResponse({
    required this.requestSummary,
    required this.availableOptions,
    required this.recommendedPlans,
    this.optimalPlan,
    this.itinerary,
    this.tripSummary,
  });

  factory TripPlannerResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    return TripPlannerResponse(
      requestSummary: RequestSummary.fromJson(data['requestSummary'] ?? {}),
      availableOptions: AvailableOptions.fromJson(data['availableOptions'] ?? {}),
      recommendedPlans: (data['recommendedPlans'] as List?)
              ?.map((e) => RecommendedPlan.fromJson(e))
              .toList() ??
          [],
      optimalPlan: data['optimalPlan'] != null
          ? RecommendedPlan.fromJson(data['optimalPlan'])
          : null,
      itinerary: (data['itinerary'] as List?)
          ?.map((e) => ItineraryDay.fromJson(e))
          .toList(),
      tripSummary: data['tripSummary'] != null
          ? TripSummary.fromJson(data['tripSummary'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'requestSummary': {
          'startLocation': requestSummary.startLocation,
          'endLocation': requestSummary.endLocation,
          'startTime': requestSummary.startTime.toIso8601String(),
          'endTime': requestSummary.endTime.toIso8601String(),
          'numberOfTravelers': requestSummary.numberOfTravelers,
          'budget': requestSummary.budget,
          'interests': requestSummary.interests,
        },
        'availableOptions': {
          'outboundTransportation': availableOptions.outboundTransportation
              .map((t) => {
                    'id': t.id,
                    'listingId': t.listingId,
                    'providerName': t.providerName,
                    'vehicleType': t.vehicleType,
                    'pricePerSeat': t.pricePerSeat,
                    'seatsAvailable': t.seatsAvailable,
                    'departureTime': t.departureTime.toIso8601String(),
                    if (t.arrivalTime != null)
                      'arrivalTime': t.arrivalTime!.toIso8601String(),
                    'avgRating': t.avgRating,
                    'totalCost': t.totalCost,
                    if (t.pickupLocation != null) 'pickupLocation': t.pickupLocation,
                    if (t.dropoffLocation != null) 'dropoffLocation': t.dropoffLocation,
                    if (t.totalReviews != null) 'totalReviews': t.totalReviews,
                    if (t.amenities != null) 'amenities': t.amenities,
                  })
              .toList(),
          'returnTransportation': availableOptions.returnTransportation
              .map((t) => {
                    'id': t.id,
                    'listingId': t.listingId,
                    'providerName': t.providerName,
                    'vehicleType': t.vehicleType,
                    'pricePerSeat': t.pricePerSeat,
                    'seatsAvailable': t.seatsAvailable,
                    'departureTime': t.departureTime.toIso8601String(),
                    if (t.arrivalTime != null)
                      'arrivalTime': t.arrivalTime!.toIso8601String(),
                    'avgRating': t.avgRating,
                    'totalCost': t.totalCost,
                    if (t.pickupLocation != null) 'pickupLocation': t.pickupLocation,
                    if (t.dropoffLocation != null) 'dropoffLocation': t.dropoffLocation,
                    if (t.totalReviews != null) 'totalReviews': t.totalReviews,
                    if (t.amenities != null) 'amenities': t.amenities,
                  })
              .toList(),
          'accommodations': availableOptions.accommodations
              .map((a) => {
                    'id': a.id,
                    'accommodationId': a.accommodationId,
                    'name': a.name,
                    'location': a.location,
                    'avgRating': a.avgRating,
                    'totalCost': a.totalCost,
                    'numberOfNights': a.numberOfNights,
                    'roomAllocations': a.roomAllocations
                        .map((r) => {
                              'roomId': r.roomId,
                              'roomType': r.roomType,
                              'pricePerNight': r.pricePerNight,
                              'capacity': r.capacity,
                              'numberOfRooms': r.numberOfRooms,
                              'guestsAllocated': r.guestsAllocated,
                              'totalCost': r.totalCost,
                              if (r.amenities != null) 'amenities': r.amenities,
                            })
                        .toList(),
                    if (a.availableRooms != null)
                      'availableRooms': a.availableRooms!
                          .map((r) => {
                                'roomId': r.roomId,
                                'roomType': r.roomType,
                                'capacity': r.capacity,
                                'pricePerNight': r.pricePerNight,
                                if (r.amenities != null) 'amenities': r.amenities,
                              })
                          .toList(),
                    if (a.amenities != null) 'amenities': a.amenities,
                    if (a.images != null) 'images': a.images,
                    if (a.description != null) 'description': a.description,
                    if (a.checkInDate != null)
                      'checkInDate': a.checkInDate!.toIso8601String(),
                    if (a.checkOutDate != null)
                      'checkOutDate': a.checkOutDate!.toIso8601String(),
                    if (a.totalGuests != null) 'totalGuests': a.totalGuests,
                    if (a.totalReviews != null) 'totalReviews': a.totalReviews,
                  })
              .toList(),
          'activities': availableOptions.activities
              .map((act) => {
                    'id': act.id,
                    'title': act.title,
                    'description': act.description,
                    'location': act.location,
                    'estimatedCost': act.estimatedCost,
                    'duration': act.duration,
                    'category': act.category,
                  })
              .toList(),
        },
        'recommendedPlans': recommendedPlans
            .map((plan) => {
                  'optionId': plan.optionId,
                  'planName': plan.planName,
                  'description': plan.description,
                  'isOptimal': plan.isOptimal,
                  if (plan.optimizationScore != null)
                    'optimizationScore': plan.optimizationScore,
                  if (plan.outboundTransport != null)
                    'outboundTransport': {
                      'id': plan.outboundTransport!.id,
                      'listingId': plan.outboundTransport!.listingId,
                      'providerName': plan.outboundTransport!.providerName,
                      'vehicleType': plan.outboundTransport!.vehicleType,
                      'pricePerSeat': plan.outboundTransport!.pricePerSeat,
                      'seatsAvailable': plan.outboundTransport!.seatsAvailable,
                      'departureTime': plan.outboundTransport!.departureTime.toIso8601String(),
                      if (plan.outboundTransport!.arrivalTime != null)
                        'arrivalTime': plan.outboundTransport!.arrivalTime!.toIso8601String(),
                      'avgRating': plan.outboundTransport!.avgRating,
                      'totalCost': plan.outboundTransport!.totalCost,
                    },
                  if (plan.returnTransport != null)
                    'returnTransport': {
                      'id': plan.returnTransport!.id,
                      'listingId': plan.returnTransport!.listingId,
                      'providerName': plan.returnTransport!.providerName,
                      'vehicleType': plan.returnTransport!.vehicleType,
                      'pricePerSeat': plan.returnTransport!.pricePerSeat,
                      'seatsAvailable': plan.returnTransport!.seatsAvailable,
                      'departureTime': plan.returnTransport!.departureTime.toIso8601String(),
                      if (plan.returnTransport!.arrivalTime != null)
                        'arrivalTime': plan.returnTransport!.arrivalTime!.toIso8601String(),
                      'avgRating': plan.returnTransport!.avgRating,
                      'totalCost': plan.returnTransport!.totalCost,
                    },
                  if (plan.accommodation != null)
                    'accommodation': {
                      'id': plan.accommodation!.id,
                      'accommodationId': plan.accommodation!.accommodationId,
                      'name': plan.accommodation!.name,
                      'location': plan.accommodation!.location,
                      'avgRating': plan.accommodation!.avgRating,
                      'totalCost': plan.accommodation!.totalCost,
                      'numberOfNights': plan.accommodation!.numberOfNights,
                      'roomAllocations': plan.accommodation!.roomAllocations
                          .map((r) => {
                                'roomId': r.roomId,
                                'roomType': r.roomType,
                                'pricePerNight': r.pricePerNight,
                                'capacity': r.capacity,
                                'numberOfRooms': r.numberOfRooms,
                                'guestsAllocated': r.guestsAllocated,
                                'totalCost': r.totalCost,
                              })
                          .toList(),
                    },
                  'activities': plan.activities
                      .map((act) => {
                            'id': act.id,
                            'title': act.title,
                            'description': act.description,
                            'location': act.location,
                            'estimatedCost': act.estimatedCost,
                            'duration': act.duration,
                            'category': act.category,
                          })
                      .toList(),
                  'costs': {
                    'transportation': plan.costs.transportation,
                    'accommodation': plan.costs.accommodation,
                    if (plan.costs.activities != null) 'activities': plan.costs.activities,
                    'total': plan.costs.total,
                  },
                  'warnings': plan.warnings,
                })
            .toList(),
        if (optimalPlan != null)
          'optimalPlan': {
            'optionId': optimalPlan!.optionId,
            'planName': optimalPlan!.planName,
            'description': optimalPlan!.description,
            'isOptimal': optimalPlan!.isOptimal,
            if (optimalPlan!.optimizationScore != null)
              'optimizationScore': optimalPlan!.optimizationScore,
            if (optimalPlan!.outboundTransport != null)
              'outboundTransport': {
                'id': optimalPlan!.outboundTransport!.id,
                'listingId': optimalPlan!.outboundTransport!.listingId,
                'providerName': optimalPlan!.outboundTransport!.providerName,
                'vehicleType': optimalPlan!.outboundTransport!.vehicleType,
                'pricePerSeat': optimalPlan!.outboundTransport!.pricePerSeat,
                'seatsAvailable': optimalPlan!.outboundTransport!.seatsAvailable,
                'departureTime': optimalPlan!.outboundTransport!.departureTime.toIso8601String(),
                if (optimalPlan!.outboundTransport!.arrivalTime != null)
                  'arrivalTime': optimalPlan!.outboundTransport!.arrivalTime!.toIso8601String(),
                'avgRating': optimalPlan!.outboundTransport!.avgRating,
                'totalCost': optimalPlan!.outboundTransport!.totalCost,
              },
            if (optimalPlan!.returnTransport != null)
              'returnTransport': {
                'id': optimalPlan!.returnTransport!.id,
                'listingId': optimalPlan!.returnTransport!.listingId,
                'providerName': optimalPlan!.returnTransport!.providerName,
                'vehicleType': optimalPlan!.returnTransport!.vehicleType,
                'pricePerSeat': optimalPlan!.returnTransport!.pricePerSeat,
                'seatsAvailable': optimalPlan!.returnTransport!.seatsAvailable,
                'departureTime': optimalPlan!.returnTransport!.departureTime.toIso8601String(),
                if (optimalPlan!.returnTransport!.arrivalTime != null)
                  'arrivalTime': optimalPlan!.returnTransport!.arrivalTime!.toIso8601String(),
                'avgRating': optimalPlan!.returnTransport!.avgRating,
                'totalCost': optimalPlan!.returnTransport!.totalCost,
              },
            if (optimalPlan!.accommodation != null)
              'accommodation': {
                'id': optimalPlan!.accommodation!.id,
                'accommodationId': optimalPlan!.accommodation!.accommodationId,
                'name': optimalPlan!.accommodation!.name,
                'location': optimalPlan!.accommodation!.location,
                'avgRating': optimalPlan!.accommodation!.avgRating,
                'totalCost': optimalPlan!.accommodation!.totalCost,
                'numberOfNights': optimalPlan!.accommodation!.numberOfNights,
                'roomAllocations': optimalPlan!.accommodation!.roomAllocations
                    .map((r) => {
                          'roomId': r.roomId,
                          'roomType': r.roomType,
                          'pricePerNight': r.pricePerNight,
                          'capacity': r.capacity,
                          'numberOfRooms': r.numberOfRooms,
                          'guestsAllocated': r.guestsAllocated,
                          'totalCost': r.totalCost,
                        })
                    .toList(),
              },
            'activities': optimalPlan!.activities
                .map((act) => {
                      'id': act.id,
                      'title': act.title,
                      'description': act.description,
                      'location': act.location,
                      'estimatedCost': act.estimatedCost,
                      'duration': act.duration,
                      'category': act.category,
                    })
                .toList(),
            'costs': {
              'transportation': optimalPlan!.costs.transportation,
              'accommodation': optimalPlan!.costs.accommodation,
              if (optimalPlan!.costs.activities != null)
                'activities': optimalPlan!.costs.activities,
              'total': optimalPlan!.costs.total,
            },
            'warnings': optimalPlan!.warnings,
          },
        if (itinerary != null)
          'itinerary': itinerary!
              .map((day) => {
                    'day': day.day,
                    'date': day.date,
                    'dayOfWeek': day.dayOfWeek,
                    'theme': day.theme,
                    'totalEstimatedCost': day.totalEstimatedCost,
                    if (day.totalDuration != null) 'totalDuration': day.totalDuration,
                    'activities': day.activities
                        .map((act) => {
                              'time': act.time,
                              'type': act.type,
                              'title': act.title,
                              'description': act.description,
                              'estimatedCost': act.estimatedCost,
                              if (act.location != null)
                                'location': {
                                  'name': act.location!.name,
                                  if (act.location!.address != null)
                                    'address': act.location!.address,
                                  'coordinates': {
                                    'lat': act.location!.coordinates.lat,
                                    'lng': act.location!.coordinates.lng,
                                  },
                                },
                              if (act.tips != null) 'tips': act.tips,
                              if (act.duration != null) 'duration': act.duration,
                              if (act.placeDetails != null)
                                'placeDetails': {
                                  if (act.placeDetails!.rating != null)
                                    'rating': act.placeDetails!.rating,
                                  if (act.placeDetails!.userRatingsTotal != null)
                                    'userRatingsTotal': act.placeDetails!.userRatingsTotal,
                                  if (act.placeDetails!.priceLevel != null)
                                    'priceLevel': act.placeDetails!.priceLevel,
                                  if (act.placeDetails!.website != null)
                                    'website': act.placeDetails!.website,
                                  if (act.placeDetails!.phoneNumber != null)
                                    'phoneNumber': act.placeDetails!.phoneNumber,
                                  if (act.placeDetails!.photos != null)
                                    'photos': act.placeDetails!.photos,
                                },
                            })
                        .toList(),
                  })
              .toList(),
        if (tripSummary != null)
          'tripSummary': {
            'totalDays': tripSummary!.totalDays,
            'totalNights': tripSummary!.totalNights,
            'estimatedTotalCost': tripSummary!.estimatedTotalCost,
            'remainingBudget': tripSummary!.remainingBudget,
            'budgetStatus': tripSummary!.budgetStatus,
          },
      };
}

// ============================================================================
// BOOKING MODELS
// ============================================================================

class RoomSelection {
  final int roomId;
  final int numberOfRooms;

  RoomSelection({
    required this.roomId,
    required this.numberOfRooms,
  });

  Map<String, dynamic> toJson() => {
        'roomId': roomId,
        'numberOfRooms': numberOfRooms,
      };

  factory RoomSelection.fromJson(Map<String, dynamic> json) {
    return RoomSelection(
      roomId: json['roomId'] ?? 0,
      numberOfRooms: json['numberOfRooms'] ?? 0,
    );
  }
}

class BookingRequest {
  final int? outboundTransportId;
  final int? returnTransportId;
  final int seatsNeeded;
  final int? accommodationId;
  final List<RoomSelection> selectedRoomAllocations;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final List<int>? selectedActivities;
  final String? paymentMethod;
  final String? stripePaymentIntentId;
  final String? specialRequests;

  BookingRequest({
    this.outboundTransportId,
    this.returnTransportId,
    required this.seatsNeeded,
    this.accommodationId,
    required this.selectedRoomAllocations,
    required this.checkInDate,
    required this.checkOutDate,
    this.selectedActivities,
    this.paymentMethod,
    this.stripePaymentIntentId,
    this.specialRequests,
  });

  Map<String, dynamic> toJson() => {
        if (outboundTransportId != null) 'outboundTransportId': outboundTransportId,
        if (returnTransportId != null) 'returnTransportId': returnTransportId,
        'seatsNeeded': seatsNeeded,
        if (accommodationId != null) 'accommodationId': accommodationId,
        'selectedRoomAllocations':
            selectedRoomAllocations.map((e) => e.toJson()).toList(),
        'checkInDate': checkInDate.toIso8601String(),
        'checkOutDate': checkOutDate.toIso8601String(),
        if (selectedActivities != null) 'selectedActivities': selectedActivities,
        if (paymentMethod != null) 'paymentMethod': paymentMethod,
        if (stripePaymentIntentId != null)
          'stripePaymentIntentId': stripePaymentIntentId,
        if (specialRequests != null) 'specialRequests': specialRequests,
      };
}

class TransportBooking {
  final int id;
  final String status;
  final double totalPrice;
  final int? offerId;

  TransportBooking({
    required this.id,
    required this.status,
    required this.totalPrice,
    this.offerId,
  });

  factory TransportBooking.fromJson(Map<String, dynamic> json) {
    return TransportBooking(
      id: json['id'] ?? 0,
      status: json['status'] ?? 'pending',
      totalPrice: _toDouble(json['totalPrice']),
      offerId: json['offerId'],
    );
  }
}

class AccommodationBooking {
  final int id;
  final String status;
  final double totalPrice;

  AccommodationBooking({
    required this.id,
    required this.status,
    required this.totalPrice,
  });

  factory AccommodationBooking.fromJson(Map<String, dynamic> json) {
    return AccommodationBooking(
      id: json['id'] ?? 0,
      status: json['status'] ?? 'pending',
      totalPrice: _toDouble(json['totalPrice']),
    );
  }
}

class TransportationBookings {
  final TransportBooking? outbound;
  final TransportBooking? return_;

  TransportationBookings({this.outbound, this.return_});

  factory TransportationBookings.fromJson(Map<String, dynamic> json) {
    return TransportationBookings(
      outbound: json['outbound'] != null
          ? TransportBooking.fromJson(json['outbound'])
          : null,
      return_: json['return'] != null
          ? TransportBooking.fromJson(json['return'])
          : null,
    );
  }
}

class BookingDetails {
  final TransportationBookings transportationBookings;
  final List<AccommodationBooking> accommodationBookings;

  BookingDetails({
    required this.transportationBookings,
    required this.accommodationBookings,
  });

  factory BookingDetails.fromJson(Map<String, dynamic> json) {
    return BookingDetails(
      transportationBookings: TransportationBookings.fromJson(
          json['transportationBookings'] ?? {}),
      accommodationBookings: (json['accommodationBookings'] as List?)
              ?.map((e) => AccommodationBooking.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class BookingConfirmation {
  final bool success;
  final BookingDetails bookings;
  final double totalCost;
  final String message;

  BookingConfirmation({
    required this.success,
    required this.bookings,
    required this.totalCost,
    required this.message,
  });

  factory BookingConfirmation.fromJson(Map<String, dynamic> json) {
    return BookingConfirmation(
      success: json['success'] ?? false,
      bookings: BookingDetails.fromJson(json['bookings'] ?? {}),
      totalCost: _toDouble(json['totalCost']),
      message: json['message'] ?? '',
    );
  }
}

// ============================================================================
// SAVED PLAN MODELS
// ============================================================================

class SavedPlan {
  final int id;
  final String userId;
  final String planName;
  final String? description;
  final String status; // "draft" | "booked" | "expired"
  final String startLocation;
  final String endLocation;
  final DateTime startTime;
  final DateTime endTime;
  final int numberOfTravelers;
  final double budget;
  final List<String> interests;
  final bool needsReturnTransport;
  
  // Selected IDs (with alternative names for compatibility)
  final int? selectedOutboundTransportId;
  final int? selectedReturnTransportId;
  final int? selectedAccommodationId;
  final int? seatsNeeded;
  final List<int>? selectedActivities;
  
  // Cost & Metadata
  final double totalCost;
  final List<String>? tags;
  final String? notes;
  
  // Timestamps
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? bookedAt;
  final DateTime? savedAt;
  final DateTime? lastViewedAt;
  
  // Original search parameters (for re-searching)
  final Map<String, dynamic>? originalSearchParams;
  
  // Complete search results data (can be very large)
  final Map<String, dynamic>? searchResultsData;
  
  // Alternative: older planData format
  final Map<String, dynamic>? planData;
  
  // Nested objects from API joins
  final TransportOption? outboundTransport;
  final TransportOption? returnTransport;
  final AccommodationOption? accommodation;
  final List<RoomAllocation>? roomAllocations;

  SavedPlan({
    required this.id,
    required this.userId,
    required this.planName,
    this.description,
    required this.status,
    required this.startLocation,
    required this.endLocation,
    required this.startTime,
    required this.endTime,
    required this.numberOfTravelers,
    required this.budget,
    required this.interests,
    required this.needsReturnTransport,
    this.selectedOutboundTransportId,
    this.selectedReturnTransportId,
    this.selectedAccommodationId,
    this.seatsNeeded,
    this.selectedActivities,
    required this.totalCost,
    this.tags,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.bookedAt,
    this.savedAt,
    this.lastViewedAt,
    this.originalSearchParams,
    this.searchResultsData,
    this.planData,
    this.outboundTransport,
    this.returnTransport,
    this.accommodation,
    this.roomAllocations,
  });

  factory SavedPlan.fromJson(Map<String, dynamic> json) {
    // Extract planData and searchResultsData
    final planData = json['planData'] as Map<String, dynamic>?;
    final searchResultsData = json['searchResultsData'] as Map<String, dynamic>? ?? 
                              planData?['searchResultsData'] as Map<String, dynamic>?;
    
    // Extract originalSearchParams
    final originalSearchParams = json['originalSearchParams'] as Map<String, dynamic>? ??
                                 planData?['originalSearchParams'] as Map<String, dynamic>?;
    
    // Parse timestamps
    DateTime? bookedAt;
    if (json['bookedAt'] != null) {
      bookedAt = DateTime.parse(json['bookedAt']);
    } else if (planData?['bookedAt'] != null) {
      bookedAt = DateTime.parse(planData!['bookedAt']);
    }
    
    DateTime? savedAt;
    if (json['savedAt'] != null) {
      savedAt = DateTime.parse(json['savedAt']);
    } else if (planData?['savedAt'] != null) {
      savedAt = DateTime.parse(planData!['savedAt']);
    }
    
    // Parse nested transportation listings
    TransportOption? outboundTransport;
    if (json['TransportationListing_SavedTripPlan_selectedOutboundTransportIdToTransportationListing'] != null) {
      final transportData = json['TransportationListing_SavedTripPlan_selectedOutboundTransportIdToTransportationListing'];
      outboundTransport = TransportOption(
        id: transportData['id'] ?? 0,
        listingId: transportData['id'] ?? 0,
        providerName: transportData['provider']?['user']?['username'] ?? '',
        vehicleType: transportData['provider']?['vehicleType'] ?? '',
        pricePerSeat: _toDouble(transportData['pricePerSeat']),
        seatsAvailable: transportData['seatsAvailable'] ?? 0,
        departureTime: transportData['departureTime'] != null
            ? DateTime.parse(transportData['departureTime'])
            : DateTime.now(),
        arrivalTime: transportData['arrivalTime'] != null
            ? DateTime.parse(transportData['arrivalTime'])
            : null,
        avgRating: 0.0,
        totalCost: _toDouble(transportData['pricePerSeat']),
        pickupLocation: transportData['startLocationText'],
        dropoffLocation: transportData['endLocationText'],
        amenities: transportData['mediaUrls'] != null 
            ? List<String>.from(transportData['mediaUrls']) 
            : null,
      );
    }
    
    TransportOption? returnTransport;
    if (json['TransportationListing_SavedTripPlan_selectedReturnTransportIdToTransportationListing'] != null) {
      final transportData = json['TransportationListing_SavedTripPlan_selectedReturnTransportIdToTransportationListing'];
      returnTransport = TransportOption(
        id: transportData['id'] ?? 0,
        listingId: transportData['id'] ?? 0,
        providerName: transportData['provider']?['user']?['username'] ?? '',
        vehicleType: transportData['provider']?['vehicleType'] ?? '',
        pricePerSeat: _toDouble(transportData['pricePerSeat']),
        seatsAvailable: transportData['seatsAvailable'] ?? 0,
        departureTime: transportData['departureTime'] != null
            ? DateTime.parse(transportData['departureTime'])
            : DateTime.now(),
        arrivalTime: transportData['arrivalTime'] != null
            ? DateTime.parse(transportData['arrivalTime'])
            : null,
        avgRating: 0.0,
        totalCost: _toDouble(transportData['pricePerSeat']),
        pickupLocation: transportData['startLocationText'],
        dropoffLocation: transportData['endLocationText'],
        amenities: transportData['mediaUrls'] != null 
            ? List<String>.from(transportData['mediaUrls']) 
            : null,
      );
    }
    
    // Parse accommodation
    AccommodationOption? accommodation;
    if (json['Accommodation'] != null) {
      final accomData = json['Accommodation'];
      final rooms = (accomData['rooms'] as List?)
          ?.map((room) => RoomInfo(
                roomId: room['id'] ?? 0,
                roomType: room['roomType'] ?? '',
                capacity: room['capacity'] ?? 0,
                pricePerNight: _toDouble(room['pricePerNight']),
                amenities: room['mediaUrls'] != null 
                    ? List<String>.from(room['mediaUrls']) 
                    : null,
              ))
          .toList();
      
      accommodation = AccommodationOption(
        id: accomData['id'] ?? 0,
        accommodationId: accomData['id'] ?? 0,
        name: accomData['name'] ?? '',
        location: accomData['location'] ?? '',
        avgRating: 0.0,
        totalCost: 0.0,
        numberOfNights: 0,
        roomAllocations: [],
        availableRooms: rooms,
        amenities: null,
        images: accomData['mediaUrls'] != null 
            ? List<String>.from(accomData['mediaUrls']) 
            : null,
        description: accomData['description'],
      );
    }
    
    // Parse room allocations from SavedPlanRoomAllocation
    List<RoomAllocation>? roomAllocations;
    if (json['SavedPlanRoomAllocation'] != null) {
      roomAllocations = (json['SavedPlanRoomAllocation'] as List)
          .map((allocation) {
            final roomData = allocation['Room'];
            return RoomAllocation(
              roomId: allocation['roomId'] ?? roomData?['id'] ?? 0,
              roomType: roomData?['roomType'] ?? '',
              pricePerNight: _toDouble(roomData?['pricePerNight']),
              capacity: roomData?['capacity'] ?? 0,
              numberOfRooms: allocation['numberOfRooms'] ?? 1,
              guestsAllocated: 0,
              totalCost: _toDouble(roomData?['pricePerNight']) * (allocation['numberOfRooms'] ?? 1),
              amenities: roomData?['mediaUrls'] != null 
                  ? List<String>.from(roomData['mediaUrls']) 
                  : null,
            );
          })
          .toList();
    }
    
    // Extract totalCost - handle both string and number
    double totalCost = 0.0;
    if (json['totalCost'] != null) {
      totalCost = _toDouble(json['totalCost']);
    } else if (planData?['totalCost'] != null) {
      totalCost = _toDouble(planData!['totalCost']);
    }
    
    // Extract budget - handle both string and number
    double budget = 0.0;
    if (json['budget'] != null) {
      budget = _toDouble(json['budget']);
    }
    
    return SavedPlan(
      id: _toInt(json['id']),
      userId: json['userId'] ?? '',
      planName: json['planName'] ?? '',
      description: json['description'] ?? planData?['description'],
      status: json['status'] ?? 'draft',
      startLocation: json['startLocation'] ?? 'Unknown',
      endLocation: json['endLocation'] ?? 'Unknown',
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'])
          : DateTime.now(),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'])
          : DateTime.now(),
      numberOfTravelers: _toInt(json['numberOfTravelers']),
      budget: budget,
      interests: json['interests'] != null
          ? List<String>.from(json['interests'])
          : [],
      needsReturnTransport: json['needsReturnTransport'] ?? true,
      selectedOutboundTransportId: _toNullableInt(json['selectedOutboundTransportId'] ?? json['selectedOutboundId']),
      selectedReturnTransportId: _toNullableInt(json['selectedReturnTransportId'] ?? json['selectedReturnId']),
      selectedAccommodationId: _toNullableInt(json['selectedAccommodationId']),
      seatsNeeded: _toNullableInt(json['seatsNeeded']),
      selectedActivities: json['selectedActivities'] != null
          ? (json['selectedActivities'] as List).map((e) => _toInt(e)).toList()
          : null,
      totalCost: totalCost,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      notes: json['notes'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      bookedAt: bookedAt,
      savedAt: savedAt,
      lastViewedAt: json['lastViewedAt'] != null
          ? DateTime.parse(json['lastViewedAt'])
          : null,
      originalSearchParams: originalSearchParams,
      searchResultsData: searchResultsData,
      planData: planData,
      outboundTransport: outboundTransport,
      returnTransport: returnTransport,
      accommodation: accommodation,
      roomAllocations: roomAllocations,
    );
  }

Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'planName': planName,
        if (description != null) 'description': description,
        'status': status,
        'startLocation': startLocation,
        'endLocation': endLocation,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
        'numberOfTravelers': numberOfTravelers,
        'budget': budget,
        'interests': interests,
        'needsReturnTransport': needsReturnTransport,
        if (selectedOutboundTransportId != null)
          'selectedOutboundTransportId': selectedOutboundTransportId,
        if (selectedReturnTransportId != null)
          'selectedReturnTransportId': selectedReturnTransportId,
        if (selectedAccommodationId != null)
          'selectedAccommodationId': selectedAccommodationId,
        if (seatsNeeded != null) 'seatsNeeded': seatsNeeded,
        if (selectedActivities != null)
          'selectedActivities': selectedActivities,
        'totalCost': totalCost,
        if (tags != null) 'tags': tags,
        if (notes != null) 'notes': notes,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        if (bookedAt != null) 'bookedAt': bookedAt!.toIso8601String(),
        if (savedAt != null) 'savedAt': savedAt!.toIso8601String(),
        if (lastViewedAt != null) 'lastViewedAt': lastViewedAt!.toIso8601String(),
        if (originalSearchParams != null) 'originalSearchParams': originalSearchParams,
        if (searchResultsData != null) 'searchResultsData': searchResultsData,
        if (planData != null) 'planData': planData,
      };
  
  // Helper getters for booking information
  Map<String, dynamic>? get bookings => planData?['bookings'];
  
  DateTime? get checkInDate {
    if (planData?['checkInDate'] != null) {
      return DateTime.parse(planData!['checkInDate']);
    }
    // Also check room allocations
    if (roomAllocations != null && roomAllocations!.isNotEmpty) {
      // Return start time as fallback
      return startTime;
    }
    return null;
  }
  
  DateTime? get checkOutDate {
    if (planData?['checkOutDate'] != null) {
      return DateTime.parse(planData!['checkOutDate']);
    }
    // Also check room allocations
    if (roomAllocations != null && roomAllocations!.isNotEmpty) {
      // Return end time as fallback
      return endTime;
    }
    return null;
  }
  
  String? get paymentMethod => planData?['paymentMethod'];
  
  String? get stripePaymentIntentId => planData?['stripePaymentIntentId'];
  
  // Status checkers
  bool get isBooked => status == 'booked';
  
  bool get isDraft => status == 'draft';
  
  bool get isExpired => status == 'expired';
  
  // Convenience getters for alternative field names (compatibility)
  int? get selectedOutboundId => selectedOutboundTransportId;
  
  int? get selectedReturnId => selectedReturnTransportId;  
      
}

class SavePlanRequest {
  final String planName;
  final String? description;
  final int selectedOutboundId;
  final int? selectedReturnId;
  final int selectedAccommodationId;
  final List<RoomSelection> selectedRoomAllocations;
  final List<int>? selectedActivities;
  final double totalCost;
  final List<String>? tags;
  final TripSearchParams originalSearchParams;
  final Map<String, dynamic>? searchResultsData;
  final String status; // "saved" or "booked"

  SavePlanRequest({
    required this.planName,
    this.description,
    required this.selectedOutboundId,
    this.selectedReturnId,
    required this.selectedAccommodationId,
    required this.selectedRoomAllocations,
    this.selectedActivities,
    required this.totalCost,
    this.tags,
    required this.originalSearchParams,
    this.searchResultsData,
    this.status = 'saved', // Default to 'saved'
  });

  Map<String, dynamic> toJson() => {
        'planName': planName,
        if (description != null) 'description': description,
        'selectedOutboundId': selectedOutboundId,
        if (selectedReturnId != null) 'selectedReturnId': selectedReturnId,
        'selectedAccommodationId': selectedAccommodationId,
        'selectedRoomAllocations':
            selectedRoomAllocations.map((e) => e.toJson()).toList(),
        if (selectedActivities != null) 'selectedActivities': selectedActivities,
        'totalCost': totalCost,
        if (tags != null) 'tags': tags,
        'originalSearchParams': originalSearchParams.toJson(),
        'status': status,
        'startLocation': originalSearchParams.startLocation,
        'endLocation': originalSearchParams.endLocation,
        'startTime': originalSearchParams.startTime.toIso8601String(),
        'endTime': originalSearchParams.endTime.toIso8601String(),
        'numberOfTravelers': originalSearchParams.numberOfTravelers,
        'budget': originalSearchParams.budget,
        'interests': originalSearchParams.interests,
        'needsReturnTransport': originalSearchParams.needsReturnTransport,
        if (searchResultsData != null) 'searchResultsData': searchResultsData,
      };
}
