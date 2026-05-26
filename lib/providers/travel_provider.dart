import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/trip_plan.dart';
import '../models/message.dart';
import '../services/storage_service.dart';
import '../services/gemini_service.dart';

class TravelProvider extends ChangeNotifier {
  final StorageService _storageService;
  
  TravelProvider(this._storageService) {
    initialize();
  }

  // State variables
  String? apiKey;
  String geminiModel = 'gemini-1.5-flash';
  String systemPrompt = '';
  List<TripPlan> allTrips = [];
  TripPlan? currentTrip;
  
  bool isLoading = false;
  bool isTyping = false;
  String? errorMessage;

  // Initialize
  Future<void> initialize() async {
    apiKey = _storageService.getApiKey();
    
    String storedModel = _storageService.getGeminiModel();
    if (storedModel == 'gemini-2.0-flash') {
      storedModel = 'gemini-1.5-flash';
      await _storageService.saveGeminiModel(storedModel);
    }
    geminiModel = storedModel;
    
    systemPrompt = _storageService.getSystemPrompt() ?? '';
    allTrips = _storageService.getAllTripPlans();
    notifyListeners();
  }

  // Helper to create/get GeminiService
  GeminiService? get _geminiService {
    if (apiKey == null || apiKey!.isEmpty) return null;
    return GeminiService(apiKey: apiKey!, model: geminiModel);
  }

  // Set API Key
  Future<bool> setApiKey(String key) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final tempService = GeminiService(apiKey: key, model: geminiModel);
      final isValid = await tempService.validateApiKey(key);
      
      if (isValid) {
        await _storageService.saveApiKey(key);
        apiKey = key;
        isLoading = false;
        notifyListeners();
        return true;
      } else {
        errorMessage = 'Invalid API Key';
        isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Start New Trip
  Future<void> startNewTrip(TripPlan plan) async {
    if (_geminiService == null) {
      errorMessage = 'API Key not set';
      notifyListeners();
      return;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final generatedItinerary = await _geminiService!.generateItinerary(plan);
      
      final newTrip = plan.copyWith(
        id: const Uuid().v4(),
        generatedItinerary: generatedItinerary,
        messages: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _storageService.saveTripPlan(newTrip);
      allTrips.insert(0, newTrip);
      currentTrip = newTrip;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Send Message
  Future<void> sendMessage(String messageContent) async {
    if (_geminiService == null || currentTrip == null) {
      errorMessage = 'API Key not set or no active trip';
      notifyListeners();
      return;
    }

    // Capture history before adding the new user message for context
    final chatHistory = List<Message>.from(currentTrip!.messages);

    final userMessage = Message(
      id: const Uuid().v4(),
      role: 'user',
      content: messageContent,
      timestamp: DateTime.now(),
    );

    // Add user message and update UI immediately
    currentTrip = currentTrip!.copyWith(
      messages: List.from(currentTrip!.messages)..add(userMessage),
      updatedAt: DateTime.now(),
    );
    
    isTyping = true;
    errorMessage = null;
    notifyListeners();

    try {
      final replyContent = await _geminiService!.sendChatMessage(
        chatHistory,
        messageContent,
        currentTrip!.generatedItinerary,
      );

      final modelMessage = Message(
        id: const Uuid().v4(),
        role: 'model',
        content: replyContent,
        timestamp: DateTime.now(),
      );

      currentTrip = currentTrip!.copyWith(
        messages: List.from(currentTrip!.messages)..add(modelMessage),
        updatedAt: DateTime.now(),
      );

      await _storageService.saveTripPlan(currentTrip!);
      
      // Update the trip in allTrips list and re-sort
      final index = allTrips.indexWhere((t) => t.id == currentTrip!.id);
      if (index != -1) {
        allTrips[index] = currentTrip!;
        allTrips.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isTyping = false;
      notifyListeners();
    }
  }

  // Load Trip
  void loadTrip(String id) {
    final index = allTrips.indexWhere((t) => t.id == id);
    if (index != -1) {
      currentTrip = allTrips[index];
      notifyListeners();
    }
  }

  // Delete Trip
  Future<void> deleteTrip(String id) async {
    await _storageService.deleteTripPlan(id);
    allTrips.removeWhere((t) => t.id == id);
    if (currentTrip?.id == id) {
      currentTrip = null;
    }
    notifyListeners();
  }

  // Clear All Trips
  Future<void> clearAllTrips() async {
    await _storageService.clearAllTripPlans();
    allTrips.clear();
    currentTrip = null;
    notifyListeners();
  }

  // Clear Error
  void clearError() {
    errorMessage = null;
    notifyListeners();
  }

  // Update Settings
  Future<void> updateSettings(String model, String prompt) async {
    geminiModel = model;
    systemPrompt = prompt;
    await _storageService.saveGeminiModel(model);
    await _storageService.saveSystemPrompt(prompt);
    notifyListeners();
  }
}
