import 'package:flutter/material.dart';
import 'package:tour_ease/model/tripPlanner/tripPlannerModels.dart';
import 'package:tour_ease/utils/trip_plan_formatter.dart';

/// This example demonstrates how to use TripPlanFormatter in a real Flutter widget
/// to save a trip plan with the proper API request format.

class SaveTripPlanExample extends StatelessWidget {
  final TripPlannerResponse tripResults;
  final TransportOption selectedOutbound;
  final TransportOption selectedReturn;
  final AccommodationOption selectedAccommodation;
  final List<RoomSelection> roomSelections;
  final TripSearchParams originalSearchParams;

  const SaveTripPlanExample({
    Key? key,
    required this.tripResults,
    required this.selectedOutbound,
    required this.selectedReturn,
    required this.selectedAccommodation,
    required this.roomSelections,
    required this.originalSearchParams,
  }) : super(key: key);

  /// This method shows the complete flow of saving a trip plan
  void saveTripPlan(BuildContext context) {
    // Step 1: Create the properly formatted SavePlanRequest using TripPlanFormatter
    final saveRequest = TripPlanFormatter.createSavePlanRequest(
      planName: 'My Lahore Weekend Trip',
      description: 'A wonderful weekend getaway to explore Lahore',
      selectedOutbound: selectedOutbound,
      selectedReturn: selectedReturn,
      selectedAccommodation: selectedAccommodation,
      selectedRoomAllocations: roomSelections,
      selectedActivities: [], // Add activity IDs if user selected any
      tags: ['weekend', 'cultural', 'lahore'], // Optional tags
      originalSearchParams: originalSearchParams,
      fullTripResults: tripResults,
    );

    // Step 2: Validate the request before sending
    if (!TripPlanFormatter.validateSavePlanRequest(saveRequest)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Invalid plan data'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Step 3: Format for API request
    final apiRequestBody = TripPlanFormatter.formatForApiRequest(saveRequest);

    // Step 4: Send to your backend API
    // Example: await apiService.savePlan(apiRequestBody);
    
    // For demonstration, print the request structure
    debugPrint('API Request Body:');
    debugPrint('Plan Name: ${apiRequestBody['planName']}');
    debugPrint('Total Cost: ${apiRequestBody['totalCost']}');
    debugPrint('Outbound Transport ID: ${apiRequestBody['selectedOutboundId']}');
    debugPrint('Return Transport ID: ${apiRequestBody['selectedReturnId']}');
    debugPrint('Accommodation ID: ${apiRequestBody['selectedAccommodationId']}');
    debugPrint('Number of Room Types: ${apiRequestBody['selectedRoomAllocations'].length}');
    debugPrint('Has Full Trip Data: ${apiRequestBody['searchResultsData'] != null}');

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Trip plan saved successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  /// Alternative: Save using the optimal/best plan
  void saveOptimalPlan(BuildContext context) {
    try {
      final saveRequest = TripPlanFormatter.createSavePlanRequestFromOptimal(
        customPlanName: 'Best Value - Lahore Trip',
        customDescription: 'System recommended optimal trip',
        selectedActivities: [],
        tags: ['optimal', 'recommended'],
        fullTripResults: tripResults,
        originalSearchParams: originalSearchParams,
      );

      if (!TripPlanFormatter.validateSavePlanRequest(saveRequest)) {
        throw Exception('Invalid optimal plan data');
      }

      final apiRequestBody = TripPlanFormatter.formatForApiRequest(saveRequest);
      
      // Send to API
      // await apiService.savePlan(apiRequestBody);

      debugPrint('Optimal plan saved successfully');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Save Trip Plan Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => saveTripPlan(context),
              child: const Text('Save Custom Plan'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => saveOptimalPlan(context),
              child: const Text('Save Optimal Plan'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Example of the resulting API request structure
/// 
/// The TripPlanFormatter.formatForApiRequest() method produces:
/// 
/// ```json
/// {
///   "planName": "My Lahore Weekend Trip",
///   "description": "A wonderful weekend getaway to explore Lahore",
///   "selectedOutboundId": 993,
///   "selectedReturnId": 1103,
///   "selectedAccommodationId": 51,
///   "selectedRoomAllocations": [
///     {"roomId": 259, "numberOfRooms": 1},
///     {"roomId": 260, "numberOfRooms": 1},
///     {"roomId": 262, "numberOfRooms": 1}
///   ],
///   "selectedActivities": [],
///   "totalCost": 78736,
///   "tags": ["weekend", "cultural", "lahore"],
///   "originalSearchParams": {
///     "startLocation": "islamabad",
///     "endLocation": "Lahor",
///     "startTime": "2025-11-21T22:00:00.000Z",
///     "endTime": "2025-11-24T17:00:00.000Z",
///     "budget": 499100,
///     "numberOfTravelers": 2,
///     "interests": [],
///     "needsReturnTransport": true
///   },
///   "status": "saved",
///   "startLocation": "islamabad",
///   "endLocation": "Lahor",
///   "startTime": "2025-11-21T22:00:00.000Z",
///   "endTime": "2025-11-24T17:00:00.000Z",
///   "numberOfTravelers": 2,
///   "budget": 499100,
///   "interests": [],
///   "needsReturnTransport": true,
///   "searchResultsData": {
///     "transportationOptions": { /* full data */ },
///     "accommodationOptions": [ /* full data */ ],
///     "itinerary": [ /* full data */ ],
///     "tripSummary": { /* full data */ },
///     "requestSummary": { /* full data */ },
///     "availableOptions": { /* full data */ },
///     "recommendedPlans": [ /* full data */ ],
///     "optimalPlan": { /* full data */ }
///   }
/// }
/// ```
