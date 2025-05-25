import 'package:flutter/material.dart';
import 'package:green_urban_connect/data/models/initiative_model.dart';
import 'package:green_urban_connect/domain/usecases/initiative_usecases.dart';
import 'package:green_urban_connect/presentation/viewmodels/auth_viewmodel.dart'; // To get current user info

enum InitiativesStatus { initial, loading, loaded, error, submitting, submitted }

class InitiativesViewModel extends ChangeNotifier {
  final GetInitiativesUseCase _getInitiativesUseCase;
  final AddInitiativeUseCase _addInitiativeUseCase;
  final GetInitiativeByIdUseCase _getInitiativeByIdUseCase;
  final AuthViewModel _authViewModel; // To get current user ID and name

  InitiativesViewModel({
    required GetInitiativesUseCase getInitiativesUseCase,
    required AddInitiativeUseCase addInitiativeUseCase,
    required GetInitiativeByIdUseCase getInitiativeByIdUseCase,
    required AuthViewModel authViewModel,
  })  : _getInitiativesUseCase = getInitiativesUseCase,
        _addInitiativeUseCase = addInitiativeUseCase,
        _getInitiativeByIdUseCase = getInitiativeByIdUseCase,
        _authViewModel = authViewModel {
    fetchInitiatives(); // Fetch initiatives when ViewModel is created
  }

  InitiativesStatus _status = InitiativesStatus.initial;
  List<InitiativeModel> _initiatives = [];
  InitiativeModel? _selectedInitiative;
  String? _errorMessage;

  InitiativesStatus get status => _status;
  List<InitiativeModel> get initiatives => _initiatives;
  InitiativeModel? get selectedInitiative => _selectedInitiative;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == InitiativesStatus.loading;
  bool get isSubmitting => _status == InitiativesStatus.submitting;


  Future<void> fetchInitiatives() async {
    _status = InitiativesStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      _initiatives = await _getInitiativesUseCase();
      _status = InitiativesStatus.loaded;
    } catch (e) {
      _status = InitiativesStatus.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<void> fetchInitiativeById(String id) async {
    _status = InitiativesStatus.loading;
    _selectedInitiative = null; // Clear previous selection
    _errorMessage = null;
    notifyListeners();
    try {
      _selectedInitiative = await _getInitiativeByIdUseCase(id);
      _status = InitiativesStatus.loaded;
      if (_selectedInitiative == null) {
        _errorMessage = "Initiative not found.";
        _status = InitiativesStatus.error;
      }
    } catch (e) {
      _status = InitiativesStatus.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }


  Future<bool> addInitiative(InitiativeModel initiative) async {
    _status = InitiativesStatus.submitting;
    _errorMessage = null;
    notifyListeners();

    // Ensure organizerId and organizerName are set from the current user
    final currentUser = _authViewModel.currentUser;
    if (currentUser == null) {
      _status = InitiativesStatus.error;
      _errorMessage = "User not authenticated. Please log in to propose an initiative.";
      notifyListeners();
      return false;
    }

    final initiativeWithOwnerInfo = InitiativeModel(
      title: initiative.title,
      description: initiative.description,
      location: initiative.location,
      date: initiative.date,
      category: initiative.category,
      imageUrl: initiative.imageUrl, // Pass along if provided
      organizerId: currentUser.id, // Set from logged-in user
      organizerName: currentUser.displayName ?? currentUser.email, // Set from logged-in user
      // status, createdAt, participantIds will use defaults or be null
    );


    try {
      final newInitiativeId = await _addInitiativeUseCase(initiativeWithOwnerInfo);
      // Optionally, refetch all initiatives or add the new one to the local list
      await fetchInitiatives(); // Easiest way to update the list
      _status = InitiativesStatus.submitted;
      notifyListeners();
      return true;
    } catch (e) {
      _status = InitiativesStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearSelectedInitiative() {
    _selectedInitiative = null;
    // Optionally reset status if needed, or just notify
    notifyListeners();
  }
}