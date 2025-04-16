import 'package:e_health_front/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:e_health_front/screens/chatDetailScreen.dart';
import '../services/chat_service.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Show bottom sheet with doctors that don't have a chat
          _showDoctorsWithoutChat();
        },
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        icon: const Icon(Icons.chat, color: Colors.white),
        label: const Text(
          'New conversation',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        tooltip: 'New conversation',
      ),
      floatingActionButtonLocation: CustomFloatingActionButtonLocation(),
    );
  }

  // New method to show bottom sheet with doctors
  void _showDoctorsWithoutChat() async {
    // Show loading indicator first
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      final myDoctor = await ApiService().fetchMyDoctors();
      final doctorHaveChat = await ChatService().getChats();

      // Extract the IDs of doctors who already have a chat
      final doctorWithChatIds =
          doctorHaveChat.map((chat) => chat['doctor']['_id']).toSet();

      // Keep only the doctors who don't have a chat
      final doctorsWithoutChat =
          myDoctor
              .where((doc) => !doctorWithChatIds.contains(doc['_id']))
              .toList();

      // Close the loading indicator
      Navigator.of(context).pop();

      // Show the bottom sheet with the list of doctors
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            // Use at least 40% of screen height, or more if needed
            height: MediaQuery.of(context).size.height * 0.7,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Select a doctor',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Expanded(
                  child:
                      doctorsWithoutChat.isEmpty
                          ? const Center(
                            child: Text(
                              'No doctors available for new conversations',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          )
                          : ListView.builder(
                            itemCount: doctorsWithoutChat.length,
                            itemBuilder: (context, index) {
                              final doctor = doctorsWithoutChat[index];
                              return _buildDoctorListTile(doctor);
                            },
                          ),
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      // Close the loading indicator
      Navigator.of(context).pop();

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading doctors: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Widget to build each doctor list tile
  Widget _buildDoctorListTile(dynamic doctor) {
    return InkWell(
      onTap: () {
        Navigator.pop(context); // Close the bottom sheet
        _startNewChat(doctor);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
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
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dr. ${doctor['firstName']} ${doctor['lastName']}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    doctor['speciality'] ?? 'Doctor',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  // Method to start a new chat with a doctor
  void _startNewChat(dynamic doctor) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(child: CircularProgressIndicator());
        },
      );

      // Get the token
      final token = await ChatService().getToken();

      if (token == null) {
        throw Exception('Authorization token not found');
      }

      // Create a new chat using the existing createChat method
      final response = await ChatService().createChat(
        token: token,
        doctorId: doctor['_id'],
      );

      // Close loading indicator
      Navigator.of(context).pop();

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Parse the response to get the new chat data
        final newChat = json.decode(response.body);

        // Navigate to chat detail screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    ChatDetailScreen(chatId: newChat['_id'], doctor: doctor),
          ),
        ).then((_) => _refreshChats());

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Started conversation with Dr. ${doctor['firstName']} ${doctor['lastName']}',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Show error if request failed
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to create conversation: ${response.reasonPhrase}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Close loading indicator
      Navigator.of(context).pop();

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating conversation: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
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

    return Material(
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
                                  hasUnread ? FontWeight.bold : FontWeight.w500,
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
                                                    fontWeight: FontWeight.w500,
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

  Future<List<dynamic>> _doctorNotHaveChat() async {
    final myDoctor = await ApiService().fetchMyDoctors();
    final doctorHaveChat = await ChatService().getChats();

    // Extract the IDs of doctors who have a chat
    final doctorWithChatIds =
        doctorHaveChat.map((chat) => chat['doctor']['_id']).toSet();

    // Keep only the doctors who don't have a chat
    final doctorsWithoutChat =
        myDoctor
            .where((doc) => !doctorWithChatIds.contains(doc['_id']))
            .toList();

    return doctorsWithoutChat;
  }
}

class CustomFloatingActionButtonLocation extends FloatingActionButtonLocation {
  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    // Get the standard position
    final Offset standardOffset = FloatingActionButtonLocation.endFloat
        .getOffset(scaffoldGeometry);

    // Move it up by X pixels (adjust the value as needed)
    return Offset(standardOffset.dx, standardOffset.dy - 80.0);
  }
}
