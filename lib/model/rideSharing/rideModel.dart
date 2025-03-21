class Ride {
  final String id;
  final String driverName;
  final String vehicleType;
  final String pickupLocation;
  final String destination;
  final DateTime departureTime;
  final double price;
  final int availableSeats;
  final int luggageCapacity;
  final double rating;
  final String imageUrl;

  Ride({
    required this.id,
    required this.driverName,
    required this.vehicleType,
    required this.pickupLocation,
    required this.destination,
    required this.departureTime,
    required this.price,
    required this.availableSeats,
    required this.luggageCapacity,
    required this.rating,
    required this.imageUrl,
  });

  factory Ride.fromJson(Map<String, dynamic> json) {
    return Ride(
      id: json['id'].toString(), // Converting to string since your model expects String
      driverName: json['driver']['name'],
      vehicleType: json['vehicle']['model'],
      pickupLocation: json['pickup'],
      destination: json['destination'],
      departureTime: DateTime.parse(json['departureTime']),
      price: json['price'].toDouble(),
      availableSeats: json['availableSeats'],
      luggageCapacity: json['availableLuggage'],
      rating: json['driver']['rating'].toDouble(),
      imageUrl: json['driver']['profileImage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'driver_name': driverName,
      'vehicle_type': vehicleType,
      'pickup_location': pickupLocation,
      'destination': destination,
      'departure_time': departureTime.toIso8601String(),
      'price': price,
      'available_seats': availableSeats,
      'luggage_capacity': luggageCapacity,
      'rating': rating,
      'image_url': imageUrl,
    };
  }


}

