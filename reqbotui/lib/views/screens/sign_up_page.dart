import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:reqbot/controllers/signup_controller.dart';
import '../widgets/auth_header.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/gradient_button.dart';
import '../widgets/social_auth_buttons.dart';
import '../widgets/auth_navigation.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final SignUpController controller = SignUpController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _handleSignUp() {
    if (_formKey.currentState?.validate() ?? false) {
      if (!controller.isTermsAccepted.value) {
        _showMessage(
          "Please accept the terms and conditions",
          isError: true,
        );
        return;
      }
      controller.signUp(context);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              FadeInDown(
                duration: const Duration(milliseconds: 1000),
                child: AuthHeader(title: "Sign Up", height: 300),
              ),
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      FadeInUp(
                        duration: const Duration(milliseconds: 1200),
                        child: CustomTextField(
                          controller: controller.nameController,
                          labelText: "Full Name",
                          validator: controller.validateName,
                          keyboardType: TextInputType.name,
                        ),
                      ),
                      const SizedBox(height: 15),
                      FadeInUp(
                        duration: const Duration(milliseconds: 1400),
                        child: CustomTextField(
                          controller: controller.emailController,
                          labelText: "Email",
                          validator: controller.validateEmail,
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ),
                      const SizedBox(height: 15),
                      FadeInUp(
                        duration: const Duration(milliseconds: 1600),
                        child: CustomTextField(
                          controller: controller.phoneController,
                          labelText: "Phone Number",
                          validator: controller.validatePhone,
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                      const SizedBox(height: 15),
                      FadeInUp(
                        duration: const Duration(milliseconds: 1800),
                        child: CustomTextField(
                          controller: controller.companyController,
                          labelText: "Company",
                          validator: controller.validateCompany,
                        ),
                      ),
                      const SizedBox(height: 15),
                      FadeInUp(
                        duration: const Duration(milliseconds: 2000),
                        child: CustomTextField(
                          controller: controller.positionController,
                          labelText: "Position",
                          validator: controller.validatePosition,
                        ),
                      ),
                      const SizedBox(height: 15),
                      FadeInUp(
                        duration: const Duration(milliseconds: 2200),
                        child: CustomTextField(
                          controller: controller.passwordController,
                          labelText: "Password",
                          obscureText: true,
                          validator: controller.validatePassword,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Terms and Conditions
                      FadeInUp(
                        duration: const Duration(milliseconds: 2400),
                        child: ValueListenableBuilder<bool>(
                          valueListenable: controller.isTermsAccepted,
                          builder: (context, value, child) {
                            return Row(
                              children: [
                                Checkbox(
                                  value: value,
                                  onChanged: (newValue) {
                                    controller.isTermsAccepted.value =
                                        newValue ?? false;
                                  },
                                  activeColor:
                                      const Color.fromRGBO(143, 148, 251, 1),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      controller.isTermsAccepted.value =
                                          !controller.isTermsAccepted.value;
                                    },
                                    child: Text.rich(
                                      TextSpan(
                                        text: "I agree to the processing of ",
                                        style: const TextStyle(
                                          color: Colors.black87,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: "Personal data",
                                            style: TextStyle(
                                              color: const Color.fromRGBO(
                                                  143, 148, 251, 1),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 20),
                      FadeInUp(
                        duration: const Duration(milliseconds: 2600),
                        child: GradientButton(
                          text: "Sign Up",
                          onTap: _handleSignUp,
                        ),
                      ),
                      const SizedBox(height: 30),
                      FadeInUp(
                        duration: const Duration(milliseconds: 2800),
                        child: const SocialAuthButtons(),
                      ),
                      const SizedBox(height: 20),
                      FadeInUp(
                        duration: const Duration(milliseconds: 3000),
                        child: AuthNavigation(
                          questionText: "Already have an account?",
                          actionText: "Sign in",
                          onTap: () => Navigator.pushReplacementNamed(
                              context, '/sign-in'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
