# Summary: Trip Plan API Request Formatting

## What Was Created

I've created a comprehensive utility for formatting trip plan data for API requests when saving plans in your Tour Ease app.

## Files Created/Modified

### 1. **`lib/utils/trip_plan_formatter.dart`** (NEW)
The main utility class with the following methods:

- `createSavePlanRequest()` - Creates formatted request from user selections
- `createSavePlanRequestFromOptimal()` - Creates request from the best/optimal plan
- `validateSavePlanRequest()` - Validates request before sending
- `formatForApiRequest()` - Converts to exact API JSON structure
- `getTripSummary()` - Extracts key info for display/logging

### 2. **`lib/view/tripPlanner/confirm_trip_page.dart`** (MODIFIED)
Updated the `_savePlan()` method to:
- Use `TripPlanFormatter` for consistent formatting
- Add validation before saving
- Include proper error handling
- Provide user feedback

### 3. **`lib/utils/TRIP_PLAN_FORMATTER_README.md`** (NEW)
Complete documentation including:
- Purpose and usage
- All method descriptions
- Expected API structure
- Room allocation format
- Validation rules
- Migration guide

### 4. **`lib/utils/trip_plan_formatter_usage_example.dart`** (NEW)
Practical Flutter widget example showing:
- How to save custom plans
- How to save optimal plans
- Complete API request structure
- Error handling patterns

## Key Features

### Proper API Request Format
The formatter creates requests matching your exact JSON structure:

```json
{
  "planName": "plan plan",
  "description": "12345",
  "selectedOutboundId": 993,
  "selectedReturnId": 1103,
  "selectedAccommodationId": 51,
  "selectedRoomAllocations": [
    {"roomId": 259, "numberOfRooms": 1},
    ...
  ],
  "selectedActivities": [],
  "totalCost": 830536,
  "tags": [],
  "originalSearchParams": {...},
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
    // FULL trip results data including all options, itinerary, etc.
  }
}
```

### The `searchResultsData` Field
This critical field stores the **complete** `TripPlannerResponse`, including:
- All transportation options (outbound & return)
- All accommodation options  
- Daily itinerary with activities
- Trip summary with cost breakdowns
- Available activities
- Recommended plans
- The optimal/best plan

This allows you to:
- Display full details of saved plans later
- Compare different saved plans
- Restore search parameters
- Show what was available at save time

### Room Allocations
Rooms are properly formatted as:
```dart
[
  {"roomId": 259, "numberOfRooms": 1},
  {"roomId": 260, "numberOfRooms": 1},
  {"roomId": 262, "numberOfRooms": 1},
  // etc.
]
```

### Automatic Cost Calculation
The formatter automatically calculates total cost:
```dart
totalCost = outboundCost + returnCost + accommodationCost
```

### Built-in Validation
Validates that requests have:
- Non-empty plan name
- Valid transport ID (> 0)
- Valid accommodation ID (> 0)
- Total cost > 0
- Valid search parameters

## How to Use

### In ConfirmTripPage (already updated):

```dart
void _savePlan() {
  final originalRequest = context.read<TripPlannerBloc>().state.originalRequest;
  
  final saveRequest = TripPlanFormatter.createSavePlanRequest(
    planName: 'My Trip Plan',
    description: 'Weekend trip',
    selectedOutbound: widget.outbound!,
    selectedReturn: widget.returnTransport!,
    selectedAccommodation: widget.accommodation!,
    selectedRoomAllocations: widget.selectedRoomAllocations,
    selectedActivities: [],
    tags: [],
    originalSearchParams: originalRequest,
    fullTripResults: widget.tripPlan,
  );

  if (!TripPlanFormatter.validateSavePlanRequest(saveRequest)) {
    showError('Invalid plan data');
    return;
  }

  context.read<TripPlannerBloc>().add(
    SaveTripPlan(request: saveRequest),
  );
}
```

### For Quick Save (Best Option):

```dart
final saveRequest = TripPlanFormatter.createSavePlanRequestFromOptimal(
  customPlanName: 'Best Value Trip',
  fullTripResults: tripResults,
  originalSearchParams: searchParams,
);
```

### Get API-Ready JSON:

```dart
final apiBody = TripPlanFormatter.formatForApiRequest(saveRequest);
await yourApiService.post('/save-plan', body: apiBody);
```

## Benefits

✅ **Consistent Format** - All save requests use the same structure  
✅ **Validation** - Catches errors before sending to API  
✅ **Full Context** - Stores complete trip data with `searchResultsData`  
✅ **Easy to Maintain** - Change format in one place  
✅ **Type Safe** - Uses proper Dart models  
✅ **Well Documented** - Includes README and examples  
✅ **Error Handling** - Proper null checks and validation  

## Testing

The formatter has been integrated into `ConfirmTripPage` and is ready to use. Test by:

1. Creating a trip search
2. Selecting transport and accommodation
3. Going to confirm page
4. Clicking "Save Plan"
5. Check that the request matches your API expectations

## Next Steps

1. **Backend Integration**: Ensure your API endpoint accepts this format
2. **Error Feedback**: Add more specific error messages based on validation failures
3. **Loading States**: Show loading indicator while saving
4. **Success Navigation**: Navigate to saved plans page on success
5. **Offline Support**: Consider caching save requests if offline

## Questions?

Refer to:
- `TRIP_PLAN_FORMATTER_README.md` - Full documentation
- `trip_plan_formatter_usage_example.dart` - Working example
- `trip_plan_formatter.dart` - Source code with comments

All files are in `lib/utils/` directory.
