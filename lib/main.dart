import 'package:e_health_front/screens/splashScreen.dart';
import 'package:e_health_front/services/chat_service.dart';
import 'package:e_health_front/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:e_health_front/providers/user_provider.dart';
import 'package:e_health_front/providers/article_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  
  WidgetsFlutterBinding.ensureInitialized();
  await ChatService().initializeNotifications();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');
  
  if (token != null) {
    // Un token existe, on peut démarrer le service de notification
    debugPrint('Token trouvé au démarrage, initialisation du service de notification');
    NotificationService().start(token);
  } else {
    debugPrint('Aucun token trouvé, le service de notification sera démarré après connexion');
  }
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ArticleProvider()),
      ],
      child: MyApp(),
    ),
  );
  

}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-Health',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SplashScreen(), // Commence par le SplashScreen
      debugShowCheckedModeBanner: false,
    );
  }
}