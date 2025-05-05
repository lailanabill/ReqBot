import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:reqbot/controllers/signup_controller.dart';
import '../widgets/auth_header.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/gradient_button.dart';
import '../widgets/social_auth_buttons.dart';
import '../widgets/auth_navigation.dart';
import 'package:reqbot/controllers/signup_controller.dart';

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
    "Create An Account",
    textAlign: TextAlign.center,
    style: GoogleFonts.inter(
      fontSize: 24,
      fontWeight: FontWeight.bold,
    ),
  ),
),

                  const SizedBox(height: 32),
                  
                  // Full Name Field
                  Text(
                    "Full Name",
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildFormField(
                    controller: controller.nameController,
                    validator: controller.validateName,
                    hintText: "Enter your full name",
                    keyboardType: TextInputType.name,
                    prefixIcon: Icons.person_outline,
                  ),
                  const SizedBox(height: 20),
                  
                  // Email Field
                  Text(
                    "Email",
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildFormField(
                    controller: controller.emailController,
                    validator: controller.validateEmail,
                    hintText: "Enter your email address",
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                  ),
                  const SizedBox(height: 20),
                  
                  // Phone Number Field
                  Text(
                    "Phone Number",
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildFormField(
                    controller: controller.phoneController,
                    validator: controller.validatePhone,
                    hintText: "Enter your phone number",
                    keyboardType: TextInputType.phone,
                    prefixIcon: Icons.phone_outlined,
                  ),
                  const SizedBox(height: 20),
                  
                  // Company Field
                  Text(
                    "Company",
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildFormField(
                    controller: controller.companyController,
                    validator: controller.validateCompany,
                    hintText: "Enter your company name",
                    prefixIcon: Icons.business_outlined,
                  ),
                  const SizedBox(height: 20),
                  
                  // Position Field
                  Text(
                    "Position",
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildFormField(
                    controller: controller.positionController,
                    validator: controller.validatePosition,
                    hintText: "Enter your position",
                    prefixIcon: Icons.work_outline,
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
                  _buildFormField(
                    controller: controller.passwordController,
                    validator: controller.validatePassword,
                    hintText: "Enter your password",
                    obscureText: true,
                    prefixIcon: Icons.lock_outline,
                    suffixIcon: Icons.visibility_off,
                  ),
                  const SizedBox(height: 20),
                  
                  // Terms and Conditions Checkbox
                  ValueListenableBuilder<bool>(
                    valueListenable: controller.isTermsAccepted,
                    builder: (context, value, child) {
                      return Row(
                        children: [
                          Checkbox(
                            value: value,
                            onChanged: (newValue) {
                              controller.isTermsAccepted.value = newValue ?? false;
                            },
                            activeColor: Color.fromARGB(255, 0, 54, 218),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                controller.isTermsAccepted.value = !controller.isTermsAccepted.value;
                              },
                              child: Text.rich(
                                TextSpan(
                                  text: "I agree to the processing of ",
                                  style: GoogleFonts.inter(
                                    color: Colors.grey[700],
                                    fontSize: 14,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: "Personal data",
                                      style: GoogleFonts.inter(
                                        color: Color.fromARGB(255, 0, 54, 218),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
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
                  
                  const SizedBox(height: 30),
                  // Sign Up Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _handleSignUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 0, 54, 218),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        "Sign Up",
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
                  // Already have an account
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account? ",
                          style: GoogleFonts.inter(color: Colors.grey),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pushReplacementNamed(context, '/sign-in'),
                          child: Text(
                            "Sign in",
                            style: GoogleFonts.inter(
                              color: Color.fromARGB(255, 0, 54, 218),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildFormField({
    required TextEditingController controller,
    required String? Function(String?) validator,
    required String hintText,
    required IconData prefixIcon,
    IconData? suffixIcon,
    bool obscureText = false,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.inter(
          color: Colors.grey,
          fontSize: 14,
        ),
        prefixIcon: Icon(prefixIcon, color: Colors.grey),
        suffixIcon: suffixIcon != null ? Icon(suffixIcon, color: Colors.grey) : null,
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