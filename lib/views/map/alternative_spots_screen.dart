import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/api_service.dart';
import '../../models/destination.dart';
import 'spot_detail_screen.dart';

class AlternativeSpotsScreen extends StatelessWidget {
  final String selectedSpotName;
  final String selectedAddress;

  const AlternativeSpotsScreen({
    super.key,
    required this.selectedSpotName,
    required this.selectedAddress,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Less Crowded Alternatives",
          style: GoogleFonts.outfit(
            color: const Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Destination>>(
        future: ApiService().fetchDestinations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(strokeWidth: 2.5));
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                "No alternatives found.",
                style: GoogleFonts.outfit(color: Colors.grey[500]),
              ),
            );
          }

          final allDestinations = snapshot.data!;
          final nameLower = selectedSpotName.toLowerCase();
          
          // Determine Category Keyword
          String category = "";
          if (nameLower.contains("beach") || nameLower.contains("pantai")) {
            category = "beach";
          } else if (nameLower.contains("waterfall")) {
            category = "waterfall";
          } else if (nameLower.contains("temple") || nameLower.contains("pura")) {
            category = "temple";
          } else if (nameLower.contains("hike") || nameLower.contains("trek") || nameLower.contains("mount")) {
            category = "hike";
          } else if (nameLower.contains("reef") || nameLower.contains("bay") || nameLower.contains("lagoon") || nameLower.contains("island")) {
            category = "ocean";
          }

          // Filter logic: same category, not the same spot, prioritizing less crowd levels (Small / Moderate)
          final alternatives = allDestinations.where((dest) {
            final destNameLower = dest.name.toLowerCase();
            final destDescLower = dest.description.toLowerCase();
            final isSameSpot = destNameLower.contains(nameLower) || nameLower.contains(destNameLower);
            
            if (isSameSpot) return false;

            // Matching category or description
            bool categoryMatch = false;
            if (category == "beach") {
              categoryMatch = destNameLower.contains("beach") || destNameLower.contains("pantai") || destDescLower.contains("beach") || destDescLower.contains("shore");
            } else if (category == "waterfall") {
              categoryMatch = destNameLower.contains("waterfall") || destDescLower.contains("waterfall") || destDescLower.contains("cascade");
            } else if (category == "temple") {
              categoryMatch = destNameLower.contains("temple") || destNameLower.contains("pura") || destDescLower.contains("temple");
            } else if (category == "hike") {
              categoryMatch = destNameLower.contains("hike") || destNameLower.contains("trek") || destNameLower.contains("mount") || destNameLower.contains("ridge");
            } else if (category == "ocean") {
              categoryMatch = destNameLower.contains("reef") || destNameLower.contains("bay") || destNameLower.contains("lagoon") || destNameLower.contains("island") || destDescLower.contains("dive") || destDescLower.contains("snorkel");
            } else {
              // Default to matching location keyword if no category is found
              categoryMatch = dest.location.split(',').first.toLowerCase() == selectedAddress.split(',').first.toLowerCase();
            }

            // Exclude High crowd level spots to keep user safe
            return categoryMatch && (dest.crowdLevel == "Small" || dest.crowdLevel == "Moderate");
          }).toList();

          // Sort: 'Small' crowd levels first, then 'Moderate'
          alternatives.sort((a, b) {
            if (a.crowdLevel == "Small" && b.crowdLevel != "Small") return -1;
            if (a.crowdLevel != "Small" && b.crowdLevel == "Small") return 1;
            return 0;
          });

          if (alternatives.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.nature_people_outlined, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      "No similar less-crowded spots found",
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Try exploring another spot type on the map to find quiet options.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: alternatives.length,
            itemBuilder: (context, index) {
              final dest = alternatives[index];
              Color crowdColor = dest.crowdLevel == "Small"
                  ? const Color(0xFF22C55E)
                  : const Color(0xFFF59E0B);

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SpotDetailScreen(
                          name: dest.name,
                          crowdLevel: dest.crowdLevel,
                          address: dest.location,
                          description: dest.description,
                          imageUrl: dest.imageUrl,
                          rating: dest.rating,
                        ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Row(
                    children: [
                      // Image
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          bottomLeft: Radius.circular(16),
                        ),
                        child: Image.network(
                          dest.imageUrl,
                          width: 110,
                          height: 110,
                          fit: BoxFit.cover,
                        ),
                      ),
                      // Details
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                dest.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: const Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.location_on, size: 13, color: Colors.grey),
                                  const SizedBox(width: 2),
                                  Expanded(
                                    child: Text(
                                      dest.location,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey[600]),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: crowdColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      "${dest.crowdLevel} Crowd",
                                      style: GoogleFonts.outfit(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: crowdColor,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      const Icon(Icons.star, color: Colors.amber, size: 14),
                                      const SizedBox(width: 2),
                                      Text(
                                        dest.rating.toString(),
                                        style: GoogleFonts.outfit(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF1E293B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
