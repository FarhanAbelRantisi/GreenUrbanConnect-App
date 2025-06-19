import 'package:green_urban_connect/data/models/green_resource_model.dart';
import 'package:green_urban_connect/data/sources/api/open_charge_map_api_source.dart';
import 'package:green_urban_connect/data/sources/api/overpass_api_source.dart';
import 'package:green_urban_connect/data/sources/api/transport_api_source_placeholder.dart';
// import 'package:green_urban_connect/data/sources/firestore_green_resource_source.dart'; // Jika masih digunakan
import 'package:green_urban_connect/domain/repositories/i_green_resource_repository.dart';

class GreenResourceRepositoryImpl implements IGreenResourceRepository {
  final OverpassApiSource _overpassApiSource;
  final OpenChargeMapApiSource _openChargeMapApiSource;
  final TransportApiSourcePlaceholder _transportApiSource;
  // final FirestoreGreenResourceSource _firestoreSource; // Jika masih digunakan

  GreenResourceRepositoryImpl({
    required OverpassApiSource overpassApiSource,
    required OpenChargeMapApiSource openChargeMapApiSource,
    required TransportApiSourcePlaceholder transportApiSource,
    // required FirestoreGreenResourceSource firestoreSource,
  })  : _overpassApiSource = overpassApiSource,
        _openChargeMapApiSource = openChargeMapApiSource,
        _transportApiSource = transportApiSource;
        // _firestoreSource = firestoreSource;


  @override
  Future<List<GreenResourceModel>> getGreenResources(double lat, double lon, {List<GreenResourceType>? typesToFetch}) async {
    final List<GreenResourceModel> allResources = [];
    
    // Tentukan jenis apa yang akan diambil jika typesToFetch null (ambil semua yang relevan)
    final fetchAll = typesToFetch == null || typesToFetch.isEmpty;

    try {
      // Ambil data dari Overpass API (Taman, Daur Ulang, dll.)
      if (fetchAll || typesToFetch!.contains(GreenResourceType.park) || typesToFetch.contains(GreenResourceType.communityGarden)) {
        final greenSpaces = await _overpassApiSource.fetchGreenSpaces(lat, lon);
        allResources.addAll(greenSpaces.where((r) => r.type == GreenResourceType.park || r.type == GreenResourceType.communityGarden));
      }
      if (fetchAll || typesToFetch!.contains(GreenResourceType.recyclingCenter)) {
        allResources.addAll(await _overpassApiSource.fetchRecyclingCenters(lat, lon));
      }
      if (fetchAll || typesToFetch!.contains(GreenResourceType.bikeSharingStation)) {
        allResources.addAll(await _overpassApiSource.fetchBikeSharing(lat, lon));
      }
      if (fetchAll || typesToFetch!.contains(GreenResourceType.waterFountain)) {
        allResources.addAll(await _overpassApiSource.fetchDrinkingWater(lat, lon));
      }


      // Ambil data dari OpenChargeMap API (Stasiun EV)
      if (fetchAll || typesToFetch!.contains(GreenResourceType.evChargingStation)) {
        final evStations = await _openChargeMapApiSource.fetchEVChargingStations(latitude: lat, longitude: lon);
        allResources.addAll(evStations);
      }

      // Ambil data dari API Transportasi (Placeholder)
      if (fetchAll || typesToFetch!.contains(GreenResourceType.publicTransportHub)) {
        // Asumsikan kita menggunakan nama kota, atau koordinat jika API mendukung
        // Untuk Pekanbaru:
        final transportHubs = await _transportApiSource.fetchPublicTransportHubs("pekanbaru");
        allResources.addAll(transportHubs);
      }

      // TODO: Tambahkan logika untuk mengambil dari API lain jika ada (misal, pasar tani dari Overpass atau API khusus)
      // TODO: Hapus duplikat jika ada (berdasarkan ID atau kombinasi lat/lon dan nama)

    } catch (e) {
      print("Error di GreenResourceRepositoryImpl: $e");
      // Anda bisa memutuskan untuk mengembalikan sebagian data yang berhasil diambil,
      // atau throw exception lagi. Untuk saat ini, kita kembalikan apa yang ada.
    }
    
    // Filter akhir berdasarkan typesToFetch jika diberikan secara spesifik
    if (typesToFetch != null && typesToFetch.isNotEmpty) {
      return allResources.where((res) => typesToFetch.contains(res.type)).toList();
    }

    return allResources;
  }

  @override
  Future<GreenResourceModel?> getGreenResourceById(String id, GreenResourceSource source) async {
    // Logika untuk mengambil detail resource berdasarkan ID dan sumbernya.
    // Ini akan lebih kompleks karena detail mungkin perlu diambil lagi dari API asalnya.
    // Untuk saat ini, kita akan mengandalkan data mentah yang disimpan di `rawData` jika ada,
    // atau mengembalikan null jika detail lebih lanjut tidak tersedia secara langsung.
    // Contoh:
    // if (source == GreenResourceSource.osm && id.startsWith('osm_')) {
    //   // Mungkin perlu query Overpass lagi untuk detail node/way/relation by ID
    // } else if (source == GreenResourceSource.openChargeMap && id.startsWith('ocm_')) {
    //   // Mungkin perlu query OpenChargeMap lagi untuk POI by ID
    // }
    print("Fungsi getGreenResourceById belum diimplementasikan sepenuhnya untuk mengambil detail dari API asal.");
    return null; // Placeholder
  }
}