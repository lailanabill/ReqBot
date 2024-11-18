import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bye.jfif'), // Replace with your background image path
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Dark Overlay for Contrast
          Container(
            color: Colors.black.withOpacity(0.6), // Semi-transparent overlay
          ),
          // Page Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Title
                Text(
                  "Welcome",
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // White text
                  ),
                ),
                SizedBox(height: 20),
                // Description
                Text(
                  "Create an account and access \nthousands of cool stuffs",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white.withOpacity(0.9), // White text with slight transparency
                    height: 1.5, // Line height for better readability
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 40),
                // Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    children: [
                      // Getting Started Button
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/sign-up'); // Navigate to Sign Up
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF00C6AE), // Button color
                          padding: EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30), // Rounded corners
                          ),
                          elevation: 5, // Button shadow
                        ),
                        child: Center(
                          child: Text(
                            "Getting Started",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white, // Button text color
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      // Log In Text
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/sign-in'); // Navigate to Log In
                        },
                        child: Text.rich(
                          TextSpan(
                            text: "Already have an account? ",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.9),
                            ),
                            children: [
                              TextSpan(
                                text: "Log in",
                                style: TextStyle(
                                  color: Color(0xFF00C6AE), // Highlight color
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
