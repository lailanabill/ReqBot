import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reqbot/services/providers/userProvider.dart';

import 'package:reqbot/views/screens/record.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:reqbotui/screens/structured_requirements.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;

class ProjectToDB extends StatefulWidget {
  const ProjectToDB({Key? key}) : super(key: key);

  @override
  _ProjectToDBState createState() => _ProjectToDBState();
}

class _ProjectToDBState extends State<ProjectToDB> {
  bool _accepted = false;
  final ProjName = TextEditingController();

  @override
  void initState() {
    super.initState();
    // _speech = stt.SpeechToText();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload & Convert'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Project Name',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: ProjName,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter project name',
                hintText: 'e.g., Project Alpha',
              ),
            ),
            const SizedBox(height: 16),

            const SizedBox(height: 16),

            const SizedBox(height: 24),
            Row(
              children: [
                Checkbox(
                  value: _accepted,
                  onChanged: (value) {
                    setState(() {
                      _accepted = value!;
                    });
                  },
                ),
                Expanded(child: Text("I accept the Terms and Conditions"))
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _accepted && ProjName.text.isNotEmpty
                  ? () async {
                      final x0 = await Supabase.instance.client
                          .from('projects')
                          .insert(
                        {
                          "analyzer_id":
                              context.read<UserDataProvider>().AnalyzerID,
                          "name": ProjName.text
                        },
                      ).select();
                      context
                          .read<UserDataProvider>()
                          .setProjectId(x0[0]['id']);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Record(),
                        ),
                      );
                    }
                  : null,
              child: Text("Continue"),
            ),

            // TweenAnimationBuilder(
            //   duration: const Duration(milliseconds: 800),
            //   tween: Tween<Offset>(
            //     begin: const Offset(0, 0.5),
            //     end: const Offset(0, 0),
            //   ),
            //   curve: Curves.easeOut,
            //   builder: (context, Offset offset, child) {
            //     return Transform.translate(offset: offset, child: child);
            //   },
            //   child:

            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     ElevatedButton(
            //       onPressed: () {
            //         Navigator.pop(context);
            //       },
            //       style: ElevatedButton.styleFrom(
            //         padding: const EdgeInsets.symmetric(
            //             horizontal: 24, vertical: 16),
            //         backgroundColor: Colors.blueAccent,
            //       ),
            //       child: const Text(
            //         'Back',
            //         style: TextStyle(color: Colors.white), // White text
            //       ),
            //     ),
            //     ElevatedButton(
            //       onPressed: () {},
            //       style: ElevatedButton.styleFrom(
            //         padding: const EdgeInsets.symmetric(
            //             horizontal: 24, vertical: 16),
            //         backgroundColor: Colors.blueAccent,
            //       ),
            //       child: const Text(
            //         'Next',
            //         style: TextStyle(color: Colors.white), // White text
            //       ),
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }
}
