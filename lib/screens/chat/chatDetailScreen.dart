import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/chat_service.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ChatDetailScreen extends StatefulWidget {
  final String chatId;
  final dynamic doctor;

  const ChatDetailScreen({Key? key, required this.chatId, required this.doctor})
      : super(key: key);

  @override
  _ChatDetailScreenState createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  late List<dynamic> _messages = [];
  bool _isLoading = true;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();
  String _currentUserId = "67c0500e8120019fe5ed3532"; // Dynamically set this from auth service
  final ChatService _chatService = ChatService();

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _setupSocketConnection();
    
    // Scroll to bottom when messages load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    // Clean up socket connections when leaving the screen
    _chatService.leaveChat(widget.chatId);
    _chatService.stopListening();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _setupSocketConnection() async {
    try {
      await _chatService.initializeSocket();
      _chatService.joinChat(widget.chatId);
      _chatService.listenForMessages(widget.chatId, _handleNewMessage);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to connect to chat: $e')),
      );
    }
  }

  void _handleNewMessage(dynamic message) {
    setState(() {
      _messages.add(message);
    });
    
    // Scroll to bottom when new message arrives
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  Future<void> _loadMessages() async {
  setState(() {
    _isLoading = true;
  });
  
  try {
    final messages = await _chatService.getMessages(widget.chatId);
    setState(() {
      _messages = messages;
      _isLoading = false;
    });
    
    // Délai court pour s'assurer que le ListView est complètement rendu
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollToBottom();
    });
  } catch (e) {
    setState(() {
      _isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to load messages: $e')),
    );
  }
}

  void _scrollToBottom() {
  if (_scrollController.hasClients) {
    try {
      // Utilisez jumpTo pour un défilement instantané au lieu d'une animation
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      
      // Pour être sûr, ajoutez un petit délai et essayez à nouveau
      Future.delayed(const Duration(milliseconds: 50), () {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    } catch (e) {
      print("Erreur de défilement: $e");
    }
  }
}

  String _formatTimestamp(String timestamp) {
    final DateTime dateTime = DateTime.parse(timestamp);
    final DateTime now = DateTime.now();
    final bool isToday =
        dateTime.day == now.day &&
        dateTime.month == now.month &&
        dateTime.year == now.year;

    if (isToday) {
      return DateFormat('HH:mm').format(dateTime);
    } else {
      return DateFormat('MMM d, HH:mm').format(dateTime);
    }
  }

  // Method to handle sending text messages
  void _sendMessage() async {
    if (_messageController.text.trim().isNotEmpty) {
      final String message = _messageController.text;
      _messageController.clear();
      
      // Get the token
      final token = await _chatService.getToken();
      
      if (token == null) {
        // Handle case where user is not authenticated
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You need to be logged in to send messages')),
        );
        return;
      }
      
      try {
        // Send the message to the API
        await _chatService.sendTextMessage(
          token: token,
          chatId: widget.chatId,
          content: message,
        );
        
        // No need to refresh message list - socket will handle it
        // Socket will emit the new message to all connected clients
        
      } catch (e) {
        // Handle exceptions
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending message: $e')),
        );
      }
    }
  }

  // New method to handle image picking from gallery
  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? pickedImage = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70, // Reduce quality to save bandwidth
      );
      
      if (pickedImage != null) {
        await _sendImageMessage(File(pickedImage.path));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  // New method to handle taking a photo with the camera
  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? takenImage = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70, // Reduce quality to save bandwidth
      );
      
      if (takenImage != null) {
        await _sendImageMessage(File(takenImage.path));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error taking photo: $e')),
      );
    }
  }

  // New method to send the image message using ChatService
  Future<void> _sendImageMessage(File imageFile) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
    
    try {
      // Get the token
      final token = await _chatService.getToken();
      
      if (token == null) {
        // Close loading dialog
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You need to be logged in to send messages')),
        );
        return;
      }
      
      // Send the image using ChatService
      await _chatService.sendImageMessage(
        token: token,
        chatId: widget.chatId,
        imageFile: imageFile,
      );
      
      // Close loading dialog
      Navigator.pop(context);
      
      // No need to refresh message list - socket will handle it
      
    } catch (e) {
      // Close loading dialog
      Navigator.pop(context);
      // Handle exceptions
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending image: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(
                widget.doctor['image'] ?? 'https://via.placeholder.com/50',
              ),
              radius: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Dr. ${widget.doctor['firstName']} ${widget.doctor['lastName']}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(color: Colors.grey[100]),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _messages.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                size: 64,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 10),
                              Text(
                                'No messages yet',
                                style: TextStyle(color: Colors.grey, fontSize: 16),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Send a message to start the conversation',
                                style: TextStyle(color: Colors.grey, fontSize: 14),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(10),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final message = _messages[index];
                            final isCurrentUser = message['sender'] == _currentUserId;
                            final isImage = message['type'] == 'image';
                            final prevMessage = index > 0 ? _messages[index - 1] : null;
                            final showTimestamp =
                                prevMessage == null ||
                                prevMessage['sender'] != message['sender'] ||
                                DateTime.parse(message['timestamp'])
                                    .difference(
                                      DateTime.parse(prevMessage['timestamp']),
                                    )
                                    .inMinutes >
                                    5;

                            return Column(
                              crossAxisAlignment:
                                  isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                              children: [
                                if (showTimestamp || index == 0)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      top: 16,
                                      bottom: 8,
                                    ),
                                    child: Center(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          _formatTimestamp(message['timestamp']),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                Container(
                                  margin: const EdgeInsets.symmetric(vertical: 4),
                                  constraints: BoxConstraints(
                                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isCurrentUser ? Colors.blue[500] : Colors.white,
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 3,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onLongPress: () {
                                          // Show options menu (copy, delete, etc.)
                                        },
                                        child: Padding(
                                          padding: isImage
                                              ? EdgeInsets.zero
                                              : const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 10,
                                                ),
                                          child: isImage
                                              ? Column(
                                                  crossAxisAlignment: CrossAxisAlignment.end,
                                                  children: [
                                                    Image.network(
                                                      message['content'],
                                                      fit: BoxFit.cover,
                                                      width: MediaQuery.of(context).size.width * 0.6,
                                                      loadingBuilder: (
                                                        context,
                                                        child,
                                                        loadingProgress,
                                                      ) {
                                                        if (loadingProgress == null) return child;
                                                        return Container(
                                                          width: MediaQuery.of(context).size.width * 0.6,
                                                          height: 200,
                                                          alignment: Alignment.center,
                                                          child: CircularProgressIndicator(
                                                            value: loadingProgress.expectedTotalBytes != null
                                                                ? loadingProgress.cumulativeBytesLoaded /
                                                                    loadingProgress.expectedTotalBytes!
                                                                : null,
                                                          ),
                                                        );
                                                      },
                                                      errorBuilder: (
                                                        context,
                                                        error,
                                                        stackTrace,
                                                      ) {
                                                        return Container(
                                                          width: MediaQuery.of(context).size.width * 0.6,
                                                          height: 100,
                                                          alignment: Alignment.center,
                                                          color: Colors.grey[300],
                                                          child: const Column(
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            children: [
                                                              Icon(
                                                                Icons.error,
                                                                color: Colors.red,
                                                              ),
                                                              SizedBox(height: 4),
                                                              Text(
                                                                "Failed to load image",
                                                                style: TextStyle(
                                                                  fontSize: 12,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.only(
                                                        right: 8,
                                                        bottom: 4,
                                                      ),
                                                      child: Text(
                                                        _formatTimestamp(message['timestamp']),
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                          color: isCurrentUser
                                                              ? Colors.white70
                                                              : Colors.grey[600],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              : Column(
                                                  crossAxisAlignment: CrossAxisAlignment.end,
                                                  children: [
                                                    Text(
                                                      message['content'],
                                                      style: TextStyle(
                                                        color: isCurrentUser ? Colors.white : Colors.black,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      _formatTimestamp(message['timestamp']),
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        color: isCurrentUser
                                                            ? Colors.white70
                                                            : Colors.grey[600],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 3,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  color: Colors.blue[700],
                  onPressed: () {
                    // Show attachment options
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => Container(
                        height: 180,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const Text(
                              "Share Content",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildAttachmentOption(
                                  icon: Icons.photo,
                                  label: "Gallery",
                                  color: Colors.purple,
                                  onTap: () {
                                    Navigator.pop(context);
                                    _pickImageFromGallery();
                                  },
                                ),
                                _buildAttachmentOption(
                                  icon: Icons.camera_alt,
                                  label: "Camera",
                                  color: Colors.red,
                                  onTap: () {
                                    Navigator.pop(context);
                                    _pickImageFromCamera();
                                  },
                                ),
                                _buildAttachmentOption(
                                  icon: Icons.description,
                                  label: "Document",
                                  color: Colors.blue,
                                  onTap: () {
                                    Navigator.pop(context);
                                    // Implement document picker
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Document sharing coming soon'),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            decoration: const InputDecoration(
                              hintText: 'Type a message...',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 5,
                              ),
                            ),
                            maxLines: null,
                            textCapitalization: TextCapitalization.sentences,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue[700],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 25),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}