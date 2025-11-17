// Model matching backend Prisma schema exactly
class Accommodation {
  final int id;
  final String providerId;
  final String name;
  final String
      location; // Backend uses single 'location' field, not city/country
  final String description;
  final List<String> mediaUrls;
  final DateTime createdAt;
  final List<Room>? rooms;
  final double? averageRating; // Calculated by backend from reviews
  final int? reviewCount;
  final AccommodationProvider? provider; // Provider info with contact number

  Accommodation({
    required this.id,
    required this.providerId,
    required this.name,
    required this.location,
    required this.description,
    required this.mediaUrls,
    required this.createdAt,
    this.rooms,
    this.averageRating,
    this.reviewCount,
    this.provider,
  });

  factory Accommodation.fromJson(Map<String, dynamic> json) {
    return Accommodation(
      id: json['id'] ?? 0,
      providerId: json['providerId']?.toString() ?? '',
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      description: json['description'] ?? '',
      mediaUrls:
          json['mediaUrls'] != null ? List<String>.from(json['mediaUrls']) : [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      rooms: json['rooms'] != null
          ? (json['rooms'] as List).map((r) => Room.fromJson(r)).toList()
          : null,
      averageRating: json['averageRating']?.toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      provider: json['provider'] != null
          ? AccommodationProvider.fromJson(json['provider'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'providerId': providerId,
      'name': name,
      'location': location,
      'description': description,
      'mediaUrls': mediaUrls,
      'createdAt': createdAt.toIso8601String(),
      if (rooms != null) 'rooms': rooms!.map((r) => r.toJson()).toList(),
      if (averageRating != null) 'averageRating': averageRating,
      if (reviewCount != null) 'reviewCount': reviewCount,
      if (provider != null) 'provider': provider!.toJson(),
    };
  }

  // Get minimum room price
  double? get minPrice {
    if (rooms == null || rooms!.isEmpty) return null;
    return rooms!.map((r) => r.pricePerNight).reduce((a, b) => a < b ? a : b);
  }

  // Get maximum room price
  double? get maxPrice {
    if (rooms == null || rooms!.isEmpty) return null;
    return rooms!.map((r) => r.pricePerNight).reduce((a, b) => a > b ? a : b);
  }

  // Get maximum capacity
  int? get maxCapacity {
    if (rooms == null || rooms!.isEmpty) return null;
    return rooms!.map((r) => r.capacity).reduce((a, b) => a > b ? a : b);
  }
}

// Room model matching backend Prisma schema
class Room {
  final int id;
  final int accommodationId;
  final String roomType;
  final int capacity;
  final double pricePerNight;
  final List<String> mediaUrls;
  final DateTime createdAt;

  Room({
    required this.id,
    required this.accommodationId,
    required this.roomType,
    required this.capacity,
    required this.pricePerNight,
    required this.mediaUrls,
    required this.createdAt,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'] ?? 0,
      accommodationId: json['accommodationId'] ?? 0,
      roomType: json['roomType'] ?? '',
      capacity: json['capacity'] ?? 1,
      pricePerNight: _parseDouble(json['pricePerNight']),
      mediaUrls:
          json['mediaUrls'] != null ? List<String>.from(json['mediaUrls']) : [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  // Helper method to parse price from various formats (String, int, double)
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'accommodationId': accommodationId,
      'roomType': roomType,
      'capacity': capacity,
      'pricePerNight': pricePerNight,
      'mediaUrls': mediaUrls,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

// Accommodation Provider model
class AccommodationProvider {
  final String providerId;
  final String accommodationName;
  final String address;
  final String contactNumber;
  final List<String> mediaUrls;
  final DateTime createdAt;

  AccommodationProvider({
    required this.providerId,
    required this.accommodationName,
    required this.address,
    required this.contactNumber,
    required this.mediaUrls,
    required this.createdAt,
  });

  factory AccommodationProvider.fromJson(Map<String, dynamic> json) {
    return AccommodationProvider(
      providerId: json['providerId']?.toString() ?? '',
      accommodationName: json['accommodationName'] ?? '',
      address: json['address'] ?? '',
      contactNumber: json['contactNumber'] ?? '',
      mediaUrls: json['mediaUrls'] != null
          ? List<String>.from(json['mediaUrls'])
          : [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'providerId': providerId,
      'accommodationName': accommodationName,
      'address': address,
      'contactNumber': contactNumber,
      'mediaUrls': mediaUrls,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
