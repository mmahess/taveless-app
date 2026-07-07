import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../services/api_service.dart';
import '../../models/destination.dart';
import '../../controllers/profile_controller.dart';
import '../components/app_logo.dart';
import '../components/shimmer_loading.dart';
import '../../controllers/itinerary_controller.dart';
import '../itinerary/itinerary_detail_screen.dart';
import '../map/spot_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Destination>> _destinationsFuture;

  @override
  void initState() {
    super.initState();
    _destinationsFuture = _apiService.fetchDestinations();
    // Fetch saved itineraries from Supabase on launch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ItineraryController>(context, listen: false).loadSavedPlans();
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileCtrl = context.watch<ProfileController>();
    final itineraryCtrl = context.watch<ItineraryController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. App Logo & Profile Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const AppLogo(size: 36, fontSize: 20),
                    GestureDetector(
                      onTap: () {
                        itineraryCtrl.setActiveTab(4); // Navigate to Profile tab
                      },
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: profileCtrl.profileImage != null
                            ? FileImage(File(profileCtrl.profileImage!.path)) as ImageProvider
                            : (profileCtrl.uploadedImageUrl != null
                                ? NetworkImage(profileCtrl.uploadedImageUrl!) as ImageProvider
                                : null),
                        child: (profileCtrl.profileImage == null && profileCtrl.uploadedImageUrl == null)
                            ? Icon(
                                Icons.person_rounded,
                                size: 20,
                                color: Colors.grey[400],
                              )
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 2. Beautiful Typography Header
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.outfit(
                      fontSize: 36,
                      height: 1.2,
                      color: const Color(0xFF1E293B),
                    ),
                    children: [
                      const TextSpan(text: "Explore "),
                      TextSpan(
                        text: "Bali",
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const TextSpan(text: "\nwith "),
                      TextSpan(
                        text: "less crowd",
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF0560E8),
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 36),

                // 3. Top Choices Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Top Choices",
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        final itCtrl = Provider.of<ItineraryController>(context, listen: false);
                        itCtrl.setActiveTab(1); // Navigate to Crowd Map tab
                      },
                      child: Text(
                        "View all",
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF0560E8),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // 4. Destinations List
                FutureBuilder<List<Destination>>(
                  future: _destinationsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return SizedBox(
                        height: 300,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: 3,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) => const ShimmerDestinationCard(),
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return SizedBox(
                        height: 280,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline, color: Colors.red, size: 40),
                              const SizedBox(height: 8),
                              Text(
                                "Error loading destinations",
                                style: GoogleFonts.outfit(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const SizedBox(
                        height: 280,
                        child: Center(
                          child: Text("No destinations found"),
                        ),
                      );
                    }

                    final destinations = List<Destination>.from(snapshot.data!);
                    // Sort destinations so that 'Small' crowd level is shown first, then 'Moderate', and finally 'High'
                    destinations.sort((a, b) {
                      final order = {'Small': 1, 'Moderate': 2, 'High': 3};
                      final valA = order[a.crowdLevel] ?? 99;
                      final valB = order[b.crowdLevel] ?? 99;
                      return valA.compareTo(valB);
                    });
                    final displayDestinations = destinations.take(5).toList();
                    return SizedBox(
                      height: 300,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: displayDestinations.length,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          final destination = displayDestinations[index];
                          return _buildDestinationCard(destination);
                        },
                      ),
                    );
                  },
                ),

                // 5. My Saved Plans Section
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "My Saved Plans",
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    if (itineraryCtrl.savedPlans.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          itineraryCtrl.setActiveTab(4); // Directs to Profile Tab to manage
                        },
                        child: Text(
                          "Manage",
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0560E8),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 14),

                if (itineraryCtrl.isLoadingSavedPlans)
                  const SizedBox(
                    height: 100,
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 3),
                    ),
                  )
                else if (itineraryCtrl.savedPlans.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.withOpacity(0.08)),
                    ),
                    child: Center(
                      child: Text(
                        "No saved plans yet. Create one in the form tab!",
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          color: Colors.grey[500],
                        ),
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: itineraryCtrl.savedPlans.length,
                    itemBuilder: (context, index) {
                      final plan = itineraryCtrl.savedPlans[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F0FE),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.travel_explore, color: Color(0xFF0560E8)),
                          ),
                          title: Text(
                            plan.destinationName,
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                          subtitle: Text(
                            "${plan.dateRange} • ${plan.vibe}",
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              color: Colors.grey[500],
                            ),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                          onTap: () {
                            itineraryCtrl.generatedItinerary = plan;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ItineraryDetailScreen(),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDestinationCard(Destination destination) {
    Color crowdColor;
    switch (destination.crowdLevel) {
      case "Small":
        crowdColor = const Color(0xFF22C55E);
        break;
      case "Moderate":
        crowdColor = const Color(0xFFF59E0B);
        break;
      case "High":
      default:
        crowdColor = const Color(0xFFEF4444);
        break;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SpotDetailScreen(
              name: destination.name,
              crowdLevel: destination.crowdLevel,
              address: destination.location,
              description: destination.description,
              imageUrl: destination.imageUrl,
              rating: destination.rating,
            ),
          ),
        );
      },
      child: Container(
        width: 230,
      margin: const EdgeInsets.only(right: 16, bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    destination.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.image, color: Colors.grey),
                      );
                    },
                  ),
                ],
              ),
            ),
            // Info Section
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          destination.name,
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E293B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      // Crowd dot badge overlay
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: crowdColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          destination.location,
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    )
    );
  }
}
