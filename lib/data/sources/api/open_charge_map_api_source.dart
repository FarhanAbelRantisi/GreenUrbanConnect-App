import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:green_urban_connect/data/models/green_resource_model.dart';

abstract class OpenChargeMapApiSource {
  Future<List<GreenResourceModel>> fetchEVChargingStations({
    required double latitude,
    required double longitude,
    double distance = 10, // dalam kilometer
    int maxResults = 50,
    String? apiKey, // API key jika diperlukan di masa depan
  });
}

class OpenChargeMapApiSourceImpl implements OpenChargeMapApiSource {
  final http.Client client;
  // Ganti dengan API key Anda jika diperlukan. Untuk penggunaan publik, seringkali tidak wajib untuk read-only.
  // final String _apiKey = 'YOUR_OPENCHARGEMAP_API_KEY'; // Opsional
  final String _baseUrl = '[https://api.openchargemap.io/v3/poi/](https://api.openchargemap.io/v3/poi/)';

  OpenChargeMapApiSourceImpl(this.client);

  @override
  Future<List<GreenResourceModel>> fetchEVChargingStations({
    required double latitude,
    required double longitude,
    double distance = 10, // kilometer
    int maxResults = 50,
    String? apiKey,
  }) async {
    // Parameter untuk OpenChargeMap API
    // Lihat dokumentasi: [https://openchargemap.org/site/develop/api](https://openchargemap.org/site/develop/api)
    final queryParameters = {
      'output': 'json',
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'distance': distance.toString(),
      'distanceunit': 'km',
      'maxresults': maxResults.toString(),
      'compact': 'true', // Untuk data yang lebih ringkas
      'verbose': 'false', // Detail minimal
      // 'key': apiKey ?? _apiKey, // Jika menggunakan API key
    };

    // Hapus parameter key jika null atau kosong
    // queryParameters.removeWhere((key, value) => (key == 'key' && (value == null || value.isEmpty)));


    final uri = Uri.parse(_baseUrl).replace(queryParameters: queryParameters);
    print("Mencoba mengambil data EV dari: $uri");

    final response = await client.get(uri, headers: {
      'Accept': 'application/json',
      // 'X-API-Key': apiKey ?? _apiKey, // Jika API key diperlukan di header
    });

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final List<GreenResourceModel> stations = [];

      for (var stationData in data) {
        final addressInfo = stationData['AddressInfo'];
        String name = addressInfo['Title'] ?? 'Stasiun Pengisian EV Tanpa Nama';
        String address = [
          addressInfo['AddressLine1'],
          addressInfo['AddressLine2'],
          addressInfo['Town'],
          addressInfo['StateOrProvince'],
          addressInfo['Postcode'],
          addressInfo['Country']?['Title']
        ].where((s) => s != null && s.isNotEmpty).join(', ');
        
        String contact = "";
        if (addressInfo['ContactTelephone1'] != null) contact += "Tel: ${addressInfo['ContactTelephone1']}";
        if (addressInfo['ContactEmail'] != null) contact += (contact.isNotEmpty ? " / " : "") + "Email: ${addressInfo['ContactEmail']}";


        stations.add(GreenResourceModel(
          id: 'ocm_${stationData['ID']}', // ID unik dari OpenChargeMap
          name: name,
          type: GreenResourceType.evChargingStation,
          address: address.isNotEmpty ? address : 'Alamat tidak tersedia',
          latitude: addressInfo['Latitude']?.toDouble(),
          longitude: addressInfo['Longitude']?.toDouble(),
          description: stationData['GeneralComments'] ??
                      (stationData['Connections'] != null && (stationData['Connections'] as List).isNotEmpty
                          ? "Tipe Konektor: ${stationData['Connections'][0]['ConnectionType']?['Title'] ?? 'N/A'}"
                          : "Detail koneksi tidak tersedia"),
          openingHours: addressInfo['AccessComments'], // Seringkali berisi info jam buka
          contactInfo: contact.isNotEmpty ? contact : null,
          source: GreenResourceSource.openChargeMap,
          rawData: stationData,
        ));
      }
      return stations;
    } else {
      print('OpenChargeMap API Error: ${response.statusCode} - ${response.body}');
      throw Exception('Gagal mengambil data stasiun EV dari OpenChargeMap API');
    }
  }
}