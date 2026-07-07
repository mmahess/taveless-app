import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../models/itinerary.dart';
import '../services/api_service.dart';

class ItineraryController extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  // Navigation State
  int activeTab = 0;
  
  // Map Camera Focus State
  LatLng? mapFocusTarget;
  double mapFocusZoom = 9.8;

  void setActiveTab(int val) {
    activeTab = val;
    notifyListeners();
  }

  void setMapFocus(LatLng target, double zoom) {
    mapFocusTarget = target;
    mapFocusZoom = zoom;
    notifyListeners();
  }

  void clearMapFocus() {
    mapFocusTarget = null;
    notifyListeners();
  }

  // Generated Result (set by CreateItineraryScreen or loaded from saved plans)
  Itinerary? generatedItinerary;

  // Saved Plans Repository (loaded from Supabase)
  List<Itinerary> savedPlans = [];
  bool isLoadingSavedPlans = false;

  Future<void> loadSavedPlans() async {
    isLoadingSavedPlans = true;
    notifyListeners();
    try {
      savedPlans = await _apiService.fetchSavedItineraries();
    } catch (e) {
      debugPrint("Error loading saved plans: $e");
    } finally {
      isLoadingSavedPlans = false;
      notifyListeners();
    }
  }

  Future<void> savePlan(Itinerary plan) async {
    try {
      await _apiService.saveItinerary(plan);
      await loadSavedPlans(); // Reload list from Supabase
    } catch (e) {
      debugPrint("Error saving plan: $e");
      rethrow;
    }
  }

  Future<void> removePlan(Itinerary plan) async {
    try {
      await _apiService.deleteItinerary(plan.destinationName);
      await loadSavedPlans(); // Reload list from Supabase
    } catch (e) {
      debugPrint("Error removing plan: $e");
      rethrow;
    }
  }
}
