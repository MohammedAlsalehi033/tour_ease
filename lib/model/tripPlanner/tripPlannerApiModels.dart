/// Trip Planner API Models for Backend Integration
/// 
/// This file contains all the Dart models that match the backend API response format.
/// Updated to include the new day-by-day itinerary structure with Google Places enrichment.

/// Main API Response wrapper
class TripPlannerApiResponse {
  final bool success;
  final TripPlannerData? data;
  final ResponseMetadata? metadata;
  final String? message;
  final String? error;

  TripPlannerApiResponse({
    required this.success,
    this.data,
    this.metadata,
    this.message,
    this.error,
  });

  factory TripPlannerApiResponse.fromJson(Map<String, dynamic> json) {
    return TripPlannerApiResponse(
      success: json['success'] ?? false,
      data: json['data'] != null ? TripPlannerData.fromJson(json['data']) : null,
      metadata: json['metadata'] != null ? ResponseMetadata.fromJson(json['metadata']) : null,
      message: json['message']?.toString(),
      error: json['error']?.toString(),
    );
  }
}

/// Main trip planner data
class TripPlannerData {
  final TransportationOptionsContainer transportationOptions;
  final List<AccommodationApiOption> accommodationOptions;
  final List<DayItinerary> itinerary;
  final TripSummary tripSummary;

  TripPlannerData({
    required this.transportationOptions,
    required this.accommodationOptions,
    required this.itinerary,
    required this.tripSummary,
  });

  factory TripPlannerData.fromJson(Map<String, dynamic> json) {
    return TripPlannerData(
      transportationOptions: TransportationOptionsContainer.fromJson(
        json['transportationOptions'] ?? {},
      ),
      accommodationOptions: (json['accommodationOptions'] as List?)
              ?.map((e) => AccommodationApiOption.fromJson(e))
              .toList() ??
          [],
      itinerary: (json['itinerary'] as List?)
              ?.map((e) => DayItinerary.fromJson(e))
              .toList() ??
          [],
      tripSummary: TripSummary.fromJson(json['tripSummary'] ?? {}),
    );
  }
}

/// Transportation options container
class TransportationOptionsContainer {
  final List<TransportationApiOption> outbound;
  final List<TransportationApiOption> return_;

  TransportationOptionsContainer({
    required this.outbound,
    required this.return_,
  });

  factory TransportationOptionsContainer.fromJson(Map<String, dynamic> json) {
    return TransportationOptionsContainer(
      outbound: (json['outbound'] as List?)
              ?.map((e) => TransportationApiOption.fromJson(e))
              .toList() ??
          [],
      return_: (json['return'] as List?)
              ?.map((e) => TransportationApiOption.fromJson(e))
              .toList() ??
          [],
    );
  }
}

/// Transportation option from API
class TransportationApiOption {
  final String id;
  final String providerName;
  final String vehicleType;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final double pricePerSeat;
  final int availableSeats;
  final double? avgRating;
  final int? totalReviews;
  final List<String>? amenities;

  TransportationApiOption({
    required this.id,
    required this.providerName,
    required this.vehicleType,
    required this.departureTime,
    required this.arrivalTime,
    required this.pricePerSeat,
    required this.availableSeats,
    this.avgRating,
    this.totalReviews,
    this.amenities,
  });

  factory TransportationApiOption.fromJson(Map<String, dynamic> json) {
    return TransportationApiOption(
      id: json['id']?.toString() ?? '',
      providerName: json['providerName']?.toString() ?? '',
      vehicleType: json['vehicleType']?.toString() ?? '',
      departureTime: DateTime.parse(json['departureTime']),
      arrivalTime: DateTime.parse(json['arrivalTime']),
      pricePerSeat: (json['pricePerSeat'] ?? 0).toDouble(),
      availableSeats: json['availableSeats'] ?? 0,
      avgRating: json['avgRating']?.toDouble(),
      totalReviews: json['totalReviews'],
      amenities: (json['amenities'] as List?)?.map((e) => e.toString()).toList(),
    );
  }
}

/// Accommodation option from API
class AccommodationApiOption {
  final String id;
  final String name;
  final String location;
  final String providerName;
  final double? avgRating;
  final int? totalReviews;
  final int numberOfNights;
  final double totalCost;
  final List<String>? amenities;
  final List<RoomAllocation> roomAllocations;

  AccommodationApiOption({
    required this.id,
    required this.name,
    required this.location,
    required this.providerName,
    this.avgRating,
    this.totalReviews,
    required this.numberOfNights,
    required this.totalCost,
    this.amenities,
    required this.roomAllocations,
  });

  factory AccommodationApiOption.fromJson(Map<String, dynamic> json) {
    return AccommodationApiOption(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      providerName: json['providerName']?.toString() ?? '',
      avgRating: json['avgRating']?.toDouble(),
      totalReviews: json['totalReviews'],
      numberOfNights: json['numberOfNights'] ?? 0,
      totalCost: (json['totalCost'] ?? 0).toDouble(),
      amenities: (json['amenities'] as List?)?.map((e) => e.toString()).toList(),
      roomAllocations: (json['roomAllocations'] as List?)
              ?.map((e) => RoomAllocation.fromJson(e))
              .toList() ??
          [],
    );
  }
}

/// Room allocation details
class RoomAllocation {
  final String roomType;
  final int numberOfRooms;
  final int capacity;
  final double pricePerNight;
  final double totalCost;
  final List<String>? amenities;

  RoomAllocation({
    required this.roomType,
    required this.numberOfRooms,
    required this.capacity,
    required this.pricePerNight,
    required this.totalCost,
    this.amenities,
  });

  factory RoomAllocation.fromJson(Map<String, dynamic> json) {
    return RoomAllocation(
      roomType: json['roomType']?.toString() ?? '',
      numberOfRooms: json['numberOfRooms'] ?? 0,
      capacity: json['capacity'] ?? 0,
      pricePerNight: (json['pricePerNight'] ?? 0).toDouble(),
      totalCost: (json['totalCost'] ?? 0).toDouble(),
      amenities: (json['amenities'] as List?)?.map((e) => e.toString()).toList(),
    );
  }
}

/// Day-by-day itinerary
class DayItinerary {
  final int day;
  final String date;
  final String dayOfWeek;
  final String theme;
  final int totalDuration;
  final double totalEstimatedCost;
  final List<DayActivity> activities;

  DayItinerary({
    required this.day,
    required this.date,
    required this.dayOfWeek,
    required this.theme,
    required this.totalDuration,
    required this.totalEstimatedCost,
    required this.activities,
  });

  factory DayItinerary.fromJson(Map<String, dynamic> json) {
    return DayItinerary(
      day: json['day'] ?? 0,
      date: json['date']?.toString() ?? '',
      dayOfWeek: json['dayOfWeek']?.toString() ?? '',
      theme: json['theme']?.toString() ?? '',
      totalDuration: json['totalDuration'] ?? 0,
      totalEstimatedCost: (json['totalEstimatedCost'] ?? 0).toDouble(),
      activities: (json['activities'] as List?)
              ?.map((e) => DayActivity.fromJson(e))
              .toList() ??
          [],
    );
  }
}

/// Individual activity in a day
class DayActivity {
  final String time;
  final String title;
  final String description;
  final ActivityLocation location;
  final int duration;
  final double estimatedCost;
  final String category;
  final String mapUrl;
  final String? tips;
  final bool? bookingRequired;
  final PlaceDetails? placeDetails; // Google Places enrichment

  DayActivity({
    required this.time,
    required this.title,
    required this.description,
    required this.location,
    required this.duration,
    required this.estimatedCost,
    required this.category,
    required this.mapUrl,
    this.tips,
    this.bookingRequired,
    this.placeDetails,
  });

  factory DayActivity.fromJson(Map<String, dynamic> json) {
    return DayActivity(
      time: json['time']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      location: ActivityLocation.fromJson(json['location'] ?? {}),
      duration: json['duration'] ?? 0,
      estimatedCost: (json['estimatedCost'] ?? 0).toDouble(),
      category: json['category']?.toString() ?? '',
      mapUrl: json['mapUrl']?.toString() ?? '',
      tips: json['tips']?.toString(),
      bookingRequired: json['bookingRequired'],
      placeDetails: json['placeDetails'] != null
          ? PlaceDetails.fromJson(json['placeDetails'])
          : null,
    );
  }

  /// Check if this is a major attraction with Google Places data
  bool get hasGoogleData => placeDetails != null;

  /// Check if this is a meal activity
  bool get isMeal => ['breakfast', 'lunch', 'dinner'].contains(category);

  /// Check if this is a major attraction
  bool get isAttraction => ['attraction', 'activity', 'shopping'].contains(category);
}

/// Activity location details
class ActivityLocation {
  final String name;
  final String? address;
  final Coordinates? coordinates;

  ActivityLocation({
    required this.name,
    this.address,
    this.coordinates,
  });

  factory ActivityLocation.fromJson(Map<String, dynamic> json) {
    return ActivityLocation(
      name: json['name']?.toString() ?? '',
      address: json['address']?.toString(),
      coordinates: json['coordinates'] != null
          ? Coordinates.fromJson(json['coordinates'])
          : null,
    );
  }
}

/// Geographic coordinates
class Coordinates {
  final double lat;
  final double lng;

  Coordinates({
    required this.lat,
    required this.lng,
  });

  factory Coordinates.fromJson(Map<String, dynamic> json) {
    return Coordinates(
      lat: (json['lat'] ?? 0).toDouble(),
      lng: (json['lng'] ?? 0).toDouble(),
    );
  }
}

/// Google Places API enrichment data
class PlaceDetails {
  final double? rating;
  final int? userRatingsTotal;
  final int? priceLevel;
  final OpeningHours? openingHours;
  final String? website;
  final String? phoneNumber;
  final List<String>? photos;
  final List<PlaceReview>? reviews;

  PlaceDetails({
    this.rating,
    this.userRatingsTotal,
    this.priceLevel,
    this.openingHours,
    this.website,
    this.phoneNumber,
    this.photos,
    this.reviews,
  });

  factory PlaceDetails.fromJson(Map<String, dynamic> json) {
    return PlaceDetails(
      rating: json['rating']?.toDouble(),
      userRatingsTotal: json['userRatingsTotal'],
      priceLevel: json['priceLevel'],
      openingHours: json['openingHours'] != null
          ? OpeningHours.fromJson(json['openingHours'])
          : null,
      website: json['website']?.toString(),
      phoneNumber: json['phoneNumber']?.toString(),
      photos: (json['photos'] as List?)?.map((e) => e.toString()).toList(),
      reviews: (json['reviews'] as List?)
          ?.map((e) => PlaceReview.fromJson(e))
          .toList(),
    );
  }

  /// Get price level as string (₨ to ₨₨₨₨)
  String get priceLevelString {
    if (priceLevel == null) return '';
    return '₨' * (priceLevel ?? 0);
  }
}

/// Opening hours information
class OpeningHours {
  final bool openNow;
  final List<String>? weekdayText;

  OpeningHours({
    required this.openNow,
    this.weekdayText,
  });

  factory OpeningHours.fromJson(Map<String, dynamic> json) {
    return OpeningHours(
      openNow: json['openNow'] ?? false,
      weekdayText:
          (json['weekdayText'] as List?)?.map((e) => e.toString()).toList(),
    );
  }
}

/// Google Place review
class PlaceReview {
  final String author;
  final int rating;
  final String text;
  final String? time;

  PlaceReview({
    required this.author,
    required this.rating,
    required this.text,
    this.time,
  });

  factory PlaceReview.fromJson(Map<String, dynamic> json) {
    return PlaceReview(
      author: json['author']?.toString() ?? '',
      rating: json['rating'] ?? 0,
      text: json['text']?.toString() ?? '',
      time: json['time']?.toString(),
    );
  }
}

/// Trip summary with costs
class TripSummary {
  final int totalDays;
  final int totalNights;
  final CostBreakdown estimatedTotalCost;
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
      estimatedTotalCost: CostBreakdown.fromJson(
        json['estimatedTotalCost'] ?? {},
      ),
      remainingBudget: (json['remainingBudget'] ?? 0).toDouble(),
      budgetStatus: json['budgetStatus']?.toString() ?? '',
    );
  }

  /// Check if budget is within limits
  bool get isWithinBudget => budgetStatus == 'within_budget';

  /// Get budget usage percentage
  double getBudgetUsagePercentage(double totalBudget) {
    if (totalBudget <= 0) return 0;
    return (estimatedTotalCost.total / totalBudget) * 100;
  }
}

/// Cost breakdown
class CostBreakdown {
  final double transportation;
  final double accommodation;
  final double activities;
  final double meals;
  final double total;

  CostBreakdown({
    required this.transportation,
    required this.accommodation,
    required this.activities,
    required this.meals,
    required this.total,
  });

  factory CostBreakdown.fromJson(Map<String, dynamic> json) {
    return CostBreakdown(
      transportation: (json['transportation'] ?? 0).toDouble(),
      accommodation: (json['accommodation'] ?? 0).toDouble(),
      activities: (json['activities'] ?? 0).toDouble(),
      meals: (json['meals'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
    );
  }
}

/// Response metadata
class ResponseMetadata {
  final double requestedBudget;
  final String budgetCurrency;
  final bool specialRequirementsApplied;
  final DateTime requestProcessedAt;
  final int? apiCallsUsed;

  ResponseMetadata({
    required this.requestedBudget,
    required this.budgetCurrency,
    required this.specialRequirementsApplied,
    required this.requestProcessedAt,
    this.apiCallsUsed,
  });

  factory ResponseMetadata.fromJson(Map<String, dynamic> json) {
    return ResponseMetadata(
      requestedBudget: (json['requestedBudget'] ?? 0).toDouble(),
      budgetCurrency: json['budgetCurrency']?.toString() ?? 'PKR',
      specialRequirementsApplied: json['specialRequirementsApplied'] ?? false,
      requestProcessedAt: DateTime.parse(
        json['requestProcessedAt'] ?? DateTime.now().toIso8601String(),
      ),
      apiCallsUsed: json['apiCallsUsed'],
    );
  }
}

/// API Request model
class TripPlannerRequest {
  final String startLocation;
  final String endLocation;
  final DateTime startTime;
  final DateTime endTime;
  final List<String>? interests;
  final double budget;
  final int numberOfTravelers;
  final bool needsReturnTransport;
  final String? specialRequirements;

  TripPlannerRequest({
    required this.startLocation,
    required this.endLocation,
    required this.startTime,
    required this.endTime,
    this.interests,
    required this.budget,
    required this.numberOfTravelers,
    this.needsReturnTransport = true,
    this.specialRequirements,
  });

  Map<String, dynamic> toJson() {
    return {
      'startLocation': startLocation,
      'endLocation': endLocation,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'interests': interests ?? [],
      'budget': budget,
      'numberOfTravelers': numberOfTravelers,
      'needsReturnTransport': needsReturnTransport,
      if (specialRequirements != null) 'specialRequirements': specialRequirements,
    };
  }
}
