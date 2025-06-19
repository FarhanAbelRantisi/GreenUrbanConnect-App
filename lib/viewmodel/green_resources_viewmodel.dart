import 'package:flutter/material.dart';
import 'package:green_urban_connect/data_domain/models/green_resource_model.dart';
import 'package:green_urban_connect/data_domain/usecases/green_resource_usecases.dart';

enum GreenResourcesStatus { initial, loading, loaded, error }

class GreenResourcesViewModel extends ChangeNotifier {
  final GetGreenResourcesUseCase _getGreenResourcesUseCase;
  final GetGreenResourceByIdUseCase _getGreenResourceByIdUseCase;

  // Koordinat default untuk Pekanbaru (perkiraan pusat kota)
  // Anda mungkin ingin mendapatkan ini dari GPS pengguna atau input lain di masa depan
  final double _defaultLatitude = 0.5071;
  final double _defaultLongitude = 101.4478;


  GreenResourcesViewModel({
    required GetGreenResourcesUseCase getGreenResourcesUseCase,
    required GetGreenResourceByIdUseCase getGreenResourceByIdUseCase,
  })  : _getGreenResourcesUseCase = getGreenResourcesUseCase,
        _getGreenResourceByIdUseCase = getGreenResourceByIdUseCase {
    fetchGreenResources(); // Ambil resources saat ViewModel dibuat
  }

  GreenResourcesStatus _status = GreenResourcesStatus.initial;
  List<GreenResourceModel> _allFetchedResources = []; // Simpan semua hasil fetch awal
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
    // Jika types tidak null, kita sedang melakukan filter fetch, jadi jangan hapus _selectedFilterType
    // Jika types null, ini adalah fetch umum, jadi _selectedFilterType mungkin sudah di-set
    notifyListeners();
    try {
      // Gunakan _selectedFilterType jika ada, atau types dari argumen, atau ambil semua
      final typesToFetch = types ?? (_selectedFilterType != null ? [_selectedFilterType!] : null);
      _allFetchedResources = await _getGreenResourcesUseCase(_defaultLatitude, _defaultLongitude, typesToFetch: typesToFetch);
      _status = GreenResourcesStatus.loaded;
    } catch (e) {
      _status = GreenResourcesStatus.error;
      _errorMessage = "Gagal memuat sumber daya: ${e.toString()}";
      _allFetchedResources = []; // Kosongkan jika error
    }
    notifyListeners();
  }

  Future<void> fetchGreenResourceById(String id, GreenResourceSource source) async {
    // Coba cari dari daftar yang sudah ada dulu
    _selectedResource = _allFetchedResources.firstWhere((res) => res.id == id, orElse: () => null as GreenResourceModel);

    if (_selectedResource != null) {
        _status = GreenResourcesStatus.loaded;
        notifyListeners();
        return;
    }
    
    // Jika tidak ada, coba ambil detail (implementasi repo masih placeholder)
    _status = GreenResourcesStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      _selectedResource = await _getGreenResourceByIdUseCase(id, source);
      _status = GreenResourcesStatus.loaded;
      if (_selectedResource == null) {
        _errorMessage = "Sumber daya tidak ditemukan.";
        _status = GreenResourcesStatus.error;
      }
    } catch (e) {
      _status = GreenResourcesStatus.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  void clearSelectedResource() {
    _selectedResource = null;
    notifyListeners();
  }

  void setFilterType(GreenResourceType? type) {
    _selectedFilterType = type;
    // Tidak perlu fetch ulang di sini karena 'resources' getter sudah menghandle filter
    // Jika ingin fetch ulang dari API dengan filter, panggil:
    // fetchGreenResources(types: type != null ? [type] : null);
    notifyListeners();
  }
}