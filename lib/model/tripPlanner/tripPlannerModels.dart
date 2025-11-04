// Trip Planner Request Model - Matches POST /api/planner/generate
class TripPlanRequest {
  final String startLocation;
  final String endLocation;
  final DateTime startTime;
  final DateTime endTime;
  final List<String> interests;
  final double budget;
  final int numberOfTravelers;
  final bool needsReturnTransport;
  final String? specialRequirements;

  TripPlanRequest({
    required this.startLocation,
    required this.endLocation,
    required this.startTime,
    required this.endTime,
    required this.interests,
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
      'interests': interests,
      'budget': budget,
      'numberOfTravelers': numberOfTravelers,
      'needsReturnTransport': needsReturnTransport,
      if (specialRequirements != null && specialRequirements!.isNotEmpty) 
        'specialRequirements': specialRequirements,
    };
  }
}

// Transportation Option Model - Matches actual API response
class TransportationOption {
  final String id;
  final String providerId;
  final String providerName;
  final String vehicleType;
  final double pricePerSeat;
  final int seatsAvailable;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final String? startLocationText;
  final String? endLocationText;
  final double? avgRating;
  final int totalReviews;
  final List<String> amenities;
  final double totalCost;
  final bool isReturnTrip;

  TransportationOption({
    required this.id,
    required this.providerId,
    required this.providerName,
    required this.vehicleType,
    required this.pricePerSeat,
    required this.seatsAvailable,
    required this.departureTime,
    required this.arrivalTime,
    this.startLocationText,
    this.endLocationText,
    this.avgRating,
    required this.totalReviews,
    required this.amenities,
    required this.totalCost,
    required this.isReturnTrip,
  });

  factory TransportationOption.fromJson(Map<String, dynamic> json) {
    return TransportationOption(
      id: json['id']?.toString() ?? '',
      providerId: json['providerId'] ?? '',
      providerName: json['providerName'] ?? '',
      vehicleType: json['vehicleType'] ?? '',
      pricePerSeat: (json['pricePerSeat'] ?? 0).toDouble(),
      seatsAvailable: json['availableSeats'] ?? json['seatsAvailable'] ?? 0,
      departureTime: json['departureTime'] != null 
          ? DateTime.parse(json['departureTime']) 
          : DateTime.now(),
      arrivalTime: json['arrivalTime'] != null 
          ? DateTime.parse(json['arrivalTime']) 
          : DateTime.now().add(const Duration(hours: 4)),
      startLocationText: json['startLocationText'],
      endLocationText: json['endLocationText'],
      avgRating: json['avgRating'] != null ? (json['avgRating'] as num).toDouble() : null,
      totalReviews: json['totalReviews'] ?? 0,
      amenities: json['amenities'] != null 
          ? List<String>.from(json['amenities']) 
          : [],
      totalCost: (json['totalCost'] ?? 0).toDouble(),
      isReturnTrip: json['isReturnTrip'] ?? false,
    );
  }

  // Backward compatibility
  int get availableSeats => seatsAvailable;
}

// Room Allocation Model - Matches actual API response
class RoomAllocation {
  final int roomId;
  final String roomType;
  final double pricePerNight;
  final int capacity;
  final int numberOfRooms;
  final int guestsAllocated;
  final double totalCost;
  final List<String> amenities;

  RoomAllocation({
    required this.roomId,
    required this.roomType,
    required this.pricePerNight,
    required this.capacity,
    required this.numberOfRooms,
    required this.guestsAllocated,
    required this.totalCost,
    required this.amenities,
  });

  factory RoomAllocation.fromJson(Map<String, dynamic> json) {
    return RoomAllocation(
      roomId: json['roomId'] ?? 0,
      roomType: json['roomType'] ?? '',
      pricePerNight: (json['pricePerNight'] ?? 0).toDouble(),
      capacity: json['capacity'] ?? 0,
      numberOfRooms: json['numberOfRooms'] ?? 0,
      guestsAllocated: json['guestsAllocated'] ?? 0,
      totalCost: (json['totalCost'] ?? 0).toDouble(),
      amenities: json['amenities'] != null 
          ? List<String>.from(json['amenities']) 
          : [],
    );
  }
}

// Accommodation Option Model - Matches actual API response
class AccommodationOption {
  final String id;
  final String providerId;
  final String name;
  final String location;
  final String? providerName;
  final String? description;
  final List<String> mediaUrls;
  final double avgRating;
  final int totalReviews;
  final List<String> amenities;
  final List<RoomAllocation> roomAllocations;
  final double totalCost;
  final int totalGuests;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int numberOfNights;

  AccommodationOption({
    required this.id,
    required this.providerId,
    required this.name,
    required this.location,
    this.providerName,
    this.description,
    required this.mediaUrls,
    required this.avgRating,
    required this.totalReviews,
    required this.amenities,
    required this.roomAllocations,
    required this.totalCost,
    required this.totalGuests,
    required this.checkInDate,
    required this.checkOutDate,
    required this.numberOfNights,
  });

  factory AccommodationOption.fromJson(Map<String, dynamic> json) {
    return AccommodationOption(
      id: json['id']?.toString() ?? '',
      providerId: json['providerId'] ?? '',
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      providerName: json['providerName'],
      description: json['description'],
      mediaUrls: List<String>.from(json['mediaUrls'] ?? []),
      avgRating: (json['avgRating'] ?? 0).toDouble(),
      totalReviews: json['totalReviews'] ?? 0,
      amenities: json['amenities'] != null 
          ? List<String>.from(json['amenities']) 
          : [],
      roomAllocations: (json['roomAllocations'] as List?)
              ?.map((room) => RoomAllocation.fromJson(room))
              .toList() ??
          [],
      totalCost: (json['totalCost'] ?? 0).toDouble(),
      totalGuests: json['totalGuests'] ?? 0,
      checkInDate: json['checkInDate'] != null
          ? DateTime.parse(json['checkInDate'])
          : DateTime.now(),
      checkOutDate: json['checkOutDate'] != null
          ? DateTime.parse(json['checkOutDate'])
          : DateTime.now(),
      numberOfNights: json['numberOfNights'] ?? 0,
    );
  }
}

// Location Coordinates Model
class LocationCoordinates {
  final double lat;
  final double lng;

  LocationCoordinates({
    required this.lat,
    required this.lng,
  });

  factory LocationCoordinates.fromJson(Map<String, dynamic> json) {
    return LocationCoordinates(
      lat: (json['lat'] ?? 0).toDouble(),
      lng: (json['lng'] ?? 0).toDouble(),
    );
  }
}

// Activity Location Model
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

// Opening Hours Model
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
      weekdayText: json['weekdayText'] != null 
          ? List<String>.from(json['weekdayText']) 
          : null,
    );
  }
}

// Place Review Model
class PlaceReview {
  final String author;
  final int rating;
  final String text;
  final String time;

  PlaceReview({
    required this.author,
    required this.rating,
    required this.text,
    required this.time,
  });

  factory PlaceReview.fromJson(Map<String, dynamic> json) {
    return PlaceReview(
      author: json['author'] ?? '',
      rating: json['rating'] ?? 0,
      text: json['text'] ?? '',
      time: json['time'] ?? '',
    );
  }
}

// Place Details Model (Google Places API data)
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
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      userRatingsTotal: json['userRatingsTotal'],
      priceLevel: json['priceLevel'],
      openingHours: json['openingHours'] != null 
          ? OpeningHours.fromJson(json['openingHours']) 
          : null,
      website: json['website'],
      phoneNumber: json['phoneNumber'],
      photos: json['photos'] != null ? List<String>.from(json['photos']) : null,
      reviews: json['reviews'] != null
          ? (json['reviews'] as List).map((r) => PlaceReview.fromJson(r)).toList()
          : null,
    );
  }
}

// Itinerary Activity Model
class ItineraryActivity {
  final String time;
  final String title;
  final String description;
  final ActivityLocation location;
  final int duration;
  final double estimatedCost;
  final String category;
  final String mapUrl;
  final String? tips;
  final bool bookingRequired;
  final PlaceDetails? placeDetails;

  ItineraryActivity({
    required this.time,
    required this.title,
    required this.description,
    required this.location,
    required this.duration,
    required this.estimatedCost,
    required this.category,
    required this.mapUrl,
    this.tips,
    required this.bookingRequired,
    this.placeDetails,
  });

  factory ItineraryActivity.fromJson(Map<String, dynamic> json) {
    return ItineraryActivity(
      time: json['time'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      location: ActivityLocation.fromJson(json['location'] ?? {}),
      duration: json['duration'] ?? 0,
      estimatedCost: (json['estimatedCost'] ?? 0).toDouble(),
      category: json['category'] ?? '',
      mapUrl: json['mapUrl'] ?? '',
      tips: json['tips'],
      bookingRequired: json['bookingRequired'] ?? false,
      placeDetails: json['placeDetails'] != null 
          ? PlaceDetails.fromJson(json['placeDetails']) 
          : null,
    );
  }
}

// Day Itinerary Model
class DayItinerary {
  final int day;
  final String date;
  final String dayOfWeek;
  final String theme;
  final int totalDuration;
  final double totalEstimatedCost;
  final List<ItineraryActivity> activities;

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
      date: json['date'] ?? '',
      dayOfWeek: json['dayOfWeek'] ?? '',
      theme: json['theme'] ?? '',
      totalDuration: json['totalDuration'] ?? 0,
      totalEstimatedCost: (json['totalEstimatedCost'] ?? 0).toDouble(),
      activities: (json['activities'] as List?)
              ?.map((activity) => ItineraryActivity.fromJson(activity))
              .toList() ??
          [],
    );
  }
}

// Trip Summary Cost Breakdown Model
class TripCostBreakdown {
  final double transportation;
  final double accommodation;
  final double activities;
  final double meals;
  final double total;

  TripCostBreakdown({
    required this.transportation,
    required this.accommodation,
    required this.activities,
    required this.meals,
    required this.total,
  });

  factory TripCostBreakdown.fromJson(Map<String, dynamic> json) {
    return TripCostBreakdown(
      transportation: (json['transportation'] ?? 0).toDouble(),
      accommodation: (json['accommodation'] ?? 0).toDouble(),
      activities: (json['activities'] ?? 0).toDouble(),
      meals: (json['meals'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
    );
  }
}

// Trip Summary Model
class TripSummary {
  final int totalDays;
  final int totalNights;
  final TripCostBreakdown estimatedTotalCost;
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
      estimatedTotalCost: TripCostBreakdown.fromJson(json['estimatedTotalCost'] ?? {}),
      remainingBudget: (json['remainingBudget'] ?? 0).toDouble(),
      budgetStatus: json['budgetStatus'] ?? 'unknown',
    );
  }
}

// Activity Model (simplified for backward compatibility)
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
      estimatedCost: (json['estimatedCost'] ?? 0).toDouble(),
      duration: json['duration'] ?? 0,
      category: json['category'] ?? '',
    );
  }
}

// Plan Costs Model (deprecated - use TripCostBreakdown instead)
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
      transportation: (json['transportation'] ?? 0).toDouble(),
      accommodation: (json['accommodation'] ?? 0).toDouble(),
      activities: json['activities'] != null ? (json['activities'] as num).toDouble() : null,
      total: (json['total'] ?? 0).toDouble(),
    );
  }
}

// Trip Plan Model - Individual plan option
class TripPlan {
  final String optionId;
  final String planName;
  final String? description;
  final PlanCosts costs;
  final TransportationOption? outboundTransport;
  final TransportationOption? returnTransport;
  final AccommodationOption? accommodation;
  final List<Activity> activities;
  final bool isOptimal;
  final double optimizationScore;
  final List<String> warnings;

  TripPlan({
    required this.optionId,
    required this.planName,
    this.description,
    required this.costs,
    this.outboundTransport,
    this.returnTransport,
    this.accommodation,
    required this.activities,
    required this.isOptimal,
    required this.optimizationScore,
    required this.warnings,
  });

  factory TripPlan.fromJson(Map<String, dynamic> json) {
    return TripPlan(
      optionId: json['optionId']?.toString() ?? '',
      planName: json['planName'] ?? '',
      description: json['description'],
      costs: PlanCosts.fromJson(json['costs'] ?? {}),
      outboundTransport: json['outboundTransport'] != null
          ? TransportationOption.fromJson(json['outboundTransport'])
          : null,
      returnTransport: json['returnTransport'] != null
          ? TransportationOption.fromJson(json['returnTransport'])
          : null,
      accommodation: json['accommodation'] != null
          ? AccommodationOption.fromJson(json['accommodation'])
          : null,
      activities: (json['activities'] as List?)
              ?.map((activity) => Activity.fromJson(activity))
              .toList() ??
          [],
      isOptimal: json['isOptimal'] ?? false,
      optimizationScore: (json['optimizationScore'] ?? 0).toDouble(),
      warnings: List<String>.from(json['warnings'] ?? []),
    );
  }

  // Backward compatibility getters
  AccommodationOption? get accommodationDetails => accommodation;
  TransportationOption? get outboundTransportation => outboundTransport;
  TransportationOption? get returnTransportation => returnTransport;
}

// Transportation Options Container
class TransportationOptions {
  final List<TransportationOption> outbound;
  final List<TransportationOption> return_;

  TransportationOptions({
    required this.outbound,
    required this.return_,
  });

  factory TransportationOptions.fromJson(Map<String, dynamic> json) {
    return TransportationOptions(
      outbound: (json['outbound'] as List?)
              ?.map((option) => TransportationOption.fromJson(option))
              .toList() ??
          [],
      return_: (json['return'] as List?)
              ?.map((option) => TransportationOption.fromJson(option))
              .toList() ??
          [],
    );
  }
}

// Trip Plan Response Data Model - Main API response structure
class TripPlanResponseData {
  final TransportationOptions transportationOptions;
  final List<AccommodationOption> accommodationOptions;
  final List<DayItinerary> itinerary;
  final TripSummary tripSummary;

  TripPlanResponseData({
    required this.transportationOptions,
    required this.accommodationOptions,
    required this.itinerary,
    required this.tripSummary,
  });

  factory TripPlanResponseData.fromJson(Map<String, dynamic> json) {
    return TripPlanResponseData(
      transportationOptions: TransportationOptions.fromJson(
        json['transportationOptions'] ?? {}
      ),
      accommodationOptions: (json['accommodationOptions'] as List?)
              ?.map((option) => AccommodationOption.fromJson(option))
              .toList() ??
          [],
      itinerary: (json['itinerary'] as List?)
              ?.map((day) => DayItinerary.fromJson(day))
              .toList() ??
          [],
      tripSummary: TripSummary.fromJson(json['tripSummary'] ?? {}),
    );
  }
}

// API Metadata Model
class ApiMetadata {
  final double requestedBudget;
  final String budgetCurrency;
  final bool specialRequirementsApplied;
  final DateTime requestProcessedAt;
  final int apiCallsUsed;

  ApiMetadata({
    required this.requestedBudget,
    required this.budgetCurrency,
    required this.specialRequirementsApplied,
    required this.requestProcessedAt,
    required this.apiCallsUsed,
  });

  factory ApiMetadata.fromJson(Map<String, dynamic> json) {
    return ApiMetadata(
      requestedBudget: (json['requestedBudget'] ?? 0).toDouble(),
      budgetCurrency: json['budgetCurrency'] ?? 'PKR',
      specialRequirementsApplied: json['specialRequirementsApplied'] ?? false,
      requestProcessedAt: json['requestProcessedAt'] != null
          ? DateTime.parse(json['requestProcessedAt'])
          : DateTime.now(),
      apiCallsUsed: json['apiCallsUsed'] ?? 0,
    );
  }
}

// Trip Plan Response Model - Handles actual API response
class TripPlanResponse {
  final bool success;
  final Map<String, dynamic> availableOptions;
  final List<TripPlan> recommendedPlans;
  final TripPlan? optimalPlan;
  final ApiMetadata metadata;
  final TripPlanResponseData? itineraryData;

  TripPlanResponse({
    required this.success,
    required this.availableOptions,
    required this.recommendedPlans,
    this.optimalPlan,
    required this.metadata,
    this.itineraryData,
  });

  factory TripPlanResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    
    return TripPlanResponse(
      success: json['success'] ?? false,
      availableOptions: data['availableOptions'] ?? {},
      recommendedPlans: (data['recommendedPlans'] as List?)
              ?.map((plan) => TripPlan.fromJson(plan))
              .toList() ??
          [],
      optimalPlan: data['optimalPlan'] != null
          ? TripPlan.fromJson(data['optimalPlan'])
          : null,
      metadata: ApiMetadata.fromJson(json['metadata'] ?? {}),
      itineraryData: data['itinerary'] != null
          ? TripPlanResponseData.fromJson(data)
          : null,
    );
  }

  // Helper getters for available options
  List<TransportationOption> get outboundTransportation =>
      (availableOptions['outboundTransportation'] as List?)
          ?.map((option) => TransportationOption.fromJson(option))
          .toList() ??
      [];

  List<TransportationOption> get returnTransportation =>
      (availableOptions['returnTransportation'] as List?)
          ?.map((option) => TransportationOption.fromJson(option))
          .toList() ??
      [];

  List<AccommodationOption> get accommodations =>
      (availableOptions['accommodations'] as List?)
          ?.map((option) => AccommodationOption.fromJson(option))
          .toList() ??
      [];

  List<Activity> get activities =>
      (availableOptions['activities'] as List?)
          ?.map((activity) => Activity.fromJson(activity))
          .toList() ??
      [];

  // Itinerary data (if available)
  List<DayItinerary> get itinerary => itineraryData?.itinerary ?? [];

  TripSummary? get tripSummary => itineraryData?.tripSummary;
}

// Saved Plan Model
class SavedTripPlan {
  final int id;
  final String planName;
  final String? description;
  final String status;
  final double totalCost;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;
  final TripPlan? planDetails;

  SavedTripPlan({
    required this.id,
    required this.planName,
    this.description,
    required this.status,
    required this.totalCost,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
    this.planDetails,
  });

  factory SavedTripPlan.fromJson(Map<String, dynamic> json) {
    return SavedTripPlan(
      id: json['id'] ?? 0,
      planName: json['planName'] ?? '',
      description: json['description'],
      status: json['status'] ?? 'draft',
      totalCost: (json['totalCost'] ?? 0).toDouble(),
      tags: List<String>.from(json['tags'] ?? []),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      planDetails: json['planDetails'] != null
          ? TripPlan.fromJson(json['planDetails'])
          : null,
    );
  }
}
