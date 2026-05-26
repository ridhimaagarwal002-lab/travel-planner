import 'message.dart';

class TripPlan {
  final String id;
  final String title;
  final String destination;
  final int duration;
  final String budget;
  final String travelStyle;
  final String travelers;
  final String specialRequests;
  final String generatedItinerary;
  final List<Message> messages;
  final DateTime createdAt;
  final DateTime updatedAt;

  TripPlan({
    required this.id,
    required this.title,
    required this.destination,
    required this.duration,
    required this.budget,
    required this.travelStyle,
    required this.travelers,
    required this.specialRequests,
    required this.generatedItinerary,
    required this.messages,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TripPlan.fromJson(Map<String, dynamic> json) {
    return TripPlan(
      id: json['id'] as String,
      title: json['title'] as String,
      destination: json['destination'] as String,
      duration: json['duration'] as int,
      budget: json['budget'] as String,
      travelStyle: json['travelStyle'] as String,
      travelers: json['travelers'] as String,
      specialRequests: json['specialRequests'] as String,
      generatedItinerary: json['generatedItinerary'] as String,
      messages: (json['messages'] as List<dynamic>?)
              ?.map((e) => Message.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'destination': destination,
      'duration': duration,
      'budget': budget,
      'travelStyle': travelStyle,
      'travelers': travelers,
      'specialRequests': specialRequests,
      'generatedItinerary': generatedItinerary,
      'messages': messages.map((m) => m.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  TripPlan copyWith({
    String? id,
    String? title,
    String? destination,
    int? duration,
    String? budget,
    String? travelStyle,
    String? travelers,
    String? specialRequests,
    String? generatedItinerary,
    List<Message>? messages,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TripPlan(
      id: id ?? this.id,
      title: title ?? this.title,
      destination: destination ?? this.destination,
      duration: duration ?? this.duration,
      budget: budget ?? this.budget,
      travelStyle: travelStyle ?? this.travelStyle,
      travelers: travelers ?? this.travelers,
      specialRequests: specialRequests ?? this.specialRequests,
      generatedItinerary: generatedItinerary ?? this.generatedItinerary,
      messages: messages ?? this.messages,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
