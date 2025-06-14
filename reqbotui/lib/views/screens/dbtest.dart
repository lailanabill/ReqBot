import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DbTestScreen extends StatefulWidget {
  const DbTestScreen({super.key});

  @override
  State<DbTestScreen> createState() => _DbTestScreenState();
}

class _DbTestScreenState extends State<DbTestScreen> {
  String PID = '';
  int uid = 0;

  void pid() async {
    final contents =
        await rootBundle.loadString('assets/umls/context_diagram_5.puml');
    final cleaned = contents.trim().replaceAll('\r\n', '\n');
    setState(() {
      PID = cleaned;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Database Test'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(PID),
            ElevatedButton(
              onPressed: () {
                pid();
              },
              child: const Text('project id'),
            ),
            ElevatedButton(
              onPressed: () {
                // Add your button action here
              },
              child: const Text('analyzer id'),
            ),
          ],
        ),
      ),
    );
  }
}
