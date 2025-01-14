import 'package:flutter/material.dart';

class AuthNavigation extends StatelessWidget {
  final String questionText;
  final String actionText;
  final VoidCallback onTap;

  const AuthNavigation({
    Key? key,
    required this.questionText,
    required this.actionText,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text.rich(
        TextSpan(
          text: "$questionText ",
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
          children: [
            TextSpan(
              text: actionText,
              style: const TextStyle(
                color: Color.fromRGBO(143, 148, 251, 1),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
