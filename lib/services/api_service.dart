import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/destination.dart';
import '../models/local_event.dart';
import '../models/itinerary.dart';

class ApiService {
  // Replace these with your actual Supabase credentials from settings
  static const String baseUrl =
      'https://qskwapbgeivipgruxafj.supabase.co/rest/v1';
  static const String anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFza3dhcGJnZWl2aXBncnV4YWZqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODMyMzU1MjcsImV4cCI6MjA5ODgxMTUyN30.w_i2XDY1Z34JKkd2ScBqYUPbcgOGDHFig08MNEMQBUI';

  // Request headers required for Supabase authentication
  Map<String, String> get headers => {
    'apikey': anonKey,
    'Authorization': 'Bearer $anonKey',
    'Content-Type': 'application/json',
    'Prefer': 'return=representation', // Echoes back created object on POST
  };

  // 1. Fetch Destinations from Supabase
  Future<List<Destination>> fetchDestinations() async {
    final response = await http.get(
      Uri.parse('$baseUrl/destinations?select=*'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Destination.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load destinations: ${response.body}');
    }
  }

  // 2. Fetch Local Events from Supabase
  Future<List<LocalEvent>> fetchLocalEvents() async {
    final response = await http.get(
      Uri.parse('$baseUrl/events?select=*'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => LocalEvent.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load events: ${response.body}');
    }
  }

  // 3. Save Itinerary to Supabase
  Future<void> saveItinerary(Itinerary itinerary) async {
    // Delete any existing duplicate entry with the same destinationName first
    try {
      await deleteItinerary(itinerary.destinationName);
    } catch (_) {
      // Silently ignore if not found
    }

    final response = await http.post(
      Uri.parse('$baseUrl/itineraries'),
      headers: headers,
      body: jsonEncode(itinerary.toJson()),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Failed to save itinerary to database: ${response.body}');
    }
  }

  // 4. Fetch Saved Itineraries from Supabase
  Future<List<Itinerary>> fetchSavedItineraries() async {
    final response = await http.get(
      Uri.parse('$baseUrl/itineraries?select=*'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Itinerary.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch saved itineraries: ${response.body}');
    }
  }

  // 4.5. Delete Itinerary from Supabase
  Future<void> deleteItinerary(String destinationName) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/itineraries?destinationName=eq.${Uri.encodeComponent(destinationName)}'),
      headers: headers,
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete itinerary: ${response.body}');
    }
  }

  // 5. Upload profile picture to Supabase Storage 'avatars' bucket
  Future<String> uploadImage(File file) async {
    final projectUrl = baseUrl.replaceAll('/rest/v1', '');
    final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final url = '$projectUrl/storage/v1/object/avatars/$fileName';

    final bytes = await file.readAsBytes();

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'apikey': anonKey,
        'Authorization': 'Bearer $anonKey',
        'Content-Type': 'image/jpeg',
      },
      body: bytes,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      // Return the public URL for the avatars bucket
      return '$projectUrl/storage/v1/object/public/avatars/$fileName';
    } else {
      throw Exception('Upload failed: ${response.statusCode} - ${response.body}');
    }
  }
}
