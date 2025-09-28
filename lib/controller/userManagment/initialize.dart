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

    final String firebaseUid = currentUser.uid;
    print("Initializing user data for Firebase UID: $firebaseUid");

    try {
      final response = await dio.get(
        'https://api.tourease.me/api/getUserById',
        queryParameters: {
          "id": firebaseUid,
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
          final userData = responseBody['data'];
          
          // Ensure the API response user ID matches Firebase UID
          if (userData['id'] != firebaseUid) {
            print("WARNING: API user ID (${userData['id']}) doesn't match Firebase UID ($firebaseUid)");
            // Force the correct ID
            userData['id'] = firebaseUid;
          }
          
          UserModel.fromJson(userData);
          print("User data loaded successfully for: ${UserModel().id}");
        } else {
          throw Exception(
              'API Error: ${responseBody['message'] ?? "Unknown error"}');
        }
      } else {
        throw Exception('Server Error: Status Code ${response.statusCode}');
      }
    } catch (error) {
      print("Error initializing user: $error");
      
      // Fallback: Create minimal user data from Firebase
      UserModel().updateUser(
        id: firebaseUid,
        email: currentUser.email ?? '',
        username: currentUser.email ?? '',
      );
      print("Fallback user data created for: $firebaseUid");
    }
  }
}