import 'package:firebase_auth/firebase_auth.dart';
import 'package:tour_ease/model/tripPlanner/saved_plan_models.dart';
import 'package:tour_ease/Services/ApiService.dart';

class SavedPlansService {
  static const String baseUrl = 'http://localhost:3000';
  
  // Get Firebase ID token and create API service instance
  static Future<APIServiceNodeJS> _getApiService() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    final token = await user.getIdToken();
    return APIServiceNodeJS(baseUrl, token ?? '');
  }

  // Save a new plan
  static Future<SavedPlanResponse> savePlan(SavePlanRequest request) async {
    final apiService = await _getApiService();
    
    return await apiService.post(
      path: '/api/planner/saved',
      body: request.toJson(),
      fromJson: (json) => SavedPlanResponse.fromJson(json),
    );
  }

  // Get all saved plans with optional filters
  static Future<SavedPlansListResponse> getSavedPlans({
    String? status,
    String? startLocation,
    String? endLocation,
    int? minBudget,
    int? maxBudget,
    String? tags,
    int page = 1,
    int limit = 10,
  }) async {
    final apiService = await _getApiService();

    final queryParams = <String, dynamic>{};
    if (status != null) queryParams['status'] = status;
    if (startLocation != null) queryParams['startLocation'] = startLocation;
    if (endLocation != null) queryParams['endLocation'] = endLocation;
    if (minBudget != null) queryParams['minBudget'] = minBudget;
    if (maxBudget != null) queryParams['maxBudget'] = maxBudget;
    if (tags != null) queryParams['tags'] = tags;
    queryParams['page'] = page;
    queryParams['limit'] = limit;

    return await apiService.get(
      path: '/api/planner/saved',
      queryParams: queryParams,
      fromJson: (json) => SavedPlansListResponse.fromJson(json),
    );
  }

  // Get a single saved plan by ID
  static Future<SavedPlanDetailResponse> getSavedPlan(int id) async {
    final apiService = await _getApiService();
    
    return await apiService.get(
      path: '/api/planner/saved/$id',
      fromJson: (json) => SavedPlanDetailResponse.fromJson(json),
    );
  }

  // Delete a saved plan
  static Future<void> deleteSavedPlan(int id) async {
    final apiService = await _getApiService();
    
    await apiService.delete(
      path: '/api/planner/saved/$id',
      fromJson: (_) => null,
    );
  }
}
