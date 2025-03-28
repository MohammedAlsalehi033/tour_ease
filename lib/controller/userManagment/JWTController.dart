import 'package:firebase_auth/firebase_auth.dart';

Future<String?> getFirebaseIdToken() async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    String? idToken = await user.getIdToken();
    return idToken;
  }
  return null;
}