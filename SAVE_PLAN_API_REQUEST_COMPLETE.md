# Complete Save Plan API Request Structure

## Overview
This document details the complete API request structure when clicking "Save Plan" in the TripPlanner feature.

## API Endpoint
```
POST /api/planner/saved
```

## Request Flow
1. User selects transportation and accommodation options in `TripResultsPage`
2. User clicks "Confirm Selection" → navigates to `ConfirmTripPage`
3. User clicks "Save Plan" button in `ConfirmTripPage`
4. `TripPlanFormatter.createSavePlanRequest()` creates a properly formatted `SavePlanRequest` object
5. `TripPlannerBloc` dispatches `SaveTripPlan` event
6. `TripPlannerRepository.savePlan()` calls API with `request.toJson()`

## Complete JSON Structure

```json
{
  // Basic Plan Information
  "planName": "User-entered plan name",
  "description": "Optional description",
  
  // Selected IDs
  "selectedOutboundId": 123,
  "selectedReturnId": 456,
  "selectedAccommodationId": 789,
  
  // Room Selections
  "selectedRoomAllocations": [
    {
      "roomId": 101,
      "quantity": 1
    },
    {
      "roomId": 102,
      "quantity": 1
    }
  ],
  
  // Activities & Tags
  "selectedActivities": [],
  "tags": ["adventure", "nature", "hiking"],
  
  // Cost Calculation
  "totalCost": 150000,
  
  // Status
  "status": "saved",
  
  // Original Search Parameters (preserved)
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
  
  // Duplicated fields from originalSearchParams (for backend convenience)
  "startLocation": "Islamabad",
  "endLocation": "Skardu",
  "startTime": "2025-12-01T08:00:00.000Z",
  "endTime": "2025-12-05T18:00:00.000Z",
  "numberOfTravelers": 2,
  "budget": 200000,
  "interests": ["adventure", "nature"],
  "needsReturnTransport": true,
  
  // COMPLETE Search Results Data
  "searchResultsData": {
    "requestSummary": {
      "startLocation": "Islamabad",
      "endLocation": "Skardu",
      "startTime": "2025-12-01T08:00:00.000Z",
      "endTime": "2025-12-05T18:00:00.000Z",
      "numberOfTravelers": 2,
      "budget": 200000,
      "interests": ["adventure", "nature"]
    },
    "availableOptions": {
      "outboundTransportation": [
        {
          "id": 123,
          "listingId": 100,
          "providerName": "Mountain Movers",
          "vehicleType": "SUV",
          "pricePerSeat": 5000,
          "seatsAvailable": 4,
          "departureTime": "2025-12-01T08:00:00.000Z",
          "arrivalTime": "2025-12-01T14:00:00.000Z",
          "avgRating": 4.5,
          "totalCost": 10000,
          "pickupLocation": "Islamabad Airport",
          "dropoffLocation": "Skardu City Center",
          "totalReviews": 150,
          "amenities": ["AC", "WiFi", "Water"]
        }
        // ... more transport options
      ],
      "returnTransportation": [
        // ... similar structure
      ],
      "accommodations": [
        {
          "id": 789,
          "accommodationId": 50,
          "name": "Mountain View Hotel",
          "location": "Skardu City Center",
          "avgRating": 4.8,
          "totalCost": 80000,
          "numberOfNights": 4,
          "roomAllocations": [
            {
              "roomId": 101,
              "roomType": "Deluxe",
              "pricePerNight": 10000,
              "capacity": 2,
              "numberOfRooms": 1,
              "guestsAllocated": 2,
              "totalCost": 40000,
              "amenities": ["Mountain View", "Balcony"]
            }
          ],
          "availableRooms": [
            {
              "roomId": 101,
              "roomType": "Deluxe",
              "capacity": 2,
              "pricePerNight": 10000,
              "amenities": ["Mountain View", "Balcony"]
            }
          ],
          "amenities": ["Restaurant", "WiFi", "Parking"],
          "images": ["https://example.com/hotel1.jpg"],
          "description": "Comfortable hotel with mountain views",
          "checkInDate": "2025-12-01T14:00:00.000Z",
          "checkOutDate": "2025-12-05T11:00:00.000Z",
          "totalGuests": 2,
          "totalReviews": 200
        }
        // ... more accommodations
      ],
      "activities": [
        {
          "id": "act1",
          "title": "Shangrila Resort Visit",
          "description": "Visit the famous Shangrila Resort",
          "location": "Lower Kachura Lake",
          "estimatedCost": 2000,
          "duration": 180,
          "category": "sightseeing"
        }
        // ... more activities
      ]
    },
    "recommendedPlans": [
      {
        "optionId": "plan1",
        "planName": "Budget Explorer",
        "description": "Affordable adventure package",
        "isOptimal": false,
        "optimizationScore": 0.85,
        "outboundTransport": { /* TransportOption object */ },
        "returnTransport": { /* TransportOption object */ },
        "accommodation": { /* AccommodationOption object */ },
        "activities": [ /* Activity objects */ ],
        "costs": {
          "transportation": 30000,
          "accommodation": 80000,
          "activities": 20000,
          "total": 130000
        },
        "warnings": []
      }
      // ... more recommended plans
    ],
    "optimalPlan": {
      "optionId": "optimal1",
      "planName": "Best Value Package",
      "description": "Optimized for budget and experience",
      "isOptimal": true,
      "optimizationScore": 0.95,
      "outboundTransport": { /* TransportOption object */ },
      "returnTransport": { /* TransportOption object */ },
      "accommodation": { /* AccommodationOption object */ },
      "activities": [ /* Activity objects */ ],
      "costs": {
        "transportation": 30000,
        "accommodation": 80000,
        "activities": 20000,
        "total": 130000
      },
      "warnings": []
    },
    "itinerary": [
      {
        "day": 1,
        "date": "2025-12-01",
        "dayOfWeek": "Monday",
        "theme": "Arrival & Exploration",
        "totalEstimatedCost": 5000,
        "totalDuration": 480,
        "activities": [
          {
            "time": "08:00 AM",
            "type": "travel",
            "title": "Departure from Islamabad",
            "description": "Begin journey to Skardu",
            "estimatedCost": 0,
            "location": {
              "name": "Islamabad Airport",
              "address": "Airport Road, Islamabad",
              "coordinates": {
                "lat": 33.6167,
                "lng": 73.0667
              }
            },
            "tips": "Arrive 30 minutes early",
            "duration": 360,
            "placeDetails": {
              "rating": 4.2,
              "userRatingsTotal": 500,
              "priceLevel": 2,
              "website": "https://example.com",
              "phoneNumber": "+92-51-1234567",
              "photos": ["https://example.com/photo1.jpg"]
            }
          }
          // ... more activities for the day
        ]
      }
      // ... more days
    ],
    "tripSummary": {
      "totalDays": 5,
      "totalNights": 4,
      "estimatedTotalCost": 145000,
      "remainingBudget": 55000,
      "budgetStatus": "within_budget"
    }
  }
}
```

## Field Descriptions

### Top-Level Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `planName` | string | ✓ | User-provided or default plan name |
| `description` | string | ✗ | Optional plan description |
| `selectedOutboundId` | int | ✓ | ID of selected outbound transport |
| `selectedReturnId` | int | ✗ | ID of selected return transport (null if one-way) |
| `selectedAccommodationId` | int | ✓ | ID of selected accommodation |
| `selectedRoomAllocations` | array | ✓ | Array of room selections with quantities |
| `selectedActivities` | array | ✗ | Array of activity IDs (empty by default) |
| `totalCost` | number | ✓ | Total calculated cost (PKR) |
| `tags` | array | ✗ | Custom tags/interests from search |
| `status` | string | ✓ | Plan status: "saved" or "booked" |
| `originalSearchParams` | object | ✓ | Complete original search parameters |
| `searchResultsData` | object | ✓ | **ENTIRE** trip search results |

### Duplicated Search Parameters (Backend Convenience)

These fields are duplicated from `originalSearchParams` for easier backend queries:
- `startLocation`
- `endLocation`
- `startTime`
- `endTime`
- `numberOfTravelers`
- `budget`
- `interests`
- `needsReturnTransport`

## Implementation Files

### Model Definition
**File:** `/lib/model/tripPlanner/tripPlannerModels.dart`

```dart
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

  // ... constructor and toJson()
}
```

### Formatter Utility
**File:** `/lib/utils/trip_plan_formatter.dart`

```dart
class TripPlanFormatter {
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
    // Creates properly formatted SavePlanRequest
  }
}
```

### Usage Example
**File:** `/lib/view/tripPlanner/confirm_trip_page.dart`

```dart
void _savePlan() {
  final saveRequest = TripPlanFormatter.createSavePlanRequest(
    planName: widget.tripPlan.optimalPlan?.planName ?? 'My Trip Plan',
    description: widget.tripPlan.optimalPlan?.description,
    selectedOutbound: widget.outbound!,
    selectedReturn: widget.returnTransport ?? widget.outbound!,
    selectedAccommodation: widget.accommodation!,
    selectedRoomAllocations: widget.selectedRoomAllocations,
    selectedActivities: [],
    tags: [],
    originalSearchParams: originalRequest,
    fullTripResults: widget.tripPlan,
  );

  // Dispatch to BLoC
  context.read<TripPlannerBloc>().add(
    SaveTripPlan(request: saveRequest),
  );
}
```

## Key Updates Made

### 1. Complete `TripPlannerResponse.toJson()`
**Updated:** `/lib/model/tripPlanner/tripPlannerModels.dart`

The `toJson()` method now serializes **ALL** trip data including:
- ✅ Complete `availableOptions` with all transport and accommodation details
- ✅ All `recommendedPlans` with full plan details
- ✅ Complete `optimalPlan` structure
- ✅ Full `itinerary` with all activities and location details
- ✅ Complete `tripSummary` with cost breakdowns

**Before:** Only included minimal `requestSummary`

**After:** Includes complete search results data for backend reference

### 2. Verified `SavePlanRequest.toJson()`
Already includes all required fields:
- ✅ Basic plan info (name, description)
- ✅ Selected IDs (transport, accommodation)
- ✅ Room allocations
- ✅ Status field
- ✅ Original search params
- ✅ Duplicated top-level fields
- ✅ Complete searchResultsData

## Data Flow

```
User Selection
    ↓
TripResultsPage (select options)
    ↓
ConfirmTripPage (review & save)
    ↓
TripPlanFormatter.createSavePlanRequest()
    ↓
SavePlanRequest object
    ↓
SavePlanRequest.toJson()
    ↓
API Request Body (complete JSON)
    ↓
Backend API: POST /api/planner/saved
```

## Testing

To verify the complete API request, add debug logging in the repository:

```dart
// lib/model/tripPlanner/tripPlannerRepository.dart
import 'dart:convert';

Future<SavedPlan> savePlan(SavePlanRequest request) async {
  try {
    final body = request.toJson();
    
    // Debug: Print complete API request
    print('═══════════════════════════════════════════');
    print('SAVE PLAN API REQUEST');
    print('═══════════════════════════════════════════');
    print(JsonEncoder.withIndent('  ').convert(body));
    print('═══════════════════════════════════════════');
    
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

## Status Values

The `status` field indicates the plan state:
- **`"saved"`** - Plan saved for later (default)
- **`"booked"`** - Plan confirmed and paid

When saving a plan, it always starts with `status: "saved"`.
When booking a plan (payment completed), the status changes to `"booked"`.

## Validation

The `TripPlanFormatter.validateSavePlanRequest()` ensures:
- ✅ Plan name is not empty
- ✅ Selected outbound transport ID is valid
- ✅ Selected accommodation ID is valid
- ✅ Total cost is greater than 0

## Complete Data Preservation

The `searchResultsData` field stores the **ENTIRE** trip search response, allowing:
- Full reconstruction of the trip plan
- Access to all alternative options
- Complete itinerary details
- All activity and location information
- Backend analysis and optimization

This ensures that saved plans can be:
- Re-opened and modified
- Compared with other plans
- Analyzed for improvement
- Used for recommendations

## Summary

✅ **All fields from your specification are now included**
✅ **searchResultsData contains the complete trip response**
✅ **Room allocations properly formatted**
✅ **Status field defaults to "saved"**
✅ **Original search params preserved**
✅ **Validation ensures data integrity**

The API request structure now **exactly matches** your specification! 🎉
