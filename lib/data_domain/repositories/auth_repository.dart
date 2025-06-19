import 'package:green_urban_connect/data_domain/models/user_model.dart';
import 'package:green_urban_connect/data_domain/sources/firebase_auth_source.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class IAuthRepository {
  Future<UserModel?> signUp(String email, String password, String? displayName);
  Future<UserModel?> signIn(String email, String password);
  Future<void> signOut();
  UserModel? getCurrentUser();
  Stream<UserModel?> get userStream;
  Future<void> createUserDocument(UserModel user);
  Future<UserModel?> getUserDocument(String userId);
}

class AuthRepositoryImpl implements IAuthRepository {
  final FirebaseAuthSource _firebaseAuthSource;
  final FirebaseFirestore _firestore;

  AuthRepositoryImpl(this._firebaseAuthSource, this._firestore);

  CollectionReference get _usersCollection => _firestore.collection('users');

  @override
  Future<UserModel?> signUp(String email, String password, String? displayName) async {
    final userModel = await _firebaseAuthSource.signUpWithEmailPassword(email, password, displayName);
    if (userModel != null) {
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
      return null;
    }
  }
}