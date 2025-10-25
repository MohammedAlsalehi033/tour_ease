import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tour_ease/controller/userManagment//JWTController.dart';
import 'package:tour_ease/model/userManagment/UserRepo.dart';
import 'package:tour_ease/model/userManagment/user.dart';

abstract class SignUp {
  Future<UserModel> signUpWithEmailAndPassword(String email, String password);
}

class SignUpWithFireBaseController implements SignUp {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserRepo userRepo;

  SignUpWithFireBaseController(this.userRepo);

  @override
  Future<UserModel> signUpWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (_auth.currentUser == null) {
        throw Exception('Firebase user creation failed');
      }


      final user = UserModel();

      user.updateUser(
        id: _auth.currentUser!.uid,
        email: email,
        accountStatus: "active",
      );

      final apiResponse = await userRepo.createUser(user);

      if (apiResponse.statusCode == 200 || apiResponse.statusCode == 201) {
        return user;
      } else {
        // If backend creation fails, delete the Firebase user to maintain consistency
        await _auth.currentUser?.delete();
        throw Exception('Failed to create user in the database');
      }
    } catch (e) {
      print('Error during sign-up: $e');
      rethrow;
    }
  }


  // Future<void> testForJWT() async {
  //   final dio = Dio();
  //   final idToken = await getFirebaseIdToken();
  //   try {
  //     final response = await dio.post(
  //       'http://10.0.2.2:3000/verifyJWT',
  //       options: Options(
  //         headers: {
  //           'Authorization': 'Bearer $idToken',
  //         },
  //       ),
  //       // Add the required body data
  //       data: {
  //         'name': 'Test User',
  //         'email': 'test@example.com',
  //       },
  //     );
  //     print('Response: ${response.data}');
  //   } on DioException catch (e) {
  //     // Add more detailed error logging
  //     if (e.response != null) {
  //       print('Error status: ${e.response?.statusCode}');
  //       print('Error data: ${e.response?.data}');
  //     } else {
  //       print('Error: ${e.message}');
  //     }
  //     print('Request details: ${e.requestOptions.uri}');
  //     print('Request headers: ${e.requestOptions.headers}');
  //   }
  // }

}