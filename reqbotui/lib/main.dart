import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const ReqBotApp());
}

class ReqBotApp extends StatelessWidget {
  const ReqBotApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ReqBot',
      theme: ThemeData(
        primarySwatch: Colors.blue, // Primary color for the app
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomeScreen(), // Set the home screen to HomeScreen
    );
  }
}
