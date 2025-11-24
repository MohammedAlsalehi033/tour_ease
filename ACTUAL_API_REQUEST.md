# Actual API Request When Clicking "Save Plan"

## API Endpoint
```
POST /api/planner/saved
```

## Request Flow
1. User clicks **"Save Plan"** button in `ConfirmTripPage`
2. `TripPlanFormatter.createSavePlanRequest()` creates a `SavePlanRequest` object
3. `TripPlannerBloc` dispatches `SaveTripPlan` event
4. `TripPlannerRepository.savePlan()` calls API with `request.toJson()`

## Actual JSON Body Sent to API

```json
{
  "planName": "My Trip Plan",
  "description": "Optional description",
  "selectedOutboundId": 993,
  "selectedReturnId": 1103,
  "selectedAccommodationId": 51,
  "selectedRoomAllocations": [
    {
      "roomId": 259,
      "numberOfRooms": 1
    },
    {
      "roomId": 260,
      "numberOfRooms": 1
    },
    {
      "roomId": 262,
      "numberOfRooms": 1
    }
  ],
  "selectedActivities": [],
  "totalCost": 830536,
  "tags": [],
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
    "transportationOptions": {
      "outbound": [...],
      "return": [...]
    },
    "accommodationOptions": [...],
    "itinerary": [...],
    "tripSummary": {...},
    "availableOptions": {...},
    "recommendedPlans": [...],
    "optimalPlan": {...}
  }
}
```

## Key Fields Explained

| Field | Type | Source | Description |
|-------|------|--------|-------------|
| `planName` | string | User input or `optimalPlan.planName` | Name of the saved plan |
| `description` | string? | Optional user input | Plan description |
| `selectedOutboundId` | int | Selected `TransportOption.id` | Outbound transport ID |
| `selectedReturnId` | int? | Selected `TransportOption.id` | Return transport ID (optional) |
| `selectedAccommodationId` | int | Selected `AccommodationOption.id` | Accommodation ID |
| `selectedRoomAllocations` | array | User selections | Room IDs and quantities |
| `selectedActivities` | array | User selections | Activity IDs (empty by default) |
| `totalCost` | number | Calculated | Sum of transport + accommodation costs |
| `tags` | array | User input | Custom tags (empty by default) |
| `originalSearchParams` | object | From `TripSearchParams` | Original search criteria |
| **`status`** | string | **"saved"** | Status of plan (saved/booked) |
| `startLocation` | string | Duplicated from `originalSearchParams` | Starting city |
| `endLocation` | string | Duplicated from `originalSearchParams` | Destination city |
| `startTime` | string | Duplicated from `originalSearchParams` | ISO 8601 start date/time |
| `endTime` | string | Duplicated from `originalSearchParams` | ISO 8601 end date/time |
| `numberOfTravelers` | int | Duplicated from `originalSearchParams` | Number of travelers |
| `budget` | number | Duplicated from `originalSearchParams` | Budget in PKR |
| `interests` | array | Duplicated from `originalSearchParams` | User interests |
| `needsReturnTransport` | bool | Duplicated from `originalSearchParams` | Return transport required |
| **`searchResultsData`** | object | **Complete `TripPlannerResponse.toJson()`** | **Full trip search results** |

## Code Location

**Repository Method** (sends the request):
```dart
// lib/model/tripPlanner/tripPlannerRepository.dart:91
Future<SavedPlan> savePlan(SavePlanRequest request) async {
  try {
    return await apiService.post<SavedPlan>(
      path: "/api/planner/saved",
      body: request.toJson(), // ← This creates the JSON above
      fromJson: (json) => SavedPlan.fromJson(json),
    );
  } catch (e) {
    throw Exception('Failed to save trip plan: $e');
  }
}
```

**Model toJson() Method** (creates the JSON):
```dart
// lib/model/tripPlanner/tripPlannerModels.dart:1142
Map<String, dynamic> toJson() => {
  'planName': planName,
  if (description != null) 'description': description,
  'selectedOutboundId': selectedOutboundId,
  if (selectedReturnId != null) 'selectedReturnId': selectedReturnId,
  'selectedAccommodationId': selectedAccommodationId,
  'selectedRoomAllocations': selectedRoomAllocations.map((e) => e.toJson()).toList(),
  if (selectedActivities != null) 'selectedActivities': selectedActivities,
  'totalCost': totalCost,
  if (tags != null) 'tags': tags,
  'originalSearchParams': originalSearchParams.toJson(),
  'status': status, // ← Now included!
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
```

## What Changed

✅ **FIXED**: Added `status` field to `SavePlanRequest` model
- Now defaults to `"saved"` when creating a SavePlanRequest
- Included in the `toJson()` output sent to the API

## Testing

To verify the API request, you can add debug logging in the repository:

```dart
Future<SavedPlan> savePlan(SavePlanRequest request) async {
  try {
    final body = request.toJson();
    print('═══ SAVE PLAN API REQUEST ═══');
    print(jsonEncode(body)); // Shows exact JSON being sent
    print('═════════════════════════════');
    
    return await apiService.post<SavedPlan>(
      path: "/api/planner/saved",
      body: body,
      fromJson: (json) => SavedPlan.fromJson(json),
    );
  } catch (e) {
    throw Exception('Failed to save trip plan: $e');
  }
}
```

Now the request matches your expected format! 🎉
