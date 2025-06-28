import 'package:get_it/get_it.dart';
import 'package:green_urban_connect/data_domain/repositories/auth_repository.dart';
import 'package:green_urban_connect/data_domain/repositories/green_resource_repository.dart';
import 'package:green_urban_connect/data_domain/repositories/initiative_repository.dart';
import 'package:green_urban_connect/data_domain/repositories/urban_issue_repository.dart';
import 'package:green_urban_connect/data_domain/sources/api/open_charge_map_api_source.dart';
import 'package:green_urban_connect/data_domain/sources/api/overpass_api_source.dart';
import 'package:green_urban_connect/data_domain/sources/api/transport_api_source_placeholder.dart';
import 'package:green_urban_connect/data_domain/sources/firebase_auth_source.dart';
import 'package:green_urban_connect/data_domain/sources/firebase_storage_source.dart';
import 'package:green_urban_connect/data_domain/sources/firestore_initiative_source.dart';
import 'package:green_urban_connect/data_domain/sources/firestore_urban_issue_source.dart';
import 'package:green_urban_connect/data_domain/usecases/auth_usecases.dart';
import 'package:green_urban_connect/data_domain/usecases/green_resource_usecases.dart';
import 'package:green_urban_connect/data_domain/usecases/initiative_usecases.dart';
import 'package:green_urban_connect/data_domain/usecases/urban_issue_usecases.dart';
import 'package:green_urban_connect/viewmodel/auth_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:green_urban_connect/viewmodel/green_resources_viewmodel.dart';
import 'package:green_urban_connect/viewmodel/initiatives_viewmodel.dart';
import 'package:green_urban_connect/viewmodel/urban_issue_viewmodel.dart';
import 'package:http/http.dart' as http;

final sl = GetIt.instance;

void setupServiceLocator() {
  // HTTP Client
  sl.registerLazySingleton(() => http.Client());

  // Firebase Instances
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => FirebaseStorage.instance);

  // --- Data Sources ---
  sl.registerLazySingleton<FirebaseAuthSource>(() => FirebaseAuthSourceImpl(sl()));
  sl.registerLazySingleton<FirestoreInitiativeSource>(() => FirestoreInitiativeSourceImpl(sl()));
  sl.registerLazySingleton<FirestoreUrbanIssueSource>(() => FirestoreUrbanIssueSourceImpl(sl()));
  sl.registerLazySingleton<FirebaseStorageSource>(() => FirebaseStorageSourceImpl(sl()));
  sl.registerLazySingleton<OverpassApiSource>(() => OverpassApiSourceImpl(sl()));
  sl.registerLazySingleton<OpenChargeMapApiSource>(() => OpenChargeMapApiSourceImpl(sl()));
  sl.registerLazySingleton<TransportApiSourcePlaceholder>(() => TransportApiSourcePlaceholderImpl());

  // --- Repositories ---
  sl.registerLazySingleton<IAuthRepository>(() => AuthRepositoryImpl(sl(), sl()));
  sl.registerLazySingleton<IInitiativeRepository>(() => InitiativeRepositoryImpl(sl()));
  sl.registerLazySingleton<IUrbanIssueRepository>(() => UrbanIssueRepositoryImpl(sl(), sl()));
  sl.registerLazySingleton<IGreenResourceRepository>(() => GreenResourceRepositoryImpl(
        overpassApiSource: sl(),
        openChargeMapApiSource: sl(),
        transportApiSource: sl(),
      ));

  // --- Use Cases ---
  // Auth
  sl.registerLazySingleton(() => SignUpUseCase(sl()));
  sl.registerLazySingleton(() => SignInUseCase(sl()));
  sl.registerLazySingleton(() => SignOutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  sl.registerLazySingleton(() => GetUserStreamUseCase(sl()));
  // Initiatives
  sl.registerLazySingleton(() => GetInitiativesUseCase(sl()));
  sl.registerLazySingleton(() => AddInitiativeUseCase(sl()));
  sl.registerLazySingleton(() => GetInitiativeByIdUseCase(sl()));
  sl.registerLazySingleton(() => UpdateInitiativeUseCase(sl()));
  sl.registerLazySingleton(() => DeleteInitiativeUseCase(sl()));
  // Urban Issues
  sl.registerLazySingleton(() => GetUrbanIssuesUseCase(sl()));
  sl.registerLazySingleton(() => AddUrbanIssueUseCase(sl()));
  sl.registerLazySingleton(() => UploadIssueImageUseCase(sl()));
  // Green Resources
  sl.registerLazySingleton(() => GetGreenResourcesUseCase(sl()));
  sl.registerLazySingleton(() => GetGreenResourceByIdUseCase(sl()));


  // --- ViewModels ---
  sl.registerFactory(() => AuthViewModel(
        signUpUseCase: sl(),
        signInUseCase: sl(),
        signOutUseCase: sl(),
        getCurrentUserUseCase: sl(),
        getUserStreamUseCase: sl(),
      ));
  sl.registerFactory(() => InitiativesViewModel(
        getInitiativesUseCase: sl(),
        addInitiativeUseCase: sl(),
        getInitiativeByIdUseCase: sl(),
        authViewModel: sl(),
        deleteInitiativeUseCase: sl(),
        updateInitiativeUseCase: sl()
      ));
  sl.registerFactory(() => UrbanIssueViewModel(
        getUrbanIssuesUseCase: sl(),
        addUrbanIssueUseCase: sl(),
        uploadIssueImageUseCase: sl(),
        authViewModel: sl(),
      ));
  sl.registerFactory(() => GreenResourcesViewModel(
        getGreenResourcesUseCase: sl(),
        getGreenResourceByIdUseCase: sl(),
      ));
}