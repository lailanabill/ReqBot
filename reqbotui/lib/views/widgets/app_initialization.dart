import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/widgets.dart'; // Required for WidgetsFlutterBinding

Future<void> initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://amwbjumsltfluzggoxpw.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFtd2JqdW1zbHRmbHV6Z2dveHB3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDMzNTAwMDAsImV4cCI6MjA1ODkyNjAwMH0.IE4Ae5uDxY_ZEvlfa3ijigYgESrLqm8ugtP8FP6PMrY',
        
  );

  

  // Lock device orientation
  await SystemChrome.setPreferredOrientations([
    //auto rotate
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
}
