import 'dart:async';
import 'package:e_health_front/services/api_service.dart';
import 'package:e_health_front/services/chat_service.dart';
import 'package:flutter/material.dart';

class NotificationService {
  final ChatService _chatService = ChatService();
  ApiService apiService = ApiService();
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  Timer? _timer;
  // Liste pour stocker les IDs des notifications déjà vues
  Set<String> _processedNotificationIds = {};

  // Démarre le service de notification avec un token
  int _compteur = 0; // Déclaration au niveau de la classe

  void start(String token) {
    // Ne rien faire si le timer est déjà en cours
    if (_timer != null) return;

    debugPrint('🔔 Service de notification démarré');

    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      _compteur++; // Incrémente le compteur
      print("🔄 Vérification #$_compteur des notifications...");
      _fetchNotifications(token, _compteur);
    });
  }

  Future<void> _fetchNotifications(String token, int _compteur) async {
    try {
      final notifications = await apiService.getNotifications(token);

      if (_compteur == 1) {
        for (var notification in notifications) {
          _processedNotificationIds.add(notification['_id'].toString());
        }
        debugPrint('🚫 Notifications initiales ignorées mais enregistrées.');
        return;
      }

      final newNotifications =
          notifications.where((notification) {
            final id = notification['_id'].toString();
            return !_processedNotificationIds.contains(id);
          }).toList();

      if (newNotifications.isNotEmpty) {
        debugPrint(
          '🆕 ${newNotifications.length} nouvelle(s) notification(s) trouvée(s):',
        );
        await _chatService.initializeNotifications();
        for (var notification in newNotifications) {
          if (notification['type'] == 'appointment') {
            _chatService.showNotification(
              notification['title'] ?? 'Pas de titre',
              notification['content'] ?? 'Pas de contenu',
            );
          }
        }
        for (var notification in newNotifications) {
          _displayNotification(notification);
          _processedNotificationIds.add(notification['_id'].toString());
        }
      } else {
        debugPrint('✅ Aucune nouvelle notification');
      }
    } catch (e) {
      debugPrint('❌ Erreur lors de la récupération des notifications: $e');
    }
  }

  void _displayNotification(Map<String, dynamic> notification) {
    final String id = notification['_id'] ?? 'N/A';
    final String title = notification['title'] ?? 'Pas de titre';
    final String content = notification['content'] ?? 'Pas de contenu';
    final String type = notification['type'] ?? 'unknown';
    final bool isRead = notification['isRead'] ?? false;
    final String createdAt = notification['createdAt'] ?? '';

    debugPrint('📱 ==========================================');
    debugPrint('📱 NOUVELLE NOTIFICATION:');
    debugPrint('📱 ID: $id');
    debugPrint('📱 Titre: $title');
    debugPrint('📱 Contenu: $content');
    debugPrint('📱 Type: $type');
    debugPrint('📱 Lu: ${isRead ? "Oui" : "Non"}');
    debugPrint('📱 Date: $createdAt');
    debugPrint('📱 ==========================================');
  }

  // Arrête le service de notification
  void stop() {
    _timer?.cancel();
    _timer = null;
    debugPrint('🛑 Service de notification arrêté');
  }

  // Réinitialise l'historique des notifications
  void resetHistory() {
    _processedNotificationIds.clear();
    debugPrint('🧹 Historique des notifications réinitialisé');
  }

  // Méthode pour obtenir le nombre de notifications non lues
  int getUnreadCount() {
    return _processedNotificationIds.length;
  }

  // Méthode pour marquer une notification comme lue (optionnelle)
  void markAsRead(String notificationId) {
    _processedNotificationIds.add(notificationId);
    debugPrint('✅ Notification $notificationId marquée comme lue');
  }
}
