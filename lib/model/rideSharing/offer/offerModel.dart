import 'package:tour_ease/model/userManagment/transportationProvider.dart';

class OfferModel {
  final int id;
  final String senderId;
  final String recipientId;
  final double pricePerSeat;
  final int seatsRequested;
  final String? message;
  final int? transportationListingId;
  final int? transportationRequestId;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? sender;
  final Map<String, dynamic>? recipient;
  final Map<String, dynamic>? listing;  // Added listing field
  final Map<String, dynamic>? request;   // Added request field (present in the response as null)

  OfferModel({
    required this.id,
    required this.senderId,
    required this.recipientId,
    required this.pricePerSeat,
    required this.seatsRequested,
    this.message,
    this.transportationListingId,
    this.transportationRequestId,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.sender,
    this.recipient,
    this.listing,  // Added listing field
    this.request,  // Added request field
  });

  factory OfferModel.fromJson(Map<String, dynamic> json) {
    return OfferModel(
      id: json['id'],
      senderId: json['senderId'],
      recipientId: json['recipientId'],
      pricePerSeat: double.parse(json['pricePerSeat'].toString()),
      seatsRequested: json['seatsRequested'],
      message: json['message'],
      transportationListingId: json['transportationListingId'],
      transportationRequestId: json['transportationRequestId'],
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      sender: json['sender'],
      recipient: json['recipient'],
      listing: json['listing'],  // Added listing field
      request: json['request'],  // Added request field
    );
  }

  Map<String, dynamic> toJson() {
    final map = {
      'id': id,
      'senderId': senderId,
      'recipientId': recipientId,
      'pricePerSeat': pricePerSeat.toString(),
      'seatsRequested': seatsRequested,
      'message': message,
      'transportationListingId': transportationListingId,
      'transportationRequestId': transportationRequestId,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'sender': sender,
      'recipient': recipient,
      'listing': listing,  // Added listing field
      'request': request,  // Added request field
    };

    if (updatedAt != null) {
      map['updatedAt'] = updatedAt!.toIso8601String();
    }

    return map;
  }

  @override
  String toString() {
    return 'OfferModel{id: $id, senderId: $senderId, recipientId: $recipientId, pricePerSeat: $pricePerSeat, seatsRequested: $seatsRequested, message: $message, transportationListingId: $transportationListingId, transportationRequestId: $transportationRequestId, status: $status, createdAt: $createdAt, updatedAt: $updatedAt, sender: $sender, recipient: $recipient, listing: $listing, request: $request}';
  }
}