import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../controllers/profile_controller.dart';
import '../../controllers/itinerary_controller.dart';
import '../itinerary/ai_itinerary_screen.dart';
import '../components/app_logo.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Load saved itineraries from Supabase on start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ItineraryController>(context, listen: false).loadSavedPlans();
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileCtrl = context.watch<ProfileController>();
    final itineraryCtrl = context.watch<ItineraryController>();
    final primaryBlue = const Color(0xFF0560E8);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FD),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 20.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 1. Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "My Profile",
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // 2. Profile Avatar with Dynamic Camera Capture
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 64,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: profileCtrl.profileImage != null
                          ? FileImage(File(profileCtrl.profileImage!.path))
                          : null,
                      child: profileCtrl.profileImage == null
                          ? Icon(
                              Icons.person_rounded,
                              size: 64,
                              color: Colors.grey[400],
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 4,
                      child: GestureDetector(
                        onTap: () {
                          profileCtrl.capturePhoto();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: primaryBlue,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 3. User Name & Email info
                Text(
                  profileCtrl.name,
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  profileCtrl.email,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 32),

                // 4. My Saved Plans Section (Integrated with Supabase)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.withOpacity(0.1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.bookmark_outline, color: primaryBlue, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            "My Saved Plans",
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      if (itineraryCtrl.isLoadingSavedPlans)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20.0),
                          child: Center(
                            child: CircularProgressIndicator(strokeWidth: 3),
                          ),
                        )
                      else if (itineraryCtrl.savedPlans.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            "No saved plans yet. Create one in the form tab!",
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              color: Colors.grey[500],
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
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.withOpacity(0.08)),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
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
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                  onPressed: () async {
                                    try {
                                      await itineraryCtrl.removePlan(plan);
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text("Plan deleted from Supabase!"),
                                          duration: Duration(seconds: 1),
                                        ),
                                      );
                                    } catch (e) {
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text("Failed to delete plan: $e"),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  },
                                ),
                                onTap: () {
                                  // Set active itinerary and open view result screen
                                  itineraryCtrl.generatedItinerary = plan;
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const AIItineraryScreen(),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Version Label
                const AppLogo(size: 28, fontSize: 16, showText: true),
                const SizedBox(height: 8),
                Text(
                  "Version 1.0.0",
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: Colors.grey[400],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
