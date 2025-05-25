import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:green_urban_connect/data/models/user_model.dart';

abstract class FirebaseAuthSource {
  Future<UserModel?> signUpWithEmailPassword(String email, String password, String? displayName);
  Future<UserModel?> signInWithEmailPassword(String email, String password);
  Future<void> signOut();
  UserModel? getCurrentUser();
  Stream<UserModel?> get userStream;
}

class FirebaseAuthSourceImpl implements FirebaseAuthSource {
  final fb_auth.FirebaseAuth _firebaseAuth;

  FirebaseAuthSourceImpl(this._firebaseAuth);

  @override
  Future<UserModel?> signUpWithEmailPassword(String email, String password, String? displayName) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user != null) {
        if (displayName != null && displayName.isNotEmpty) {
          await userCredential.user!.updateDisplayName(displayName);
        }
        // You might want to create a user document in Firestore here as well
        return UserModel.fromFirebaseUser(userCredential.user!);
      }
      return null;
    } on fb_auth.FirebaseAuthException catch (e) {
      // Handle specific Firebase Auth exceptions (e.g., email-already-in-use)
      print("FirebaseAuthException on sign up: ${e.message}");
      throw Exception(e.message); // Re-throw to be caught by ViewModel
    } catch (e) {
      print("Unknown error on sign up: $e");
      throw Exception("An unknown error occurred during sign up.");
    }
  }

  @override
  Future<UserModel?> signInWithEmailPassword(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user != null ? UserModel.fromFirebaseUser(userCredential.user!) : null;
    } on fb_auth.FirebaseAuthException catch (e) {
      // Handle specific Firebase Auth exceptions (e.g., user-not-found, wrong-password)
      print("FirebaseAuthException on sign in: ${e.message}");
      throw Exception(e.message);
    } catch (e) {
      print("Unknown error on sign in: $e");
      throw Exception("An unknown error occurred during sign in.");
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      print("Error signing out: $e");
      throw Exception("Error signing out.");
    }
  }

  @override
  UserModel? getCurrentUser() {
    final user = _firebaseAuth.currentUser;
    return user != null ? UserModel.fromFirebaseUser(user) : null;
  }

  @override
  Stream<UserModel?> get userStream {
    return _firebaseAuth.authStateChanges().map((firebaseUser) {
      return firebaseUser != null ? UserModel.fromFirebaseUser(firebaseUser) : null;
    });
  }
}