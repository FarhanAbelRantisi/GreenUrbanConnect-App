import 'package:green_urban_connect/data_domain/models/green_resource_model.dart';
import 'package:green_urban_connect/data_domain/sources/api/open_charge_map_api_source.dart';
import 'package:green_urban_connect/data_domain/sources/api/overpass_api_source.dart';
import 'package:green_urban_connect/data_domain/sources/api/transport_api_source_placeholder.dart';

abstract class IGreenResourceRepository {
  Future<List<GreenResourceModel>> getGreenResources(double lat, double lon, {List<GreenResourceType>? typesToFetch});
  Future<GreenResourceModel?> getGreenResourceById(String id, GreenResourceSource source);
}

class GreenResourceRepositoryImpl implements IGreenResourceRepository {
  final OverpassApiSource _overpassApiSource;
  final OpenChargeMapApiSource _openChargeMapApiSource;
  final TransportApiSourcePlaceholder _transportApiSource;

  GreenResourceRepositoryImpl({
    required OverpassApiSource overpassApiSource,
    required OpenChargeMapApiSource openChargeMapApiSource,
    required TransportApiSourcePlaceholder transportApiSource,
  })  : _overpassApiSource = overpassApiSource,
        _openChargeMapApiSource = openChargeMapApiSource,
        _transportApiSource = transportApiSource;

  @override
  Future<List<GreenResourceModel>> getGreenResources(double lat, double lon, {List<GreenResourceType>? typesToFetch}) async {
    final List<GreenResourceModel> allResources = [];
    final fetchAll = typesToFetch == null || typesToFetch.isEmpty;

    try {
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

      if (fetchAll || typesToFetch!.contains(GreenResourceType.evChargingStation)) {
        final evStations = await _openChargeMapApiSource.fetchEVChargingStations(latitude: lat, longitude: lon);
        allResources.addAll(evStations);
      }

      if (fetchAll || typesToFetch!.contains(GreenResourceType.publicTransportHub)) {
        final transportHubs = await _transportApiSource.fetchPublicTransportHubs("pekanbaru");
        allResources.addAll(transportHubs);
      }
    } catch (e) {
      print("Error di GreenResourceRepositoryImpl: $e");
}
if (typesToFetch != null && typesToFetch.isNotEmpty){
return allResources.where((res) => typesToFetch.contains(res.type)).toList();
}
return allResources;
}
@override
Future<GreenResourceModel?> getGreenResourceById(String id, GreenResourceSource source) async {
print("Fungsi getGreenResourceById belum diimplementasikan sepenuhnya untuk mengambil detail dari API asal.");
return null; // Placeholder
}
}