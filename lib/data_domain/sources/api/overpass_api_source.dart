import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:green_urban_connect/data_domain/models/green_resource_model.dart';

abstract class OverpassApiSource {
  Future<List<GreenResourceModel>> fetchGreenSpaces(double lat, double lon, {double radius = 5000}); // radius dalam meter
  Future<List<GreenResourceModel>> fetchRecyclingCenters(double lat, double lon, {double radius = 5000});
  Future<List<GreenResourceModel>> fetchBikeSharing(double lat, double lon, {double radius = 5000});
  Future<List<GreenResourceModel>> fetchDrinkingWater(double lat, double lon, {double radius = 5000});
}

class OverpassApiSourceImpl implements OverpassApiSource {
  final http.Client client;
  final String _baseUrl = 'https://overpass-api.de/api/interpreter';

  OverpassApiSourceImpl(this.client);

  Future<List<GreenResourceModel>> _fetchFromOverpass(String query) async {
    final response = await client.post(
      Uri.parse(_baseUrl),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'data': query},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<GreenResourceModel> resources = [];
      if (data['elements'] != null) {
        for (var element in data['elements']) {
          final tags = element['tags'];
          if (tags != null) {
            String name = tags['name'] ?? 'Tanpa Nama';
            String address = _formatAddress(tags);
            GreenResourceType type = GreenResourceType.other; // Default
            String osmId = '${element['type']}_${element['id']}';

            // Logika untuk menentukan tipe berdasarkan tag OSM
            if (element['type'] == 'node' || element['type'] == 'way' || element['type'] == 'relation') {
                if (tags['leisure'] == 'park' || tags['leisure'] == 'garden' || tags['boundary'] == 'national_park' || tags['boundary'] == 'protected_area') {
                    type = GreenResourceType.park;
                } else if (tags['landuse'] == 'allotments' || (tags['leisure'] == 'garden' && tags['community'] != null)) {
                    type = GreenResourceType.communityGarden;
                } else if (tags['amenity'] == 'recycling') {
                    type = GreenResourceType.recyclingCenter;
                } else if (tags['amenity'] == 'marketplace' && (tags['produce'] != null || tags['organic'] != null || name.toLowerCase().contains('tani'))) {
                    type = GreenResourceType.farmersMarket;
                } else if (tags['amenity'] == 'bicycle_rental' || tags['amenity'] == 'bicycle_sharing') {
                    type = GreenResourceType.bikeSharingStation;
                } else if (tags['amenity'] == 'drinking_water') {
                    type = GreenResourceType.waterFountain;
                }
            }
            
            // Hanya tambahkan jika tipe berhasil diidentifikasi (bukan 'other' kecuali memang itu tujuannya)
            // atau jika query spesifik untuk tipe 'other'
            // Untuk sekarang, kita asumsikan query sudah spesifik, jadi semua hasil relevan
            resources.add(GreenResourceModel(
              id: 'osm_$osmId', // Prefix untuk menandakan sumber
              name: name,
              type: type,
              address: address.isNotEmpty ? address : 'Detail lokasi tidak tersedia',
              latitude: element['lat'] ?? (element['center'] != null ? element['center']['lat'] : null),
              longitude: element['lon'] ?? (element['center'] != null ? element['center']['lon'] : null),
              source: GreenResourceSource.osm,
              rawData: element, // Simpan data mentah untuk detail
              description: tags['description'] ?? tags['note'],
              openingHours: tags['opening_hours'],
            ));
          }
        }
      }
      return resources;
    } else {
      print('Overpass API Error: ${response.statusCode} - ${response.body}');
      throw Exception('Gagal mengambil data dari Overpass API');
    }
  }

  String _formatAddress(Map<String, dynamic> tags) {
    // Membuat alamat dari tag OSM, ini bisa sangat bervariasi
    List<String> addressParts = [];
    if (tags['addr:street'] != null) addressParts.add(tags['addr:street']);
    if (tags['addr:housenumber'] != null) addressParts.add(tags['addr:housenumber']);
    if (tags['addr:postcode'] != null) addressParts.add(tags['addr:postcode']);
    if (tags['addr:city'] != null) addressParts.add(tags['addr:city']);
    if (tags['addr:suburb'] != null && !addressParts.contains(tags['addr:city'])) addressParts.add(tags['addr:suburb']);


    if (addressParts.isEmpty && tags['name'] != null) {
        // Jika tidak ada tag alamat formal, gunakan deskripsi lokasi umum jika ada
        if(tags['is_in'] != null) return "${tags['name']}, ${tags['is_in']}";
        return tags['name']!; // Fallback ke nama jika tidak ada alamat
    }
    return addressParts.join(', ');
  }

  @override
  Future<List<GreenResourceModel>> fetchGreenSpaces(double lat, double lon, {double radius = 5000}) {
    // Contoh bounding box untuk Pekanbaru (perkiraan)
    // double minLat = 0.44; double minLon = 101.36;
    // double maxLat = 0.60; double maxLon = 101.52;
    // String bbox = "$minLat,$minLon,$maxLat,$maxLon";
    // Atau menggunakan around filter
    String around = "(around:$radius,$lat,$lon)";

    String query = """
      [out:json][timeout:25];
      (
        node["leisure"="park"]$around;
        way["leisure"="park"]$around;
        relation["leisure"="park"]$around;
        node["leisure"="garden"]$around;
        way["leisure"="garden"]$around;
        relation["leisure"="garden"]$around;
        node["landuse"="allotments"]$around; // Kebun komunitas
        way["landuse"="allotments"]$around;
        node["boundary"="national_park"]$around;
        way["boundary"="national_park"]$around;
        relation["boundary"="national_park"]$around;
        node["boundary"="protected_area"]$around;
        way["boundary"="protected_area"]$around;
        relation["boundary"="protected_area"]$around;
      );
      out center;
    """;
    return _fetchFromOverpass(query);
  }
  
  @override
  Future<List<GreenResourceModel>> fetchRecyclingCenters(double lat, double lon, {double radius = 5000}) {
    String around = "(around:$radius,$lat,$lon)";
    String query = """
      [out:json][timeout:25];
      (
        node["amenity"="recycling"]$around;
        way["amenity"="recycling"]$around;
      );
      out center;
    """;
    return _fetchFromOverpass(query);
  }

  @override
  Future<List<GreenResourceModel>> fetchBikeSharing(double lat, double lon, {double radius = 5000}) {
    String around = "(around:$radius,$lat,$lon)";
    String query = """
      [out:json][timeout:25];
      (
        node["amenity"="bicycle_rental"]$around;
        way["amenity"="bicycle_rental"]$around;
        node["amenity"="bicycle_sharing"]$around;
        way["amenity"="bicycle_sharing"]$around;
      );
      out center;
    """;
     return _fetchFromOverpass(query);
  }

   @override
  Future<List<GreenResourceModel>> fetchDrinkingWater(double lat, double lon, {double radius = 5000}) {
    String around = "(around:$radius,$lat,$lon)";
    String query = """
      [out:json][timeout:25];
      (
        node["amenity"="drinking_water"]$around;
      );
      out center;
    """;
     return _fetchFromOverpass(query);
  }
}