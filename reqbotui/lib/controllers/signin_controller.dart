import 'package:flutter/material.dart';
import 'package:reqbot/services/auth/auth_services.dart';

class SignInController {
  final AuthServices authServices = AuthServices();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email or Phone number is required';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    return null;
  }

  Future<void> login(BuildContext context) async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    try {
      final response = await authServices.signInWithEmailPassword(email, password);

      if (response.session != null) {
        if (!context.mounted) return; // Prevents navigation after widget disposal
        Navigator.pushReplacementNamed(context, '/HomeScreen');
      } else {
        _showSnackBar(context, "Login failed: No session found");
      }
    } catch (e) {
      _showSnackBar(context, "Login Error: ${e.toString()}");
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
  }
}
