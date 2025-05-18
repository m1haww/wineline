import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Set<Marker> _markers = {};
  static const CameraPosition _initialCamera = CameraPosition(
    target: LatLng(40.72, -73.85),
    zoom: 14,
  );
  BitmapDescriptor? _customIcon;
  GoogleMapController? _mapController;
  Map<String, dynamic>? _selectedItem;
  Offset? _infoWindowOffset;
  String _searchQuery = '';
  String _selectedType = 'Bar';
  String _selectedStyle = 'Natural';
  List _collections = [];

  @override
  void initState() {
    super.initState();
    _loadCustomMarkerAndCollections();
  }

  Future<void> _loadCustomMarkerAndCollections() async {
    final BitmapDescriptor customIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48, 48)),
      'images/Group10.png',
    );
    final String data = await rootBundle.loadString('assets/data.json');
    final jsonResult = json.decode(data);
    final List collections = jsonResult['wineCollections'];
    setState(() {
      _customIcon = customIcon;
      _collections = collections;
    });
    _updateMarkers();
  }

  void _updateMarkers() {
    if (_customIcon == null) return;
    Set<Marker> markers = {};
    Map<String, int> cityCounts = {};
    Map<String, int> cityIndex = {};
    // Filter collections
    final filtered =
        _collections.where((item) {
          final typeMatch =
              item['type'] == null || item['type'] == _selectedType;
          final styleMatch =
              item['style'] == null || item['style'] == _selectedStyle;
          final cityMatch =
              _searchQuery.isEmpty ||
              (item['city']?.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ) ??
                  false);
          return typeMatch && styleMatch && cityMatch;
        }).toList();
    for (var item in filtered) {
      final city = item['city'] ?? '';
      cityCounts[city] = (cityCounts[city] ?? 0) + 1;
    }
    for (var i = 0; i < filtered.length; i++) {
      final item = filtered[i];
      final coords = item['coordinates'];
      final city = item['city'] ?? '';
      if (coords != null) {
        int index = cityIndex[city] ?? 0;
        int total = cityCounts[city] ?? 1;
        double angle = (2 * pi * index) / total;
        double offset = 0.01; // ~1km, adjust as needed
        double latOffset = cos(angle) * offset;
        double lngOffset = sin(angle) * offset;
        cityIndex[city] = index + 1;
        markers.add(
          Marker(
            markerId: MarkerId(item['title'] ?? 'loc$i'),
            position: LatLng(
              coords['lat'] + latOffset,
              coords['lng'] + lngOffset,
            ),
            icon: _customIcon!,
            infoWindow: InfoWindow(
              title: item['title'],
              snippet: item['description'],
            ),
          ),
        );
      }
    }
    setState(() {
      _markers = markers;
    });
    // Zoom to marker if only one match
    if (filtered.length == 1 && _mapController != null) {
      final coords = filtered[0]['coordinates'];
      if (coords != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(LatLng(coords['lat'], coords['lng']), 15),
        );
      }
    }
  }

  void _onTypeSelected(String type) {
    setState(() {
      _selectedType = type;
    });
    _updateMarkers();
  }

  void _onStyleSelected(String style) {
    setState(() {
      _selectedStyle = style;
    });
    _updateMarkers();
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
    });
    _updateMarkers();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _onMapTap(LatLng latLng) {
    setState(() {
      _selectedItem = null;
      _infoWindowOffset = null;
    });
  }

  void _showDetailsDialog(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder:
          (context) => Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child:
                      item['image'] != null
                          ? Image.asset(
                            item['image'],
                            height: 180,
                            fit: BoxFit.cover,
                          )
                          : Container(height: 180, color: Colors.grey[300]),
                ),
                const SizedBox(height: 16),
                Text(
                  item['title'] ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item['description'] ?? '',
                  style: const TextStyle(fontSize: 15),
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Orange header and search bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFE86F1C),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                children: [
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextField(
                      onChanged: _onSearchChanged,
                      decoration: const InputDecoration(
                        hintText: 'Search for a city',
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Google Map
          Positioned.fill(
            top: 90,
            child: Stack(
              children: [
                GoogleMap(
                  mapType: MapType.normal,
                  initialCameraPosition: _initialCamera,
                  markers: _markers,
                  onMapCreated: _onMapCreated,
                  onTap: _onMapTap,
                  padding: const EdgeInsets.only(top: 90, bottom: 180),
                  zoomControlsEnabled: false,
                ),
                if (_markers.isEmpty)
                  const Center(
                    child: Text(
                      'No match',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Orange filter section at the bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFE86F1C),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Type',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => _onTypeSelected('Bar'),
                        child: _buildChip('Bar', _selectedType == 'Bar'),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _onTypeSelected('Cellar'),
                        child: _buildChip('Cellar', _selectedType == 'Cellar'),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _onTypeSelected('Restaurant'),
                        child: _buildChip(
                          'Restaurant',
                          _selectedType == 'Restaurant',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Style',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => _onStyleSelected('Natural'),
                        child: _buildChip(
                          'Natural',
                          _selectedStyle == 'Natural',
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _onStyleSelected('Biodynamic'),
                        child: _buildChip(
                          'Biodynamic',
                          _selectedStyle == 'Biodynamic',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, bool selected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? Colors.black : Colors.brown[300],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.brown[300]!, width: 2),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: selected ? Colors.white : Colors.black,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
