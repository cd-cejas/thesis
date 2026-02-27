import 'package:flutter/material.dart';
import '../deepseek_service.dart';
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
  final DeepSeekService _deepSeekService = DeepSeekService();
  final List<Map<String, String>> _apiMessageHistory = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  void _initializeChat() {
    // Add system prompt to API history
    _apiMessageHistory.add({
      'role': 'system',
      'content': DeepSeekService.systemPrompt,
    });

    // Build initial greeting based on context
    String greeting;
    if (widget.profession != null) {
      greeting =
          "I see you're interested in ${widget.profession}. What courses would "
          "you like to know about in this field?";
      // Add context to API history so the AI knows the user's interest
      _apiMessageHistory.add({'role': 'assistant', 'content': greeting});
    } else if (widget.initialQuery != null) {
      greeting =
          'I\'ll help you find the best information about "${widget.initialQuery}". '
          'What would you like to know?';
      _apiMessageHistory.add({'role': 'assistant', 'content': greeting});
    } else {
      greeting =
          "Hello! I'm your AI Career Guidance Assistant. Ask me anything about "
          "careers, colleges, or courses that interest you!";
      _apiMessageHistory.add({'role': 'assistant', 'content': greeting});
    }

    _addBotMessage(greeting);
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

    // Add user message to API history
    _apiMessageHistory.add({'role': 'user', 'content': message});

    setState(() {
      _isLoading = true;
    });

    // Call DeepSeek API with full conversation history
    final response = await _deepSeekService.sendMessage(_apiMessageHistory);

    setState(() {
      _isLoading = false;
    });

    // Check for errors and show appropriate message
    if (response.startsWith('Error:')) {
      _addBotMessage(
        'Sorry, I encountered an issue. $response\n\nPlease try again.',
      );
      // Remove the failed user message from API history so it can be retried
      _apiMessageHistory.removeLast();
    } else {
      // Add successful assistant response to API history
      _apiMessageHistory.add({'role': 'assistant', 'content': response});
      _addBotMessage(response);
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
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.textPrimaryFor(isLight),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "AI Career Guidance",
          style: TextStyle(
            color: AppColors.textPrimaryFor(isLight),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: AppColors.backgroundFor(isLight),
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            radius: 1,
            colors: AppColors.gradientColors(isLight),
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
                        style: TextStyle(
                          color: AppColors.textSecondaryFor(isLight),
                          fontSize: 16,
                        ),
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
                      style: TextStyle(
                        color: AppColors.textSecondaryFor(isLight),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

            // Input Area
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: AppColors.dividerColor(isLight),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      style: TextStyle(
                        color: AppColors.textPrimaryFor(isLight),
                      ),
                      enabled: !_isLoading,
                      decoration: InputDecoration(
                        hintText: "Ask me anything...",
                        hintStyle: TextStyle(
                          color: AppColors.textSecondaryFor(isLight),
                        ),
                        filled: true,
                        fillColor: AppColors.cardOverlay(isLight),
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
                            color: AppColors.dividerColor(isLight),
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
    final isLight = Theme.of(context).brightness == Brightness.light;
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
              : AppColors.cardOverlay(isLight),
          borderRadius: BorderRadius.circular(16),
          border: message.isUser
              ? null
              : Border.all(color: AppColors.primary.withOpacity(0.3), width: 1),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: message.isUser
                ? Colors.black
                : AppColors.textPrimaryFor(isLight),
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
