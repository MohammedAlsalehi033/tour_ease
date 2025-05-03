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
  final String baseUrl;
  final Dio dio = Dio();

  OfferRepoNodeJSApi(this.apiService) : baseUrl = apiService.baseUrl;

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

    final data =  {
      "page": page,
    "limit": limit,
    "sort": sort,
    "senderId": senderId,
    "recipientId": recipientId,
    "status": status,
    "listingId": listingId,
    "requestId": requestId,
  };

    try {
      final response = await dio.get(
          '$baseUrl/api/offers',
          options: Options(contentType: "application/json"),

      );
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final offers = (data['data'] as List)

              .map((offer) => OfferModel.fromJson(offer))

              .toList();
          return offers;
        } else {
          throw Exception('API request was not successful');
        }
      } else {
        throw Exception('Failed to load offers: ${response.statusCode}');
      }
    } catch (e) {

      throw Exception('Error fetching offers: $e');
    }
  }

  @override
  Future<OfferModel> getOfferById(int id) async {
    try {
      final response = await dio.get(
        '$baseUrl/api/offers/$id',
        options: Options(contentType: "application/json"),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return OfferModel.fromJson(data['data']);
        } else {
          throw Exception('API request was not successful');
        }
      } else {
        throw Exception('Failed to load offer: ${response.statusCode}');
      }
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
      print(recipientId);
      print(senderId);
      final response = await dio.post(
          '$baseUrl/api/offers',
          options: Options(contentType: "application/json"),
          data: {
            "senderId": senderId,
            "recipientId": recipientId,
            "pricePerSeat": pricePerSeat,
            "seatsRequested": seatsRequested,
            "message": message,
            "transportationListingId": transportationListingId,
            "transportationRequestId": transportationRequestId,
          }
      );

      if (response.statusCode == 201) {
        final data = response.data;
        if (data['success'] == true) {
          return OfferModel.fromJson(data['data']);
        } else {
          throw Exception('API request was not successful');
        }
      } else {
        throw Exception('Failed to create offer: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating offer: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> acceptOffer(int id) async {
    try {
      final response = await dio.put(
        '$baseUrl/api/offers/$id/accept',
        options: Options(contentType: "application/json"),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return {
            'offer': OfferModel.fromJson(data['data']['offer']),
            'booking': data['data']['booking'],
            'message': data['data']['message'],
          };
        } else {
          throw Exception('API request was not successful');
        }
      } else {
        throw Exception('Failed to accept offer: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error accepting offer: $e');
    }
  }

  @override
  Future<OfferModel> rejectOffer(int id) async {
    try {
      final response = await dio.put(
        '$baseUrl/api/offers/$id/reject',
        options: Options(contentType: "application/json"),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return OfferModel.fromJson(data['data']);
        } else {
          throw Exception('API request was not successful');
        }
      } else {
        throw Exception('Failed to reject offer: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error rejecting offer: $e');
    }
  }

  @override
  Future<List<OfferModel>> getReceivedOffers(String userId, {int page = 1, int limit = 10, String? status}) async {
    try {
      String url = '$baseUrl/api/users/$userId/received-offers?page=$page&limit=$limit';
      if (status != null) {
        url += '&status=$status';
      }

      final response = await dio.get(
        url,
        options: Options(contentType: "application/json"),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final offers = (data['data'] as List)
              .map((offer) => OfferModel.fromJson(offer))
              .toList();
          return offers;
        } else {
          throw Exception('API request was not successful');
        }
      } else {
        throw Exception('Failed to load received offers: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching received offers: $e');
    }
  }

  @override
  Future<List<OfferModel>> getSentOffers(String userId, {int page = 1, int limit = 10, String? status}) async {
    try {
      String url = '$baseUrl/api/users/$userId/sent-offers?page=$page&limit=$limit';
      if (status != null) {
        url += '&status=$status';
      }

      final response = await dio.get(
        url,
        options: Options(contentType: "application/json"),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final offers = (data['data'] as List)
              .map((offer) => OfferModel.fromJson(offer))
              .toList();
          return offers;
        } else {
          throw Exception('API request was not successful');
        }
      } else {
        throw Exception('Failed to load sent offers: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching sent offers: $e');
    }
  }

  @override
  Future<List<OfferModel>> getOffersForListing(int listingId, {int page = 1, int limit = 10, String? status}) async {
    try {
      String url = '$baseUrl/api/listings/$listingId/offers?page=$page&limit=$limit';
      if (status != null) {
        url += '&status=$status';
      }

      final response = await dio.get(
        url,
        options: Options(contentType: "application/json"),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final offers = (data['data'] as List)
              .map((offer) => OfferModel.fromJson(offer))
              .toList();
          return offers;
        } else {
          throw Exception('API request was not successful');
        }
      } else {
        throw Exception('Failed to load listing offers: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching listing offers: $e');
    }
  }

  @override
  Future<List<OfferModel>> getOffersForRequest(int requestId, {int page = 1, int limit = 10, String? status}) async {
    try {
      String url = '$baseUrl/api/requests/$requestId/offers?page=$page&limit=$limit';
      if (status != null) {
        url += '&status=$status';
      }

      final response = await dio.get(
        url,
        options: Options(contentType: "application/json"),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final offers = (data['data'] as List)
              .map((offer) => OfferModel.fromJson(offer))
              .toList();
          return offers;
        } else {
          throw Exception('API request was not successful');
        }
      } else {
        throw Exception('Failed to load request offers: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching request offers: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getUserOfferStats(String userId) async {
    try {
      final response = await dio.get(
        '$baseUrl/api/users/$userId/offer-stats',
        options: Options(contentType: "application/json"),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return data['data'];
        } else {
          throw Exception('API request was not successful');
        }
      } else {
        throw Exception('Failed to load user offer stats: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching user offer stats: $e');
    }
  }
}