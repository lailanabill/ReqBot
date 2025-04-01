import 'package:flutter/material.dart';
import 'package:gotrue/src/types/auth_response.dart';
import 'package:reqbot/services/auth/auth_services.dart';

class SignUpController {
  final AuthServices authServices = AuthServices();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController companyController = TextEditingController();
  final TextEditingController positionController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final ValueNotifier<bool> isTermsAccepted = ValueNotifier(false);

  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Full Name is required';
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim())) {
      return 'Enter a valid email';
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty)
      return 'Phone Number is required';
    if (!RegExp(r'^\d{10,15}$').hasMatch(value.trim())) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters long';
    if (!RegExp(r'[A-Z]').hasMatch(value))
      return 'Password must contain an uppercase letter';
    if (!RegExp(r'[a-z]').hasMatch(value))
      return 'Password must contain a lowercase letter';
    if (!RegExp(r'[0-9]').hasMatch(value))
      return 'Password must contain a digit';
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Password must contain a special character';
    }
    return null; // Password is valid
  }

  Future<void> signUp(BuildContext context) async {
    if (!isTermsAccepted.value) {
      _showSnackBar(context, "You must accept the terms and conditions.");
      return;
    }

    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final company = companyController.text.trim();
    final position = positionController.text.trim();
    final password = passwordController.text.trim();

    print(
        'Signing up with: $name, $email, $phone, $company, $position'); // Debugging output

    try {
      final response = await authServices.signUpWithEmailPassword(
        name,
        email,
        phone,
        password,
        company,
        position,
      );

      if (response.user != null) {
        _showSnackBar(context, "Sign-up successful! Please verify your email.");
        if (!context.mounted) return;
        Navigator.pushNamed(context, '/sign-in');
      } else {
        _showSnackBar(context, "Sign-up failed: ${response.error?.message}");
      }
    } catch (e) {
      _showSnackBar(context, "Error during sign-up: ${e.toString()}");
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
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    companyController.dispose();
    positionController.dispose();
    passwordController.dispose();
  }
}

extension on AuthResponse {
  get error => null;
}
