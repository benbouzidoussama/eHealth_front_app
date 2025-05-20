// ignore_for_file: use_key_in_widget_constructors
import 'package:e_health_front/screens/appointment/appointmentScreen.dart';
import 'package:e_health_front/screens/chat/chatDetailScreen.dart';
import 'package:e_health_front/services/chat_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:e_health_front/providers/user_provider.dart';
import 'package:e_health_front/services/api_service.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class NotificationsScreen extends StatefulWidget {
  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<dynamic> _notifications = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final apiService = ApiService();
      final token = userProvider.user?['token'] ?? '';

      final notifications = await apiService.getNotifications(token);

      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  String _formatDate(String dateString) {
    initializeDateFormatting('fr_FR', null);
    final date = DateTime.parse(dateString);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      // Today
      return DateFormat('HH:mm', 'fr_FR').format(date);
    } else if (difference.inDays == 1) {
      // Yesterday
      return 'Hier à ${DateFormat('HH:mm', 'fr_FR').format(date)}';
    } else if (difference.inDays < 7) {
      // This week
      return DateFormat('EEEE à HH:mm', 'fr_FR').format(date);
    } else {
      // Older
      return DateFormat('d MMMM y à HH:mm', 'fr_FR').format(date);
    }
  }

  Future<void> _markAsRead(String notificationId) async {
    try {
      final apiService = ApiService();

      //Implement markNotificationAsRead in ApiService
      await apiService.markNotificationAsRead(notificationId);

      setState(() {
        _notifications =
            _notifications.map((notification) {
              if (notification['_id'] == notificationId) {
                notification['isRead'] = true;
              }
              return notification;
            }).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: Impossible de marquer comme lu')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 224, 221, 221),
      appBar: AppBar(
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.keyboard_arrow_left, color: Colors.black),
        ),
        backgroundColor: const Color.fromARGB(255, 224, 221, 221),
        title: Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: _fetchNotifications),
        ],
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : _hasError
              ? _buildErrorView()
              : _notifications.isEmpty
              ? _buildEmptyView()
              : _buildNotificationsList(),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 60, color: Colors.red),
          SizedBox(height: 16),
          Text(
            'Une erreur est survenue',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(_errorMessage),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: _fetchNotifications,
            child: Text('Réessayer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xff575de3),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off, size: 60, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Aucune notification',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('Vous n\'avez pas encore reçu de notifications'),
        ],
      ),
    );
  }

  Widget _buildNotificationsList() {
    return RefreshIndicator(
      onRefresh: _fetchNotifications,
      child: ListView.builder(
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final notification = _notifications[index];
          final bool isRead = notification['isRead'] ?? false;
          final String formattedDate = _formatDate(notification['createdAt']);

          return Card(
            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            elevation: isRead ? 1 : 3,
            color: isRead ? Colors.white : Color(0xFFE8EAFE),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(
                backgroundColor: Color(0xff575de3),
                child: _getNotificationIcon(notification['type']),
              ),
              title: Text(
                notification['title'],
                style: TextStyle(
                  fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 4),
                  Text(
                    notification['content'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    formattedDate,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
              trailing: Icon(
                Icons.circle,
                color: isRead ? Colors.green : Colors.red,
                size: 10,
              ),
              onTap: () async {
                // Handle notification tap based on type
                // You can navigate to different screens based on notification type
                if (!isRead) {
                  _markAsRead(notification['_id']);
                }

                // Example navigation based on type
                if (notification['type'] == 'message') {
                  // Navigate to chat screen
                  ChatService chatService = ChatService();
                  final doctorId = await chatService.getDoctorIdByChatId(
                    notification['relatedEntity'],
                  );
                  ApiService apiService = ApiService();
                  if (doctorId != null) {
                    final doctor = await apiService.fetchDoctorById(doctorId);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => ChatDetailScreen(
                              chatId: notification['relatedEntity'],
                              doctor: doctor,
                            ),
                      ),
                    );
                  }
                } else if (notification['type'] == 'appointment') {
                  //Navigate to appointment details
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AppointmentScreen(),
                    ),
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }

  Widget _getNotificationIcon(String type) {
    switch (type) {
      case 'message':
        return Icon(Icons.message, color: Colors.white);
      case 'appointment':
        return Icon(Icons.calendar_today, color: Colors.white);
      case 'reminder':
        return Icon(Icons.alarm, color: Colors.white);
      case 'alert':
        return Icon(Icons.warning, color: Colors.white);
      default:
        return Icon(Icons.notifications, color: Colors.white);
    }
  }
}
