import 'package:e_health_front/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// 1. Modèle pour les messages du chat
class ChatMessage {
  final String content;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.content,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({Key? key}) : super(key: key);

  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  bool _isTyping = false;

  // Couleurs thématiques pour l'app santé
  final Color _primaryColor = const Color(
    0xFF1E88E5,
  ); // Bleu pour le thème médical
  final Color _accentColor = const Color(0xFF42A5F5);
  final Color _userBubbleColor = const Color(0xFFE3F2FD);
  final Color _botBubbleColor = const Color(0xFFFFFFFF);
  final Color _backgroundColor = const Color(0xFFF5F7FA);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _primaryColor,
        elevation: 0,
        title: const Text(
          'Assistant santé',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              _showInfoDialog(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // En-tête avec image/logo
          Container(
            color: _primaryColor,
            padding: const EdgeInsets.only(bottom: 16),
            child: Center(
              child: Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 5,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.medical_services_rounded,
                  color: _primaryColor,
                  size: 32,
                ),
              ),
            ),
          ),

          // Messages du chat
          Expanded(
            child: _messages.isEmpty ? _buildEmptyState() : _buildMessageList(),
          ),

          // Indicateur de chargement
          if (_isLoading && !_isTyping)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Center(
                child: SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(_primaryColor),
                  ),
                ),
              ),
            ),

          // Champ de saisie du message
          _buildMessageInput(),
        ],
      ),
    );
  }

  // État vide - premier lancement
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.chat_outlined, size: 48, color: _primaryColor),
          ),
          const SizedBox(height: 24),
          Text(
            "Comment puis-je vous aider aujourd'hui ?",
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Posez-moi une question sur votre santé",
            style: TextStyle(fontSize: 15, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  // Liste des messages
  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 4),
      itemCount: _isTyping ? _messages.length + 1 : _messages.length,
      itemBuilder: (_, int index) {
        if (_isTyping && index == 0) {
          return _buildTypingIndicator();
        }

        final messageIndex = _isTyping ? index - 1 : index;
        final message = _messages[_messages.length - 1 - messageIndex];

        // Ajout de l'horodatage et vérification des messages groupés
        final bool isFirstInGroup = _isFirstInGroup(message, messageIndex);
        final bool isLastInGroup = _isLastInGroup(message, messageIndex);

        return Column(
          children: [
            if (isFirstInGroup && !message.isUser) _buildMessageHeader(),
            _buildMessage(message, isFirstInGroup, isLastInGroup),
            if (isLastInGroup) _buildTimestamp(message),
            const SizedBox(height: 2),
          ],
        );
      },
    );
  }

  bool _isFirstInGroup(ChatMessage message, int index) {
    if (index == _messages.length - 1) return true;

    final previousIndex = _messages.length - 1 - (index + 1);
    if (previousIndex < 0) return true;

    final previousMessage = _messages[previousIndex];
    return previousMessage.isUser != message.isUser;
  }

  bool _isLastInGroup(ChatMessage message, int index) {
    if (index == 0) return true;

    final nextIndex = _messages.length - 1 - (index - 1);
    if (nextIndex >= _messages.length) return true;

    final nextMessage = _messages[nextIndex];
    return nextMessage.isUser != message.isUser;
  }

  // En-tête de message pour le chatbot
  Widget _buildMessageHeader() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 4),
      child: Row(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: _primaryColor,
            child: const Icon(
              Icons.medical_services_rounded,
              size: 14,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            "Assistant santé",
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Widget de message
  Widget _buildMessage(
    ChatMessage message,
    bool isFirstInGroup,
    bool isLastInGroup,
  ) {
    final borderRadius = BorderRadius.only(
      topLeft: Radius.circular(
        message.isUser
            ? 20
            : isFirstInGroup
            ? 20
            : 5,
      ),
      topRight: Radius.circular(
        message.isUser
            ? isFirstInGroup
                ? 20
                : 5
            : 20,
      ),
      bottomLeft: Radius.circular(
        message.isUser
            ? 20
            : isLastInGroup
            ? 20
            : 5,
      ),
      bottomRight: Radius.circular(
        message.isUser
            ? isLastInGroup
                ? 20
                : 5
            : 20,
      ),
    );

    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: EdgeInsets.only(
          left: message.isUser ? 48 : 4,
          right: message.isUser ? 4 : 48,
          bottom: 2,
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: message.isUser ? _userBubbleColor : _botBubbleColor,
          borderRadius: borderRadius,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, 1),
              blurRadius: 3,
            ),
          ],
        ),
        child: Text(
          message.content,
          style: TextStyle(
            fontSize: 15,
            color: message.isUser ? Colors.black87 : Colors.black87,
          ),
        ),
      ),
    );
  }

  // Horodatage des messages
  Widget _buildTimestamp(ChatMessage message) {
    final timeString = DateFormat('HH:mm').format(message.timestamp);

    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(
          top: 4,
          left: message.isUser ? 0 : 16,
          right: message.isUser ? 16 : 0,
        ),
        child: Text(
          timeString,
          style: TextStyle(fontSize: 11, color: Colors.grey[500]),
        ),
      ),
    );
  }

  // Indicateur de frappe amélioré
  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(right: 64, bottom: 6),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: _botBubbleColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, 1),
              blurRadius: 3,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            _DotPulse(),
            SizedBox(width: 4),
            _DotPulse(delay: 300),
            SizedBox(width: 4),
            _DotPulse(delay: 600),
          ],
        ),
      ),
    );
  }

  // Champ de saisie du message redessiné
  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _textController,
                decoration: InputDecoration(
                  hintText: 'Écrivez votre message...',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 14.0,
                  ),
                ),
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: _isLoading ? null : _handleSubmitted,
              ),
            ),
          ),
          const SizedBox(width: 8.0),
          Material(
            color: _isLoading ? Colors.grey[300] : _primaryColor,
            borderRadius: BorderRadius.circular(24),
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap:
                  _isLoading
                      ? null
                      : () => _handleSubmitted(_textController.text),
              child: Container(
                padding: const EdgeInsets.all(12),
                child: Icon(Icons.send_rounded, color: Colors.white, size: 22),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Méthode pour afficher la boîte de dialogue d'informations
  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.info_outline, color: _primaryColor),
              const SizedBox(width: 10),
              const Text('À propos'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Assistant Santé',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 10),
              const Text(
                'Cet assistant vous aide à répondre à vos questions de santé. '
                'Veuillez noter que cette application ne remplace pas une consultation médicale professionnelle.',
              ),
              const SizedBox(height: 15),
              Text(
                'En cas d\'urgence, contactez immédiatement un professionnel de santé.',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red[700],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Fermer'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }

  void _handleSubmitted(String text) async {
    if (text.trim().isEmpty) return;

    _textController.clear();

    final userMessage = ChatMessage(content: text, isUser: true);

    setState(() {
      _messages.add(userMessage);
      _isLoading = true;
      _isTyping = true;
    });

    try {
      final response = await _apiService.sendMessageChatbot(text);

      final botMessage = ChatMessage(content: response, isUser: false);

      setState(() {
        _isTyping = false;
        _messages.add(botMessage);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isTyping = false;
        _messages.add(
          ChatMessage(
            content: 'Désolé, une erreur est survenue. Veuillez réessayer.',
            isUser: false,
          ),
        );
        _isLoading = false;
      });
    }
  }
}

// Widget animé pour créer l'effet de points qui pulsent
class _DotPulse extends StatefulWidget {
  final int delay;

  const _DotPulse({this.delay = 0});

  @override
  _DotPulseState createState() => _DotPulseState();
}

class _DotPulseState extends State<_DotPulse>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Décalage pour créer un effet en cascade
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 8 + (_animation.value * 2),
          height: 8 + (_animation.value * 2),
          decoration: BoxDecoration(
            color: Colors.grey[700],
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}
