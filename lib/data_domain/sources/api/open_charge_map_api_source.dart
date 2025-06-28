import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:green_urban_connect/data_domain/models/green_resource_model.dart';

abstract class OpenChargeMapApiSource {
  Future<List<GreenResourceModel>> fetchEVChargingStations({
    required double latitude,
    required double longitude,
    double distance = 10,
    int maxResults = 50,
  });
}

class OpenChargeMapApiSourceImpl implements OpenChargeMapApiSource {
  final http.Client client;
  final String _baseUrl = 'https://api.openchargemap.io/v3/poi/';
  // Hardcoded API key
  final String _openChargeMapApiKey = '39d61807-d0c2-4006-bfab-5bde9d5aafa6';

  OpenChargeMapApiSourceImpl(this.client);

  @override
  Future<List<GreenResourceModel>> fetchEVChargingStations({
    required double latitude,
    required double longitude,
    double distance = 10,
    int maxResults = 50,
  }) async {
    // Use the hardcoded API key directly
    if (_openChargeMapApiKey.isEmpty) {
      print('Warning: No OpenChargeMap API key provided. Returning empty EV stations list.');
      print('To fetch EV charging stations, please provide an API key from https://openchargemap.org/site/loginprovider');
      return [];
    }

    final queryParameters = {
      'output': 'json',
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'distance': distance.toString(),
      'distanceunit': 'km',
      'maxresults': maxResults.toString(),
      'compact': 'true',
      'verbose': 'false',
      'key': _openChargeMapApiKey,
    };

    final uri = Uri.parse(_baseUrl).replace(queryParameters: queryParameters);
    print('Fetching EV stations from: $uri');

    try {
      final response = await client.get(uri, headers: {
        'Accept': 'application/json',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is! List) {
          print('Unexpected response format: $data');
          throw Exception('Invalid response format from OpenChargeMap API');
        }

        final List<GreenResourceModel> stations = [];
        for (var stationData in data) {
          final addressInfo = stationData['AddressInfo'];
          if (addressInfo == null) continue;

          String name = addressInfo['Title'] ?? 'Unnamed EV Station';
          String address = [
            addressInfo['AddressLine1'],
            addressInfo['AddressLine2'],
            addressInfo['Town'],
            addressInfo['StateOrProvince'],
            addressInfo['Postcode'],
            addressInfo['Country']?['Title']
          ].where((s) => s != null && s.isNotEmpty).join(', ');

          String contact = '';
          if (addressInfo['ContactTelephone1'] != null) {
            contact += 'Tel: ${addressInfo['ContactTelephone1']}';
          }
          if (addressInfo['ContactEmail'] != null) {
            contact += (contact.isNotEmpty ? ' / ' : '') + 'Email: ${addressInfo['ContactEmail']}';
          }

          stations.add(GreenResourceModel(
            id: 'ocm_${stationData['ID']}',
            name: name,
            type: GreenResourceType.evChargingStation,
            address: address.isNotEmpty ? address : 'Address not available',
            latitude: addressInfo['Latitude']?.toDouble(),
            longitude: addressInfo['Longitude']?.toDouble(),
            description: stationData['GeneralComments'] ??
                (stationData['Connections'] != null &&
                        (stationData['Connections'] as List).isNotEmpty
                    ? 'Connector Type: ${stationData['Connections'][0]['ConnectionType']?['Title'] ?? 'N/A'}'
                    : 'Connection details not available'),
            openingHours: addressInfo['AccessComments'],
            contactInfo: contact.isNotEmpty ? contact : null,
            source: GreenResourceSource.openChargeMap,
            rawData: stationData,
          ));
        }
        print('Fetched ${stations.length} EV stations');
        return stations;
      } else if (response.statusCode == 403) {
        print('OpenChargeMap API Error: Invalid or missing API key');
        print('Please get a free API key from https://openchargemap.org/site/loginprovider');
        return [];
      } else {
        print('OpenChargeMap API Error: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error fetching EV stations: $e');
      return [];
    }
  }
}