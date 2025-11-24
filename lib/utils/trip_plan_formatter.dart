import 'package:tour_ease/model/tripPlanner/tripPlannerModels.dart';

/// Utility class to format trip plan data for API requests
class TripPlanFormatter {
  /// Creates a properly formatted SavePlanRequest from selected options
  /// 
  /// This formats the data to match the expected API structure with:
  /// - Basic plan info (name, description)
  /// - Selected IDs for transport and accommodation
  /// - Room allocations
  /// - Cost calculations
  /// - Original search parameters
  /// - Full search results data for reference
  static SavePlanRequest createSavePlanRequest({
    required String planName,
    String? description,
    required TransportOption selectedOutbound,
    required TransportOption selectedReturn,
    required AccommodationOption selectedAccommodation,
    List<RoomSelection>? selectedRoomAllocations,
    List<int>? selectedActivities,
    List<String>? tags,
    required TripSearchParams originalSearchParams,
    required TripPlannerResponse fullTripResults,
  }) {
    // Calculate total cost from selected options
    final totalCost = (selectedOutbound.totalCost) +
        (selectedReturn.totalCost) +
        (selectedAccommodation.totalCost);

    // Create the save request with full data
    return SavePlanRequest(
      planName: planName,
      description: description,
      selectedOutboundId: selectedOutbound.id,
      selectedReturnId: selectedReturn.id,
      selectedAccommodationId: selectedAccommodation.id,
      selectedRoomAllocations: selectedRoomAllocations ?? [],
      selectedActivities: selectedActivities ?? [],
      totalCost: totalCost,
      tags: tags ?? [],
      originalSearchParams: originalSearchParams,
      searchResultsData: fullTripResults.toJson(), // Store complete trip results
    );
  }

  /// Creates a SavePlanRequest from the optimal/best plan
  /// 
  /// This is useful when the user wants to save the recommended best option
  static SavePlanRequest createSavePlanRequestFromOptimal({
    String? customPlanName,
    String? customDescription,
    List<int>? selectedActivities,
    List<String>? tags,
    required TripPlannerResponse fullTripResults,
    required TripSearchParams originalSearchParams,
  }) {
    if (fullTripResults.optimalPlan == null) {
      throw Exception('No optimal plan available in trip results');
    }

    final optimalPlan = fullTripResults.optimalPlan!;
    
    // Validate required data
    if (optimalPlan.outboundTransport == null) {
      throw Exception('Optimal plan missing outbound transport');
    }
    if (optimalPlan.accommodation == null) {
      throw Exception('Optimal plan missing accommodation');
    }

    return SavePlanRequest(
      planName: customPlanName ?? optimalPlan.planName,
      description: customDescription ?? optimalPlan.description,
      selectedOutboundId: optimalPlan.outboundTransport!.id,
      selectedReturnId: optimalPlan.returnTransport?.id,
      selectedAccommodationId: optimalPlan.accommodation!.id,
      selectedRoomAllocations: optimalPlan.accommodation!.roomAllocations
          .map((room) => RoomSelection(
                roomId: room.roomId,
                numberOfRooms: room.numberOfRooms,
              ))
          .toList(),
      selectedActivities: selectedActivities ?? [],
      totalCost: optimalPlan.costs.total,
      tags: tags ?? [],
      originalSearchParams: originalSearchParams,
      searchResultsData: fullTripResults.toJson(),
    );
  }

  /// Validates that a SavePlanRequest has all required data
  static bool validateSavePlanRequest(SavePlanRequest request) {
    if (request.planName.isEmpty) return false;
    if (request.selectedOutboundId <= 0) return false;
    if (request.selectedAccommodationId <= 0) return false;
    if (request.totalCost <= 0) return false;
    return true;
  }

  /// Creates a formatted map for the API request body
  /// 
  /// This returns the exact structure expected by the backend API
  /// matching the JSON format you provided in your user request
  static Map<String, dynamic> formatForApiRequest(SavePlanRequest request) {
    final json = request.toJson();
    
    // Ensure the structure matches your API expectations
    return {
      'planName': json['planName'],
      'description': json['description'],
      'selectedOutboundId': json['selectedOutboundId'],
      'selectedReturnId': json['selectedReturnId'],
      'selectedAccommodationId': json['selectedAccommodationId'],
      'selectedRoomAllocations': json['selectedRoomAllocations'],
      'selectedActivities': json['selectedActivities'] ?? [],
      'totalCost': json['totalCost'],
      'tags': json['tags'] ?? [],
      'originalSearchParams': json['originalSearchParams'],
      'status': 'saved', // Default status for saved plans
      'startLocation': json['startLocation'],
      'endLocation': json['endLocation'],
      'startTime': json['startTime'],
      'endTime': json['endTime'],
      'numberOfTravelers': json['numberOfTravelers'],
      'budget': json['budget'],
      'interests': json['interests'],
      'needsReturnTransport': json['needsReturnTransport'],
      'searchResultsData': json['searchResultsData'],
    };
  }

  /// Extracts key trip information for display/logging
  static Map<String, dynamic> getTripSummary(SavePlanRequest request) {
    return {
      'planName': request.planName,
      'totalCost': request.totalCost,
      'destination': request.originalSearchParams.endLocation,
      'startDate': request.originalSearchParams.startTime.toIso8601String(),
      'endDate': request.originalSearchParams.endTime.toIso8601String(),
      'travelers': request.originalSearchParams.numberOfTravelers,
      'hasReturnTransport': request.selectedReturnId != null,
      'numberOfRooms': request.selectedRoomAllocations.length,
    };
  }
}
