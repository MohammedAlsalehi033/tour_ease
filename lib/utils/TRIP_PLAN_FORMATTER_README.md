# Trip Plan Formatter Utility

This utility helps format trip plan data for API requests when saving or booking trip plans in the Tour Ease app.

## Purpose

The `TripPlanFormatter` class provides helper methods to:
- Create properly formatted `SavePlanRequest` objects
- Validate save plan requests before sending to the API
- Format data to match the expected API structure
- Extract trip summaries for display/logging

## When to Use

Use `TripPlanFormatter` whenever you need to save a trip plan, particularly in:
- `ConfirmTripPage` when the user clicks "Save Plan"
- `TripResultsPage` when quickly saving the optimal plan
- Any custom booking flow where trip data needs to be persisted

## Key Methods

### 1. `createSavePlanRequest()`

Creates a formatted `SavePlanRequest` from user-selected options.

**Use case**: User has manually selected transport, accommodation, and rooms.

```dart
final saveRequest = TripPlanFormatter.createSavePlanRequest(
  planName: 'My Trip to Lahore',
  description: 'Weekend getaway',
  selectedOutbound: selectedOutboundTransport,
  selectedReturn: selectedReturnTransport,
  selectedAccommodation: selectedHotel,
  selectedRoomAllocations: roomSelections,
  selectedActivities: [],
  tags: ['weekend', 'cultural'],
  originalSearchParams: searchParams,
  fullTripResults: tripResults,
);
```

### 2. `createSavePlanRequestFromOptimal()`

Creates a `SavePlanRequest` using the system's optimal/best recommended plan.

**Use case**: User wants to save the "Best Match" option without custom selections.

```dart
final saveRequest = TripPlanFormatter.createSavePlanRequestFromOptimal(
  customPlanName: 'Best Value Trip',
  fullTripResults: tripResults,
  originalSearchParams: searchParams,
);
```

### 3. `formatForApiRequest()`

Converts a `SavePlanRequest` into the exact JSON structure expected by the backend API.

```dart
final apiBody = TripPlanFormatter.formatForApiRequest(saveRequest);
// Send apiBody to your backend
await api.post('/save-plan', body: apiBody);
```

### 4. `validateSavePlanRequest()`

Validates that a save plan request has all required data.

```dart
if (!TripPlanFormatter.validateSavePlanRequest(saveRequest)) {
  // Handle validation error
  showError('Invalid plan data');
  return;
}
```

## Expected API Request Structure

The formatter creates requests matching this structure:

```json
{
  "planName": "My Trip Plan",
  "description": "Description text",
  "selectedOutboundId": 993,
  "selectedReturnId": 1103,
  "selectedAccommodationId": 51,
  "selectedRoomAllocations": [
    {"roomId": 259, "numberOfRooms": 1},
    {"roomId": 260, "numberOfRooms": 1}
  ],
  "selectedActivities": [],
  "totalCost": 78736,
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
    // Complete trip results including:
    // - transportationOptions
    // - accommodationOptions
    // - itinerary
    // - tripSummary
    // - availableOptions
    // - recommendedPlans
    // - optimalPlan
  }
}
```

## searchResultsData Field

The `searchResultsData` field stores the **complete** trip planner response, including:
- All transportation options (outbound and return)
- All accommodation options
- Daily itinerary
- Trip summary with cost breakdowns
- Available activities
- Recommended trip plans
- The optimal/best plan

This allows the app to:
- Display saved plans with full details later
- Compare different saved plans
- Restore user's search and re-run if needed
- Show what options were available at the time of saving

## Usage in ConfirmTripPage

See the updated `_savePlan()` method in `confirm_trip_page.dart`:

```dart
void _savePlan() {
  // Get data from BLoC
  final originalRequest = context.read<TripPlannerBloc>().state.originalRequest;
  
  // Create formatted request
  final saveRequest = TripPlanFormatter.createSavePlanRequest(
    planName: widget.tripPlan.optimalPlan?.planName ?? 'My Trip Plan',
    description: widget.tripPlan.optimalPlan?.description,
    selectedOutbound: widget.outbound!,
    selectedReturn: widget.returnTransport!,
    selectedAccommodation: widget.accommodation!,
    selectedRoomAllocations: widget.selectedRoomAllocations,
    selectedActivities: [],
    tags: [],
    originalSearchParams: originalRequest,
    fullTripResults: widget.tripPlan,
  );

  // Validate before saving
  if (!TripPlanFormatter.validateSavePlanRequest(saveRequest)) {
    showError('Invalid plan data');
    return;
  }

  // Save via BLoC
  context.read<TripPlannerBloc>().add(
    SaveTripPlan(request: saveRequest),
  );
}
```

## Cost Calculation

The formatter automatically calculates the total cost from:
- Outbound transport cost
- Return transport cost  
- Accommodation cost

```dart
final totalCost = (selectedOutbound.totalCost) +
    (selectedReturn.totalCost) +
    (selectedAccommodation.totalCost);
```

## Room Allocations

Room allocations are formatted as:

```dart
List<RoomSelection> roomSelections = [
  RoomSelection(roomId: 259, numberOfRooms: 1),
  RoomSelection(roomId: 260, numberOfRooms: 1),
  // ... more rooms
];
```

Each room selection includes:
- `roomId`: The unique ID of the room type
- `numberOfRooms`: How many of this room type to book (quantity)

## Validation Rules

A valid save plan request must have:
- Non-empty plan name
- Valid outbound transport ID (> 0)
- Valid accommodation ID (> 0)
- Total cost greater than 0
- Valid original search parameters

## Benefits

Using `TripPlanFormatter`:
- ✅ Ensures consistent API request format
- ✅ Reduces code duplication across the app
- ✅ Provides validation before sending requests
- ✅ Makes it easy to add new fields in one place
- ✅ Keeps full trip context with `searchResultsData`
- ✅ Easier to test and maintain

## Migration from Direct SavePlanRequest

**Before:**
```dart
final saveRequest = SavePlanRequest(
  planName: 'My Plan',
  selectedOutboundId: outbound.id,
  selectedReturnId: returnTransport.id,
  selectedAccommodationId: accommodation.id,
  selectedRoomAllocations: rooms,
  totalCost: calculateCost(),
  originalSearchParams: params,
  searchResultsData: tripPlan.toJson(),
);
```

**After:**
```dart
final saveRequest = TripPlanFormatter.createSavePlanRequest(
  planName: 'My Plan',
  selectedOutbound: outbound,
  selectedReturn: returnTransport,
  selectedAccommodation: accommodation,
  selectedRoomAllocations: rooms,
  originalSearchParams: params,
  fullTripResults: tripPlan,
);
```

The formatter handles cost calculation and proper JSON formatting automatically.
