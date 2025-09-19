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
      id: json['id'],
      reviewerId: json['reviewerId'],
      reviewableType: json['reviewableType'],
      reviewableId: json['reviewableId'] is int
          ? json['reviewableId']
          : int.tryParse(json['reviewableId'].toString()) ?? 0,
      rating: json['rating'] is int
          ? json['rating']
          : int.tryParse(json['rating'].toString()) ?? 0,
      comment: json['comment'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class ReviewStats {
  final int totalReviews;
  final double averageRating;
  final Map<String, int> ratingDistribution;

  ReviewStats({
    required this.totalReviews,
    required this.averageRating,
    required this.ratingDistribution,
  });

  factory ReviewStats.fromApiResponse(Map<String, dynamic> json) {
    // API shape: { success, data: { totalReviews, averageRating, ratingDistribution } }
    final data = json['data'] ?? json;
    return ReviewStats(
      totalReviews: data['totalReviews'] ?? 0,
      averageRating: (data['averageRating'] is num)
          ? (data['averageRating'] as num).toDouble()
          : double.tryParse(data['averageRating']?.toString() ?? '0') ?? 0,
      ratingDistribution: (data['ratingDistribution'] as Map<String, dynamic>?)
              ?.map((key, value) => MapEntry(key, (value as num).toInt()))
          ?? <String, int>{},
    );
  }
}

