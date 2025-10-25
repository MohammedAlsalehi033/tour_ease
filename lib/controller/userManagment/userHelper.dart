import 'package:firebase_auth/firebase_auth.dart';
import 'package:tour_ease/model/userManagment/user.dart';
import 'package:tour_ease/controller/userManagment/authenticationManager.dart';

class UserHelper {
  /// Safely get the current user ID
  /// Returns Firebase UID as the source of truth, falls back to UserModel if needed
  static String? getCurrentUserId() {
    // Primary source: Firebase Auth (most reliable)
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      return firebaseUser.uid;
    }
    
    // Fallback: UserModel singleton (if Firebase user is null for some reason)
    final userModelId = UserModel().id;
    if (userModelId.isNotEmpty) {
      return userModelId;
    }
    
    // No authenticated user
    return null;
  }

  /// Get current user ID with error handling
  /// Throws exception if no user is authenticated
  static String getCurrentUserIdOrThrow() {
    final userId = getCurrentUserId();
    if (userId == null || userId.isEmpty) {
      throw Exception('No authenticated user found. User must be logged in.');
    }
    return userId;
  }

  /// Check if user is properly authenticated and initialized
  static bool isUserAuthenticated() {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final userModelId = UserModel().id;
    
    return firebaseUser != null && 
           userModelId.isNotEmpty && 
           firebaseUser.uid == userModelId;
  }

  /// Verify user ID consistency between Firebase and UserModel
  static bool isUserIdConsistent() {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final userModelId = UserModel().id;
    
    if (firebaseUser == null) return userModelId.isEmpty;
    return firebaseUser.uid == userModelId;
  }

  /// Force sync UserModel with Firebase Auth state
  static void syncUserModel() {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      if (UserModel().id != firebaseUser.uid) {
        print('Syncing UserModel ID from ${UserModel().id} to ${firebaseUser.uid}');
        UserModel().updateUser(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? UserModel().email,
        );
      }
    } else {
      UserModel().clear();
    }
  }
}