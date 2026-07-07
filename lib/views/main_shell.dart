import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/itinerary_controller.dart';
import 'home/home_screen.dart';
import 'map/crowd_map_screen.dart';
import 'itinerary/create_itinerary_screen.dart';
import 'events/local_events_screen.dart';
import 'profile/profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  final List<Widget> _screens = [
    const HomeScreen(),
    const CrowdMapScreen(),
    const CreateItineraryScreen(),
    const LocalEventsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final itineraryCtrl = context.watch<ItineraryController>();
    final activeIndex = itineraryCtrl.activeTab;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: IndexedStack(
        index: activeIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(context, 0, Icons.home_outlined, Icons.home, "Home", activeIndex),
                _buildNavItem(context, 1, Icons.map_outlined, Icons.map, "Crowd Map", activeIndex),
                _buildCenterButton(context),
                _buildNavItem(context, 3, Icons.calendar_today_outlined, Icons.calendar_today, "Events", activeIndex),
                _buildNavItem(context, 4, Icons.person_outline, Icons.person, "Profile", activeIndex),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, IconData outlineIcon, IconData solidIcon, String label, int activeIndex) {
    final isSelected = activeIndex == index;
    final primaryBlue = const Color(0xFF0560E8);
    final itineraryCtrl = Provider.of<ItineraryController>(context, listen: false);
    
    return GestureDetector(
      onTap: () {
        itineraryCtrl.setActiveTab(index);
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSelected ? solidIcon : outlineIcon,
            color: isSelected ? primaryBlue : Colors.grey[400],
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected ? primaryBlue : Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterButton(BuildContext context) {
    final primaryBlue = const Color(0xFF0560E8);
    final itineraryCtrl = Provider.of<ItineraryController>(context, listen: false);
    
    return GestureDetector(
      onTap: () {
        itineraryCtrl.setActiveTab(2);
      },
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: primaryBlue,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: primaryBlue.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.add_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}
