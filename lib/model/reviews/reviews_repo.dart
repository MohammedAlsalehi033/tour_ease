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
      path: '/api/reviews/stats/TRANSPORTATION_LISTING/$driverId',
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
}


