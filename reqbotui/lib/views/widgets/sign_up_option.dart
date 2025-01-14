import 'package:flutter/material.dart';

class SignUpOption extends StatelessWidget {
  const SignUpOption({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/sign-up'),
      child: const Text.rich(
        TextSpan(
          text: "Don't have an account? ",
          children: [
            TextSpan(
              text: "Sign up",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
