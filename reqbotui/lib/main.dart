import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'views/themes/light_theme.dart';
import 'views/themes/dark_theme.dart';
import 'views/widgets/app_routes.dart';
import 'views/widgets/app_initialization.dart';
import 'services/providers/favorites_provider.dart';

void main() async {
  await initializeApp(); // Initialization logic moved to a helper
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => FavoritesProvider(),
        ),
      ],
      child: const ReqBotApp(),
    ),
  );
}

class ReqBotApp extends StatelessWidget {
  const ReqBotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ReqBot',
      theme: buildLightTheme(), // Moved light theme logic to a separate file
      darkTheme: buildDarkTheme(), // Moved dark theme logic to a separate file
      themeMode: ThemeMode.system,
      initialRoute: '/',
      routes: AppRoutes.routes, // Moved route logic to a separate file
    );
  }
}
