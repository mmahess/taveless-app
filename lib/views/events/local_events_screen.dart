import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/api_service.dart';
import '../../models/local_event.dart';
import '../components/shimmer_loading.dart';
import 'event_detail_screen.dart';

class LocalEventsScreen extends StatefulWidget {
  const LocalEventsScreen({super.key});

  @override
  State<LocalEventsScreen> createState() => _LocalEventsScreenState();
}

class _LocalEventsScreenState extends State<LocalEventsScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<LocalEvent>> _eventsFuture;

  @override
  void initState() {
    super.initState();
    _eventsFuture = _apiService.fetchLocalEvents();
  }

  @override
  Widget build(BuildContext context) {
    final primaryBlue = const Color(0xFF0560E8);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Center(
                  child: Text(
                    "Local Events",
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                FutureBuilder<List<LocalEvent>>(
                  future: _eventsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Featured Event",
                                style: GoogleFonts.outfit(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1E293B),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          const ShimmerFeaturedEvent(),
                          const SizedBox(height: 32),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Upcoming Events",
                                style: GoogleFonts.outfit(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1E293B),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          const ShimmerUpcomingEvent(),
                          const ShimmerUpcomingEvent(),
                        ],
                      );
                    } else if (snapshot.hasError) {
                      return const SizedBox(
                        height: 500,
                        child: Center(child: Text("Error loading local events")),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const SizedBox(
                        height: 500,
                        child: Center(child: Text("No events found")),
                      );
                    }

                    final allEvents = snapshot.data!;
                    final featured = allEvents.firstWhere(
                      (e) => e.isFeatured,
                      orElse: () => allEvents.first,
                    );
                    final upcoming = allEvents.where((e) => e.id != featured.id).toList();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Featured Event Section
                        Text(
                          "Featured Event",
                          style: GoogleFonts.outfit(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Featured Card
                        _buildFeaturedCard(featured, primaryBlue),
                        const SizedBox(height: 32),

                        // Upcoming Events Section
                        Text(
                          "Upcoming Events",
                          style: GoogleFonts.outfit(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Upcoming List
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: upcoming.length,
                          itemBuilder: (context, index) {
                            return _buildUpcomingCard(upcoming[index], primaryBlue);
                          },
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedCard(LocalEvent event, Color primaryBlue) {
    Color crowdColor = event.crowdLevel == "Small"
        ? const Color(0xFF22C55E)
        : event.crowdLevel == "Moderate"
            ? const Color(0xFFF59E0B)
            : const Color(0xFFEF4444);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            // Image Stack
            SizedBox(
              height: 180,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(event.imageUrl, fit: BoxFit.cover),
                  // Dark cover gradient
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ),
                  // "LIVE TONIGHT" red label
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDC2626),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.circle, color: Colors.white, size: 8),
                          const SizedBox(width: 6),
                          Text(
                            event.time,
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Crowd status indicator top right
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: crowdColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                  // Details inside image bottom
                  Positioned(
                    bottom: 16,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: Colors.white70, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              event.location,
                              style: GoogleFonts.outfit(
                                color: Colors.white70,
                                fontSize: 13,
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
            // Bottom Action Bar of Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Chips
                  Row(
                    children: event.tags.map((tag) {
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: tag == "Sports" ? const Color(0xFFD1FAE5) : const Color(0xFFDBEAFE),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          tag,
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: tag == "Sports" ? const Color(0xFF065F46) : const Color(0xFF1E40AF),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  // Button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EventDetailScreen(event: event),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: Text(
                      "See Details",
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingCard(LocalEvent event, Color primaryBlue) {
    Color crowdColor = event.crowdLevel == "Small"
        ? const Color(0xFF22C55E)
        : event.crowdLevel == "Moderate"
            ? const Color(0xFFF59E0B)
            : const Color(0xFFEF4444);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event Title & Crowd dot
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  event.title,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ),
              const SizedBox(width: 8),
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
          // Metadata Row (Location, Date)
          Row(
            children: [
              const Icon(Icons.location_on, size: 12, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                event.location,
                style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.calendar_month, size: 12, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                event.date,
                style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Chips and Add Button Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: event.tags.map((tag) {
                  return Container(
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: tag == "Cultural"
                          ? const Color(0xFFFEF3C7)
                          : tag == "Ceremony"
                              ? const Color(0xFFF3E8FF)
                              : const Color(0xFFE0F2FE),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      tag,
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: tag == "Cultural"
                            ? const Color(0xFFB45309)
                            : tag == "Ceremony"
                                ? const Color(0xFF6B21A8)
                                : const Color(0xFF0369A1),
                      ),
                    ),
                  );
                }).toList(),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EventDetailScreen(event: event),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: Text(
                  "See Details",
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
