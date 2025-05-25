import 'package:green_urban_connect/data/models/user_model.dart';
import 'package:green_urban_connect/data/sources/firebase_auth_source.dart';
import 'package:green_urban_connect/domain/repositories/i_auth_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final FirebaseAuthSource _firebaseAuthSource;
  final FirebaseFirestore _firestore;

  AuthRepositoryImpl(this._firebaseAuthSource, this._firestore);

  CollectionReference get _usersCollection => _firestore.collection('users');

  @override
  Future<UserModel?> signUp(String email, String password, String? displayName) async {
    final userModel = await _firebaseAuthSource.signUpWithEmailPassword(email, password, displayName);
    if (userModel != null) {
      // Create a corresponding document in Firestore
      await createUserDocument(userModel);
    }
    return userModel;
  }

  @override
  Future<UserModel?> signIn(String email, String password) {
    return _firebaseAuthSource.signInWithEmailPassword(email, password);
  }

  @override
  Future<void> signOut() {
    return _firebaseAuthSource.signOut();
  }

  @override
  UserModel? getCurrentUser() {
    return _firebaseAuthSource.getCurrentUser();
  }

  @override
  Stream<UserModel?> get userStream {
    return _firebaseAuthSource.userStream;
  }

  @override
  Future<void> createUserDocument(UserModel user) async {
    try {
      // Use .set() with merge: true to create or update the document
      // This is safer if the method might be called multiple times
      await _usersCollection.doc(user.id).set(user.toFirestore(), SetOptions(merge: true));
    } catch (e) {
      print("Error creating user document: $e");
      throw Exception("Could not save user details.");
    }
  }

  @override
  Future<UserModel?> getUserDocument(String userId) async {
    try {
      final docSnapshot = await _usersCollection.doc(userId).get();
      if (docSnapshot.exists) {
        return UserModel.fromFirestore(docSnapshot);
      }
      return null;
    } catch (e) {
      print("Error fetching user document: $e");
      return null; // Or throw an exception
    }
  }
}