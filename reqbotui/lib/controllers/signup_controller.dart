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
    if (value == null || value.trim().isEmpty) {
      return 'Full name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim())) {
      return 'Name can only contain letters';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegExp = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegExp.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    // Allows formats: +1234567890, 1234567890, 123-456-7890
    final phoneRegExp = RegExp(r'^\+?\d{10,15}$|^\d{3}-\d{3}-\d{4}$');
    if (!phoneRegExp.hasMatch(value.trim().replaceAll(' ', ''))) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  String? validateCompany(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Company name is required';
    }
    if (value.trim().length < 2) {
      return 'Company name must be at least 2 characters';
    }
    return null;
  }

  String? validatePosition(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Position is required';
    }
    if (value.trim().length < 2) {
      return 'Position must be at least 2 characters';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Password must contain at least one special character';
    }
    return null;
  }

  Future<void> signUp(BuildContext context) async {
    try {
      if (!isTermsAccepted.value) {
        _showErrorMessage(context, "Please accept the terms and conditions");
        return;
      }

      final response = await authServices.signUpWithEmailPassword(
        nameController.text.trim(),
        emailController.text.trim(),
        phoneController.text.trim(),
        passwordController.text.trim(),
        companyController.text.trim(),
        positionController.text.trim(),
      );

      if (!context.mounted) return;

      if (response.user != null) {
        _showSuccessMessage(context, "Account created successfully!");
        Navigator.pushReplacementNamed(context, '/sign-in');
      } else {
        _showErrorMessage(context, "Registration failed");
      }
    } catch (e) {
      if (!context.mounted) return;
      _handleSignUpError(context, e);
    }
  }

  void _handleSignUpError(BuildContext context, dynamic error) {
    String message = "Registration failed";

    if (error.toString().contains("email")) {
      message = "This email is already registered";
    } else if (error.toString().contains("network")) {
      message = "Network error. Please check your connection";
    } else if (error.toString().contains("weak-password")) {
      message = "Password is too weak";
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
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    companyController.dispose();
    positionController.dispose();
    passwordController.dispose();
  }
}
