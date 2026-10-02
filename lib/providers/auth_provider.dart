import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import '../services/firebase_service.dart';
import '../services/storage_service.dart';

class AuthProvider with ChangeNotifier {
  final StorageService _storageService;
  final FirebaseService _firebaseService = FirebaseService();
  final Uuid _uuid = const Uuid();

  UserModel? _currentUser;
  bool _isAuthenticated = false;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  bool get isFirebaseConnected => _firebaseService.isFirebaseInitialized;

  // Callback to reload user-isolated data when account switches
  Function()? onUserChanged;

  AuthProvider(this._storageService) {
    _loadCurrentSession();
  }

  void _loadCurrentSession() {
    _currentUser = _storageService.getCurrentUser();
    _isAuthenticated = _currentUser != null;
    notifyListeners();
  }

  Future<String?> login({required String email, required String password}) async {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      return 'Email and password cannot be empty';
    }

    _isLoading = true;
    notifyListeners();

    try {
      // 1. Try Real Firebase Auth if initialized
      if (_firebaseService.isFirebaseInitialized) {
        try {
          await _firebaseService.signInWithEmail(email, password);
        } catch (_) {
          // Fallback to local auth if network or demo mode
        }
      }

      // 2. Validate with user database
      final user = _storageService.authenticate(email.trim(), password.trim());
      if (user == null) {
        _isLoading = false;
        notifyListeners();
        return 'Invalid email or password. Please try again.';
      }

      _currentUser = user;
      _isAuthenticated = true;
      _storageService.setCurrentUserId(user.id);
      _isLoading = false;

      // Sync user profile to Firestore
      _firebaseService.syncUserProfileToFirestore(user);

      onUserChanged?.call();
      notifyListeners();
      return null; // Success
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.toString();
    }
  }

  Future<String?> register({
    required String name,
    required String email,
    required String password,
    required String college,
    required String studentId,
  }) async {
    if (name.trim().isEmpty) return 'Please enter your full name';
    if (email.trim().isEmpty || !email.contains('@')) return 'Please enter a valid academic/work email';
    if (password.length < 6) return 'Password must be at least 6 characters long';
    if (college.trim().isEmpty) return 'Please enter your University / College name';

    _isLoading = true;
    notifyListeners();

    try {
      final existingUsers = _storageService.getAllUsers();
      final alreadyExists = existingUsers.any((u) => u.email.toLowerCase() == email.trim().toLowerCase());
      if (alreadyExists) {
        _isLoading = false;
        notifyListeners();
        return 'An account with this email already exists. Please log in.';
      }

      // 1. Register with Firebase Auth
      if (_firebaseService.isFirebaseInitialized) {
        try {
          await _firebaseService.signUpWithEmail(email, password);
        } catch (_) {}
      }

      final newUser = UserModel(
        id: _uuid.v4(),
        name: name.trim(),
        email: email.trim(),
        college: college.trim(),
        studentId: studentId.trim().isEmpty ? 'STU-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}' : studentId.trim(),
        role: 'Student Quant Trader',
        registeredAt: DateTime.now(),
      );

      _storageService.registerUser(newUser, password.trim());
      _currentUser = newUser;
      _isAuthenticated = true;
      _storageService.setCurrentUserId(newUser.id);
      _isLoading = false;

      // Sync new user to Cloud Firestore
      _firebaseService.syncUserProfileToFirestore(newUser);

      onUserChanged?.call();
      notifyListeners();
      return null; // Success
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.toString();
    }
  }

  Future<void> logout() async {
    await _firebaseService.signOut();
    _currentUser = null;
    _isAuthenticated = false;
    _storageService.setCurrentUserId(null);
    onUserChanged?.call();
    notifyListeners();
  }
}
