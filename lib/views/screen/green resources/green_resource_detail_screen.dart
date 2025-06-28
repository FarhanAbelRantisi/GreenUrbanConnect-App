import 'package:flutter/material.dart';
import 'package:green_urban_connect/data_domain/models/green_resource_model.dart';
import 'package:green_urban_connect/viewmodel/green_resources_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class GreenResourceDetailScreen extends StatefulWidget {
  static const routeName = 'green-resource-detail';
  final String resourceId; // ID ini bisa berupa "osm_node_123", "ocm_456"

  const GreenResourceDetailScreen({super.key, required this.resourceId});

  @override
  State<GreenResourceDetailScreen> createState() => _GreenResourceDetailScreenState();
}

class _GreenResourceDetailScreenState extends State<GreenResourceDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<GreenResourcesViewModel>(context, listen: false);
      // Mencoba mencari resource dari daftar yang sudah ada di ViewModel berdasarkan ID.
      // Jika tidak ada, ViewModel.fetchGreenResourceById akan dipanggil (implementasinya masih placeholder).
      // Untuk sekarang, kita asumsikan data sudah ada di daftar `_allFetchedResources` di ViewModel.
      viewModel.fetchGreenResourceById(widget.resourceId, _getSourceFromId(widget.resourceId));
    });
  }

  GreenResourceSource _getSourceFromId(String id) {
    if (id.startsWith('osm_')) return GreenResourceSource.osm;
    if (id.startsWith('ocm_')) return GreenResourceSource.openChargeMap;
    if (id.startsWith('gtfs_')) return GreenResourceSource.gtfs;
    return GreenResourceSource.other;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<GreenResourcesViewModel>(context, listen: false).clearSelectedResource();
      }
    });
    super.dispose();
  }

  Future<void> _launchMapsUrl(double? lat, double? lon, String address) async {
    Uri mapsUrl;
    if (lat != null && lon != null) {
      mapsUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lon');
    } else {
      mapsUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}');
    }
    
    if (await canLaunchUrl(mapsUrl)) {
      await launchUrl(mapsUrl);
    } else {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tidak dapat membuka peta untuk $address')),
        );
      }
    }
  }

  Future<void> _launchPhoneUrl(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '')); // Bersihkan nomor telepon
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tidak dapat menghubungi $phoneNumber')),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<GreenResourcesViewModel>(context);
    // Ambil resource dari _selectedResource yang di-set oleh fetchGreenResourceById
    // atau langsung dari daftar jika ID cocok (seperti yang dilakukan di initState)
    final resource = viewModel.selectedResource ?? viewModel.resources.firstWhere((r) => r.id == widget.resourceId, orElse: () => null as GreenResourceModel);


    return Scaffold(
      appBar: AppBar(
        title: Text(resource?.name ?? 'Detail Sumber Daya'),
      ),
      body: _buildBody(viewModel, resource),
    );
  }

  Widget _buildBody(GreenResourcesViewModel viewModel, GreenResourceModel? resource) {
    // Jika viewmodel sedang loading DAN resource belum ada (misal, baru masuk screen)
    if (viewModel.isLoading && resource == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // Jika ada error di viewmodel DAN resource masih null
    if (viewModel.status == GreenResourcesStatus.error && resource == null) {
      return Center(
        child: Text(viewModel.errorMessage ?? 'Gagal memuat detail sumber daya.'),
      );
    }

    // Jika resource tetap null setelah loading/error (tidak ditemukan)
    if (resource == null) {
        return const Center(child: Text('Sumber daya tidak ditemukan.'));
    }


    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (resource.imageUrl != null && resource.imageUrl!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Image.network(
                resource.imageUrl!,
                width: double.infinity,
                height: 220,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 220,
                  color: Colors.grey[300],
                  child: Icon(resource.typeIcon, size: 60, color: Colors.grey[600]),
                ),
              ),
            ),
          if (resource.imageUrl != null && resource.imageUrl!.isNotEmpty)
            const SizedBox(height: 16),

          Text(
            resource.name,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Chip(
            avatar: Icon(resource.typeIcon, size: 18, color: Theme.of(context).primaryColorDark),
            label: Text(resource.typeDisplay),
            backgroundColor: Theme.of(context).primaryColorLight.withOpacity(0.7),
          ),
          const SizedBox(height: 20),

          if (resource.description != null && resource.description!.isNotEmpty)
            _buildDetailCard(
              context,
              icon: Icons.info_outline,
              title: 'Tentang Tempat Ini',
              content: resource.description!,
            ),
          
          _buildDetailCard(
            context,
            icon: Icons.location_on_outlined,
            title: 'Alamat',
            content: resource.address,
            trailing: IconButton(
              icon: Icon(Icons.directions, color: Theme.of(context).primaryColor),
              tooltip: 'Petunjuk Arah',
              onPressed: () => _launchMapsUrl(resource.latitude, resource.longitude, resource.address),
            )
          ),

          if (resource.openingHours != null && resource.openingHours!.isNotEmpty)
            _buildDetailCard(
              context,
              icon: Icons.access_time_outlined,
              title: 'Jam Buka',
              content: resource.openingHours!,
            ),
          
          if (resource.contactInfo != null && resource.contactInfo!.isNotEmpty)
            _buildDetailCard(
              context,
              icon: Icons.contact_phone_outlined,
              title: 'Kontak',
              content: resource.contactInfo!,
              trailing: IconButton(
                icon: Icon(Icons.phone, color: Theme.of(context).primaryColor),
                tooltip: 'Telepon',
                onPressed: () => _launchPhoneUrl(resource.contactInfo!),
              )
            ),
          
          if (resource.latitude != null && resource.longitude != null)
             _buildDetailCard(
              context,
              icon: Icons.map_outlined,
              title: 'Koordinat',
              content: 'Lat: ${resource.latitude!.toStringAsFixed(5)}, Lon: ${resource.longitude!.toStringAsFixed(5)}',
            ),

          const SizedBox(height: 20),
          // Menampilkan data mentah jika ada (untuk debugging atau detail lebih lanjut)
          // ExpansionTile(
          //   leading: Icon(Icons.data_object_outlined),
          //   title: Text("Data Mentah dari API (${resource.source.name})"),
          //   children: [
          //     Padding(
          //       padding: const EdgeInsets.all(8.0),
          //       child: Text(
          //         resource.rawData != null 
          //         ? JsonEncoder.withIndent('  ').convert(resource.rawData) 
          //         : "Tidak ada data mentah.",
          //         style: TextStyle(fontFamily: 'monospace', fontSize: 12),
          //       ),
          //     )
          //   ],
          // )
        ],
      ),
    );
  }

  Widget _buildDetailCard(BuildContext context, {required IconData icon, required String title, required String content, Widget? trailing}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor, size: 28),
        title: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(content, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey[700])),
        ),
        trailing: trailing,
        isThreeLine: content.length > 60,
      ),
    );
  }
}