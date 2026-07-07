import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../controllers/itinerary_controller.dart';
import '../../models/itinerary.dart';

class SpotDetailScreen extends StatelessWidget {
  final String name;
  final String crowdLevel;
  final String address;
  final String description;
  final String imageUrl;
  final double rating;

  const SpotDetailScreen({
    super.key,
    required this.name,
    required this.crowdLevel,
    required this.address,
    required this.description,
    required this.imageUrl,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    Color crowdColor;
    if (crowdLevel == "Small") {
      crowdColor = const Color(0xFF22C55E);
    } else if (crowdLevel == "Moderate") {
      crowdColor = const Color(0xFFF59E0B);
    } else {
      crowdColor = const Color(0xFFEF4444);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Large Header Background Image
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 380,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.4),
                      Colors.transparent,
                      Colors.black.withOpacity(0.6),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ),

          // 2. Scrollable Detail content sheet
          Positioned.fill(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 320), // Spacing for background image
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title Row
                        Text(
                          name,
                          style: GoogleFonts.outfit(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Rating & Location row
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 18),
                            const SizedBox(width: 4),
                            Text(
                              rating.toString(),
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Icon(Icons.location_on, color: Colors.grey, size: 16),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                address,
                                style: GoogleFonts.outfit(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Crowd Status Alert Banner
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: crowdColor.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: crowdColor.withOpacity(0.2)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, color: crowdColor, size: 22),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "$crowdLevel Crowd Level Detected",
                                      style: GoogleFonts.outfit(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: crowdColor,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      crowdLevel == "High"
                                          ? "Consider visiting during early mornings or alternative quiet temples."
                                          : "Perfect time to visit. Enjoy a tranquil experience with fewer crowds.",
                                      style: GoogleFonts.outfit(
                                        fontSize: 12,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Description Header
                        Text(
                          "About this Destination",
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Description Text
                        Text(
                          description,
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            color: Colors.grey[700],
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Add to Itinerary Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              _showAddToItineraryBottomSheet(context);
                            },
                            icon: const Icon(Icons.add_location_alt_outlined, color: Colors.white),
                            label: Text(
                              "Add to My Itinerary",
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0560E8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Floating Close Back Button (Layered on top)
          Positioned(
            top: 50,
            left: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.close, size: 20, color: Colors.black87),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddToItineraryBottomSheet(BuildContext context) {
    final itineraryCtrl = Provider.of<ItineraryController>(context, listen: false);
    final savedPlans = itineraryCtrl.savedPlans;

    if (savedPlans.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text("No Itineraries Found", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          content: Text(
            "You haven't created any trip itineraries yet. Go to the Create tab to start your first trip!",
            style: GoogleFonts.outfit(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (context) {
        int selectedPlanIndex = 0;
        int selectedDayIndex = 0;

        return StatefulBuilder(
          builder: (context, setBottomSheetState) {
            final activePlan = savedPlans[selectedPlanIndex];

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Add to Trip Itinerary",
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Select which trip and day to add '$name':",
                    style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey[500]),
                  ),
                  const Divider(height: 24),

                  // Dropdown selector for Itinerary
                  Text(
                    "Select Trip",
                    style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: selectedPlanIndex,
                        isExpanded: true,
                        items: List.generate(savedPlans.length, (index) {
                          final plan = savedPlans[index];
                          return DropdownMenuItem<int>(
                            value: index,
                            child: Text(
                              "${plan.destinationName} (${plan.dateRange})",
                              style: GoogleFonts.outfit(fontSize: 14),
                            ),
                          );
                        }),
                        onChanged: (val) {
                          if (val != null) {
                            setBottomSheetState(() {
                              selectedPlanIndex = val;
                              selectedDayIndex = 0; // Reset selected day for new plan
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Day selector
                  Text(
                    "Select Day",
                    style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 44,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: activePlan.days.length,
                      itemBuilder: (context, index) {
                        final isSelected = selectedDayIndex == index;
                        return GestureDetector(
                          onTap: () {
                            setBottomSheetState(() {
                              selectedDayIndex = index;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 10),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF0560E8) : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: Center(
                              child: Text(
                                "Day ${index + 1}",
                                style: GoogleFonts.outfit(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? Colors.white : Colors.black87,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Add Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context); // Close bottom sheet

                        final targetPlan = savedPlans[selectedPlanIndex];
                        final targetDay = targetPlan.days[selectedDayIndex];

                        final newActivity = ItineraryActivity(
                          id: "custom_${DateTime.now().millisecondsSinceEpoch}",
                          title: name,
                          location: address,
                          time: "12:00 PM",
                          crowdLevel: crowdLevel,
                          description: description,
                          cost: 5.0,
                        );

                        targetDay.activities.add(newActivity);

                        try {
                          // Show loading overlay
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => const Center(child: CircularProgressIndicator()),
                          );

                          await itineraryCtrl.savePlan(targetPlan);

                          if (!context.mounted) return;
                          Navigator.pop(context); // Close loading overlay

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Added '$name' to Day ${selectedDayIndex + 1} of ${targetPlan.destinationName}!"),
                              backgroundColor: const Color(0xFF22C55E),
                            ),
                          );
                        } catch (e) {
                          if (!context.mounted) return;
                          Navigator.pop(context); // Close loading overlay
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Failed to save changes: $e"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0560E8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(
                        "Confirm Add",
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
