import 'package:flutter/material.dart';
import 'package:day_night_time_picker/day_night_time_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RideFilterModel {
  final DateTime? selectedDate;
  final Time startTime;
  final Time endTime;
  final int numberOfTravelers;
  final int luggageCapacity;
  final String pickupLocation;
  final String destination;
  final RangeValues priceRange;
  final LatLng pickupLocationCoordinates;
  final LatLng destinationCoordinates;

  const RideFilterModel({
    this.selectedDate,
    required this.startTime,
    required this.endTime,
    this.numberOfTravelers = 1,
    this.luggageCapacity = 1,
    this.pickupLocation = '',
    this.destination = '',
    this.priceRange = const RangeValues(20, 100),
    this.destinationCoordinates = const LatLng(10, 10),
    this.pickupLocationCoordinates = const LatLng(10, 10),
  });

  RideFilterModel copyWith({
    DateTime? selectedDate,
    Time? startTime,
    Time? endTime,
    int? numberOfTravelers,
    int? luggageCapacity,
    String? pickupLocation,
    String? destination,
    RangeValues? priceRange,
    LatLng? pickupLocationCoordinates,
    LatLng? destinationCoordinates,
  }) {

    return RideFilterModel(
      selectedDate: selectedDate ?? this.selectedDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      numberOfTravelers: numberOfTravelers ?? this.numberOfTravelers,
      luggageCapacity: luggageCapacity ?? this.luggageCapacity,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      destination: destination ?? this.destination,
      priceRange: priceRange ?? this.priceRange,
      pickupLocationCoordinates: pickupLocationCoordinates ?? this.pickupLocationCoordinates,
      destinationCoordinates: destinationCoordinates ?? this.destinationCoordinates,
    );
  }

  factory RideFilterModel.initial() {
    return RideFilterModel(
      startTime: Time(hour: 11, minute: 30, second: 20),
      endTime: Time(hour: 11, minute: 30, second: 20),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'selectedDate': selectedDate?.toIso8601String(),
      'startTime': {
        'hour': startTime.hour,
        'minute': startTime.minute,
        'second': startTime.second,
      },
      'endTime': {
        'hour': endTime.hour,
        'minute': endTime.minute,
        'second': endTime.second,
      },
      'numberOfTravelers': numberOfTravelers,
      'luggageCapacity': luggageCapacity,
      'pickupLocation': pickupLocation,
      'destination': destination,
      'priceRangeStart': priceRange.start,
      'priceRangeEnd': priceRange.end,
      'pickupLocationLat': pickupLocationCoordinates.latitude,
      'pickupLocationLng': pickupLocationCoordinates.longitude,
      'destinationLat': destinationCoordinates.latitude,
      'destinationLng': destinationCoordinates.longitude,
    };
  }

  factory RideFilterModel.fromJson(Map<String, dynamic> json) {
    return RideFilterModel(
      selectedDate: json['selectedDate'] != null
          ? DateTime.parse(json['selectedDate'])
          : null,
      startTime: Time(
        hour: json['startTime']['hour'],
        minute: json['startTime']['minute'],
        second: json['startTime']['second'],
      ),
      endTime: Time(
        hour: json['endTime']['hour'],
        minute: json['endTime']['minute'],
        second: json['endTime']['second'],
      ),
      numberOfTravelers: json['numberOfTravelers'],
      luggageCapacity: json['luggageCapacity'],
      pickupLocation: json['pickupLocation'],
      destination: json['destination'],
      priceRange: RangeValues(
        json['priceRangeStart'],
        json['priceRangeEnd'],
      ),
      pickupLocationCoordinates: LatLng(
        json['pickupLocationLat'] ?? 10,
        json['pickupLocationLng'] ?? 10,
      ),
      destinationCoordinates: LatLng(
        json['destinationLat'] ?? 10,
        json['destinationLng'] ?? 10,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is RideFilterModel &&
        other.selectedDate == selectedDate &&
        other.startTime.hour == startTime.hour &&
        other.startTime.minute == startTime.minute &&
        other.startTime.second == startTime.second &&
        other.endTime.hour == endTime.hour &&
        other.endTime.minute == endTime.minute &&
        other.endTime.second == endTime.second &&
        other.numberOfTravelers == numberOfTravelers &&
        other.luggageCapacity == luggageCapacity &&
        other.pickupLocation == pickupLocation &&
        other.destination == destination &&
        other.priceRange.start == priceRange.start &&
        other.priceRange.end == priceRange.end &&
        other.pickupLocationCoordinates.latitude == pickupLocationCoordinates.latitude &&
        other.pickupLocationCoordinates.longitude == pickupLocationCoordinates.longitude &&
        other.destinationCoordinates.latitude == destinationCoordinates.latitude &&
        other.destinationCoordinates.longitude == destinationCoordinates.longitude;
  }

  @override
  int get hashCode {
    return selectedDate.hashCode ^
    startTime.hashCode ^
    endTime.hashCode ^
    numberOfTravelers.hashCode ^
    luggageCapacity.hashCode ^
    pickupLocation.hashCode ^
    destination.hashCode ^
    priceRange.hashCode ^
    pickupLocationCoordinates.hashCode ^
    destinationCoordinates.hashCode;
  }

  get destinationLat => null;
}