import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/travel_provider.dart';
import '../models/trip_plan.dart';
import '../services/pdf_service.dart';
import '../widgets/message_bubble.dart';
import '../widgets/typing_indicator.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isInputEmpty = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _messageController.addListener(() {
      setState(() {
        _isInputEmpty = _messageController.text.trim().isEmpty;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void _sendMessage(TravelProvider provider) async {
    if (_isInputEmpty || provider.isTyping) return;
    
    final text = _messageController.text.trim();
    if (text.isEmpty) return; // double check for whitespace only
    
    _messageController.clear();
    
    if (_tabController.index != 1) {
      _tabController.animateTo(1);
    }
    
    _scrollToBottom();
    
    try {
      await provider.sendMessage(text);
      if (provider.errorMessage != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
        provider.clearError();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send message: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TravelProvider>(
      builder: (context, provider, child) {
        final trip = provider.currentTrip;
        
        if (trip == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Trip Not Found')),
            body: const Center(child: Text('No trip loaded.')),
          );
        }

        if (_tabController.index == 1) {
          _scrollToBottom();
        }

        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trip.destination,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'AI Travel Agent',
                  style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.7)),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.picture_as_pdf),
                onPressed: () async {
                  try {
                    final pdfService = PdfService();
                    await pdfService.exportItineraryToPdf(trip);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('PDF Error: $e'), backgroundColor: Colors.red),
                    );
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: const Color(0xFF152847),
                      title: const Text('Delete Trip?'),
                      content: const Text('Are you sure you want to delete this trip?'),
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
                  if (confirm == true && context.mounted) {
                    try {
                      await provider.deleteTrip(trip.id);
                      if (context.mounted) Navigator.pop(context);
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Delete Error: $e'), backgroundColor: Colors.red),
                        );
                      }
                    }
                  }
                },
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: const Color(0xFFF4A825),
              labelColor: const Color(0xFFF4A825),
              unselectedLabelColor: const Color(0xFFB0BEC5),
              tabs: const [
                Tab(icon: Icon(Icons.assignment), text: 'Itinerary 📋'),
                Tab(icon: Icon(Icons.chat), text: 'Chat 💬'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildItineraryTab(trip.generatedItinerary),
              _buildChatTab(trip, provider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildItineraryTab(String markdownData) {
    return Container(
      color: const Color(0xFF0A1628),
      child: Stack(
        children: [
          Markdown(
            data: markdownData,
            styleSheet: MarkdownStyleSheet(
              h1: const TextStyle(color: Color(0xFFF4A825), fontWeight: FontWeight.bold, fontSize: 24),
              h2: const TextStyle(color: Color(0xFFF4A825), fontWeight: FontWeight.bold, fontSize: 20),
              h3: const TextStyle(color: Color(0xFFF4A825), fontWeight: FontWeight.bold, fontSize: 18),
              p: const TextStyle(color: Colors.white, fontSize: 16),
              listBullet: const TextStyle(color: Color(0xFFF4A825)),
              code: const TextStyle(backgroundColor: Color(0xFF152847), color: Colors.white, fontFamily: 'monospace'),
              codeblockDecoration: BoxDecoration(
                color: const Color(0xFF152847),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton.extended(
              backgroundColor: const Color(0xFFF4A825),
              foregroundColor: const Color(0xFF0A1628),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: markdownData));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Itinerary copied to clipboard'),
                    backgroundColor: Color(0xFF152847),
                  ),
                );
              },
              icon: const Icon(Icons.copy),
              label: const Text('Copy Itinerary', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatTab(TripPlan trip, TravelProvider provider) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: trip.messages.length + (provider.isTyping ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == trip.messages.length) {
                return const TypingIndicator();
              }
              final message = trip.messages[index];
              return MessageBubble(
                message: message,
                isUser: message.role == 'user',
              )
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.2, end: 0, duration: 400.ms, curve: Curves.easeOut);
            },
          ),
        ),
        _buildInputBar(provider),
      ],
    );
  }

  Widget _buildInputBar(TravelProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: const Color(0xFF0F1F3D),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Ask about your trip...',
                  hintStyle: TextStyle(color: Color(0xFFB0BEC5)),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  fillColor: Colors.transparent,
                  filled: false,
                ),
                onSubmitted: (_) => _sendMessage(provider),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (_isInputEmpty || provider.isTyping)
                    ? const Color(0xFF152847)
                    : const Color(0xFFF4A825),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.send,
                  color: (_isInputEmpty || provider.isTyping)
                      ? const Color(0xFFB0BEC5)
                      : const Color(0xFF0A1628),
                ),
                onPressed: (_isInputEmpty || provider.isTyping) ? null : () => _sendMessage(provider),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
