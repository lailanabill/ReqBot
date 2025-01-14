import 'package:flutter/material.dart';
import 'package:reqbot/controllers/signin_controller.dart';
import '../widgets/auth_header.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/gradient_button.dart';
import '../widgets/social_auth_buttons.dart';
import '../widgets/auth_navigation.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final SignInController controller = SignInController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            AuthHeader(title: "Login", height: 300),
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    CustomTextField(
                      controller: controller.emailController,
                      labelText: "Email",
                      validator: controller.validateEmail,
                    ),
                    const SizedBox(height: 15),
                    CustomTextField(
                      controller: controller.passwordController,
                      labelText: "Password",
                      obscureText: true,
                      validator: controller.validatePassword,
                    ),
                    const SizedBox(height: 20),
                    GradientButton(
                      text: "Login",
                      onTap: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          controller.login(context);
                        }
                      },
                    ),
                    const SizedBox(height: 30),
                    const SocialAuthButtons(),
                    const SizedBox(height: 20),
                    AuthNavigation(
                      questionText: "Don't have an account?",
                      actionText: "Sign up",
                      onTap: () => Navigator.pushNamed(context, '/sign-up'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
