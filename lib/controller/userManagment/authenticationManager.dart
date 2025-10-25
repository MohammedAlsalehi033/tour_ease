import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tour_ease/model/userManagment/user.dart';
import 'package:tour_ease/controller/userManagment/initialize.dart';

class AuthenticationManager {
  static final AuthenticationManager _instance = AuthenticationManager._internal();
  factory AuthenticationManager() => _instance;
  AuthenticationManager._internal();

  final StreamController<User?> _authStateController = StreamController<User?>.broadcast();
  final StreamController<UserModel?> _userDataController = StreamController<UserModel?>.broadcast();
  
  Stream<User?> get authStateStream => _authStateController.stream;
  Stream<UserModel?> get userDataStream => _userDataController.stream;
  
  User? _currentFirebaseUser;
  UserModel? _currentUserData;
  bool _isInitialized = false;
  
  User? get currentFirebaseUser => _currentFirebaseUser;
  UserModel? get currentUserData => _currentUserData;
  String? get currentUserId => _currentFirebaseUser?.uid;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    // Listen to Firebase auth state changes
    FirebaseAuth.instance.authStateChanges().listen(_onAuthStateChanged);
    
    // Set initial state
    _currentFirebaseUser = FirebaseAuth.instance.currentUser;
    if (_currentFirebaseUser != null) {
      await _initializeUserData();
    }
    _isInitialized = true;
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    print('Auth state changed: ${firebaseUser?.uid}');
    
    if (firebaseUser == null) {
      // User logged out
      _currentFirebaseUser = null;
      _currentUserData = null;
      UserModel().clear(); // Clear the singleton
    } else if (_currentFirebaseUser?.uid != firebaseUser.uid) {
      // Different user logged in
      _currentFirebaseUser = firebaseUser;
      await _initializeUserData();
    }
    
    _authStateController.add(firebaseUser);
    _userDataController.add(_currentUserData);
  }

  Future<void> _initializeUserData() async {
    if (_currentFirebaseUser == null) return;
    
    try {
      print('Initializing user data for: ${_currentFirebaseUser!.uid}');
      
      // Clear existing data first to prevent stale data
      UserModel().clear();
      
      // Initialize user data from API
      await UserInitializer().initializeUser();
      
      // Verify the user ID matches Firebase
      if (UserModel().id != _currentFirebaseUser!.uid) {
        print('WARNING: UserModel ID (${UserModel().id}) does not match Firebase UID (${_currentFirebaseUser!.uid})');
        // Force sync the ID
        UserModel().updateUser(id: _currentFirebaseUser!.uid);
      }
      
      _currentUserData = UserModel();
      print('User data initialized successfully for: ${_currentUserData?.id}');
      
    } catch (e) {
      print('Error initializing user data: $e');
      // Fallback: create minimal user data from Firebase user
      UserModel().updateUser(
        id: _currentFirebaseUser!.uid,
        email: _currentFirebaseUser!.email ?? '',
      );
      _currentUserData = UserModel();
    }
  }

  Future<void> refreshUserData() async {
    if (_currentFirebaseUser != null) {
      await _initializeUserData();
    }
  }

  void dispose() {
    _authStateController.close();
    _userDataController.close();
  }
}