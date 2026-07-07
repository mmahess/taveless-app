class Destination {
  final String id;
  final String name;
  final String location;
  final double rating;
  final String imageUrl;
  final String crowdLevel; // 'Small', 'Moderate', 'High'
  final String description;
  final double latitude;
  final double longitude;

  Destination({
    required this.id,
    required this.name,
    required this.location,
    required this.rating,
    required this.imageUrl,
    required this.crowdLevel,
    required this.description,
    required this.latitude,
    required this.longitude,
  });

  factory Destination.fromJson(Map<String, dynamic> json) {
    return Destination(
      id: json['id'].toString(),
      name: json['name'] as String,
      location: json['location'] as String,
      rating: (json['rating'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String,
      crowdLevel: json['crowdLevel'] as String,
      description: json['description'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'rating': rating,
      'imageUrl': imageUrl,
      'crowdLevel': crowdLevel,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
