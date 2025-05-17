import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class MessageNotificationService {
  final FlutterLocalNotificationsPlugin notificationsPlugin = FlutterLocalNotificationsPlugin();
  //final String baseUrl = "http://localhost:3000/api"; // Utilisez la même URL que votre ApiService
  final String baseUrl = "https://10.0.2.2:3000/api"; // Remplacez par l'URL de votre API
  Timer? messageCheckTimer;
  
  // Initialiser les notifications
  Future<void> initNotification() async {
    AndroidInitializationSettings initializationSettingsAndroid = 
        const AndroidInitializationSettings('app_icon');
    DarwinInitializationSettings initializationSettingsIOS = 
        const DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) {
        // Rediriger vers la page des messages quand on clique sur la notification
        print('Notification de message cliquée!');
        // Vous pourriez implémenter ici la navigation vers l'écran de messages
        // Exemple: Navigator.of(context).pushNamed('/messages');
      },
    );
  }
  
  // Afficher une notification
  Future<void> showMessageNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'messages_channel_id',
      'Messages',
      channelDescription: 'Notifications pour les nouveaux messages',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      sound: RawResourceAndroidNotificationSound('notification_sound'), // Ajouter un son personnalisé
      playSound: true,
      enableVibration: true,
    );
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'notification_sound.aiff', // Son personnalisé pour iOS
      ),
    );
    await notificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
    );
  }
  
  // Récupérer les messages et vérifier s'il y a de nouveaux messages
  Future<void> checkForNewMessages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");
    String? lastMessageTime = prefs.getString("lastMessageTime");
    
    if (token == null) {
      print("Utilisateur non connecté, impossible de vérifier les messages");
      return;
    }
    
    try {
      // Modifiez cette URL selon l'API de votre backend
      final response = await http.get(
        Uri.parse('$baseUrl/messages/unread'),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> newMessages = data['messages'] ?? [];
        
        if (newMessages.isNotEmpty) {
          // Afficher une notification pour chaque nouveau message ou une seule pour tous
          for (int i = 0; i < newMessages.length; i++) {
            var message = newMessages[i];
            String senderName = message['senderName'] ?? "Nouveau message";
            String messageText = message['text'] ?? "Vous avez reçu un nouveau message";
            
            await showMessageNotification(
              id: i,
              title: senderName,
              body: messageText,
            );
          }
          
          // Mettre à jour le dernier temps de vérification
          prefs.setString("lastMessageTime", DateTime.now().toIso8601String());
        }
      } else {
        print("Erreur lors de la vérification des messages: ${response.body}");
      }
    } catch (e) {
      print("Exception lors de la vérification des messages: $e");
    }
  }
  
  // Démarrer la vérification périodique des messages
  void startMessageChecking() {
    // Vérifier les messages toutes les 30 secondes
    messageCheckTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      checkForNewMessages();
    });
  }
  
  // Arrêter la vérification périodique
  void stopMessageChecking() {
    messageCheckTimer?.cancel();
    messageCheckTimer = null;
  }
}