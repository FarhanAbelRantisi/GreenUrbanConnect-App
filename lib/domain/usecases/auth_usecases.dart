import 'package:green_urban_connect/data/models/user_model.dart';
import 'package:green_urban_connect/domain/repositories/i_auth_repository.dart';

// --- Sign Up Use Case ---
class SignUpUseCase {
  final IAuthRepository repository;
  SignUpUseCase(this.repository);

  Future<UserModel?> call(String email, String password, String? displayName) async {
    return await repository.signUp(email, password, displayName);
  }
}

// --- Sign In Use Case ---
class SignInUseCase {
  final IAuthRepository repository;
  SignInUseCase(this.repository);

  Future<UserModel?> call(String email, String password) async {
    return await repository.signIn(email, password);
  }
}

// --- Sign Out Use Case ---
class SignOutUseCase {
  final IAuthRepository repository;
  SignOutUseCase(this.repository);

  Future<void> call() async {
    return await repository.signOut();
  }
}

// --- Get Current User Use Case ---
class GetCurrentUserUseCase {
  final IAuthRepository repository;
  GetCurrentUserUseCase(this.repository);

  UserModel? call() {
    return repository.getCurrentUser();
  }
}

// --- Get User Stream Use Case ---
class GetUserStreamUseCase {
  final IAuthRepository repository;
  GetUserStreamUseCase(this.repository);

  Stream<UserModel?> call() {
    return repository.userStream;
  }
}