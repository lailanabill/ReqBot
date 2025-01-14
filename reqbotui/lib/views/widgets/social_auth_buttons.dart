import 'package:flutter/material.dart';

class SocialAuthButtons extends StatelessWidget {
  const SocialAuthButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          "Sign in with",
          style: TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _socialIcon(Icons.facebook, Colors.blue),
            const SizedBox(width: 10),
            _socialIcon(Icons.g_translate, Colors.red),
            const SizedBox(width: 10),
            _socialIcon(Icons.apple, Colors.black),
          ],
        ),
      ],
    );
  }

  Widget _socialIcon(IconData icon, Color color) {
    return CircleAvatar(
      radius: 25,
      backgroundColor: Colors.white,
      child: Icon(icon, color: color),
    );
  }
}
