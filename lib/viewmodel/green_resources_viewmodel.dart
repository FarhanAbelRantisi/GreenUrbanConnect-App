import 'package:flutter/material.dart';
import 'package:green_urban_connect/data_domain/models/green_resource_model.dart';
import 'package:green_urban_connect/data_domain/usecases/green_resource_usecases.dart';

enum GreenResourcesStatus { initial, loading, loaded, error }

class GreenResourcesViewModel extends ChangeNotifier {
  final GetGreenResourcesUseCase _getGreenResourcesUseCase;
  final GetGreenResourceByIdUseCase _getGreenResourceByIdUseCase;

  final double _defaultLatitude = 0.5071;
  final double _defaultLongitude = 101.4478;

  GreenResourcesViewModel({
    required GetGreenResourcesUseCase getGreenResourcesUseCase,
    required GetGreenResourceByIdUseCase getGreenResourceByIdUseCase,
  })  : _getGreenResourcesUseCase = getGreenResourcesUseCase,
        _getGreenResourceByIdUseCase = getGreenResourceByIdUseCase {
    fetchGreenResources();
  }

  GreenResourcesStatus _status = GreenResourcesStatus.initial;
  List<GreenResourceModel> _allFetchedResources = [];
  GreenResourceModel? _selectedResource;
  String? _errorMessage;
  GreenResourceType? _selectedFilterType;

  GreenResourcesStatus get status => _status;
  List<GreenResourceModel> get resources {
    if (_selectedFilterType == null) {
      return _allFetchedResources;
    }
    return _allFetchedResources.where((res) => res.type == _selectedFilterType).toList();
  }
  GreenResourceModel? get selectedResource => _selectedResource;
  String? get errorMessage => _errorMessage;
  GreenResourceType? get selectedFilterType => _selectedFilterType;
  bool get isLoading => _status == GreenResourcesStatus.loading;

  Future<void> fetchGreenResources({List<GreenResourceType>? types}) async {
    _status = GreenResourcesStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      final typesToFetch = types ?? (_selectedFilterType != null ? [_selectedFilterType!] : null);
      _allFetchedResources = await _getGreenResourcesUseCase(_defaultLatitude, _defaultLongitude, typesToFetch: typesToFetch);
      _status = GreenResourcesStatus.loaded;
      print('Fetched ${_allFetchedResources.length} resources');
    } catch (e) {
      _status = GreenResourcesStatus.error;
      _errorMessage = 'Failed to load resources: $e';
      _allFetchedResources = [];
      print('Error in fetchGreenResources: $e');
    }
    notifyListeners();
  }

  Future<void> fetchGreenResourceById(String id, GreenResourceSource source) async {
    _selectedResource = _allFetchedResources.firstWhere(
      (res) => res.id == id,
      orElse: () => GreenResourceModel(
        id: '',
        name: '',
        type: GreenResourceType.other,
        address: '',
        source: GreenResourceSource.other,
      ),
    );

    if (_selectedResource?.id.isNotEmpty == true) {
      _status = GreenResourcesStatus.loaded;
      notifyListeners();
      return;
    }

    _status = GreenResourcesStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      _selectedResource = await _getGreenResourceByIdUseCase(id, source);
      _status = GreenResourcesStatus.loaded;
      if (_selectedResource == null) {
        _errorMessage = 'Resource not found.';
        _status = GreenResourcesStatus.error;
      }
    } catch (e) {
      _status = GreenResourcesStatus.error;
      _errorMessage = 'Failed to load resource: $e';
    }
    notifyListeners();
  }

  void clearSelectedResource() {
    _selectedResource = null;
    notifyListeners();
  }

  void setFilterType(GreenResourceType? type) {
    _selectedFilterType = type;
    notifyListeners();
  }
}