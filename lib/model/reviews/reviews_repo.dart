import 'package:tour_ease/Services/ApiService.dart';
import 'package:tour_ease/model/reviews/review_model.dart';

abstract class ReviewsRepository {
  Future<ReviewModel> createTransportationBookingReview({
    required int bookingId,
    required int rating,
    required String comment,
  });

  Future<ReviewStats> getDriverStats({
    required String driverId,
  });

  Future<ReviewStats> getListingStats({
    required int listingId,
  });

  Future<List<ReviewModel>> getTransportationBookingReviews({
    required int bookingId,
  });

  Future<List<ReviewModel>> getReviewsByReviewer({
    required String reviewerId,
  });

  Future<List<ExtendedReviewModel>> getExtendedReviewsByReviewer({
    required String reviewerId,
  });
}

class ReviewsRepositoryApi implements ReviewsRepository {
  final APIService apiService;
  ReviewsRepositoryApi(this.apiService);


  @override
  Future<ReviewModel> createTransportationBookingReview({
    required int bookingId,
    required int rating,
    required String comment,
  }) async {
    return await apiService.post<ReviewModel>(
      path: '/api/reviews',
      body: {
        'reviewableType': 'TRANSPORTATION_BOOKING',
        'reviewableId': bookingId,
        'rating': rating,
        'comment': comment,
      },
      fromJson: (json) {
        final data = json['data'] ?? json; // handle wrapper
        return ReviewModel.fromJson(data);
      },
    );
  }

  @override
  Future<ReviewStats> getDriverStats({required String driverId}) async {
    return await apiService.get<ReviewStats>(
      path: '/api/reviews/stats/TRANSPORTATION_PROVIDER/$driverId',
      fromJson: (json) => ReviewStats.fromApiResponse({'data': json}),
    );
  }

  @override
  Future<ReviewStats> getListingStats({required int listingId}) async {
    return await apiService.get<ReviewStats>(
      path: '/api/reviews/stats/TRANSPORTATION_LISTING/$listingId',
      fromJson: (json) => ReviewStats.fromApiResponse({'data': json}),
    );
  }

  @override
  Future<List<ReviewModel>> getTransportationBookingReviews({
    required int bookingId,
  }) async {
    return await apiService.get<List<ReviewModel>>(
      path: '/api/reviews/TRANSPORTATION_BOOKING/$bookingId',
      fromJson: (json) {
        final data = json['data'] ?? json;
        if (data is List) {
          return data.map((reviewJson) => ReviewModel.fromJson(reviewJson)).toList();
        }
        return [];
      },
    );
  }

  @override
  Future<List<ReviewModel>> getReviewsByReviewer({
    required String reviewerId,
  }) async {
    return await apiService.get<List<ReviewModel>>(
      path: '/api/reviews/reviewer/$reviewerId',
      fromJson: (json) {
        // json here is already the data array from response.data["data"]
        if (json is List) {
          return json.map((reviewJson) => ReviewModel.fromJson(reviewJson)).toList();
        }
        return [];
      },
    );
  }

  @override
  Future<List<ExtendedReviewModel>> getExtendedReviewsByReviewer({
    required String reviewerId,
  }) async {
    return await apiService.get<List<ExtendedReviewModel>>(
      path: '/api/reviews/reviewer/$reviewerId',
      fromJson: (json) {
        // json here is already the data array from response.data["data"]
        if (json is List) {
          return json.map((reviewJson) => ExtendedReviewModel.fromJson(reviewJson)).toList();
        }
        return [];
      },
    );
  }
}
