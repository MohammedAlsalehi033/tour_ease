class ReviewModel {
  final int id;
  final String reviewerId;
  final String reviewableType;
  final int reviewableId;
  final int rating;
  final String comment;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.reviewerId,
    required this.reviewableType,
    required this.reviewableId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      reviewerId: json['reviewerId']?.toString() ?? '',
      reviewableType: json['reviewableType']?.toString() ?? '',
      reviewableId: json['reviewableId'] is int
          ? json['reviewableId']
          : int.tryParse(json['reviewableId'].toString()) ?? 0,
      rating: json['rating'] is int
          ? json['rating']
          : int.tryParse(json['rating'].toString()) ?? 0,
      comment: json['comment']?.toString() ?? '',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class ExtendedReviewModel {
  final int id;
  final String reviewerId;
  final String reviewableType;
  final int rating;
  final String comment;
  final DateTime createdAt;
  final int? transportationListingId;
  final int? accommodationId;
  final int? roomId;
  final int? transportationBookingId;
  final int? accommodationBookingId;
  final TransportationBookingDetails? transportationBooking;

  ExtendedReviewModel({
    required this.id,
    required this.reviewerId,
    required this.reviewableType,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.transportationListingId,
    this.accommodationId,
    this.roomId,
    this.transportationBookingId,
    this.accommodationBookingId,
    this.transportationBooking,
  });

  factory ExtendedReviewModel.fromJson(Map<String, dynamic> json) {
    return ExtendedReviewModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      reviewerId: json['reviewerId']?.toString() ?? '',
      reviewableType: json['reviewableType']?.toString() ?? '',
      rating: json['rating'] is int
          ? json['rating']
          : int.tryParse(json['rating'].toString()) ?? 0,
      comment: json['comment']?.toString() ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      transportationListingId: json['transportationListingId'] != null
          ? (json['transportationListingId'] is int
              ? json['transportationListingId']
              : int.tryParse(json['transportationListingId'].toString()))
          : null,
      accommodationId: json['accommodationId'] != null
          ? (json['accommodationId'] is int
              ? json['accommodationId']
              : int.tryParse(json['accommodationId'].toString()))
          : null,
      roomId: json['roomId'] != null
          ? (json['roomId'] is int
              ? json['roomId']
              : int.tryParse(json['roomId'].toString()))
          : null,
      transportationBookingId: json['transportationBookingId'] != null
          ? (json['transportationBookingId'] is int
              ? json['transportationBookingId']
              : int.tryParse(json['transportationBookingId'].toString()))
          : null,
      accommodationBookingId: json['accommodationBookingId'] != null
          ? (json['accommodationBookingId'] is int
              ? json['accommodationBookingId']
              : int.tryParse(json['accommodationBookingId'].toString()))
          : null,
      transportationBooking: json['transportationBooking'] != null
          ? TransportationBookingDetails.fromJson(json['transportationBooking'])
          : null,
    );
  }

  bool get isProviderReview => reviewableType == 'TRANSPORTATION_PROVIDER';
  bool get isBookingReview => reviewableType == 'TRANSPORTATION_BOOKING';
}

class TransportationBookingDetails {
  final int id;
  final String status;
  final String totalPrice;

  TransportationBookingDetails({
    required this.id,
    required this.status,
    required this.totalPrice,
  });

  factory TransportationBookingDetails.fromJson(Map<String, dynamic> json) {
    return TransportationBookingDetails(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      status: json['status']?.toString() ?? '',
      totalPrice: json['totalPrice']?.toString() ?? '0',
    );
  }
}

class ReviewStats {
  final int totalReviews;
  final double averageRating;
  final Map<String, int> ratingDistribution;
  final Map<String, dynamic> stats;
  final List<dynamic> reviews;

  ReviewStats({
    required this.totalReviews,
    required this.averageRating,
    required this.ratingDistribution,
    required this.stats,  
    required this.reviews,
  });

  factory ReviewStats.fromApiResponse(Map<String, dynamic> json) {
    // API shape: { success, data: { totalReviews, averageRating, ratingDistribution, stats, reviews } }
    final data = json['data'] ?? json;
    return ReviewStats( 
      totalReviews: data['totalReviews'] ?? 0,
      averageRating: (data['averageRating'] is num)
          ? (data['averageRating'] as num).toDouble()
          : double.tryParse(data['averageRating']?.toString() ?? '0') ?? 0,
      ratingDistribution: (data['ratingDistribution'] as Map<String, dynamic>?)
              ?.map((key, value) => MapEntry(key, (value as num).toInt()))
          ?? <String, int>{},
      stats: data['stats'] ?? <String, dynamic>{},
      reviews: (data['reviews'] is List) 
          ? (data['reviews'] as List<dynamic>) 
          : <dynamic>[],
    );
  }
}

