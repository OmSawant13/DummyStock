import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../firebase_options.dart';
import '../models/user_model.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  bool _isFirebaseInitialized = false;
  bool get isFirebaseInitialized => _isFirebaseInitialized;

  FirebaseAuth? _auth;
  FirebaseFirestore? _firestore;

  FirebaseAuth? get auth => _auth;
  FirebaseFirestore? get firestore => _firestore;

  Future<void> initialize() async {
    try {
      if (kIsWeb) {
        // On web, attempt initialization safely
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ).timeout(const Duration(seconds: 3));
      } else {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      _auth = FirebaseAuth.instance;
      _firestore = FirebaseFirestore.instance;
      _isFirebaseInitialized = true;
    } catch (e) {
      // Graceful fallback to resilient offline database if Firebase config is unavailable
      _isFirebaseInitialized = false;
    }
  }

  // --- Real Firebase Authentication ---

  Future<UserCredential?> signUpWithEmail(String email, String password) async {
    if (!_isFirebaseInitialized || _auth == null) return null;
    try {
      return await _auth!.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<UserCredential?> signInWithEmail(String email, String password) async {
    if (!_isFirebaseInitialized || _auth == null) return null;
    try {
      return await _auth!.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    if (_isFirebaseInitialized && _auth != null) {
      await _auth!.signOut();
    }
  }

  User? get currentFirebaseUser => _auth?.currentUser;

  // --- Real Cloud Firestore Operations ---

  Future<void> syncUserProfileToFirestore(UserModel user) async {
    if (!_isFirebaseInitialized || _firestore == null) return;
    try {
      await _firestore!.collection('users').doc(user.id).set(user.toJson(), SetOptions(merge: true));
    } catch (_) {}
  }

  Future<void> syncPortfolioToFirestore(String userId, Map<String, dynamic> portfolioData) async {
    if (!_isFirebaseInitialized || _firestore == null) return;
    try {
      await _firestore!.collection('portfolios').doc(userId).set(portfolioData, SetOptions(merge: true));
    } catch (_) {}
  }

  Future<void> logTradeToFirestore(String userId, Map<String, dynamic> tradeData) async {
    if (!_isFirebaseInitialized || _firestore == null) return;
    try {
      await _firestore!.collection('trades').add({
        'userId': userId,
        ...tradeData,
        'cloudSyncedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }
}
