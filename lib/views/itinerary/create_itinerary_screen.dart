import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../controllers/itinerary_controller.dart';
import '../../models/itinerary.dart';
import 'ai_itinerary_screen.dart';

class CreateItineraryScreen extends StatefulWidget {
  const CreateItineraryScreen({super.key});

  @override
  State<CreateItineraryScreen> createState() => _CreateItineraryScreenState();
}

class _CreateItineraryScreenState extends State<CreateItineraryScreen> {
  final TextEditingController _destinationCtrl = TextEditingController();

  // Local form state
  DateTime _departureDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  DateTime _returnDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  int _adultsCount = 2;
  int _childrenCount = 0;

  @override
  void dispose() {
    _destinationCtrl.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    const months = [
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
    return "${months[date.month - 1]} ${date.day}, ${date.year}";
  }

  Future<void> _selectDate(BuildContext context, bool isDeparture) async {
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isDeparture ? _departureDate : _returnDate,
      firstDate: today,
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
      setState(() {
        if (isDeparture) {
          _departureDate = picked;
          // Auto-adjust return date if it's before new departure
          if (_returnDate.isBefore(_departureDate)) {
            _returnDate = _departureDate.add(const Duration(days: 1));
          }
        } else {
          _returnDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final itineraryCtrl = Provider.of<ItineraryController>(
      context,
      listen: false,
    );
    final primaryBlue = const Color(0xFF0560E8);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FD),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Blue Top Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                top: 60,
                left: 24,
                right: 24,
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
                  Text(
                    "Create Travel Plan",
                    style: GoogleFonts.outfit(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Enter plan details to create a custom manual travel itinerary planner.",
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w300,
                      color: Colors.white.withOpacity(0.85),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Travel Plan Name Input
                  _buildSectionTitle("Travel Plan Name"),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: primaryBlue.withOpacity(0.2)),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.edit_note, color: primaryBlue, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _destinationCtrl,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "e.g. My Bali Adventure",
                              hintStyle: GoogleFonts.outfit(
                                color: Colors.grey[400],
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Travel Dates (Departure & Return side-by-side)
                  _buildSectionTitle("Travel Dates"),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _selectDate(context, true),
                          child: _buildFormFieldCard(
                            title: "Departure",
                            value: _formatDate(_departureDate),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _selectDate(context, false),
                          child: _buildFormFieldCard(
                            title: "Return",
                            value: _formatDate(_returnDate),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Travelers counters side-by-side
                  _buildSectionTitle("Travelers"),
                  Row(
                    children: [
                      // Adults
                      Expanded(
                        child: _buildCounterFieldCard(
                          title: "Adults",
                          value: "$_adultsCount People",
                          onIncrement: () => setState(() => _adultsCount++),
                          onDecrement: () {
                            if (_adultsCount > 1) {
                              setState(() => _adultsCount--);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Children
                      Expanded(
                        child: _buildCounterFieldCard(
                          title: "Children",
                          value: "$_childrenCount People",
                          onIncrement: () => setState(() => _childrenCount++),
                          onDecrement: () {
                            if (_childrenCount > 0) {
                              setState(() => _childrenCount--);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Create Manual Plan Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_destinationCtrl.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Please enter a Travel Plan name."),
                            ),
                          );
                          return;
                        }

                        if (_returnDate.isBefore(_departureDate)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Return date cannot be before departure date.",
                              ),
                            ),
                          );
                          return;
                        }

                        final daysCount =
                            _returnDate.difference(_departureDate).inDays + 1;
                        const List<String> weekdays = [
                          "Monday",
                          "Tuesday",
                          "Wednesday",
                          "Thursday",
                          "Friday",
                          "Saturday",
                          "Sunday",
                        ];
                        const List<String> monthsList = [
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

                        final List<ItineraryDay> manualDays = [];
                        for (int i = 0; i < daysCount; i++) {
                          final dayDate = _departureDate.add(Duration(days: i));
                          final weekdayStr = weekdays[dayDate.weekday - 1];

                          manualDays.add(
                            ItineraryDay(
                              dayNumber: i + 1,
                              dateString: "${dayDate.day} $weekdayStr",
                              weekday: weekdayStr,
                              dayOfMonth: "${dayDate.day}",
                              activities: [],
                            ),
                          );
                        }

                        final rangeStart =
                            "${_departureDate.day} ${monthsList[_departureDate.month - 1]}";
                        final rangeEnd =
                            "${_returnDate.day} ${monthsList[_returnDate.month - 1]}";

                        final manualItinerary = Itinerary(
                          destinationName: _destinationCtrl.text,
                          dateRange: "$rangeStart - $rangeEnd",
                          vibe: "Custom",
                          totalDays: daysCount,
                          totalTravelers: _adultsCount + _childrenCount,
                          estimatedBudget: 0.0,
                          days: manualDays,
                        );

                        itineraryCtrl.generatedItinerary = manualItinerary;

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AIItineraryScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Create Itinerary",
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Icon(
                            Icons.edit_note,
                            color: Colors.white,
                            size: 24,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF1E293B),
        ),
      ),
    );
  }

  Widget _buildFormFieldCard({required String title, required String value}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F52BA),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCounterFieldCard({
    required String title,
    required String value,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
  }) {
    final primaryBlue = const Color(0xFF0560E8);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F52BA),
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: onIncrement,
                    child: Icon(
                      Icons.add_circle_outline,
                      color: primaryBlue,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: onDecrement,
                    child: Icon(
                      Icons.remove_circle_outline,
                      color: primaryBlue,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
