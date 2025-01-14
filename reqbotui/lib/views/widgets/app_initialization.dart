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
    url: 'https://lfmhmnbqlyqdiwndbiyl.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxmbWhtbmJxbHlxZGl3bmRiaXlsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzUwODQ5NjIsImV4cCI6MjA1MDY2MDk2Mn0.EuhYfqnTT2oreH5i7Lr37x8V36PXkpwJVe0uTs21Lys',
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
