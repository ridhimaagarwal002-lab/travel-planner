import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/trip_plan.dart';
import '../utils/constants.dart';

class StorageService {
  static const String _apiKeyKey = 'api_key';
  static const String _geminiModelKey = 'gemini_model';
  static const String _systemPromptKey = 'system_prompt';
  static const String _tripPlanPrefix = 'trip_';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  // API Key
  Future<void> saveApiKey(String key) async {
    await _prefs.setString(_apiKeyKey, key);
  }

  String? getApiKey() {
    return _prefs.getString(_apiKeyKey);
  }

  // Gemini Model
  Future<void> saveGeminiModel(String model) async {
    await _prefs.setString(_geminiModelKey, model);
  }

  String getGeminiModel() {
    return _prefs.getString(_geminiModelKey) ?? AppConstants.defaultGeminiModel;
  }

  // System Prompt
  Future<void> saveSystemPrompt(String prompt) async {
    await _prefs.setString(_systemPromptKey, prompt);
  }

  String? getSystemPrompt() {
    return _prefs.getString(_systemPromptKey);
  }

  // Trip Plans
  Future<void> saveTripPlan(TripPlan plan) async {
    final key = '$_tripPlanPrefix${plan.id}';
    final jsonString = jsonEncode(plan.toJson());
    await _prefs.setString(key, jsonString);
  }

  List<TripPlan> getAllTripPlans() {
    final keys = _prefs.getKeys().where((k) => k.startsWith(_tripPlanPrefix));
    
    final List<TripPlan> tripPlans = [];
    
    for (final key in keys) {
      final jsonString = _prefs.getString(key);
      if (jsonString != null) {
        try {
          final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
          tripPlans.add(TripPlan.fromJson(jsonMap));
        } catch (e) {
          // Ignore parsing errors for individual plans
          print('Error parsing trip plan for key $key: $e');
        }
      }
    }
    
    // Sort by updatedAt descending
    tripPlans.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    
    return tripPlans;
  }

  Future<void> deleteTripPlan(String id) async {
    final key = '$_tripPlanPrefix$id';
    await _prefs.remove(key);
  }

  Future<void> clearAllTripPlans() async {
    final keys = _prefs.getKeys().where((k) => k.startsWith(_tripPlanPrefix)).toList();
    for (final key in keys) {
      await _prefs.remove(key);
    }
  }

  TripPlan? getTripPlanById(String id) {
    final key = '$_tripPlanPrefix$id';
    final jsonString = _prefs.getString(key);
    
    if (jsonString != null) {
      try {
        final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
        return TripPlan.fromJson(jsonMap);
      } catch (e) {
        print('Error parsing trip plan for id $id: $e');
        return null;
      }
    }
    return null;
  }
}
