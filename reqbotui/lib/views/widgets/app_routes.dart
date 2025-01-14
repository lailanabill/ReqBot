import 'package:flutter/material.dart';
import '/views/screens/mail_page.dart';
import '/views/screens/record.dart';
import '/views/screens/sign_in_page.dart';
import '/views/screens/sign_up_page.dart';
import '/views/screens/welcome_page.dart';
import '/views/screens/home_screen.dart';
import '/views/screens/favorites_screen.dart';

class AppRoutes {
  static final Map<String, WidgetBuilder> routes = {
    '/': (context) => WelcomePage(),
    '/sign-in': (context) => SignInPage(),
    '/sign-up': (context) => SignUpPage(),
    '/HomeScreen': (context) => HomeScreen(),
    '/record': (context) => Record(),
    '/FavoritesScreen': (context) => FavoritesScreen(),
    '/MailPage': (context) => const MailPage(),
  };
}
