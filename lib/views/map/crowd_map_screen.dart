import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../controllers/itinerary_controller.dart';
import 'spot_detail_screen.dart';
import 'alternative_spots_screen.dart';
import '../../services/api_service.dart';
import '../../models/destination.dart';

class CrowdMapScreen extends StatefulWidget {
  const CrowdMapScreen({super.key});

  @override
  State<CrowdMapScreen> createState() => _CrowdMapScreenState();
}

class _CrowdMapScreenState extends State<CrowdMapScreen> {
  final MapController _mapController = MapController();

  // Selected destination from the map — stores the full Destination object
  Destination? _selectedDestination;
  bool _showLabels = false;

  late Future<List<Destination>> _destinationsFuture;

  @override
  void initState() {
    super.initState();
    _destinationsFuture = ApiService().fetchDestinations();
  }

  @override
  Widget build(BuildContext context) {
    final primaryBlue = const Color(0xFF0560E8);
    final itineraryCtrl = context.watch<ItineraryController>();

    // Listen to Home Screen redirects: focus the map camera dynamically onto targeted areas
    if (itineraryCtrl.mapFocusTarget != null) {
      final target = itineraryCtrl.mapFocusTarget!;
      final zoom = itineraryCtrl.mapFocusZoom;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController.move(target, zoom);
        itineraryCtrl.clearMapFocus();
      });
    }

    // Determine crowd color for the selected spot
    Color crowdLevelColor = Colors.grey;
    if (_selectedDestination != null) {
      if (_selectedDestination!.crowdLevel == "Small") {
        crowdLevelColor = const Color(0xFF22C55E);
      } else if (_selectedDestination!.crowdLevel == "Moderate") {
        crowdLevelColor = const Color(0xFFF59E0B);
      } else {
        crowdLevelColor = const Color(0xFFEF4444);
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFE2F1F8),
      body: Stack(
        children: [
          // 1. The Interactive Real Map
          Positioned.fill(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: const LatLng(-8.409518, 115.188916), // Centers on Bali Island
                initialZoom: 9.8,
                minZoom: 8.5,
                maxZoom: 18.0,
                onPositionChanged: (camera, hasGesture) {
                  // Only rebuild when crossing the label visibility threshold
                  final shouldShowLabels = (camera.zoom ?? 9.8) >= 11.5;
                  if (shouldShowLabels != _showLabels) {
                    setState(() {
                      _showLabels = shouldShowLabels;
                    });
                  }
                },
              ),
              children: [
                // OpenStreetMap tiles
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.traveless.app',
                ),

                // Dynamic Marker layer mapping database tourist spot locations
                FutureBuilder<List<Destination>>(
                  future: _destinationsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const MarkerLayer(markers: []);
                    }
                    if (snapshot.hasError || !snapshot.hasData) {
                      return const MarkerLayer(markers: []);
                    }

                    final list = snapshot.data!;

                    // Auto-select the first destination if none is selected yet
                    if (_selectedDestination == null && list.isNotEmpty) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted && _selectedDestination == null) {
                          setState(() {
                            _selectedDestination = list.first;
                          });
                        }
                      });
                    }

                    final markers = list.map((dest) {
                      final point = LatLng(dest.latitude, dest.longitude);

                      Color crowdColor = dest.crowdLevel == "Small"
                          ? const Color(0xFF22C55E)
                          : dest.crowdLevel == "Moderate"
                              ? const Color(0xFFF59E0B)
                              : const Color(0xFFEF4444);

                      return Marker(
                        point: point,
                        width: 120,
                        height: 75,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedDestination = dest;
                            });
                            _mapController.move(point, 13.5);
                          },
                          child: _buildMapPin(Icons.place, crowdColor, dest.name),
                        ),
                      );
                    }).toList();

                    return MarkerLayer(markers: markers);
                  },
                ),
              ],
            ),
          ),

          // 2. Floating Header Bar (Page Title)
          Positioned(
            top: 60,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    itineraryCtrl.setActiveTab(0); // Return to Home screen
                  },
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(Icons.arrow_back_ios_new, size: 16, color: Colors.black87),
                    ),
                  ),
                ),
                Text(
                  "Crowd Map",
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(width: 44),
              ],
            ),
          ),

          // 3. Floating Overlay Card Drawer at bottom
          if (_selectedDestination != null)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF2D3748), // Dark slate gray matching mockup
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title + Crowd Level Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            _selectedDestination!.name,
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: crowdLevelColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "${_selectedDestination!.crowdLevel} Crowds",
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: crowdLevelColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Location Pin Row
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 14, color: Colors.white70),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _selectedDestination!.location,
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              color: Colors.white70,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Description Row
                    Row(
                      children: [
                        const Icon(Icons.info_outline, size: 14, color: Colors.white70),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _selectedDestination!.description,
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Dual Action Buttons (Alternatives / Details)
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AlternativeSpotsScreen(
                                    selectedSpotName: _selectedDestination!.name,
                                    selectedAddress: _selectedDestination!.location,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryBlue,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Text(
                              "See Alternatives",
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SpotDetailScreen(
                                    name: _selectedDestination!.name,
                                    crowdLevel: _selectedDestination!.crowdLevel,
                                    address: _selectedDestination!.location,
                                    description: _selectedDestination!.description,
                                    imageUrl: _selectedDestination!.imageUrl,
                                    rating: _selectedDestination!.rating,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryBlue,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Text(
                              "See Details",
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            )
        ],
      ),
    );
  }

  Widget _buildMapPin(IconData icon, Color color, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        if (_showLabels) ...[
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.75),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ],
    );
  }
}
