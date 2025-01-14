import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class AuthHeader extends StatelessWidget {
  final String title;
  final double height;

  const AuthHeader({
    Key? key,
    required this.title,
    required this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/background.png'),
          fit: BoxFit.fill,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 30,
            width: 80,
            height: 200,
            child: FadeInUp(
              child: Image.asset('assets/images/light-1.png'),
            ),
          ),
          Positioned(
            left: 140,
            width: 80,
            height: 150,
            child: FadeInUp(
              delay: const Duration(milliseconds: 200),
              child: Image.asset('assets/images/light-2.png'),
            ),
          ),
          Positioned(
            right: 40,
            top: 40,
            width: 80,
            height: 150,
            child: FadeInUp(
              delay: const Duration(milliseconds: 400),
              child: Image.asset('assets/images/clock.png'),
            ),
          ),
          Center(
            child: FadeInUp(
              delay: const Duration(milliseconds: 600),
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
