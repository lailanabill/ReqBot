import 'package:flutter/material.dart';
import 'package:reqbot/services/auth/auth_services.dart';

class SignInController {
  final AuthServices authServices = AuthServices();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    // More comprehensive email validation
    final emailRegExp = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegExp.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  Future<void> login(BuildContext context) async {
    try {
      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      final response =
          await authServices.signInWithEmailPassword(email, password);

      if (!context.mounted) return;

      if (response.session != null) {
        Navigator.pushReplacementNamed(context, '/HomeScreen');
        _showSuccessMessage(context, "Login successful!");
      } else {
        _showErrorMessage(context, "Invalid credentials");
      }
    } catch (e) {
      if (!context.mounted) return;
      _handleLoginError(context, e);
    }
  }

  void _handleLoginError(BuildContext context, dynamic error) {
    String message = "Unable to login";

    if (error.toString().contains("Invalid login credentials")) {
      message = "Incorrect email or password";
    } else if (error.toString().contains("network")) {
      message = "Network error. Please check your connection";
    } else if (error.toString().contains("too many requests")) {
      message = "Too many attempts. Please try again later";
    }

    _showErrorMessage(context, message);
  }

  void _showSuccessMessage(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showErrorMessage(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
  }
}
