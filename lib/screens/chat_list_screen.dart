import 'package:flutter/material.dart';
import 'package:e_health_front/screens/chatDetailScreen.dart';
import '../services/chat_service.dart';
import 'package:intl/intl.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  late Future<List<dynamic>> _chatsFuture;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _refreshChats();
  }

  void _refreshChats() {
    setState(() {
      _chatsFuture = ChatService().getChats();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title:
            _isSearching
                ? TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: "Search conversations...",
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.grey[400]),
                  ),
                  onChanged: (value) {
                    // Implement search functionality
                    _refreshChats();
                  },
                )
                : const Text(
                  "Messages",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Colors.black,
                  ),
                ),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _refreshChats();
                }
              });
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              // Handle menu options
              if (value == 'refresh') {
                _refreshChats();
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'refresh',
                  child: Row(
                    children: [
                      Icon(Icons.refresh, size: 20),
                      SizedBox(width: 10),
                      Text('Refresh'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'archive',
                  child: Row(
                    children: [
                      Icon(Icons.archive, size: 20),
                      SizedBox(width: 10),
                      Text('Archived chats'),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _refreshChats();
        },
        child: _buildChatList(),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 4,
        onPressed: () {
          // Navigate to new conversation screen
        },
        child: const Icon(Icons.add_comment, color: Colors.white),
      ),
    );
  }

  Widget _buildChatList() {
    return FutureBuilder<List<dynamic>>(
      future: _chatsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return _buildErrorState();
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState();
        } else {
          final chats = snapshot.data!;

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: chats.length,
            separatorBuilder:
                (context, index) => Divider(
                  height: 1,
                  indent: 80,
                  endIndent: 16,
                  color: Colors.grey[200],
                ),
            itemBuilder: (context, index) {
              final chat = chats[index];
              return _buildChatTile(chat, context);
            },
          );
        }
      },
    );
  }

  Widget _buildChatTile(dynamic chat, BuildContext context) {
    final doctor = chat['doctor'];
    final lastMessage = chat['lastMessage'];
    final bool hasUnread =
        chat['unreadCount'] != null && chat['unreadCount'] > 0;
    final DateTime? messageTime =
        lastMessage != null ? DateTime.parse(lastMessage['timestamp']) : null;

    // Get local current user ID from your auth service
    const String currentUserId = "yourCurrentUserId"; // Replace with actual ID

    return Dismissible(
      key: Key(chat['_id']),
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        color: Colors.blue,
        child: const Icon(Icons.archive, color: Colors.white),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Archive chat logic
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Chat archived'),
              action: SnackBarAction(
                label: 'UNDO',
                onPressed: () {
                  // Unarchive logic
                  _refreshChats();
                },
              ),
            ),
          );
          return true;
        } else {
          // Delete chat confirmation
          return await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Delete Conversation?"),
                content: const Text(
                  "This will delete the entire conversation history. This action cannot be undone.",
                ),
                actions: [
                  TextButton(
                    child: const Text("CANCEL"),
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                  TextButton(
                    child: const Text(
                      "DELETE",
                      style: TextStyle(color: Colors.red),
                    ),
                    onPressed: () => Navigator.of(context).pop(true),
                  ),
                ],
              );
            },
          );
        }
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          // Delete chat logic
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Chat deleted')));
        }
        _refreshChats();
      },
      child: Material(
        color: hasUnread ? Colors.blue.withOpacity(0.05) : Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) =>
                        ChatDetailScreen(chatId: chat['_id'], doctor: doctor),
              ),
            ).then(
              (_) => _refreshChats(),
            ); // Refresh when returning from chat detail
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color:
                              hasUnread
                                  ? Theme.of(context).primaryColor
                                  : Colors.transparent,
                          width: hasUnread ? 2 : 0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.grey[300],
                        backgroundImage:
                            doctor['image'] != null
                                ? NetworkImage(doctor['image'])
                                : const AssetImage('images/profil.jpeg')
                                    as ImageProvider,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Dr. ${doctor['firstName']} ${doctor['lastName']}',
                              style: TextStyle(
                                fontWeight:
                                    hasUnread
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                fontSize: 16,
                                overflow: TextOverflow.ellipsis,
                              ),
                              maxLines: 1,
                            ),
                          ),
                          if (messageTime != null)
                            Container(
                              padding: const EdgeInsets.only(left: 8),
                              child: Text(
                                _formatChatTime(messageTime),
                                style: TextStyle(
                                  color:
                                      hasUnread
                                          ? Theme.of(context).primaryColor
                                          : Colors.grey[600],
                                  fontSize: 12,
                                  fontWeight:
                                      hasUnread
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child:
                                lastMessage != null
                                    ? Row(
                                      children: [
                                        if (lastMessage['type'] == 'image')
                                          Container(
                                            margin: const EdgeInsets.only(
                                              right: 4,
                                            ),
                                            child: const Icon(
                                              Icons.photo,
                                              size: 16,
                                              color: Colors.blue,
                                            ),
                                          )
                                        else if (lastMessage['type'] != 'text')
                                          Container(
                                            margin: const EdgeInsets.only(
                                              right: 4,
                                            ),
                                            child: const Icon(
                                              Icons.attach_file,
                                              size: 16,
                                              color: Colors.orange,
                                            ),
                                          ),
                                        Expanded(
                                          child: RichText(
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            text: TextSpan(
                                              style: TextStyle(
                                                color:
                                                    hasUnread
                                                        ? Colors.black87
                                                        : Colors.grey[600],
                                                fontWeight:
                                                    hasUnread
                                                        ? FontWeight.w500
                                                        : FontWeight.normal,
                                                fontSize: 14,
                                                height: 1.3,
                                              ),
                                              children: [
                                                if (lastMessage['sender'] ==
                                                    currentUserId)
                                                  const TextSpan(
                                                    text: 'You: ',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                TextSpan(
                                                  text:
                                                      lastMessage['type'] ==
                                                              'text'
                                                          ? lastMessage['content']
                                                          : lastMessage['type'] ==
                                                              'image'
                                                          ? 'Photo'
                                                          : 'Attachment',
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                    : Text(
                                      'Start a conversation',
                                      style: TextStyle(
                                        color: Colors.grey[500],
                                        fontStyle: FontStyle.italic,
                                        fontSize: 14,
                                      ),
                                    ),
                          ),
                          if (hasUnread)
                            Container(
                              margin: const EdgeInsets.only(left: 4),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                chat['unreadCount'].toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatChatTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      return DateFormat('HH:mm').format(dateTime);
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else if (now.difference(dateTime).inDays < 7) {
      return DateFormat('EEE').format(dateTime); // Day name (Mon, Tue, etc.)
    } else {
      return DateFormat('dd/MM/yyyy').format(dateTime);
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chat_bubble_outline,
              size: 80,
              color: Theme.of(context).primaryColor.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No conversations yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Connect with healthcare professionals through secure messaging',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to doctor list or new conversation screen
            },
            icon: const Icon(Icons.add),
            label: const Text('Start a new conversation'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
          ),
          const SizedBox(height: 24),
          Text(
            'Unable to load conversations',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Please check your internet connection and try again',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 15),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _refreshChats,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
