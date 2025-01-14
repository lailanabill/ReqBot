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
    final email = emailController.text;
    final password = passwordController.text;

    try {
      final response = await authServices.signInWithEmailPassword(email, password);

      if (response.session != null) {
        Navigator.pushReplacementNamed(context, '/HomeScreen');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login failed: No session found")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login Error: $e")),
      );
    }
  }
}
