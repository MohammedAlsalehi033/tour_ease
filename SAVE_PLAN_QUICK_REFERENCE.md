# Save Plan API Implementation - Quick Reference

## What Was Done

✅ **Updated `TripPlannerResponse.toJson()` to include complete search results**
- Now serializes ALL trip data instead of just minimal summary
- Includes all transportation options, accommodations, activities, itinerary, and trip summary
- Provides complete data for `searchResultsData` field

✅ **Verified `SavePlanRequest` structure matches specification**
- Includes all required fields
- Properly formats room allocations
- Duplicates search params at top level for backend convenience
- Defaults `status` to "saved"

## Files Modified

### `/lib/model/tripPlanner/tripPlannerModels.dart`
- **Updated:** `TripPlannerResponse.toJson()` method (line ~638)
- **Verified:** `SavePlanRequest.toJson()` method (line ~1441)

## API Request Structure

When clicking "Save Plan", the following JSON is sent to `POST /api/planner/saved`:

```json
{
  "planName": "string",
  "description": "string?",
  "selectedOutboundId": 123,
  "selectedReturnId": 456,
  "selectedAccommodationId": 789,
  "selectedRoomAllocations": [
    {"roomId": 101, "numberOfRooms": 1}
  ],
  "selectedActivities": [],
  "totalCost": 150000,
  "tags": ["adventure", "nature"],
  "status": "saved",
  
  // Duplicated from originalSearchParams
  "startLocation": "Islamabad",
  "endLocation": "Skardu",
  "startTime": "2025-12-01T08:00:00.000Z",
  "endTime": "2025-12-05T18:00:00.000Z",
  "numberOfTravelers": 2,
  "budget": 200000,
  "interests": ["adventure", "nature"],
  "needsReturnTransport": true,
  
  // Original search parameters (preserved)
  "originalSearchParams": {
    "startLocation": "Islamabad",
    "endLocation": "Skardu",
    "startTime": "2025-12-01T08:00:00.000Z",
    "endTime": "2025-12-05T18:00:00.000Z",
    "numberOfTravelers": 2,
    "budget": 200000,
    "interests": ["adventure", "nature"],
    "needsReturnTransport": true
  },
  
  // COMPLETE trip search results
  "searchResultsData": {
    "requestSummary": { /* ... */ },
    "availableOptions": {
      "outboundTransportation": [ /* complete list */ ],
      "returnTransportation": [ /* complete list */ ],
      "accommodations": [ /* complete list */ ],
      "activities": [ /* complete list */ ]
    },
    "recommendedPlans": [ /* all plans */ ],
    "optimalPlan": { /* best plan */ },
    "itinerary": [ /* day-by-day activities */ ],
    "tripSummary": { /* cost breakdown */ }
  }
}
```

## How to Use

### In ConfirmTripPage

```dart
import 'package:tour_ease/utils/trip_plan_formatter.dart';

void _savePlan() {
  final originalRequest = context.read<TripPlannerBloc>().state.originalRequest;
  
  final saveRequest = TripPlanFormatter.createSavePlanRequest(
    planName: 'My Trip Plan',
    description: 'Optional description',
    selectedOutbound: widget.outbound!,
    selectedReturn: widget.returnTransport!,
    selectedAccommodation: widget.accommodation!,
    selectedRoomAllocations: widget.selectedRoomAllocations,
    selectedActivities: [],
    tags: originalRequest.interests,
    originalSearchParams: originalRequest,
    fullTripResults: widget.tripPlan,  // Complete response
  );

  context.read<TripPlannerBloc>().add(
    SaveTripPlan(request: saveRequest),
  );
}
```

## Key Features

1. **Complete Data Preservation**
   - Entire trip search response stored in `searchResultsData`
   - Allows full reconstruction of saved plans
   - Enables backend analysis and optimization

2. **Room Allocations**
   - Properly formatted as `{roomId, numberOfRooms}`
   - Matches room selection structure

3. **Status Field**
   - Always "saved" when clicking "Save Plan"
   - Changes to "booked" after payment

4. **Search Params Duplication**
   - Top-level fields for easy backend queries
   - Nested `originalSearchParams` for complete data

## Testing

To verify the API request, add logging in repository:

```dart
Future<SavedPlan> savePlan(SavePlanRequest request) async {
  final body = request.toJson();
  print(JsonEncoder.withIndent('  ').convert(body));
  
  return await apiService.post<SavedPlan>(
    path: "/api/planner/saved",
    body: body,
    fromJson: (json) => SavedPlan.fromJson(json),
  );
}
```

## Documentation

See `SAVE_PLAN_API_REQUEST_COMPLETE.md` for:
- Complete field descriptions
- Data flow diagram
- Implementation details
- Example responses

## Status

✅ Implementation complete
✅ Matches specification exactly
✅ All fields included
✅ searchResultsData contains complete trip data
✅ Ready for production use
