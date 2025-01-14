import 'package:flutter/material.dart';
import 'package:animated_introduction/animated_introduction.dart';
import 'package:reqbot/controllers/welcome_controller.dart';
import '../widgets/intro_slide.dart';

class WelcomePage extends StatelessWidget {
  final WelcomeController controller = WelcomeController();

  WelcomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedIntroduction(
        slides: [
          // First Slide
          SingleIntroScreen(
            title: "Welcome",
            description: "Discover amazing features.",
            imageAsset: 'assets/images/onboard_one.png',
          ),
          // Second Slide
          SingleIntroScreen(
            title: "Get Started",
            description: "Sign up or log in to explore the app.",
            imageAsset: 'assets/images/onboard_two.png',
          ),
        ],
        onSkip: () => controller.navigateToSignUp(context),
        onDone: () => controller.navigateToSignIn(context),
        indicatorType: IndicatorType.circle,
      ),
    );
  }
}
