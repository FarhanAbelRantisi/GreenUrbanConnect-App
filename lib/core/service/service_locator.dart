import 'package:get_it/get_it.dart';
import 'package:green_urban_connect/data/repositories/auth_repository_impl.dart';
import 'package:green_urban_connect/data/repositories/green_resource_repository_impl.dart';
import 'package:green_urban_connect/data/repositories/initiative_repository_impl.dart';
import 'package:green_urban_connect/data/repositories/urban_issue_repository_impl.dart';
import 'package:green_urban_connect/data/sources/api/open_charge_map_api_source.dart';
import 'package:green_urban_connect/data/sources/api/overpass_api_source.dart';
import 'package:green_urban_connect/data/sources/api/transport_api_source_placeholder.dart';
import 'package:green_urban_connect/data/sources/firebase_auth_source.dart';
import 'package:green_urban_connect/data/sources/firebase_storage_source.dart';
// import 'package:green_urban_connect/data/sources/firestore_green_resource_source.dart'; // Mungkin masih digunakan untuk cache/data manual
import 'package:green_urban_connect/data/sources/firestore_initiative_source.dart';
import 'package:green_urban_connect/data/sources/firestore_urban_issue_source.dart';
import 'package:green_urban_connect/domain/repositories/i_auth_repository.dart';
import 'package:green_urban_connect/domain/repositories/i_green_resource_repository.dart';
import 'package:green_urban_connect/domain/repositories/i_initiative_repository.dart';
import 'package:green_urban_connect/domain/repositories/i_urban_issue_repository.dart';
import 'package:green_urban_connect/domain/usecases/auth_usecases.dart';
import 'package:green_urban_connect/domain/usecases/green_resource_usecases.dart';
import 'package:green_urban_connect/domain/usecases/initiative_usecases.dart';
import 'package:green_urban_connect/domain/usecases/urban_issue_usecases.dart';
import 'package:green_urban_connect/presentation/viewmodels/auth_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:green_urban_connect/presentation/viewmodels/green_resources_viewmodel.dart';
import 'package:green_urban_connect/presentation/viewmodels/initiatives_viewmodel.dart';
import 'package:green_urban_connect/presentation/viewmodels/urban_issue_viewmodel.dart';
import 'package:http/http.dart' as http;


final sl = GetIt.instance;

void setupServiceLocator() {
  // HTTP Client
  sl.registerLazySingleton(() => http.Client());

  // Firebase Instances
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => FirebaseStorage.instance);


  // --- Auth ---
  sl.registerLazySingleton<FirebaseAuthSource>(() => FirebaseAuthSourceImpl(sl()));
  sl.registerLazySingleton<IAuthRepository>(() => AuthRepositoryImpl(sl(), sl()));
  sl.registerLazySingleton(() => SignUpUseCase(sl()));
  sl.registerLazySingleton(() => SignInUseCase(sl()));
  sl.registerLazySingleton(() => SignOutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  sl.registerLazySingleton(() => GetUserStreamUseCase(sl()));
  sl.registerFactory(() => AuthViewModel(
        signUpUseCase: sl(),
        signInUseCase: sl(),
        signOutUseCase: sl(),
        getCurrentUserUseCase: sl(),
        getUserStreamUseCase: sl(),
      ));

  // --- Initiatives ---
  sl.registerLazySingleton<FirestoreInitiativeSource>(() => FirestoreInitiativeSourceImpl(sl()));
  sl.registerLazySingleton<IInitiativeRepository>(() => InitiativeRepositoryImpl(sl()));
  sl.registerLazySingleton(() => GetInitiativesUseCase(sl()));
  sl.registerLazySingleton(() => AddInitiativeUseCase(sl()));
  sl.registerLazySingleton(() => GetInitiativeByIdUseCase(sl()));
  sl.registerFactory(() => InitiativesViewModel(
        getInitiativesUseCase: sl(),
        addInitiativeUseCase: sl(),
        getInitiativeByIdUseCase: sl(),
        authViewModel: sl(),
      ));

  // --- Urban Issues ---
  sl.registerLazySingleton<FirestoreUrbanIssueSource>(() => FirestoreUrbanIssueSourceImpl(sl()));
  sl.registerLazySingleton<FirebaseStorageSource>(() => FirebaseStorageSourceImpl(sl()));
  sl.registerLazySingleton<IUrbanIssueRepository>(() => UrbanIssueRepositoryImpl(sl(), sl()));
  sl.registerLazySingleton(() => GetUrbanIssuesUseCase(sl()));
  sl.registerLazySingleton(() => AddUrbanIssueUseCase(sl()));
  sl.registerLazySingleton(() => UploadIssueImageUseCase(sl()));
  sl.registerFactory(() => UrbanIssueViewModel(
        getUrbanIssuesUseCase: sl(),
        addUrbanIssueUseCase: sl(),
        uploadIssueImageUseCase: sl(),
        authViewModel: sl(),
      ));

  // --- Green Resources ---
  // API Data Sources
  sl.registerLazySingleton<OverpassApiSource>(() => OverpassApiSourceImpl(sl()));
  sl.registerLazySingleton<OpenChargeMapApiSource>(() => OpenChargeMapApiSourceImpl(sl()));
  sl.registerLazySingleton<TransportApiSourcePlaceholder>(() => TransportApiSourcePlaceholderImpl());
  // Firestore source (mungkin masih berguna untuk cache atau data manual)
  // sl.registerLazySingleton<FirestoreGreenResourceSource>(() => FirestoreGreenResourceSourceImpl(sl()));
  
  sl.registerLazySingleton<IGreenResourceRepository>(() => GreenResourceRepositoryImpl(
    overpassApiSource: sl(),
    openChargeMapApiSource: sl(),
    transportApiSource: sl(),
    // firestoreSource: sl(), // Jika masih menggunakan Firestore
  ));
  sl.registerLazySingleton(() => GetGreenResourcesUseCase(sl()));
  sl.registerLazySingleton(() => GetGreenResourceByIdUseCase(sl()));
  sl.registerFactory(() => GreenResourcesViewModel(
        getGreenResourcesUseCase: sl(),
        getGreenResourceByIdUseCase: sl(),
      ));
}