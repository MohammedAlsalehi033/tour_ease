import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tour_ease/model/userManagment/user.dart';

class UserInitializer {
  Future<void> initializeUser() async {
    final dio = Dio();
    final currentUser = FirebaseAuth.instance.currentUser;
    print("currentUser1: $currentUser");

    if (currentUser == null) {

      print("No Firebase user found.");
      return;
    }

    try {
      final response = await dio.get(
        'https://api.tourease.me/api/getUserById',
        queryParameters: {
          "id": currentUser.uid,
        },
        options: Options(
          headers: {
            'Cache-Control': 'no-cache, no-store, must-revalidate',
            'Pragma': 'no-cache',
            'Expires': '0',
          },
        ),
      );

      if (response.statusCode == 200) {
        final responseBody = response.data;
        if (responseBody['success'] == true && responseBody['data'] != null) {
          UserModel.fromJson(responseBody['data']);
        } else {
          throw Exception(
              'API Error: ${responseBody['message'] ?? "Unknown error"}');
        }
      } else {
        throw Exception('Server Error: Status Code ${response.statusCode}');
      }
    } catch (error) {
      print("Error initializing user: $error");
      throw Exception('Failed to initialize user data.');
    }
  }
}