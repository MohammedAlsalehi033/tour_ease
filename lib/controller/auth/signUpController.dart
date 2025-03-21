import 'package:firebase_auth/firebase_auth.dart';
import 'package:tour_ease/model/auth/UserRepo.dart';
import 'package:tour_ease/model/auth/user.dart' as myuser;

abstract class SignUp {
  Future<myuser.User> signUpWithEmailAndPassword(String email, String password);
}

class SignUpWithFireBaseController implements SignUp {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserRepo userRepo;

  SignUpWithFireBaseController(this.userRepo);

  @override
  Future<myuser.User> signUpWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (_auth.currentUser == null) {
        throw Exception('Firebase user creation failed');
      }

      final user = myuser.User();
      user.updateUser(
        id: _auth.currentUser?.uid.toString(),
        email: email,
        accountStatus: "Active",
      );

      final apiResponse = await userRepo.createUser(user);

      if (apiResponse.statusCode == 200 || apiResponse.statusCode == 201) {
        return user;
      } else {
        await _auth.currentUser?.delete();
        throw Exception('Failed to create user in the database');
      }
    } catch (e) {
      print('Error during sign-up: $e');
      rethrow;
    }
  }
}