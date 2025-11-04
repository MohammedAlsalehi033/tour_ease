import 'package:tour_ease/Services/ApiService.dart';
import 'package:tour_ease/model/tripPlanner/tripPlannerModels.dart';

abstract class TripPlannerRepository {
  Future<TripPlanResponse> generatePlan(TripPlanRequest request);
  Future<TripPlanResponse> refinePlan({
    required Map<String, dynamic> originalRequest,
    required Map<String, dynamic> currentResults,
    required String userMessage,
  });
  Future<Map<String, dynamic>> confirmBooking({
    required String optionId,
    int? outboundTransportId,
    int? returnTransportId,
    required int seatsNeeded,
    int? accommodationId,
    List<Map<String, int>>? selectedRoomAllocations,
    required DateTime checkInDate,
    required DateTime checkOutDate,
    String? specialRequests,
  });
  Future<SavedTripPlan> saveTripPlan({
    required String planName,
    String? description,
    required int selectedOutboundId,
    int? selectedReturnId,
    int? selectedAccommodationId,
    List<Map<String, int>>? selectedRoomAllocations,
    List<int>? selectedActivities,
    required double totalCost,
    List<String>? tags,
    required Map<String, dynamic> originalSearchParams,
  });
  Future<List<SavedTripPlan>> getSavedPlans({
    String? status,
    String? tag,
    String? sortBy,
    String? order,
  });
  Future<SavedTripPlan> getSavedPlanById(int id);
  Future<SavedTripPlan> updateSavedPlan({
    required int id,
    String? planName,
    String? description,
    int? selectedOutboundId,
    int? selectedReturnId,
    int? selectedAccommodationId,
    List<Map<String, int>>? selectedRoomAllocations,
    List<int>? selectedActivities,
    double? totalCost,
    List<String>? tags,
  });
  Future<void> deleteSavedPlan(int id);
  Future<Map<String, dynamic>> bookSavedPlan(int id);
}

class TripPlannerRepositoryImpl implements TripPlannerRepository {
  final APIService apiService;

  TripPlannerRepositoryImpl({required this.apiService});

  @override
  Future<TripPlanResponse> generatePlan(TripPlanRequest request) async {
    try {
      return await apiService.post<TripPlanResponse>(
        path: "/api/planner/generate",
        body: request.toJson(),
        fromJson: (json) => TripPlanResponse.fromJson(json),
      );
    } catch (e) {
      throw Exception('Failed to generate trip plan: $e');
    }
  }

  @override
  Future<TripPlanResponse> refinePlan({
    required Map<String, dynamic> originalRequest,
    required Map<String, dynamic> currentResults,
    required String userMessage,
  }) async {
    try {
      final response = await apiService.post<Map<String, dynamic>>(
        path: "/api/planner/refine",
        body: {
          'originalRequest': originalRequest,
          'currentResults': currentResults,
          'userMessage': userMessage,
        },
        fromJson: (json) => json,
      );
      
      return TripPlanResponse.fromJson(response['data']['refinedPlans']);
    } catch (e) {
      throw Exception('Failed to refine trip plan: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> confirmBooking({
    required String optionId,
    int? outboundTransportId,
    int? returnTransportId,
    required int seatsNeeded,
    int? accommodationId,
    List<Map<String, int>>? selectedRoomAllocations,
    required DateTime checkInDate,
    required DateTime checkOutDate,
    String? specialRequests,
  }) async {
    try {
      final body = <String, dynamic>{
        'optionId': optionId,
        'seatsNeeded': seatsNeeded,
        'checkInDate': checkInDate.toIso8601String(),
        'checkOutDate': checkOutDate.toIso8601String(),
      };

      if (outboundTransportId != null) body['outboundTransportId'] = outboundTransportId;
      if (returnTransportId != null) body['returnTransportId'] = returnTransportId;
      if (accommodationId != null) body['accommodationId'] = accommodationId;
      if (selectedRoomAllocations != null) body['selectedRoomAllocations'] = selectedRoomAllocations;
      if (specialRequests != null) body['specialRequests'] = specialRequests;

      return await apiService.post<Map<String, dynamic>>(
        path: "/api/planner/confirm",
        body: body,
        fromJson: (json) => json,
      );
    } catch (e) {
      throw Exception('Failed to confirm booking: $e');
    }
  }

  @override
  Future<SavedTripPlan> saveTripPlan({
    required String planName,
    String? description,
    required int selectedOutboundId,
    int? selectedReturnId,
    int? selectedAccommodationId,
    List<Map<String, int>>? selectedRoomAllocations,
    List<int>? selectedActivities,
    required double totalCost,
    List<String>? tags,
    required Map<String, dynamic> originalSearchParams,
  }) async {
    try {
      final body = <String, dynamic>{
        'planName': planName,
        'selectedOutboundId': selectedOutboundId,
        'totalCost': totalCost,
        'originalSearchParams': originalSearchParams,
      };

      if (description != null) body['description'] = description;
      if (selectedReturnId != null) body['selectedReturnId'] = selectedReturnId;
      if (selectedAccommodationId != null) body['selectedAccommodationId'] = selectedAccommodationId;
      if (selectedRoomAllocations != null) body['selectedRoomAllocations'] = selectedRoomAllocations;
      if (selectedActivities != null) body['selectedActivities'] = selectedActivities;
      if (tags != null) body['tags'] = tags;

      return await apiService.post<SavedTripPlan>(
        path: "/api/planner/saved",
        body: body,
        fromJson: (json) => SavedTripPlan.fromJson(json['data']),
      );
    } catch (e) {
      throw Exception('Failed to save trip plan: $e');
    }
  }

  @override
  Future<List<SavedTripPlan>> getSavedPlans({
    String? status,
    String? tag,
    String? sortBy,
    String? order,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (status != null) queryParams['status'] = status;
      if (tag != null) queryParams['tag'] = tag;
      if (sortBy != null) queryParams['sortBy'] = sortBy;
      if (order != null) queryParams['order'] = order;

      return await apiService.get<List<SavedTripPlan>>(
        path: "/api/planner/saved",
        queryParams: queryParams,
        fromJson: (json) {
          final data = json['savedPlans'] as List;
          return data.map((plan) => SavedTripPlan.fromJson(plan)).toList();
        },
      );
    } catch (e) {
      throw Exception('Failed to get saved plans: $e');
    }
  }

  @override
  Future<SavedTripPlan> getSavedPlanById(int id) async {
    try {
      return await apiService.get<SavedTripPlan>(
        path: "/api/planner/saved/$id",
        fromJson: (json) => SavedTripPlan.fromJson(json),
      );
    } catch (e) {
      throw Exception('Failed to get saved plan: $e');
    }
  }

  @override
  Future<SavedTripPlan> updateSavedPlan({
    required int id,
    String? planName,
    String? description,
    int? selectedOutboundId,
    int? selectedReturnId,
    int? selectedAccommodationId,
    List<Map<String, int>>? selectedRoomAllocations,
    List<int>? selectedActivities,
    double? totalCost,
    List<String>? tags,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (planName != null) body['planName'] = planName;
      if (description != null) body['description'] = description;
      if (selectedOutboundId != null) body['selectedOutboundId'] = selectedOutboundId;
      if (selectedReturnId != null) body['selectedReturnId'] = selectedReturnId;
      if (selectedAccommodationId != null) body['selectedAccommodationId'] = selectedAccommodationId;
      if (selectedRoomAllocations != null) body['selectedRoomAllocations'] = selectedRoomAllocations;
      if (selectedActivities != null) body['selectedActivities'] = selectedActivities;
      if (totalCost != null) body['totalCost'] = totalCost;
      if (tags != null) body['tags'] = tags;

      return await apiService.put<SavedTripPlan>(
        path: "/api/planner/saved/$id",
        body: body,
        fromJson: (json) => SavedTripPlan.fromJson(json['data']),
      );
    } catch (e) {
      throw Exception('Failed to update saved plan: $e');
    }
  }

  @override
  Future<void> deleteSavedPlan(int id) async {
    try {
      await apiService.delete<void>(
        path: "/api/planner/saved/$id",
        fromJson: (_) {},
      );
    } catch (e) {
      throw Exception('Failed to delete saved plan: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> bookSavedPlan(int id) async {
    try {
      return await apiService.post<Map<String, dynamic>>(
        path: "/api/planner/saved/$id/book",
        body: {},
        fromJson: (json) => json,
      );
    } catch (e) {
      throw Exception('Failed to book saved plan: $e');
    }
  }
}
