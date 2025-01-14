import 'package:flutter/material.dart';
import 'package:reqbot/services/auth/auth_services.dart';

class HomeHeader extends StatelessWidget {
  final VoidCallback onLogout;

  const HomeHeader({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Home',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          children: [
            const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Color(0xFF3F51B5)),
            ),
            IconButton(
              onPressed: onLogout,
              icon: const Icon(Icons.logout, color: Colors.white),
            ),
          ],
        ),
      ],
    );
  }
}
