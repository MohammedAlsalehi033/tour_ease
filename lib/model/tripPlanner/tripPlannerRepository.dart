import 'package:tour_ease/Services/ApiService.dart';
import 'package:tour_ease/model/tripPlanner/tripPlannerModels.dart';

abstract class TripPlannerRepository {
  Future<TripPlannerResponse> generatePlan(TripSearchParams request);
  Future<TripPlannerResponse> refinePlan({
    required Map<String, dynamic> originalRequest,
    required Map<String, dynamic> currentResults,
    required String userMessage,
  });
  Future<BookingConfirmation> confirmBooking(BookingRequest request);
  Future<SavedPlan> savePlan(SavePlanRequest request);
  Future<List<SavedPlan>> getSavedPlans({
    String? status,
    String? tag,
    String? sortBy,
    String? order,
  });
  Future<SavedPlan> getSavedPlanById(int id);
  Future<SavedPlan> updateSavedPlan({
    required int id,
    String? planName,
    String? description,
    int? selectedOutboundId,
    int? selectedReturnId,
    int? selectedAccommodationId,
    List<RoomSelection>? selectedRoomAllocations,
    List<int>? selectedActivities,
    double? totalCost,
    List<String>? tags,
  });
  Future<void> deleteSavedPlan(int id);
  Future<BookingConfirmation> bookSavedPlan(int id);
}

class TripPlannerRepositoryImpl implements TripPlannerRepository {
  final APIService apiService;

  TripPlannerRepositoryImpl({required this.apiService});

  @override
  Future<TripPlannerResponse> generatePlan(TripSearchParams request) async {
    try {
      return await apiService.post<TripPlannerResponse>(
        path: "/api/planner/generate",
        body: request.toJson(),
        fromJson: (json) => TripPlannerResponse.fromJson(json),
      );
    } catch (e) {
      throw Exception('Failed to generate trip plan: $e');
    }
  }

  @override
  Future<TripPlannerResponse> refinePlan({
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
      
      return TripPlannerResponse.fromJson(response['data']['refinedPlans']);
    } catch (e) {
      throw Exception('Failed to refine trip plan: $e');
    }
  }

  @override
  Future<BookingConfirmation> confirmBooking(BookingRequest request) async {
    try {
      return await apiService.post<BookingConfirmation>(
        path: "/api/planner/confirm",
        body: request.toJson(),
        fromJson: (json) => BookingConfirmation.fromJson(json),
      );
    } catch (e) {
      throw Exception('Failed to confirm booking: $e');
    }
  }

  @override
  Future<SavedPlan> savePlan(SavePlanRequest request) async {
    try {
      return await apiService.post<SavedPlan>(
        path: "/api/planner/saved",
        body: request.toJson(),
        fromJson: (json) => SavedPlan.fromJson(json),
      );
    } catch (e) {
      throw Exception('Failed to save trip plan: $e');
    }
  }

  @override
  Future<List<SavedPlan>> getSavedPlans({
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

      return await apiService.get<List<SavedPlan>>(
        path: "/api/planner/saved",
        queryParams: queryParams,
        fromJson: (json) {
          if (json is List) {
            return json.map((plan) => SavedPlan.fromJson(plan)).toList();
          }
          return [];
        },
      );
    } catch (e) {
      throw Exception('Failed to get saved plans: $e');
    }
  }

  @override
  Future<SavedPlan> getSavedPlanById(int id) async {
    try {
      return await apiService.get<SavedPlan>(
        path: "/api/planner/saved/$id",
        fromJson: (json) => SavedPlan.fromJson(json),
      );
    } catch (e) {
      throw Exception('Failed to get saved plan: $e');
    }
  }

  @override
  Future<SavedPlan> updateSavedPlan({
    required int id,
    String? planName,
    String? description,
    int? selectedOutboundId,
    int? selectedReturnId,
    int? selectedAccommodationId,
    List<RoomSelection>? selectedRoomAllocations,
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
      if (selectedRoomAllocations != null) body['selectedRoomAllocations'] = selectedRoomAllocations.map((e) => e.toJson()).toList();
      if (selectedActivities != null) body['selectedActivities'] = selectedActivities;
      if (totalCost != null) body['totalCost'] = totalCost;
      if (tags != null) body['tags'] = tags;

      return await apiService.put<SavedPlan>(
        path: "/api/planner/saved/$id",
        body: body,
        fromJson: (json) => SavedPlan.fromJson(json),
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
  Future<BookingConfirmation> bookSavedPlan(int id) async {
    try {
      return await apiService.post<BookingConfirmation>(
        path: "/api/planner/saved/$id/book",
        body: {},
        fromJson: (json) => BookingConfirmation.fromJson(json),
      );
    } catch (e) {
      throw Exception('Failed to book saved plan: $e');
    }
  }
}
