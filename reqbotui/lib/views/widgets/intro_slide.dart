import 'package:flutter/material.dart';

class IntroSlide extends StatelessWidget {
  final String title;
  final String description;
  final String imageAsset;

  const IntroSlide({
    Key? key,
    required this.title,
    required this.description,
    required this.imageAsset,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(imageAsset, height: 200, fit: BoxFit.cover),
        const SizedBox(height: 20),
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          description,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
    );
  }
}
