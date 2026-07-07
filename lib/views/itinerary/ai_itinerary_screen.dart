import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../controllers/itinerary_controller.dart';
import '../../models/itinerary.dart';
import '../../services/api_service.dart';
import '../../models/destination.dart';

class AIItineraryScreen extends StatefulWidget {
  const AIItineraryScreen({super.key});

  @override
  State<AIItineraryScreen> createState() => _AIItineraryScreenState();
}

class _AIItineraryScreenState extends State<AIItineraryScreen> {
  int _selectedDayIndex = 0;
  String? _originalDestinationName;
  late Future<List<Destination>> _destinationsFuture;

  @override
  void initState() {
    super.initState();
    _destinationsFuture = ApiService().fetchDestinations();
  }

  void _showAddActivityBottomSheet(
    BuildContext context,
    Itinerary itinerary,
    ItineraryDay day,
    ItineraryController itineraryCtrl,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return FutureBuilder<List<Destination>>(
          future: _destinationsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 250,
                child: Center(child: CircularProgressIndicator(strokeWidth: 3)),
              );
            }
            if (snapshot.hasError ||
                !snapshot.hasData ||
                snapshot.data!.isEmpty) {
              return SizedBox(
                height: 200,
                child: Center(
                  child: Text(
                    "Error loading destinations from Supabase",
                    style: GoogleFonts.outfit(color: Colors.red),
                  ),
                ),
              );
            }

            final liveSpots = snapshot.data!;

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Add Stop to Day ${day.dayNumber}",
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Select a spot from your live destinations table:",
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      color: Colors.grey[500],
                    ),
                  ),
                  const Divider(height: 28),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: liveSpots.length,
                      itemBuilder: (context, index) {
                        final spot = liveSpots[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 2,
                            ),
                            leading: const Icon(
                              Icons.place,
                              color: Color(0xFF0560E8),
                            ),
                            title: Text(
                              spot.name,
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                            subtitle: Text(
                              "${spot.location} • ${spot.crowdLevel} Crowd",
                              style: GoogleFonts.outfit(fontSize: 12),
                            ),
                            onTap: () async {
                              Navigator.pop(context);

                              final newActivity = ItineraryActivity(
                                id: "custom_${DateTime.now().millisecondsSinceEpoch}",
                                title: spot.name,
                                location: spot.location,
                                time: "11:00 AM",
                                crowdLevel: spot.crowdLevel,
                                description: spot.description,
                                cost: 5.0,
                              );

                              setState(() {
                                day.activities.add(newActivity);
                              });

                              // Check if this plan is already saved in Supabase
                              final isAlreadySaved = itineraryCtrl.savedPlans
                                  .any(
                                    (p) =>
                                        p.destinationName ==
                                            itinerary.destinationName &&
                                        p.dateRange == itinerary.dateRange,
                                  );

                              if (isAlreadySaved) {
                                try {
                                  await itineraryCtrl.savePlan(itinerary);
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Plan saved"),
                                      backgroundColor: Color(0xFF22C55E),
                                    ),
                                  );
                                } catch (e) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "Failed to sync change: $e",
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Stop added locally! Click Save Changes",
                                    ),
                                    backgroundColor: Colors.blue,
                                  ),
                                );
                              }
                            },
                          ),
                        );
                      },
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

  @override
  Widget build(BuildContext context) {
    final itineraryCtrl = context.watch<ItineraryController>();
    final itinerary = itineraryCtrl.generatedItinerary;
    final primaryBlue = const Color(0xFF0560E8);

    if (itinerary != null && _originalDestinationName == null) {
      _originalDestinationName = itinerary.destinationName;
    }

    if (itinerary == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange,
                size: 50,
              ),
              const SizedBox(height: 12),
              Text(
                "No itinerary created yet.",
                style: GoogleFonts.outfit(fontSize: 16),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Go Back"),
              ),
            ],
          ),
        ),
      );
    }

    final selectedDay = itinerary.days[_selectedDayIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FD),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Blue Header Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                top: 60,
                left: 20,
                right: 20,
                bottom: 28,
              ),
              decoration: BoxDecoration(
                color: primaryBlue,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back Button
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      // Save Changes Button
                      GestureDetector(
                        onTap: () async {
                          try {
                            if (_originalDestinationName != null &&
                                _originalDestinationName !=
                                    itinerary.destinationName) {
                              await ApiService().deleteItinerary(
                                _originalDestinationName!,
                              );
                            }
                            await itineraryCtrl.savePlan(itinerary);
                            _originalDestinationName =
                                itinerary.destinationName;
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Changes for ${itinerary.destinationName} saved",
                                ),
                                duration: const Duration(seconds: 2),
                                backgroundColor: const Color(0xFF22C55E),
                              ),
                            );
                            itineraryCtrl.setActiveTab(0); // Switch to Home Tab
                            Navigator.pop(context); // Go back to Home Shell
                          } catch (e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Failed to save changes: $e"),
                                duration: const Duration(seconds: 3),
                                backgroundColor: const Color(0xFFEF4444),
                              ),
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Row(
                            children: [
                              Text(
                                "Save Changes",
                                style: GoogleFonts.outfit(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: primaryBlue,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(Icons.check, color: primaryBlue, size: 14),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          itinerary.destinationName,
                          style: GoogleFonts.outfit(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.edit,
                          color: Colors.white70,
                          size: 20,
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              final nameCtrl = TextEditingController(
                                text: itinerary.destinationName,
                              );
                              return AlertDialog(
                                title: Text(
                                  "Edit Travel Plan Name",
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                content: TextField(
                                  controller: nameCtrl,
                                  decoration: const InputDecoration(
                                    hintText: "e.g. My Bali Adventure",
                                  ),
                                  style: GoogleFonts.outfit(),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text("Cancel"),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      if (nameCtrl.text.isNotEmpty) {
                                        setState(() {
                                          itinerary.destinationName =
                                              nameCtrl.text;
                                        });
                                        Navigator.pop(context);
                                      }
                                    },
                                    child: const Text("Save"),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () async {
                      // 1. Parse initial dates from itinerary.dateRange
                      DateTime initialStart = DateTime.now();
                      DateTime initialEnd = DateTime.now().add(
                        const Duration(days: 2),
                      );

                      try {
                        final monthsMap = {
                          "Jan": 1,
                          "Feb": 2,
                          "Mar": 3,
                          "Apr": 4,
                          "May": 5,
                          "Jun": 6,
                          "Jul": 7,
                          "Aug": 8,
                          "Sep": 9,
                          "Oct": 10,
                          "Nov": 11,
                          "Dec": 12,
                        };

                        DateTime parsePart(String part) {
                          final cleaned = part.trim();
                          final words = cleaned.split(' ');
                          final d =
                              int.tryParse(words[0]) ?? DateTime.now().day;
                          final mStr = words.length > 1 ? words[1] : "";
                          final m = monthsMap[mStr] ?? DateTime.now().month;
                          final y = words.length > 2
                              ? (int.tryParse(words[2]) ?? DateTime.now().year)
                              : DateTime.now().year;
                          return DateTime(y, m, d);
                        }

                        final rangeParts = itinerary.dateRange.split('-');
                        if (rangeParts.length == 2) {
                          initialStart = parsePart(rangeParts[0]);
                          initialEnd = parsePart(rangeParts[1]);
                        }
                      } catch (_) {}

                      // 2. Show the standard calendar DateRangePicker
                      final DateTimeRange? picked = await showDateRangePicker(
                        context: context,
                        initialDateRange: DateTimeRange(
                          start: initialStart,
                          end: initialEnd,
                        ),
                        firstDate: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
                        lastDate: DateTime(2030),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.light(
                                primary: Color(0xFF0560E8),
                                onPrimary: Colors.white,
                                onSurface: Colors.black87,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );

                      if (picked != null) {
                        final List<String> weekdays = [
                          "Monday",
                          "Tuesday",
                          "Wednesday",
                          "Thursday",
                          "Friday",
                          "Saturday",
                          "Sunday",
                        ];
                        final List<String> monthsList = [
                          "Jan",
                          "Feb",
                          "Mar",
                          "Apr",
                          "May",
                          "Jun",
                          "Jul",
                          "Aug",
                          "Sep",
                          "Oct",
                          "Nov",
                          "Dec",
                        ];

                        final newDaysCount =
                            picked.end.difference(picked.start).inDays + 1;
                        final List<ItineraryDay> updatedDays = [];

                        for (int i = 0; i < newDaysCount; i++) {
                          final dayDate = picked.start.add(Duration(days: i));
                          final weekdayStr = weekdays[dayDate.weekday - 1];

                          // Preserve activities from existing days if index is within bounds
                          final existingActivities = i < itinerary.days.length
                              ? itinerary.days[i].activities
                              : <ItineraryActivity>[];

                          updatedDays.add(
                            ItineraryDay(
                              dayNumber: i + 1,
                              dateString: "${dayDate.day} $weekdayStr",
                              weekday: weekdayStr,
                              dayOfMonth: "${dayDate.day}",
                              activities: existingActivities,
                            ),
                          );
                        }

                        final rangeStartStr =
                            "${picked.start.day} ${monthsList[picked.start.month - 1]}";
                        final rangeEndStr =
                            "${picked.end.day} ${monthsList[picked.end.month - 1]}";

                        setState(() {
                          itinerary.dateRange = "$rangeStartStr - $rangeEndStr";
                          itinerary.totalDays = newDaysCount;
                          itinerary.days = updatedDays;

                          // Cap selectedDayIndex to avoid any array out-of-bounds index errors
                          if (_selectedDayIndex >= newDaysCount) {
                            _selectedDayIndex = newDaysCount - 1;
                          }
                        });
                      }
                    },
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_month,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          itinerary.dateRange,
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withOpacity(0.9),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.edit, color: Colors.white70, size: 14),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Horizontal Recommendation Section
            Padding(
              padding: const EdgeInsets.only(
                left: 20.0,
                right: 20.0,
                top: 28.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Explore Places with Less Crowds Near You",
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      itineraryCtrl.setActiveTab(1); // Navigate to Crowd Map tab
                      Navigator.pop(context); // Go back to Shell
                    },
                    child: Text(
                      "See All",
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: primaryBlue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            FutureBuilder<List<Destination>>(
              future: _destinationsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 120,
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                }
                if (snapshot.hasError ||
                    !snapshot.hasData ||
                    snapshot.data!.isEmpty) {
                  return const SizedBox();
                }

                final destinations = snapshot.data!;
                // Prioritize lesser crowd (Small & Moderate), filter out High
                final lowCrowdDestinations = destinations
                    .where(
                      (d) =>
                          d.crowdLevel == "Small" || d.crowdLevel == "Moderate",
                    )
                    .toList();
                lowCrowdDestinations.sort((a, b) {
                  if (a.crowdLevel == "Small" && b.crowdLevel != "Small") {
                    return -1;
                  }
                  if (a.crowdLevel != "Small" && b.crowdLevel == "Small") {
                    return 1;
                  }
                  return 0;
                });

                return SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: lowCrowdDestinations.length,
                    itemBuilder: (context, index) {
                      final dest = lowCrowdDestinations[index];
                      Color crowdColor = dest.crowdLevel == "Small"
                          ? const Color(0xFF22C55E)
                          : const Color(0xFFF59E0B);

                      return _buildNearChoiceCard(
                        title: dest.name.split(' (').first,
                        imageUrl: dest.imageUrl,
                        crowdColor: crowdColor,
                        onAdd: () {
                          if (_selectedDayIndex >= itinerary.days.length) {
                            return;
                          }

                          final targetDay = itinerary.days[_selectedDayIndex];
                          final newAct = ItineraryActivity(
                            id: "manual_${DateTime.now().millisecondsSinceEpoch}_${dest.name.hashCode}",
                            title: dest.name,
                            location: dest.location,
                            time: "02:30 PM",
                            crowdLevel: dest.crowdLevel,
                            description: dest.description,
                            cost: 0.0,
                          );

                          setState(() {
                            targetDay.activities.add(newAct);
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Added ${dest.name} to Day ${targetDay.dayNumber}",
                              ),
                              backgroundColor: const Color(0xFF0560E8),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),

            // Your Itinerary Day Selector Title
            Padding(
              padding: const EdgeInsets.only(
                left: 20.0,
                right: 20.0,
                top: 28.0,
                bottom: 12.0,
              ),
              child: Text(
                "Your Itinerary",
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ),

            // Horizontal Calendar Selector Row
            SizedBox(
              height: 86,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: itinerary.days.length,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemBuilder: (context, index) {
                  final day = itinerary.days[index];
                  final isSelected = _selectedDayIndex == index;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDayIndex = index;
                      });
                    },
                    child: Container(
                      width: 72,
                      margin: const EdgeInsets.only(right: 12, bottom: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? primaryBlue : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? Colors.transparent
                              : Colors.grey.withOpacity(0.2),
                        ),
                        boxShadow: [
                          if (isSelected)
                            BoxShadow(
                              color: primaryBlue.withOpacity(0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            day.dayOfMonth,
                            style: GoogleFonts.outfit(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            day.weekday,
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              color: isSelected
                                  ? Colors.white.withOpacity(0.9)
                                  : Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Timeline List of Stops
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: selectedDay.activities.length,
                    itemBuilder: (context, index) {
                      final activity = selectedDay.activities[index];
                      final isLast = index == selectedDay.activities.length - 1;

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left Indicator Timeline Line
                          Column(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: primaryBlue,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    "${index + 1}",
                                    style: GoogleFonts.outfit(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                              if (!isLast)
                                Container(
                                  width: 2,
                                  height: 90,
                                  decoration: const BoxDecoration(
                                    color: Colors.grey,
                                    border: Border(
                                      left: BorderSide(
                                        color: Colors.grey,
                                        width: 1,
                                        style: BorderStyle.solid,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(width: 16),

                          // Activity Card Info
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 24),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.grey.withOpacity(0.15),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    activity.title,
                                    style: GoogleFonts.outfit(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF1E293B),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on,
                                        size: 14,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          activity.location,
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
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      // Crowd tag dot & text
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: activity.crowdLevel == "Small"
                                              ? const Color(0xFF22C55E)
                                              : activity.crowdLevel ==
                                                    "Moderate"
                                              ? const Color(0xFFF59E0B)
                                              : const Color(0xFFEF4444),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        "${activity.crowdLevel} Crowds",
                                        style: GoogleFonts.outfit(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: activity.crowdLevel == "Small"
                                              ? const Color(0xFF22C55E)
                                              : activity.crowdLevel ==
                                                    "Moderate"
                                              ? const Color(0xFFF59E0B)
                                              : const Color(0xFFEF4444),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  GestureDetector(
                    onTap: () {
                      _showAddActivityBottomSheet(
                        context,
                        itinerary,
                        selectedDay,
                        itineraryCtrl,
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(top: 8, bottom: 24),
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F5FF),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF0560E8).withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Color(0xFFE8F0FE),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.add_location_alt_rounded,
                              color: Color(0xFF0560E8),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "Add Destination Spot",
                            style: GoogleFonts.outfit(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0560E8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNearChoiceCard({
    required String title,
    required String imageUrl,
    required Color crowdColor,
    required VoidCallback onAdd,
  }) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(imageUrl, fit: BoxFit.cover),
            // Black gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
            // Crowd Dot
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: crowdColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
            // Plus Button Overlay
            Positioned(
              top: 8,
              left: 8,
              child: GestureDetector(
                onTap: onAdd,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Color(0xFF0560E8),
                    size: 14,
                  ),
                ),
              ),
            ),
            // Title
            Positioned(
              bottom: 8,
              left: 12,
              right: 12,
              child: Text(
                title,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
