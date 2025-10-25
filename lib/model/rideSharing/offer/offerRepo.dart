import 'package:dio/dio.dart';
import 'package:tour_ease/Services/ApiService.dart';
import 'package:tour_ease/model/rideSharing/offer/offerModel.dart';

abstract class OffersRepo {
  Future<List<OfferModel>> getAllOffers({
    int page = 1,
    int limit = 10,
    String sort = 'newest',
    String? senderId,
    String? recipientId,
    String? status,
    int? listingId,
    int? requestId
  });
  Future<OfferModel> getOfferById(int id);
  Future<OfferModel> createOffer({
    required String senderId,
    required String recipientId,
    required double pricePerSeat,
    required int seatsRequested,
    String? message,
    int? transportationListingId,
    int? transportationRequestId
  });
  Future<Map<String, dynamic>> acceptOffer(int id);
  Future<OfferModel> rejectOffer(int id);
  Future<List<OfferModel>> getReceivedOffers(String userId, {int page = 1, int limit = 10, String? status});
  Future<List<OfferModel>> getSentOffers(String userId, {int page = 1, int limit = 10, String? status});
  Future<List<OfferModel>> getOffersForListing(int listingId, {int page = 1, int limit = 10, String? status});
  Future<List<OfferModel>> getOffersForRequest(int requestId, {int page = 1, int limit = 10, String? status});
  Future<Map<String, dynamic>> getUserOfferStats(String userId);
}

class OfferRepoNodeJSApi extends OffersRepo {
  final APIService apiService;

  OfferRepoNodeJSApi(this.apiService);

  @override
  Future<List<OfferModel>> getAllOffers({
    int page = 1,
    int limit = 10,
    String sort = 'newest',
    String? senderId,
    String? recipientId,
    String? status,
    int? listingId,
    int? requestId
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page.toString(),
        'limit': limit.toString(),
        'sort': sort,
      };
      if (senderId != null) queryParams['senderId'] = senderId;
      if (recipientId != null) queryParams['recipientId'] = recipientId;
      if (status != null) queryParams['status'] = status;
      if (listingId != null) queryParams['listingId'] = listingId.toString();
      if (requestId != null) queryParams['requestId'] = requestId.toString();

      return await apiService.get<List<OfferModel>>(
        path: '/api/offers',
        queryParams: queryParams,
        fromJson: (json) => (json as List).map((offer) => OfferModel.fromJson(offer)).toList(),
      );
    } catch (e) {
      throw Exception('Error fetching offers: $e');
    }
  }

  @override
  Future<OfferModel> getOfferById(int id) async {
    try {
      return await apiService.get<OfferModel>(
        path: '/api/offers/$id',
        fromJson: (json) => OfferModel.fromJson(json),
      );
    } catch (e) {
      throw Exception('Error fetching offer: $e');
    }
  }

  @override
  Future<OfferModel> createOffer({
    required String senderId,
    required String recipientId,
    required double pricePerSeat,
    required int seatsRequested,
    String? message,
    int? transportationListingId,
    int? transportationRequestId
  }) async {
    try {
      final body = <String, dynamic>{
        'senderId': senderId,
        'recipientId': recipientId,
        'pricePerSeat': pricePerSeat,
        'seatsRequested': seatsRequested,
      };
      if (message != null) body['message'] = message;
      if (transportationListingId != null) body['transportationListingId'] = transportationListingId;
      if (transportationRequestId != null) body['transportationRequestId'] = transportationRequestId;

      return await apiService.post<OfferModel>(
        path: '/api/offers',
        body: body,
        fromJson: (json) => OfferModel.fromJson(json['data']),
      );
    } catch (e) {
      throw Exception('Error creating offer: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> acceptOffer(int id) async {
    try {
      return await apiService.put<Map<String, dynamic>>(
        path: '/api/offers/$id/accept',
        body: {},
        fromJson: (json) => json['data'] as Map<String, dynamic>,
      );
    } catch (e) {
      throw Exception('Error accepting offer: $e');
    }
  }

  @override
  Future<OfferModel> rejectOffer(int id) async {
    try {
      return await apiService.put<OfferModel>(
        path: '/api/offers/$id/reject',
        body: {},
        fromJson: (json) => OfferModel.fromJson(json['data']),
      );
    } catch (e) {
      throw Exception('Error rejecting offer: $e');
    }
  }

  @override
  Future<List<OfferModel>> getReceivedOffers(String userId, {int page = 1, int limit = 10, String? status}) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      if (status != null) queryParams['status'] = status;

      return await apiService.get<List<OfferModel>>(
        path: '/api/users/$userId/received-offers',
        queryParams: queryParams,
        fromJson: (json) => (json as List).map((offer) => OfferModel.fromJson(offer)).toList(),
      );
    } catch (e) {
      throw Exception('Error fetching received offers: $e');
    }
  }

  @override
  Future<List<OfferModel>> getSentOffers(String userId, {int page = 1, int limit = 10, String? status}) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      if (status != null) queryParams['status'] = status;

      return await apiService.get<List<OfferModel>>(
        path: '/api/users/$userId/sent-offers',
        queryParams: queryParams,
        fromJson: (json) => (json as List).map((offer) => OfferModel.fromJson(offer)).toList(),
      );
    } catch (e) {
      throw Exception('Error fetching sent offers: $e');
    }
  }

  @override
  Future<List<OfferModel>> getOffersForListing(int listingId, {int page = 1, int limit = 10, String? status}) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      if (status != null) queryParams['status'] = status;

      return await apiService.get<List<OfferModel>>(
        path: '/api/listings/$listingId/offers',
        queryParams: queryParams,
        fromJson: (json) => (json as List).map((offer) => OfferModel.fromJson(offer)).toList(),
      );
    } catch (e) {
      throw Exception('Error fetching listing offers: $e');
    }
  }

  @override
  Future<List<OfferModel>> getOffersForRequest(int requestId, {int page = 1, int limit = 10, String? status}) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      if (status != null) queryParams['status'] = status;

      return await apiService.get<List<OfferModel>>(
        path: '/api/requests/$requestId/offers',
        queryParams: queryParams,
        fromJson: (json) => (json as List).map((offer) => OfferModel.fromJson(offer)).toList(),
      );
    } catch (e) {
      throw Exception('Error fetching request offers: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getUserOfferStats(String userId) async {
    try {
      return await apiService.get<Map<String, dynamic>>(
        path: '/api/users/$userId/offer-stats',
        fromJson: (json) => json as Map<String, dynamic>,
      );
    } catch (e) {
      throw Exception('Error fetching user offer stats: $e');
    }
  }
}