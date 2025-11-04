// Request model for saving a plan
class SavePlanRequest {
  final String planName;
  final String startLocation;
  final String endLocation;
  final String startTime;
  final String endTime;
  final int numberOfTravelers;
  final double budget;
  final List<String>? interests;
  final bool? needsReturnTransport;
  final int? selectedOutboundTransportId;
  final int? selectedReturnTransportId;
  final int? selectedAccommodationId;
  final List<RoomAllocation>? selectedRoomAllocations;
  final int? seatsNeeded;
  final Map<String, dynamic>? planData;
  final String? notes;
  final List<String>? tags;

  SavePlanRequest({
    required this.planName,
    required this.startLocation,
    required this.endLocation,
    required this.startTime,
    required this.endTime,
    required this.numberOfTravelers,
    required this.budget,
    this.interests,
    this.needsReturnTransport,
    this.selectedOutboundTransportId,
    this.selectedReturnTransportId,
    this.selectedAccommodationId,
    this.selectedRoomAllocations,
    this.seatsNeeded,
    this.planData,
    this.notes,
    this.tags,
  });

  Map<String, dynamic> toJson() {
    return {
      'planName': planName,
      'startLocation': startLocation,
      'endLocation': endLocation,
      'startTime': startTime,
      'endTime': endTime,
      'numberOfTravelers': numberOfTravelers,
      'budget': budget,
      if (interests != null) 'interests': interests,
      if (needsReturnTransport != null) 'needsReturnTransport': needsReturnTransport,
      if (selectedOutboundTransportId != null) 'selectedOutboundTransportId': selectedOutboundTransportId,
      if (selectedReturnTransportId != null) 'selectedReturnTransportId': selectedReturnTransportId,
      if (selectedAccommodationId != null) 'selectedAccommodationId': selectedAccommodationId,
      if (selectedRoomAllocations != null) 
        'selectedRoomAllocations': selectedRoomAllocations!.map((e) => e.toJson()).toList(),
      if (seatsNeeded != null) 'seatsNeeded': seatsNeeded,
      if (planData != null) 'planData': planData,
      if (notes != null) 'notes': notes,
      if (tags != null) 'tags': tags,
    };
  }
}

class RoomAllocation {
  final int roomId;
  final int numberOfRooms;

  RoomAllocation({required this.roomId, required this.numberOfRooms});

  Map<String, dynamic> toJson() => {'roomId': roomId, 'numberOfRooms': numberOfRooms};
}

// Response models
class SavedPlanResponse {
  final bool success;
  final SavedPlan data;
  final String message;

  SavedPlanResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  factory SavedPlanResponse.fromJson(Map<String, dynamic> json) {
    return SavedPlanResponse(
      success: json['success'] ?? false,
      data: SavedPlan.fromJson(json['data']),
      message: json['message'] ?? '',
    );
  }
}

class SavedPlan {
  final int id;
  final String userId;
  final String planName;
  final String startLocation;
  final String endLocation;
  final String startTime;
  final String endTime;
  final int numberOfTravelers;
  final double budget;
  final List<String>? interests;
  final bool? needsReturnTransport;
  final TransportSummary? selectedOutboundTransport;
  final TransportSummary? selectedReturnTransport;
  final AccommodationSummary? selectedAccommodation;
  final List<RoomAllocationDetail>? roomAllocations;
  final int? seatsNeeded;
  final Map<String, dynamic>? planData;
  final String? notes;
  final List<String>? tags;
  final String status;
  final String createdAt;
  final String updatedAt;

  SavedPlan({
    required this.id,
    required this.userId,
    required this.planName,
    required this.startLocation,
    required this.endLocation,
    required this.startTime,
    required this.endTime,
    required this.numberOfTravelers,
    required this.budget,
    this.interests,
    this.needsReturnTransport,
    this.selectedOutboundTransport,
    this.selectedReturnTransport,
    this.selectedAccommodation,
    this.roomAllocations,
    this.seatsNeeded,
    this.planData,
    this.notes,
    this.tags,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SavedPlan.fromJson(Map<String, dynamic> json) {
    return SavedPlan(
      id: json['id'],
      userId: json['userId'] ?? '',
      planName: json['planName'] ?? '',
      startLocation: json['startLocation'] ?? '',
      endLocation: json['endLocation'] ?? '',
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      numberOfTravelers: json['numberOfTravelers'] ?? 0,
      budget: (json['budget'] ?? 0).toDouble(),
      interests: json['interests'] != null ? List<String>.from(json['interests']) : null,
      needsReturnTransport: json['needsReturnTransport'],
      selectedOutboundTransport: json['selectedOutboundTransport'] != null
          ? TransportSummary.fromJson(json['selectedOutboundTransport'])
          : null,
      selectedReturnTransport: json['selectedReturnTransport'] != null
          ? TransportSummary.fromJson(json['selectedReturnTransport'])
          : null,
      selectedAccommodation: json['selectedAccommodation'] != null
          ? AccommodationSummary.fromJson(json['selectedAccommodation'])
          : null,
      roomAllocations: json['roomAllocations'] != null
          ? (json['roomAllocations'] as List).map((e) => RoomAllocationDetail.fromJson(e)).toList()
          : null,
      seatsNeeded: json['seatsNeeded'],
      planData: json['planData'],
      notes: json['notes'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      status: json['status'] ?? 'draft',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}

class TransportSummary {
  final int id;
  final ProviderInfo? provider;
  final String vehicleType;
  final double pricePerSeat;
  final String? departureTime;
  final String? arrivalTime;

  TransportSummary({
    required this.id,
    this.provider,
    required this.vehicleType,
    required this.pricePerSeat,
    this.departureTime,
    this.arrivalTime,
  });

  factory TransportSummary.fromJson(Map<String, dynamic> json) {
    return TransportSummary(
      id: json['id'],
      provider: json['provider'] != null ? ProviderInfo.fromJson(json['provider']) : null,
      vehicleType: json['vehicleType'] ?? '',
      pricePerSeat: (json['pricePerSeat'] ?? 0).toDouble(),
      departureTime: json['departureTime'],
      arrivalTime: json['arrivalTime'],
    );
  }
}

class ProviderInfo {
  final String name;
  final double? avgRating;

  ProviderInfo({required this.name, this.avgRating});

  factory ProviderInfo.fromJson(Map<String, dynamic> json) {
    return ProviderInfo(
      name: json['name'] ?? '',
      avgRating: json['avgRating']?.toDouble(),
    );
  }
}

class AccommodationSummary {
  final int id;
  final String name;
  final double? avgRating;
  final List<String>? amenities;

  AccommodationSummary({
    required this.id,
    required this.name,
    this.avgRating,
    this.amenities,
  });

  factory AccommodationSummary.fromJson(Map<String, dynamic> json) {
    return AccommodationSummary(
      id: json['id'],
      name: json['name'] ?? '',
      avgRating: json['avgRating']?.toDouble(),
      amenities: json['amenities'] != null ? List<String>.from(json['amenities']) : null,
    );
  }
}

class RoomAllocationDetail {
  final int? id;
  final RoomInfo room;
  final int numberOfRooms;
  final String? checkInDate;
  final String? checkOutDate;

  RoomAllocationDetail({
    this.id,
    required this.room,
    required this.numberOfRooms,
    this.checkInDate,
    this.checkOutDate,
  });

  factory RoomAllocationDetail.fromJson(Map<String, dynamic> json) {
    return RoomAllocationDetail(
      id: json['id'],
      room: RoomInfo.fromJson(json['room']),
      numberOfRooms: json['numberOfRooms'] ?? 1,
      checkInDate: json['checkInDate'],
      checkOutDate: json['checkOutDate'],
    );
  }
}

class RoomInfo {
  final int id;
  final String roomType;
  final int capacity;
  final double pricePerNight;

  RoomInfo({
    required this.id,
    required this.roomType,
    required this.capacity,
    required this.pricePerNight,
  });

  factory RoomInfo.fromJson(Map<String, dynamic> json) {
    return RoomInfo(
      id: json['id'],
      roomType: json['roomType'] ?? '',
      capacity: json['capacity'] ?? 0,
      pricePerNight: (json['pricePerNight'] ?? 0).toDouble(),
    );
  }
}

class SavedPlansListResponse {
  final bool success;
  final List<SavedPlan> data;
  final PaginationInfo pagination;

  SavedPlansListResponse({
    required this.success,
    required this.data,
    required this.pagination,
  });

  factory SavedPlansListResponse.fromJson(Map<String, dynamic> json) {
    return SavedPlansListResponse(
      success: json['success'] ?? false,
      data: (json['data'] as List).map((e) => SavedPlan.fromJson(e)).toList(),
      pagination: PaginationInfo.fromJson(json['pagination']),
    );
  }
}

class PaginationInfo {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  PaginationInfo({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      totalPages: json['totalPages'] ?? 0,
    );
  }
}

class SavedPlanDetailResponse {
  final bool success;
  final SavedPlan data;

  SavedPlanDetailResponse({required this.success, required this.data});

  factory SavedPlanDetailResponse.fromJson(Map<String, dynamic> json) {
    return SavedPlanDetailResponse(
      success: json['success'] ?? false,
      data: SavedPlan.fromJson(json['data']),
    );
  }
}
