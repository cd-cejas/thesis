import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AiChatbotScreen extends StatefulWidget {
  final String? profession;
  final String? initialQuery;

  const AiChatbotScreen({super.key, this.profession, this.initialQuery});

  @override
  State<AiChatbotScreen> createState() => _AiChatbotScreenState();
}

class _AiChatbotScreenState extends State<AiChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Add initial greeting or profession context
    if (widget.profession != null) {
      _addBotMessage(
        "I see you're interested in ${{widget.profession}}. What courses would "
        "you like to know about in this field?",
      );
    } else if (widget.initialQuery != null) {
      _addBotMessage(
        "I'll help you find the best information about \"${widget.initialQuery}\". "
        "What would you like to know?",
      );
    } else {
      _addBotMessage(
        "Hello! I'm your AI Career Guidance Assistant. Ask me anything about "
        "careers, colleges, or courses that interest you!",
      );
    }
  }

  void _addBotMessage(String message) {
    setState(() {
      _messages.add(
        ChatMessage(text: message, isUser: false, timestamp: DateTime.now()),
      );
    });
    _scrollToBottom();
  }

  void _addUserMessage(String message) {
    setState(() {
      _messages.add(
        ChatMessage(text: message, isUser: true, timestamp: DateTime.now()),
      );
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    _messageController.clear();
    _addUserMessage(message);

    // Simulate AI response delay
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    // Simulate AI response (in real app, call API)
    final response = _generateAIResponse(message);

    setState(() {
      _isLoading = false;
    });

    _addBotMessage(response);
  }

  String _generateAIResponse(String userMessage) {
    // This is a placeholder. In production, call your AI API here
    final lowerMessage = userMessage.toLowerCase();

    if (lowerMessage.contains('course') || lowerMessage.contains('major')) {
      return 'Based on your interests, I recommend exploring: Computer Science, '
          'Data Science, or Software Engineering. These fields offer excellent '
          'career prospects. Would you like more details about any of these?';
    } else if (lowerMessage.contains('salary') ||
        lowerMessage.contains('pay')) {
      return 'Salary varies by field and experience. Tech fields typically offer '
          'higher starting salaries (₱30-50k+), while others vary. Career path and '
          'specialization also impact earning potential. Would you like specific '
          'information about a particular field?';
    } else if (lowerMessage.contains('impossible') ||
        lowerMessage.contains('easy')) {
      return 'That depends on your background and dedication. Most careers are '
          'achievable with proper education and skill development. What specific '
          'field interests you?';
    } else if (lowerMessage.contains('college') ||
        lowerMessage.contains('university')) {
      return 'There are many excellent colleges in the Philippines. Some top options '
          'include UP, Ateneo, De La Salle, and UST. The best choice depends on your '
          'field and preferences. Would you like recommendations for a specific area?';
    } else {
      return 'Thank you for your question! Could you provide more details about what '
          'you\'re looking for? For example, are you interested in a specific career '
          'field, course recommendation, or college information?';
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "AI Career Guidance",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      backgroundColor: AppColors.background,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            radius: 1,
            colors: [const Color(0xFF00365D), Colors.black],
          ),
        ),
        child: Column(
          children: [
            // Chat Messages
            Expanded(
              child: _messages.isEmpty
                  ? Center(
                      child: Text(
                        'Start a conversation!',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 20,
                      ),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        return _buildChatBubble(_messages[index]);
                      },
                    ),
            ),

            // Loading Indicator
            if (_isLoading)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'AI is thinking...',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ],
                ),
              ),

            // Input Area
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.white12, width: 1),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      style: const TextStyle(color: Colors.white),
                      enabled: !_isLoading,
                      decoration: InputDecoration(
                        hintText: "Ask me anything...",
                        hintStyle: const TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.05),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(
                            color: Colors.white12,
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FloatingActionButton(
                    mini: true,
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.black,
                    onPressed: _isLoading ? null : _sendMessage,
                    child: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: message.isUser
              ? AppColors.primary
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: message.isUser
              ? null
              : Border.all(color: AppColors.primary.withOpacity(0.3), width: 1),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: message.isUser ? Colors.black : Colors.white,
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}
