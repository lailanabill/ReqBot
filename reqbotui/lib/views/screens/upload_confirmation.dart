import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reqbot/views/screens/home_screen.dart';

class UploadConfirmationScreen extends StatelessWidget {
  final Color primaryColor = Color.fromARGB(255, 0, 54, 218);
  final Color secondaryColor = Color.fromARGB(255, 230, 234, 255);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: secondaryColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.cloud_done,
                  size: 60,
                  color: primaryColor,
                ),
              ),
              SizedBox(height: 32),
              Text(
                'Audio Uploaded Successfully!',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                'We are processing your audio and generating requirements. You will be notified when they are ready.',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              HomeScreen(), // Replace with your home screen widget
                        ));
                    // Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Return to Home',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
