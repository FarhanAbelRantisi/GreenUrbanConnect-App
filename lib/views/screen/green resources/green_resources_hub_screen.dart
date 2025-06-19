import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:green_urban_connect/data_domain/models/green_resource_model.dart';
import 'package:green_urban_connect/viewmodel/green_resources_viewmodel.dart';
import 'package:green_urban_connect/views/screen/green%20resources/green_resource_detail_screen.dart';
import 'package:green_urban_connect/views/widgets/green%20resources/green_resource_list_item.dart';
import 'package:provider/provider.dart';

class GreenResourcesHubScreen extends StatefulWidget {
  static const routeName = '/green-resources';
  const GreenResourcesHubScreen({super.key});

  @override
  State<GreenResourcesHubScreen> createState() => _GreenResourcesHubScreenState();
}

class _GreenResourcesHubScreenState extends State<GreenResourcesHubScreen> {
  @override
  void initState() {
    super.initState();
    // ViewModel sudah mengambil data saat inisialisasi
    // Jika ingin refresh setiap kali masuk screen:
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   Provider.of<GreenResourcesViewModel>(context, listen: false).fetchGreenResources();
    // });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<GreenResourcesViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ruang & Sumber Daya Hijau'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => viewModel.fetchGreenResources(), // Fetch umum (semua tipe relevan)
            tooltip: 'Segarkan Sumber Daya',
          ),
          PopupMenuButton<GreenResourceType?>(
            icon: const Icon(Icons.filter_list),
            tooltip: "Filter berdasarkan tipe",
            onSelected: (GreenResourceType? type) {
              viewModel.setFilterType(type);
              // Jika ingin fetch ulang dari API dengan filter spesifik:
              // viewModel.fetchGreenResources(types: type != null ? [type] : null);
            },
            itemBuilder: (BuildContext context) {
              return <PopupMenuEntry<GreenResourceType?>>[
                const PopupMenuItem<GreenResourceType?>(
                  value: null, 
                  child: Text('Semua Tipe'),
                ),
                ...GreenResourceType.values.map((type) {
                  return PopupMenuItem<GreenResourceType?>(
                    value: type,
                    child: Text(type.name.replaceAllMapped(RegExp(r'[A-Z]'), (match) => ' ${match.group(0)}').trimLeft()),
                  );
                }).whereType<PopupMenuEntry<GreenResourceType?>>(),
              ];
            },
          ),
        ],
      ),
      body: _buildBody(viewModel),
    );
  }

  Widget _buildBody(GreenResourcesViewModel viewModel) {
    if (viewModel.isLoading && viewModel.resources.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.status == GreenResourcesStatus.error && viewModel.resources.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red[300], size: 50),
              const SizedBox(height: 10),
              Text(
                'Gagal memuat sumber daya.',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              if (viewModel.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top:8.0),
                  child: Text(viewModel.errorMessage!, style: TextStyle(color: Colors.grey[600]), textAlign: TextAlign.center,),
                ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
                onPressed: () => viewModel.fetchGreenResources(),
              )
            ],
          ),
        ),
      );
    }
    
    final displayedResources = viewModel.resources;

    if (displayedResources.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_outlined, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              viewModel.selectedFilterType == null
                  ? 'Belum ada sumber daya hijau yang ditemukan.'
                  : 'Tidak ada sumber daya tipe "${viewModel.selectedFilterType!.name.toLowerCase().replaceAllMapped(RegExp(r'[A-Z]'), (match) => ' ${match.group(0)}').trimLeft()}" ditemukan.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            if (viewModel.selectedFilterType != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: ElevatedButton(
                onPressed: () => viewModel.setFilterType(null), // Ini akan memicu getter 'resources' untuk menampilkan semua
                child: const Text('Tampilkan Semua Tipe'),
              ),
            )
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => viewModel.fetchGreenResources(),
      child: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: displayedResources.length,
        itemBuilder: (context, index) {
          final resource = displayedResources[index];
          return GreenResourceListItem(
            resource: resource,
            onTap: () {
              // Karena ID sekarang bisa kompleks, kita teruskan saja.
              // Detail screen mungkin perlu logika untuk menangani sumber yang berbeda.
              context.pushNamed(
                GreenResourceDetailScreen.routeName,
                pathParameters: {'resourceId': resource.id}, 
              );
            },
          );
        },
      ),
    );
  }
}