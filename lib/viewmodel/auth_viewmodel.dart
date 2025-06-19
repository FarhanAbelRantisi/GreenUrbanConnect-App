import 'package:flutter/material.dart';
import 'package:green_urban_connect/data_domain/models/user_model.dart';
import 'package:green_urban_connect/data_domain/usecases/auth_usecases.dart';

enum AuthStatus { unknown, authenticated, unauthenticated, loading, error }

class AuthViewModel extends ChangeNotifier {
  final SignUpUseCase _signUpUseCase;
  final SignInUseCase _signInUseCase;
  final SignOutUseCase _signOutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final GetUserStreamUseCase _getUserStreamUseCase;

  AuthViewModel({
    required SignUpUseCase signUpUseCase,
    required SignInUseCase signInUseCase,
    required SignOutUseCase signOutUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required GetUserStreamUseCase getUserStreamUseCase,
  })  : _signUpUseCase = signUpUseCase,
        _signInUseCase = signInUseCase,
        _signOutUseCase = signOutUseCase,
        _getCurrentUserUseCase = getCurrentUserUseCase,
        _getUserStreamUseCase = getUserStreamUseCase {
    _listenToAuthChanges(); // Start listening to auth state immediately
  }

  AuthStatus _status = AuthStatus.unknown;
  UserModel? _currentUser;
  String? _errorMessage;

  AuthStatus get status => _status;
  UserModel? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == AuthStatus.loading;

  Stream<UserModel?> get userStream => _getUserStreamUseCase();

  void _listenToAuthChanges() {
    _status = AuthStatus.loading;
    notifyListeners();
    _getUserStreamUseCase().listen((user) {
      _currentUser = user;
      _status = user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
      _errorMessage = null; // Clear error on successful auth change
      notifyListeners();
    }).onError((error) {
      _currentUser = null;
      _status = AuthStatus.error;
      _errorMessage = "Auth stream error: ${error.toString()}";
      notifyListeners();
    });
  }

  Future<void> signUp(String email, String password, String displayName) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      _currentUser = await _signUpUseCase(email, password, displayName);
      if (_currentUser != null) {
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated; // Should not happen if signUpUseCase returns null on failure
        _errorMessage = "Sign up failed. Please try again.";
      }
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<void> signIn(String email, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      _currentUser = await _signInUseCase(email, password);
      if (_currentUser != null) {
        _status = AuthStatus.authenticated;
      } else {
        // This case might occur if signInUseCase returns null without throwing
        _status = AuthStatus.unauthenticated;
        _errorMessage = "Sign in failed. Please check your credentials.";
      }
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<void> signOut() async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      await _signOutUseCase();
      _currentUser = null;
      _status = AuthStatus.unauthenticated;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  // Method to manually check current user if needed, though stream is preferred
  void checkCurrentUser() {
    _currentUser = _getCurrentUserUseCase();
    _status = _currentUser != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
    notifyListeners();
  }
}