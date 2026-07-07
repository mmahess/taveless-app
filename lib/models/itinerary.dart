class ItineraryActivity {
  final String id;
  final String title;
  final String location;
  final String time;
  final String crowdLevel; // 'Small', 'Moderate', 'High'
  final String description;
  final double cost;

  ItineraryActivity({
    required this.id,
    required this.title,
    required this.location,
    required this.time,
    required this.crowdLevel,
    required this.description,
    required this.cost,
  });

  factory ItineraryActivity.fromJson(Map<String, dynamic> json) {
    return ItineraryActivity(
      id: json['id'] as String,
      title: json['title'] as String,
      location: json['location'] as String,
      time: json['time'] as String,
      crowdLevel: json['crowdLevel'] as String,
      description: json['description'] as String,
      cost: (json['cost'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'location': location,
      'time': time,
      'crowdLevel': crowdLevel,
      'description': description,
      'cost': cost,
    };
  }
}

class ItineraryDay {
  final int dayNumber;
  final String dateString; // e.g. "24 Saturday"
  final String weekday;     // e.g. "Saturday"
  final String dayOfMonth;   // e.g. "24"
  final List<ItineraryActivity> activities;

  ItineraryDay({
    required this.dayNumber,
    required this.dateString,
    required this.weekday,
    required this.dayOfMonth,
    required this.activities,
  });

  factory ItineraryDay.fromJson(Map<String, dynamic> json) {
    return ItineraryDay(
      dayNumber: json['dayNumber'] as int,
      dateString: json['dateString'] as String,
      weekday: json['weekday'] as String,
      dayOfMonth: json['dayOfMonth'] as String,
      activities: (json['activities'] as List)
          .map((a) => ItineraryActivity.fromJson(a as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dayNumber': dayNumber,
      'dateString': dateString,
      'weekday': weekday,
      'dayOfMonth': dayOfMonth,
      'activities': activities.map((a) => a.toJson()).toList(),
    };
  }
}

class Itinerary {
  String destinationName;
  String dateRange;
  final String vibe;
  int totalDays;
  final int totalTravelers;
  final double estimatedBudget;
  List<ItineraryDay> days;

  Itinerary({
    required this.destinationName,
    required this.dateRange,
    required this.vibe,
    required this.totalDays,
    required this.totalTravelers,
    required this.estimatedBudget,
    required this.days,
  });

  factory Itinerary.fromJson(Map<String, dynamic> json) {
    return Itinerary(
      destinationName: json['destinationName'] as String,
      dateRange: json['dateRange'] as String,
      vibe: json['vibe'] as String,
      totalDays: json['totalDays'] as int,
      totalTravelers: json['totalTravelers'] as int,
      estimatedBudget: (json['estimatedBudget'] as num).toDouble(),
      days: (json['days'] as List)
          .map((d) => ItineraryDay.fromJson(d as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'destinationName': destinationName,
      'dateRange': dateRange,
      'vibe': vibe,
      'totalDays': totalDays,
      'totalTravelers': totalTravelers,
      'estimatedBudget': estimatedBudget,
      'days': days.map((d) => d.toJson()).toList(),
    };
  }
}
