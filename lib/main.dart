import 'package:e_health_front/screens/splashScreen.dart';
import 'package:e_health_front/services/chat_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:e_health_front/providers/user_provider.dart';
import 'package:e_health_front/providers/article_provider.dart';

void main()async {
  WidgetsFlutterBinding.ensureInitialized(); // <== AJOUTER CECI
  await ChatService().initializeNotifications();
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
