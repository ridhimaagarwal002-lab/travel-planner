import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/travel_provider.dart';
import 'home_screen.dart';

class ApiKeyScreen extends StatefulWidget {
  const ApiKeyScreen({super.key});

  @override
  State<ApiKeyScreen> createState() => _ApiKeyScreenState();
}

class _ApiKeyScreenState extends State<ApiKeyScreen> {
  final _apiKeyController = TextEditingController();
  bool _obscureText = true;

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _connectKey() async {
    final key = _apiKeyController.text.trim();
    if (key.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an API key'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    final provider = Provider.of<TravelProvider>(context, listen: false);
    
    try {
      final success = await provider.setApiKey(key);
      
      if (!mounted) return;

      if (success) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else if (provider.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to validate API Key: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<TravelProvider>().isLoading;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.auto_awesome,
                  size: 64,
                  color: Color(0xFFF4A825),
                ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack).fadeIn(),
                const SizedBox(height: 24),
                Text(
                  'Connect Your Gemini AI',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium,
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0, duration: 400.ms),
                const SizedBox(height: 16),
                Text(
                  'Enter your Gemini API key to get started.\nYour key is stored locally and never shared.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0, duration: 400.ms),
                const SizedBox(height: 48),
                TextField(
                  controller: _apiKeyController,
                  obscureText: _obscureText,
                  enabled: !isLoading,
                  decoration: InputDecoration(
                    labelText: 'Gemini API Key',
                    hintText: 'AIzaSy...',
                    prefixIcon: const Icon(Icons.vpn_key),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    ),
                  ),
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0, duration: 400.ms),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    'Get your free API key at aistudio.google.com',
                    style: theme.textTheme.bodySmall,
                  ),
                ).animate().fadeIn(delay: 500.ms),
                const SizedBox(height: 32),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _connectKey,
                    child: isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Color(0xFF0A1628),
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text('Connect'),
                  ),
                ).animate().fadeIn(delay: 600.ms).scale(duration: 400.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
