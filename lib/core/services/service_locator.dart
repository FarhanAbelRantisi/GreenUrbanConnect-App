import 'package:get_it/get_it.dart';
import 'package:green_urban_connect/data/repositories/auth_repository_impl.dart';
import 'package:green_urban_connect/data/repositories/initiative_repository_impl.dart';
import 'package:green_urban_connect/data/sources/firebase_auth_source.dart';
import 'package:green_urban_connect/data/sources/firestore_initiative_source.dart';
import 'package:green_urban_connect/domain/repositories/i_auth_repository.dart';
import 'package:green_urban_connect/domain/repositories/i_initiative_repository.dart';
import 'package:green_urban_connect/domain/usecases/auth_usecases.dart';
import 'package:green_urban_connect/domain/usecases/initiative_usecases.dart';
import 'package:green_urban_connect/presentation/viewmodels/auth_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:green_urban_connect/presentation/viewmodels/initiatives_viewmodel.dart';

final sl = GetIt.instance; // sl stands for Service Locator

void setupServiceLocator() {
  // Firebase Instances
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);

  // Data Sources
  sl.registerLazySingleton<FirebaseAuthSource>(() => FirebaseAuthSourceImpl(sl()));

  // Repositories
  sl.registerLazySingleton<IAuthRepository>(() => AuthRepositoryImpl(sl(), sl()));

  // Use Cases
  sl.registerLazySingleton<SignUpUseCase>(() => SignUpUseCase(sl()));
  sl.registerLazySingleton<SignInUseCase>(() => SignInUseCase(sl()));
  sl.registerLazySingleton<SignOutUseCase>(() => SignOutUseCase(sl()));
  sl.registerLazySingleton<GetCurrentUserUseCase>(() => GetCurrentUserUseCase(sl()));
  sl.registerLazySingleton<GetUserStreamUseCase>(() => GetUserStreamUseCase(sl()));

  // ViewModels
  sl.registerLazySingleton<AuthViewModel>(() => AuthViewModel(
    signUpUseCase: sl<SignUpUseCase>(),
    signInUseCase: sl<SignInUseCase>(),
    signOutUseCase: sl<SignOutUseCase>(),
    getCurrentUserUseCase: sl<GetCurrentUserUseCase>(),
    getUserStreamUseCase: sl<GetUserStreamUseCase>(),
  ));

  // --- Initiatives ---
  // Data Sources
  sl.registerLazySingleton<FirestoreInitiativeSource>(() => FirestoreInitiativeSourceImpl(sl()));

  // Repositories
  sl.registerLazySingleton<IInitiativeRepository>(() => InitiativeRepositoryImpl(sl()));

  // Use Cases
  sl.registerLazySingleton(() => GetInitiativesUseCase(sl()));
  sl.registerLazySingleton(() => AddInitiativeUseCase(sl()));
  sl.registerLazySingleton(() => GetInitiativeByIdUseCase(sl())); // For detail view
  
  // ViewModels
  sl.registerFactory(() => InitiativesViewModel(
        getInitiativesUseCase: sl(),
        addInitiativeUseCase: sl(),
        getInitiativeByIdUseCase: sl(),
        authViewModel: sl(), // Pass AuthViewModel if needed for user ID
      ));

  // Register other ViewModels here
  // sl.registerFactory(() => DashboardViewModel(...));
}