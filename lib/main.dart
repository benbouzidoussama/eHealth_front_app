import 'package:e_health_front/providers/doctor_provider.dart';
import 'package:e_health_front/screens/auth/welcomeScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:e_health_front/providers/user_provider.dart';
import 'package:e_health_front/providers/article_provider.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ArticleProvider()),
        ChangeNotifierProvider(create: (_) => DoctorProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'E-Health',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: WelcomeScreen(),
      ),
    );
  }
}
