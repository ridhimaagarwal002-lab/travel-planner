import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/trip_plan.dart';
import '../models/message.dart';

class GeminiService {
  final String apiKey;
  final String model;

  GeminiService({
    required this.apiKey,
    required this.model,
  });

  GenerativeModel _getModel(String systemInstruction) {
    return GenerativeModel(
      model: model,
      apiKey: apiKey,
      systemInstruction: Content.system(systemInstruction),
    );
  }

  Future<T> _executeWithRetry<T>(Future<T> Function() action, {int maxRetries = 3}) async {
    int attempt = 0;
    while (true) {
      attempt++;
      try {
        return await action();
      } catch (e) {
        final errorMsg = _handleError(e);
        if (errorMsg == 'Rate limit reached, try again later' && attempt < maxRetries) {
          await Future.delayed(Duration(seconds: 2 * attempt));
          continue;
        }
        rethrow;
      }
    }
  }

  Future<String> generateItinerary(TripPlan plan) async {
    const systemInstruction = "You are an expert travel planner with 20 years of experience creating personalized itineraries.";
    
    final prompt = '''
Please create a detailed day-by-day itinerary for the following trip:

Destination: ${plan.destination}
Duration: ${plan.duration} days
Budget: ${plan.budget}
Travel Style: ${plan.travelStyle}
Travelers: ${plan.travelers}
Special Requests: ${plan.specialRequests}

The itinerary must be formatted in Markdown and include:
- Day-by-day breakdown with Morning / Afternoon / Evening sections
- Hotel suggestions
- Food and restaurant recommendations
- Attractions and activities
- Transport tips
- Estimated budget breakdown
- Travel warnings or important local tips
''';

    try {
      final generativeModel = _getModel(systemInstruction);
      final response = await _executeWithRetry(() => generativeModel.generateContent([Content.text(prompt)]));
      return response.text ?? 'Failed to generate itinerary. Please try again.';
    } catch (e) {
      final errorMsg = _handleError(e);
      throw errorMsg;
    }
  }

  Future<String> sendChatMessage(List<Message> history, String userMessage, String itinerary) async {
    final systemInstruction = '''You are an expert travel planner assisting a user with their trip.
Here is the generated itinerary for context:

$itinerary

Answer the user's questions or modify the itinerary as requested.''';

    try {
      final generativeModel = _getModel(systemInstruction);
      
      final chatHistory = history.map((msg) {
        return Content(
          msg.role == 'user' ? 'user' : 'model', 
          [TextPart(msg.content)]
        );
      }).toList();
      
      final chat = generativeModel.startChat(history: chatHistory);
      final response = await _executeWithRetry(() => chat.sendMessage(Content.text(userMessage)));
      
      return response.text ?? 'I encountered an error responding to your message.';
    } catch (e) {
      final errorMsg = _handleError(e);
      throw errorMsg;
    }
  }

  Future<bool> validateApiKey(String key) async {
    try {
      final generativeModel = GenerativeModel(
        model: model,
        apiKey: key,
      );
      // Send a very short simple prompt to minimize latency and token usage
      final response = await generativeModel.generateContent([Content.text("Hi")]);
      return response.text != null;
    } catch (e) {
      final errorMsg = _handleError(e);
      if (errorMsg == 'Rate limit reached, try again later') {
        // If we hit a rate limit, the API key is valid (otherwise it would be 'Invalid API Key')
        return true;
      }
      throw errorMsg;
    }
  }

  String _handleError(dynamic error) {
    if (error is SocketException) {
      return 'No internet connection';
    }
    
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('api key') && (errorString.contains('invalid') || errorString.contains('not valid'))) {
      return 'Invalid API Key';
    }
    
    if (errorString.contains('rate limit') || errorString.contains('429') || errorString.contains('quota')) {
      return 'Rate limit reached, try again later';
    }
    
    if (errorString.contains('socket') || errorString.contains('connection') || errorString.contains('failed host lookup')) {
      return 'No internet connection';
    }

    return error.toString();
  }
}
