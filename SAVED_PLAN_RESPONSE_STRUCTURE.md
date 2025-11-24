# Saved Plan Response Structure

## Overview
This document details the complete structure of a `SavedPlan` object returned from the backend API.

## API Endpoint
```
GET /api/planner/saved/:id
GET /api/planner/saved
```

## Complete Response Structure

```typescript
{
  // ============================================================================
  // BASIC IDENTIFIERS
  // ============================================================================
  id: 123,
  userId: "user_abc123",
  
  // ============================================================================
  // PLAN INFORMATION
  // ============================================================================
  planName: "Beach Vacation to Karachi",
  description: "Relaxing 3-day beach trip with family",
  status: "draft" | "booked" | "expired",
  
  // ============================================================================
  // TRIP DETAILS
  // ============================================================================
  startLocation: "Islamabad",
  endLocation: "Karachi",
  startTime: "2025-12-01T00:00:00.000Z",
  endTime: "2025-12-05T00:00:00.000Z",
  numberOfTravelers: 4,
  budget: "200000" | 200000,  // Can be string or number
  interests: ["beach", "relaxation", "family"],
  needsReturnTransport: true,
  
  // ============================================================================
  // SELECTED OPTIONS (IDs)
  // ============================================================================
  selectedOutboundTransportId: 456 | null,
  selectedReturnTransportId: 789 | null,
  selectedAccommodationId: 321,
  selectedOutboundId: 456,        // Duplicate for compatibility
  selectedReturnId: 789,          // Duplicate for compatibility
  seatsNeeded: 4 | null,
  
  // ============================================================================
  // ACTIVITIES & COST
  // ============================================================================
  selectedActivities: [101, 102, 103] | undefined,
  totalCost: 185000,
  tags: ["beach", "family", "weekend"] | undefined,
  notes: "Remember to bring sunscreen" | null,
  
  // ============================================================================
  // ORIGINAL SEARCH PARAMETERS (stored for re-searching)
  // ============================================================================
  originalSearchParams: {
    startLocation: "Islamabad",
    endLocation: "Karachi",
    startTime: "2025-12-01T00:00:00.000Z",
    endTime: "2025-12-05T00:00:00.000Z",
    interests: ["beach", "relaxation"],
    budget: 200000,
    numberOfTravelers: 4,
    needsReturnTransport: true,
    useAIOptimization: true,
    maxIterations: 3
  },
  
  // ============================================================================
  // TIMESTAMPS
  // ============================================================================
  createdAt: "2025-11-15T10:30:00.000Z",
  updatedAt: "2025-11-20T14:45:00.000Z",
  bookedAt: "2025-11-20T14:45:00.000Z" | undefined,
  savedAt: "2025-11-15T10:30:00.000Z" | undefined,
  lastViewedAt: "2025-11-22T08:00:00.000Z" | null,
  
  // ============================================================================
  // COMPLETE SEARCH RESULTS DATA (can be JSON string or object)
  // ============================================================================
  searchResultsData: {
    // This contains ALL the data from the original search
    optimalPlan: {
      optionId: "opt-001",
      planName: "Best Value Plan",
      description: "Optimized for your budget",
      isOptimal: true,
      optimizationScore: 87.5,
      outboundTransport: { /* TransportOption */ },
      returnTransport: { /* TransportOption */ },
      accommodation: { /* AccommodationOption */ },
      activities: [ /* Activity[] */ ],
      costs: {
        transportation: 60000,
        accommodation: 80000,
        activities: 25000,
        total: 165000
      },
      warnings: []
    },
    recommendedPlans: [ /* RecommendedPlan[] */ ],
    availableOptions: {
      outboundTransportation: [ /* TransportOption[] */ ],
      returnTransportation: [ /* TransportOption[] */ ],
      accommodations: [ /* AccommodationOption[] */ ],
      activities: [ /* Activity[] */ ]
    },
    itinerary: [
      {
        day: 1,
        date: "2025-12-01",
        dayOfWeek: "Monday",
        theme: "Arrival & Beach Day",
        activities: [
          {
            time: "10:00 AM",
            type: "travel",
            title: "Depart from Islamabad",
            description: "Begin journey to Karachi",
            estimatedCost: 5000,
            location: { name: "Islamabad Airport" }
          }
          // ... more activities
        ],
        totalEstimatedCost: 35000
      }
      // ... more days
    ],
    tripSummary: {
      totalDays: 5,
      totalNights: 4,
      estimatedTotalCost: {
        transportation: 60000,
        accommodation: 80000,
        activities: 25000,
        meals: 15000,
        total: 180000
      },
      budgetStatus: "within_budget" | "over_budget"
    },
    requestSummary: {
      startLocation: "Islamabad",
      endLocation: "Karachi",
      budget: 200000,
      numberOfTravelers: 4,
      startTime: "2025-12-01",
      endTime: "2025-12-05"
    }
  },
  
  // ============================================================================
  // ALTERNATIVE: planData (older format, can be JSON string or object)
  // ============================================================================
  planData: {
    // Similar structure to searchResultsData
    itinerary: [ /* ... */ ],
    optimalPlan: { /* ... */ },
    tripSummary: { /* ... */ },
    requestSummary: { /* ... */ },
    availableOptions: { /* ... */ },
    recommendedPlans: [ /* ... */ ]
  },
  
  // ============================================================================
  // RELATED ENTITIES (populated by backend joins)
  // ============================================================================
  
  // Accommodation Details
  Accommodation: {
    id: 321,
    providerId: "provider_xyz789",
    name: "Beach Resort Karachi",
    location: "Clifton Beach, Karachi",
    description: "Luxury beachfront resort",
    mediaUrls: ["https://...", "https://..."],
    createdAt: "2025-01-10T00:00:00.000Z",
    rooms: [
      {
        id: 501,
        accommodationId: 321,
        roomType: "Deluxe Ocean View",
        pricePerNight: "15000" | 15000,
        capacity: 2,
        mediaUrls: ["https://..."],
        createdAt: "2025-01-10T00:00:00.000Z"
      }
      // ... more rooms
    ]
  },
  
  // Room Allocations (junction table)
  SavedPlanRoomAllocation: [
    {
      id: 701,
      savedPlanId: 123,
      roomId: 501,
      numberOfRooms: 2,
      checkInDate: "2025-12-01",
      checkOutDate: "2025-12-05",
      Room: {
        id: 501,
        accommodationId: 321,
        roomType: "Deluxe Ocean View",
        pricePerNight: "15000" | 15000,
        capacity: 2,
        mediaUrls: ["https://..."],
        createdAt: "2025-01-10T00:00:00.000Z"
      }
    }
    // ... more allocations
  ],
  
  // Transport Listings (populated if available)
  TransportationListing_SavedTripPlan_selectedOutboundTransportIdToTransportationListing: {
    id: 456,
    providerId: "provider_abc456",
    startLocationText: "Islamabad",
    endLocationText: "Karachi",
    departureTime: "2025-12-01T08:00:00.000Z",
    arrivalTime: "2025-12-01T20:00:00.000Z",
    pricePerSeat: 5000,
    seatsAvailable: 30,
    mediaUrls: ["https://..."],
    provider: {
      id: "provider_abc456",
      vehicleType: "Bus",
      user: {
        username: "KarachiExpressLines"
      }
    }
  },
  TransportationListing_SavedTripPlan_selectedReturnTransportIdToTransportationListing: {
    // Similar structure to outbound transport
  }
}
```

## Field Descriptions

### Core Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | number | ✓ | Unique saved plan identifier |
| `userId` | string | ✓ | User who created the plan |
| `planName` | string | ✓ | Name of the saved plan |
| `description` | string? | ✗ | Optional plan description |
| `status` | enum | ✓ | Plan status: "draft", "booked", "expired" |

### Trip Details

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `startLocation` | string | ✓ | Starting location |
| `endLocation` | string | ✓ | Destination location |
| `startTime` | string | ✓ | ISO 8601 start date/time |
| `endTime` | string | ✓ | ISO 8601 end date/time |
| `numberOfTravelers` | number | ✓ | Number of travelers |
| `budget` | number/string | ✓ | Budget (can be string or number) |
| `interests` | string[] | ✓ | User interests/tags |
| `needsReturnTransport` | boolean | ✓ | Whether return transport needed |

### Selected Options

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `selectedOutboundTransportId` | number? | ✗ | Selected outbound transport ID |
| `selectedReturnTransportId` | number? | ✗ | Selected return transport ID |
| `selectedAccommodationId` | number? | ✗ | Selected accommodation ID |
| `seatsNeeded` | number? | ✗ | Number of seats needed |
| `selectedActivities` | number[]? | ✗ | Selected activity IDs |

### Cost & Metadata

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `totalCost` | number | ✓ | Total calculated cost |
| `tags` | string[]? | ✗ | Custom tags |
| `notes` | string? | ✗ | User notes |

### Timestamps

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `createdAt` | string | ✓ | ISO 8601 creation timestamp |
| `updatedAt` | string | ✓ | ISO 8601 last update timestamp |
| `bookedAt` | string? | ✗ | ISO 8601 booking timestamp |
| `savedAt` | string? | ✗ | ISO 8601 save timestamp |
| `lastViewedAt` | string? | ✗ | ISO 8601 last view timestamp |

### Data Objects

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `originalSearchParams` | object? | ✗ | Original search parameters for re-searching |
| `searchResultsData` | object? | ✗ | Complete trip search results |
| `planData` | object? | ✗ | Alternative/legacy format |

### Nested Relations

| Field | Type | Description |
|-------|------|-------------|
| `Accommodation` | object? | Full accommodation details with rooms |
| `SavedPlanRoomAllocation` | array? | Room allocations with nested Room data |
| `TransportationListing_*` | object? | Transportation listing details |

## Model Implementation

### SavedPlan Class (Dart)

```dart
class SavedPlan {
  final int id;
  final String userId;
  final String planName;
  final String? description;
  final String status; // "draft" | "booked" | "expired"
  final String startLocation;
  final String endLocation;
  final DateTime startTime;
  final DateTime endTime;
  final int numberOfTravelers;
  final double budget;
  final List<String> interests;
  final bool needsReturnTransport;
  
  // Selected IDs
  final int? selectedOutboundTransportId;
  final int? selectedReturnTransportId;
  final int? selectedAccommodationId;
  final int? seatsNeeded;
  final List<int>? selectedActivities;
  
  // Cost & Metadata
  final double totalCost;
  final List<String>? tags;
  final String? notes;
  
  // Timestamps
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? bookedAt;
  final DateTime? savedAt;
  final DateTime? lastViewedAt;
  
  // Original search parameters
  final Map<String, dynamic>? originalSearchParams;
  
  // Complete search results data
  final Map<String, dynamic>? searchResultsData;
  
  // Alternative planData format
  final Map<String, dynamic>? planData;
  
  // Nested objects from API joins
  final TransportOption? outboundTransport;
  final TransportOption? returnTransport;
  final AccommodationOption? accommodation;
  final List<RoomAllocation>? roomAllocations;
  
  // ... constructor and methods
}
```

## Key Features

### 1. Flexible Field Types
- **Budget**: Handles both string and number types
- **Price Fields**: All prices converted to double using `_toDouble()` helper
- **Timestamps**: Automatically parsed to DateTime objects

### 2. Nested Data Parsing
- **Transportation**: Parses long backend field names
- **Accommodation**: Includes full accommodation with rooms array
- **Room Allocations**: Parses junction table with nested Room data

### 3. Alternative Field Names
- **Compatibility**: Supports both `selectedOutboundId` and `selectedOutboundTransportId`
- **Getters**: Convenience getters for alternative naming

### 4. Data Prioritization
```dart
// Example: Extract description from multiple sources
description: json['description'] ?? planData?['description']

// Example: Extract searchResultsData from multiple locations
searchResultsData: json['searchResultsData'] ?? planData?['searchResultsData']
```

### 5. Helper Getters

```dart
// Status checkers
bool get isBooked => status == 'booked';
bool get isDraft => status == 'draft';
bool get isExpired => status == 'expired';

// Alternative field names
int? get selectedOutboundId => selectedOutboundTransportId;
int? get selectedReturnId => selectedReturnTransportId;

// Booking information
Map<String, dynamic>? get bookings => planData?['bookings'];
String? get paymentMethod => planData?['paymentMethod'];
```

## Usage Examples

### 1. Fetching a Saved Plan

```dart
final repository = TripPlannerRepository();
final savedPlan = await repository.getSavedPlan(planId: 123);

print('Plan: ${savedPlan.planName}');
print('Status: ${savedPlan.status}');
print('Total Cost: ${CurrencyFormatter.formatPKR(savedPlan.totalCost)}');

if (savedPlan.isBooked) {
  print('Booked at: ${savedPlan.bookedAt}');
}
```

### 2. Accessing Nested Data

```dart
// Access accommodation details
if (savedPlan.accommodation != null) {
  print('Hotel: ${savedPlan.accommodation!.name}');
  print('Location: ${savedPlan.accommodation!.location}');
  
  // Access rooms
  for (final room in savedPlan.accommodation!.availableRooms ?? []) {
    print('Room: ${room.roomType} - ${room.pricePerNight} PKR/night');
  }
}

// Access room allocations
if (savedPlan.roomAllocations != null) {
  for (final allocation in savedPlan.roomAllocations!) {
    print('Allocated: ${allocation.numberOfRooms} x ${allocation.roomType}');
  }
}
```

### 3. Accessing Search Results Data

```dart
// Access original search results
if (savedPlan.searchResultsData != null) {
  final results = savedPlan.searchResultsData!;
  
  // Access optimal plan
  final optimalPlan = results['optimalPlan'];
  if (optimalPlan != null) {
    print('Optimal Plan: ${optimalPlan['planName']}');
    print('Score: ${optimalPlan['optimizationScore']}');
  }
  
  // Access itinerary
  final itinerary = results['itinerary'] as List?;
  if (itinerary != null) {
    for (final day in itinerary) {
      print('Day ${day['day']}: ${day['theme']}');
    }
  }
}
```

### 4. Re-searching with Original Parameters

```dart
// Use original search params to perform new search
if (savedPlan.originalSearchParams != null) {
  final searchParams = TripSearchParams.fromJson(
    savedPlan.originalSearchParams!
  );
  
  // Perform new search with same parameters
  final newResults = await repository.searchTrips(searchParams);
}
```

## Status Values

| Status | Description | Typical Flow |
|--------|-------------|--------------|
| `draft` | Plan saved but not booked | User saved plan for later |
| `booked` | Plan confirmed and paid | Payment completed |
| `expired` | Plan date has passed | Auto-updated by backend |

## Data Structures

### searchResultsData Structure
Contains the complete original search response:
- `optimalPlan`: Best recommended plan
- `recommendedPlans`: Alternative plans
- `availableOptions`: All available transport, accommodation, activities
- `itinerary`: Day-by-day activities
- `tripSummary`: Cost breakdown and trip details
- `requestSummary`: Original search parameters

### planData Structure (Legacy)
Alternative format that may contain:
- Similar data to `searchResultsData`
- Booking-specific data (`bookedAt`, `paymentMethod`)
- Custom user data

## Notes

1. **Flexible Type Handling**: The model handles both string and numeric types for prices
2. **Nested Parsing**: Automatically parses complex nested structures from backend joins
3. **Backward Compatibility**: Supports multiple field naming conventions
4. **Complete Data Preservation**: Stores entire search results for future reference
5. **Type Safety**: Converts all data to proper Dart types (DateTime, double, etc.)

## Summary

✅ **Complete structure documented**
✅ **All fields explained**
✅ **Nested data handling**
✅ **Helper getters provided**
✅ **Usage examples included**
✅ **Flexible type parsing**
✅ **Backend join support**

The `SavedPlan` model now fully supports the complete backend response structure! 🎉
