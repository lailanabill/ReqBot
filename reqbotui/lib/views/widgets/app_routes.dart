import 'package:flutter/material.dart';
import 'package:reqbot/views/screens/summary.dart';
import 'package:reqbot/views/screens/transcript.dart';
// import 'package:reqbot/views/screens/selectReqs.dart';

import '/views/screens/record.dart';
import '/views/screens/sign_in_page.dart';
import '/views/screens/sign_up_page.dart';
import '/views/screens/welcome_page.dart';
import '/views/screens/home_screen.dart';
import '/views/screens/favorites_screen.dart';

class AppRoutes {
  static final Map<String, WidgetBuilder> routes = {
    '/': (context) => WelcomePage(),
    // '/': (context) => TranscriptScreen(),
    '/sign-in': (context) => SignInPage(),
    '/sign-up': (context) => SignUpPage(),
    '/HomeScreen': (context) => HomeScreen(),
    // '/HomeScreen': (context) => DbTestScreen(),
    '/record': (context) => Record(),
    '/FavoritesScreen': (context) => FavoritesScreen(),
    // '/Requirements': (context) => SelectReqs(myreqs: ,),
  };
}
