import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/travel_provider.dart';
import 'api_key_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _promptController;
  late String _selectedModel;

  final List<String> _models = [
    'gemini-1.5-flash-latest',
    'gemini-1.5-pro',
    'gemini-2.0-flash'
  ];

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<TravelProvider>(context, listen: false);
    _selectedModel = provider.geminiModel;
    _promptController = TextEditingController(
      text: provider.systemPrompt.isEmpty 
          ? "You are an expert travel planner with 20 years of experience creating personalized itineraries." 
          : provider.systemPrompt
    );
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  void _saveSettings() {
    final provider = Provider.of<TravelProvider>(context, listen: false);
    provider.updateSettings(_selectedModel, _promptController.text.trim());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Settings saved successfully'),
        backgroundColor: Color(0xFF152847),
      ),
    );
  }

  String _maskApiKey(String? key) {
    if (key == null || key.length < 8) return 'Not Set';
    return '${key.substring(0, 4)}...${key.substring(key.length - 4)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: Consumer<TravelProvider>(
        builder: (context, provider, child) {
          return ListView(
            padding: const EdgeInsets.all(24.0),
            children: [
              _buildSectionHeader('AI Configuration'),
              Card(
                color: const Color(0xFF152847),
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('API Key', style: TextStyle(color: Color(0xFFB0BEC5))),
                          Text(_maskApiKey(provider.apiKey), style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ApiKeyScreen()),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFF4A825)),
                          ),
                          child: const Text('Change API Key', style: TextStyle(color: Color(0xFFF4A825))),
                        ),
                      ),
                      const Divider(color: Color(0xFF0A1628), height: 32),
                      const Text('Gemini Model', style: TextStyle(color: Color(0xFFB0BEC5))),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedModel,
                        dropdownColor: const Color(0xFF152847),
                        decoration: const InputDecoration(
                          filled: true,
                          fillColor: Color(0xFF0F1F3D),
                          border: OutlineInputBorder(borderSide: BorderSide.none),
                        ),
                        items: _models.map((model) {
                          return DropdownMenuItem(
                            value: model,
                            child: Text(model, style: const TextStyle(color: Colors.white)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedModel = value);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),

              _buildSectionHeader('Agent Personality'),
              Card(
                color: const Color(0xFF152847),
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _promptController,
                        maxLines: 4,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: const InputDecoration(
                          hintText: 'System prompt for the AI...',
                          filled: true,
                          fillColor: Color(0xFF0F1F3D),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _saveSettings,
                          child: const Text('Save Settings'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              _buildSectionHeader('Data Management'),
              Card(
                color: const Color(0xFF152847),
                margin: const EdgeInsets.only(bottom: 32),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            backgroundColor: const Color(0xFF152847),
                            title: const Text('Clear All Trips?'),
                            content: const Text('This will permanently delete all your saved trip plans. This action cannot be undone.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(false),
                                child: const Text('Cancel', style: TextStyle(color: Color(0xFFB0BEC5))),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(true),
                                child: const Text('Delete All', style: TextStyle(color: Colors.redAccent)),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true && context.mounted) {
                          await provider.clearAllTrips();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('All trips deleted')),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.delete_forever),
                      label: const Text('Clear All Trips'),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, top: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFFF4A825),
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}
