import 'package:green_urban_connect/data/models/user_model.dart';

abstract class IAuthRepository {
  Future<UserModel?> signUp(String email, String password, String? displayName);
  Future<UserModel?> signIn(String email, String password);
  Future<void> signOut();
  UserModel? getCurrentUser();
  Stream<UserModel?> get userStream; // Stream to listen for auth state changes
  Future<void> createUserDocument(UserModel user); // To store additional user data
  Future<UserModel?> getUserDocument(String userId);
}