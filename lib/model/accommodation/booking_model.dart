// Matches backend Prisma schema
class AccommodationBooking {
  final int id;
  final String travelerId;
  final int roomId;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final double totalPrice;
  final String status;
  final DateTime createdAt;
  final Room? room;
  final Payment? payment;

  AccommodationBooking({
    required this.id,
    required this.travelerId,
    required this.roomId,
    required this.checkInDate,
    required this.checkOutDate,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    this.room,
    this.payment,
  });

  factory AccommodationBooking.fromJson(Map<String, dynamic> json) {
    return AccommodationBooking(
      id: json['id'] ?? 0,
      travelerId: json['travelerId']?.toString() ?? '',
      roomId: json['roomId'] ?? 0,
      checkInDate: json['checkInDate'] != null
          ? DateTime.parse(json['checkInDate'])
          : DateTime.now(),
      checkOutDate: json['checkOutDate'] != null
          ? DateTime.parse(json['checkOutDate'])
          : DateTime.now(),
      totalPrice: _parseDouble(json['totalPrice']),
      status: json['status'] ?? 'pending',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      room: json['room'] != null ? Room.fromJson(json['room']) : null,
      payment:
          json['payment'] != null ? Payment.fromJson(json['payment']) : null,
    );
  }

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
      'travelerId': travelerId,
      'roomId': roomId,
      'checkInDate': checkInDate.toIso8601String(),
      'checkOutDate': checkOutDate.toIso8601String(),
      'totalPrice': totalPrice,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      if (room != null) 'room': room!.toJson(),
      if (payment != null) 'payment': payment!.toJson(),
    };
  }

  int get numberOfNights {
    return checkOutDate.difference(checkInDate).inDays;
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
  final Accommodation? accommodation;

  Room({
    required this.id,
    required this.accommodationId,
    required this.roomType,
    required this.capacity,
    required this.pricePerNight,
    required this.mediaUrls,
    required this.createdAt,
    this.accommodation,
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
      accommodation: json['accommodation'] != null
          ? Accommodation.fromJson(json['accommodation'])
          : null,
    );
  }

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
      if (accommodation != null) 'accommodation': accommodation!.toJson(),
    };
  }
}

// Accommodation model matching backend Prisma schema
class Accommodation {
  final int id;
  final String name;
  final String location; // Backend uses single 'location' field
  final List<String> mediaUrls;

  Accommodation({
    required this.id,
    required this.name,
    required this.location,
    required this.mediaUrls,
  });

  factory Accommodation.fromJson(Map<String, dynamic> json) {
    return Accommodation(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      mediaUrls:
          json['mediaUrls'] != null ? List<String>.from(json['mediaUrls']) : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'mediaUrls': mediaUrls,
    };
  }
}

class Payment {
  final int id;
  final int accommodationBookingId;
  final double amount;
  final String paymentMethod;
  final String transactionId;
  final String status;
  final DateTime createdAt;

  Payment({
    required this.id,
    required this.accommodationBookingId,
    required this.amount,
    required this.paymentMethod,
    required this.transactionId,
    required this.status,
    required this.createdAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] ?? 0,
      accommodationBookingId: json['accommodationBookingId'] ?? 0,
      amount: _parseDouble(json['amount']),
      paymentMethod: json['paymentMethod'] ?? '',
      transactionId: json['transactionId'] ?? '',
      status: json['status'] ?? 'pending',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

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
      'accommodationBookingId': accommodationBookingId,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'transactionId': transactionId,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
