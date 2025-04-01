import 'package:flutter/material.dart';

class WelcomeController {
  void navigateToSignUp(BuildContext context) {
    if (context.mounted) {
      Navigator.pushNamed(context, '/sign-up');
    }
  }

  void navigateToSignIn(BuildContext context) {
    if (context.mounted) {
      Navigator.pushNamed(context, '/sign-in');
    }
  }
}
