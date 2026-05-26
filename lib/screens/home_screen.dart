import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/travel_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/trip_plan_card.dart';
import 'chat_screen.dart';
import 'settings_screen.dart';
import 'trip_form_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Text('✈️ AI Travel Planner'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFF4A825),
        foregroundColor: const Color(0xFF0A1628),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TripFormScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text(
          'Plan New Trip',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ).animate().fadeIn(delay: 600.ms, duration: 400.ms).scale(),
      body: Consumer<TravelProvider>(
        builder: (context, provider, child) {
          if (provider.allTrips.isEmpty) {
            return EmptyState(
              onStartPlanning: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TripFormScreen()),
                );
              },
            ).animate().fadeIn(duration: 500.ms);
          }

          return RefreshIndicator(
            onRefresh: () async {
              try {
                await provider.initialize();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to refresh: $e'), backgroundColor: Colors.red),
                );
              }
            },
            color: const Color(0xFFF4A825),
            backgroundColor: const Color(0xFF152847),
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 80, top: 16, left: 16, right: 16),
              itemCount: provider.allTrips.length,
              itemBuilder: (context, index) {
                final trip = provider.allTrips[index];
                return TripPlanCard(
                  trip: trip,
                  onTap: () {
                    provider.loadTrip(trip.id);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ChatScreen()),
                    );
                  },
                  confirmDismiss: (direction) async {
                    return await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: const Color(0xFF152847),
                        title: const Text('Delete Trip?'),
                        content: Text('Are you sure you want to delete your trip to ${trip.destination}?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: const Text('Cancel', style: TextStyle(color: Color(0xFFB0BEC5))),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(true),
                            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
                          ),
                        ],
                      ),
                    );
                  },
                  onDismissed: (direction) async {
                    try {
                      await provider.deleteTrip(trip.id);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Deleted trip to ${trip.destination}'),
                            backgroundColor: const Color(0xFF152847),
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to delete: $e'), backgroundColor: Colors.red),
                        );
                      }
                    }
                  },
                ).animate(delay: (index * 100).ms)
                 .fadeIn(duration: 500.ms)
                 .slideY(begin: 0.2, end: 0, duration: 500.ms, curve: Curves.easeOut);
              },
            ),
          );
        },
      ),
    );
  }
}
