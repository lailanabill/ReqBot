import 'package:flutter/material.dart';
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
    if (value == null || value.isEmpty) return 'Full Name is required';
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'Phone Number is required';
    if (!RegExp(r'^\d{10,15}$').hasMatch(value)) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  String? validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'Password is required';
  }
  if (value.length < 8) {
    return 'Password must be at least 8 characters long';
  }
  if (!RegExp(r'[A-Z]').hasMatch(value)) {
    return 'Password must contain at least one uppercase letter';
  }
  if (!RegExp(r'[a-z]').hasMatch(value)) {
    return 'Password must contain at least one lowercase letter';
  }
  if (!RegExp(r'[0-9]').hasMatch(value)) {
    return 'Password must contain at least one digit';
  }
  if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
    return 'Password must contain at least one special character';
  }
  return null; // Password is valid
}


  Future<void> signUp(BuildContext context) async {
    if (!isTermsAccepted.value) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("You must accept the terms and conditions.")),
      );
      return;
    }

    final name = nameController.text;
    final email = emailController.text;
    final phone = phoneController.text;
    final company = companyController.text;
    final position = positionController.text;
    final password = passwordController.text;

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Sign-up successful! Please verify your email.")),
        );
        Navigator.pushNamed(context, '/sign-in');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error during sign-up: $e")),
      );
    }
  }
}
