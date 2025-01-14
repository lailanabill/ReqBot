import 'package:flutter/material.dart';

class WelcomeController {
  void navigateToSignUp(BuildContext context) {
    Navigator.pushNamed(context, '/sign-up');
  }

  void navigateToSignIn(BuildContext context) {
    Navigator.pushNamed(context, '/sign-in');
  }
}
