class LocalEvent {
  final String id;
  final String title;
  final String location;
  final String date;
  final String time;
  final String imageUrl;
  final List<String> tags;
  final String crowdLevel; // 'Small', 'Moderate', 'High'
  final bool isFeatured;
  final String description;

  LocalEvent({
    required this.id,
    required this.title,
    required this.location,
    required this.date,
    required this.time,
    required this.imageUrl,
    required this.tags,
    required this.crowdLevel,
    required this.isFeatured,
    required this.description,
  });

  factory LocalEvent.fromJson(Map<String, dynamic> json) {
    return LocalEvent(
      id: json['id'].toString(),
      title: json['title'] as String,
      location: json['location'] as String,
      date: json['date'] as String,
      time: json['time'] as String,
      imageUrl: json['imageUrl'] as String,
      tags: List<String>.from(json['tags'] as List),
      crowdLevel: json['crowdLevel'] as String,
      isFeatured: json['isFeatured'] as bool,
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'location': location,
      'date': date,
      'time': time,
      'imageUrl': imageUrl,
      'tags': tags,
      'crowdLevel': crowdLevel,
      'isFeatured': isFeatured,
      'description': description,
    };
  }
}
