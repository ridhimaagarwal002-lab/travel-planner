import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final VoidCallback onStartPlanning;

  const EmptyState({super.key, required this.onStartPlanning});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.travel_explore,
              size: 120,
              color: Color(0xFFF4A825),
            ),
            const SizedBox(height: 24),
            Text(
              'No Adventures Yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Plan your first AI-powered trip!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFFB0BEC5),
                  ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: onStartPlanning,
              child: const Text('Start Planning'),
            ),
          ],
        ),
      ),
    );
  }
}
