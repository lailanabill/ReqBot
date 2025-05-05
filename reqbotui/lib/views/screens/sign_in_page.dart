import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reqbot/controllers/signin_controller.dart';
import 'package:reqbot/services/providers/userProvider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final SignInController controller = SignInController();
  bool _rememberMe = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  Center(
  child: Text(
    "Login To Your Account",
    textAlign: TextAlign.center,
    style: GoogleFonts.inter(
      fontSize: 24,
      fontWeight: FontWeight.bold,
    ),
  ),
),
                  const SizedBox(height: 32),
                  // Email Field
                  Text(
                    "Email",
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: controller.emailController,
                    validator: controller.validateEmail,
                    decoration: InputDecoration(
                      hintText: "Enter your username e-mail",
                      hintStyle: GoogleFonts.inter(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                      prefixIcon: const Icon(Icons.email_outlined, color: Colors.grey),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.grey, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.grey, width: 1),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Password Field
                  Text(
                    "Password",
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: controller.passwordController,
                    validator: controller.validatePassword,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: "Enter your password",
                      hintStyle: GoogleFonts.inter(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                      prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                      suffixIcon: const Icon(Icons.visibility_off, color: Colors.grey),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.grey, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.grey, width: 1),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  // Forgot Password & Remember Me
                 Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          // Forgot password functionality
        },
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          "Forgot password ?",
          style: GoogleFonts.inter(
            color: Colors.black,
            fontSize: 14,
          ),
        ),
      ),
    ),
    Row(
      children: [
        Switch(
          value: _rememberMe,
          onChanged: (value) {
            setState(() {
              _rememberMe = value;
            });
          },
          activeColor: Colors.white,
          activeTrackColor: Colors.blue,
          inactiveThumbColor: Colors.white,
          inactiveTrackColor: Colors.grey,
        ),
        Text(
          "Remember me",
          style: GoogleFonts.inter(fontSize: 14),
        ),
      ],
    ),
  ],
),

                  const SizedBox(height: 20),
                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState?.validate() ?? false) {
                          controller.login(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 0, 54, 218),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        "Login",
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // OR divider
                  Row(
                    children: [
                      const Expanded(
                        child: Divider(
                          color: Colors.grey,
                          thickness: 0.5,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          "or",
                          style: GoogleFonts.inter(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Divider(
                          color: Colors.grey,
                          thickness: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Social login buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _socialLoginButton('assets/images/Facebook.png', () {}),
                      const SizedBox(width: 20),
                      _socialLoginButton('assets/images/Google.png', () {}),
                      const SizedBox(width: 20),
                      _socialLoginButton('assets/images/Linkedin.png', () {}),
                    ],
                  ),
                  const SizedBox(height: 40),
                  // Don't have an account
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: GoogleFonts.inter(color: Colors.grey),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/sign-up'),
                          child: Text(
                            "Sign up",
                            style: GoogleFonts.inter(
                              color: Color.fromARGB(255, 0, 54, 218),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _socialLoginButton(String iconPath, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Center(
          child: Image.asset(
            iconPath,
            width: 24,
            height: 24,
          ),
        ),
      ),
    );
  }
}