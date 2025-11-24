// ═══════════════════════════════════════════════════════════════════════════
// TRIP PLAN FORMATTER - QUICK REFERENCE
// ═══════════════════════════════════════════════════════════════════════════

import 'package:tour_ease/utils/trip_plan_formatter.dart';

// ───────────────────────────────────────────────────────────────────────────
// 1. CREATE SAVE REQUEST FROM USER SELECTIONS
// ───────────────────────────────────────────────────────────────────────────

final saveRequest = TripPlanFormatter.createSavePlanRequest(
  planName: 'My Trip',                      // Required: User's plan name
  description: 'Description',                // Optional: Plan description
  selectedOutbound: outboundTransport,       // Required: TransportOption
  selectedReturn: returnTransport,           // Required: TransportOption
  selectedAccommodation: accommodation,      // Required: AccommodationOption
  selectedRoomAllocations: roomSelections,   // Optional: List<RoomSelection>
  selectedActivities: [],                    // Optional: List<int> activity IDs
  tags: ['weekend', 'cultural'],             // Optional: List<String> tags
  originalSearchParams: searchParams,        // Required: TripSearchParams
  fullTripResults: tripResults,              // Required: TripPlannerResponse
);

// ───────────────────────────────────────────────────────────────────────────
// 2. CREATE FROM OPTIMAL/BEST PLAN
// ───────────────────────────────────────────────────────────────────────────

final saveRequest = TripPlanFormatter.createSavePlanRequestFromOptimal(
  customPlanName: 'Best Value Trip',         // Optional: Override plan name
  customDescription: 'System recommended',   // Optional: Override description
  selectedActivities: [],                    // Optional: Activity IDs
  tags: ['optimal'],                         // Optional: Tags
  fullTripResults: tripResults,              // Required: TripPlannerResponse
  originalSearchParams: searchParams,        // Required: TripSearchParams
);

// ───────────────────────────────────────────────────────────────────────────
// 3. VALIDATE BEFORE SENDING
// ───────────────────────────────────────────────────────────────────────────

if (!TripPlanFormatter.validateSavePlanRequest(saveRequest)) {
  // Handle validation error
  showError('Invalid plan data');
  return;
}

// ───────────────────────────────────────────────────────────────────────────
// 4. FORMAT FOR API REQUEST
// ───────────────────────────────────────────────────────────────────────────

final apiBody = TripPlanFormatter.formatForApiRequest(saveRequest);
// Returns Map<String, dynamic> ready for API

// Send to your backend:
await apiService.post('/api/save-plan', body: apiBody);

// ───────────────────────────────────────────────────────────────────────────
// 5. GET TRIP SUMMARY (for display/logging)
// ───────────────────────────────────────────────────────────────────────────

final summary = TripPlanFormatter.getTripSummary(saveRequest);
// Returns: {
//   'planName': 'My Trip',
//   'totalCost': 78736,
//   'destination': 'Lahore',
//   'startDate': '2025-11-21T22:00:00.000Z',
//   'endDate': '2025-11-24T17:00:00.000Z',
//   'travelers': 2,
//   'hasReturnTransport': true,
//   'numberOfRooms': 3
// }

// ═══════════════════════════════════════════════════════════════════════════
// API REQUEST STRUCTURE (what gets sent to backend)
// ═══════════════════════════════════════════════════════════════════════════

{
  "planName": "My Trip",
  "description": "Description",
  "selectedOutboundId": 993,
  "selectedReturnId": 1103,
  "selectedAccommodationId": 51,
  "selectedRoomAllocations": [
    {"roomId": 259, "numberOfRooms": 1},
    {"roomId": 260, "numberOfRooms": 1}
  ],
  "selectedActivities": [],
  "totalCost": 78736,
  "tags": ["weekend", "cultural"],
  "originalSearchParams": {
    "startLocation": "islamabad",
    "endLocation": "Lahor",
    "startTime": "2025-11-21T22:00:00.000Z",
    "endTime": "2025-11-24T17:00:00.000Z",
    "budget": 499100,
    "numberOfTravelers": 2,
    "interests": [],
    "needsReturnTransport": true
  },
  "status": "saved",
  "startLocation": "islamabad",
  "endLocation": "Lahor",
  "startTime": "2025-11-21T22:00:00.000Z",
  "endTime": "2025-11-24T17:00:00.000Z",
  "numberOfTravelers": 2,
  "budget": 499100,
  "interests": [],
  "needsReturnTransport": true,
  "searchResultsData": {
    // Complete TripPlannerResponse as JSON
    // Includes: transportationOptions, accommodationOptions,
    //           itinerary, tripSummary, availableOptions,
    //           recommendedPlans, optimalPlan
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// VALIDATION RULES
// ═══════════════════════════════════════════════════════════════════════════

✓ Plan name must not be empty
✓ Outbound transport ID must be > 0
✓ Accommodation ID must be > 0
✓ Total cost must be > 0
✓ Original search params must be valid

// ═══════════════════════════════════════════════════════════════════════════
// ROOM ALLOCATIONS FORMAT
// ═══════════════════════════════════════════════════════════════════════════

List<RoomSelection> roomSelections = [
  RoomSelection(roomId: 259, numberOfRooms: 1),  // 1x Deluxe Room
  RoomSelection(roomId: 260, numberOfRooms: 2),  // 2x Twin Deluxe
  RoomSelection(roomId: 262, numberOfRooms: 1),  // 1x Executive Room
];

// API format: [
//   {"roomId": 259, "numberOfRooms": 1},
//   {"roomId": 260, "numberOfRooms": 2},
//   {"roomId": 262, "numberOfRooms": 1}
// ]

// ═══════════════════════════════════════════════════════════════════════════
// COMPLETE EXAMPLE IN WIDGET
// ═══════════════════════════════════════════════════════════════════════════

void savePlan(BuildContext context) {
  // 1. Get data
  final bloc = context.read<TripPlannerBloc>();
  final originalRequest = bloc.state.originalRequest;
  
  // 2. Create request
  final saveRequest = TripPlanFormatter.createSavePlanRequest(
    planName: 'My Trip',
    selectedOutbound: selectedOutbound,
    selectedReturn: selectedReturn,
    selectedAccommodation: selectedAccommodation,
    selectedRoomAllocations: roomSelections,
    originalSearchParams: originalRequest,
    fullTripResults: tripResults,
  );
  
  // 3. Validate
  if (!TripPlanFormatter.validateSavePlanRequest(saveRequest)) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Invalid plan'), backgroundColor: Colors.red),
    );
    return;
  }
  
  // 4. Save via BLoC
  bloc.add(SaveTripPlan(request: saveRequest));
  
  // 5. Show feedback
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Saving plan...'), duration: Duration(seconds: 2)),
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// For more details, see:
// - lib/utils/TRIP_PLAN_FORMATTER_README.md (full documentation)
// - lib/utils/trip_plan_formatter_usage_example.dart (complete example)
// - TRIP_PLAN_FORMATTER_SUMMARY.md (overview)
// ═══════════════════════════════════════════════════════════════════════════
