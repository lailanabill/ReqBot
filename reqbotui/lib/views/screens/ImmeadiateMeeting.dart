import 'dart:developer';
import 'package:provider/provider.dart';
import 'package:reqbot/controllers/email_db_helper.dart';
import 'package:reqbot/services/providers/userProvider.dart';
import 'package:reqbot/views/screens/meetingPage.dart';

// import 'email_db_helper.dart';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Meeting Page',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         brightness: Brightness.light,
//         scaffoldBackgroundColor: Colors.white,
//         appBarTheme: const AppBarTheme(
//           backgroundColor: Colors.transparent,
//           foregroundColor: Colors.black,
//           elevation: 0,
//         ),
//         textTheme: const TextTheme(
//           bodyMedium: TextStyle(color: Colors.black87),
//         ),
//       ),
//       home: const QuickMeeting(),
//     );
//   }
// }

class QuickMeeting extends StatefulWidget {
  const QuickMeeting({super.key});
  @override
  State<QuickMeeting> createState() => _QuickMeetingState();
}

class _QuickMeetingState extends State<QuickMeeting> {
  bool _permissionsGranted = false;
  final TextEditingController _emailController = TextEditingController();
  String lbl_text = "";
  final EmailDBHelper _dbHelper = EmailDBHelper();
  List<String> _savedEmails = [];
  String? _selectedEmail;
  String? name;

  @override
  void initState() {
    super.initState();
    _loadSavedEmails();
    name = context.read<UserDataProvider>().Username;
  }

  Future<void> _loadSavedEmails() async {
    final emails = await _dbHelper.getEmails();
    setState(() {
      _savedEmails = emails;
    });
  }

  Future<void> _saveEmail(String email) async {
    await _dbHelper.insertEmail(email);
    await _loadSavedEmails();
  }

  Future<void> _handlePermissionsAndNavigate() async {
    _permissionsGranted = await _getPermissions();
    if (_permissionsGranted && mounted) {
      Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (_) => MeetingPage(userName: name!),
        ),
      );
    }
  }

  Future<bool> _getPermissions() async {
    if (Platform.isIOS) return true;

    final List<Permission> permissions = [
      Permission.camera,
      Permission.microphone,
      Permission.bluetoothConnect,
    ];

    final Map<Permission, PermissionStatus> statuses =
        await permissions.request();

    return statuses.values.every((status) => status.isGranted);
  }

  Future<void> _sendEmails() async {
    try {
      var userEmail = 'saher2110197@miuegypt.edu.eg';
      var password = 'swdb tsum oycl jqfd';

      final message = Message()
        ..from = Address(userEmail, 'Video Conf Bot')
        ..subject = 'Meeting Invitation'
        ..text =
            'Hello, this is the meeting link: https://saher-videoconf-1119.app.100ms.live/meeting/ziz-xixa-cdo';

      List<String> emails =
          _emailController.text.split(',').map((e) => e.trim()).toList();

      // Save each email to database
      for (var email in emails) {
        await _saveEmail(email);
      }

      message.recipients.addAll(emails);

      final smtpServer = gmail(userEmail, password);

      await send(message, smtpServer);
      setState(() {
        lbl_text = 'Emails sent successfully!';
      });
    } catch (e) {
      print('Failed to send email: $e');
      setState(() {
        lbl_text = 'Failed to send email: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [
                      Colors.blue,
                      Color(0xFF4A148C), // Dark purple
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ).createShader(bounds),
                  child: const Text(
                    'GET STARTED',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _emailController,
                    style: const TextStyle(color: Colors.black87),
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: "Enter email(s) separated by comma",
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 24,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (_savedEmails.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: DropdownButton<String>(
                      value: _selectedEmail,
                      hint: Text(
                        'Select saved email',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      dropdownColor: Colors.white,
                      style: const TextStyle(color: Colors.black87),
                      isExpanded: true,
                      underline: const SizedBox(),
                      items: _savedEmails.map((String email) {
                        return DropdownMenuItem<String>(
                          value: email,
                          child: Text(email),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedEmail = newValue;
                          if (newValue != null) {
                            // Append the new email to existing text
                            String currentText = _emailController.text.trim();
                            if (currentText.isEmpty) {
                              _emailController.text = newValue;
                            } else {
                              // Check if the email is already in the list
                              List<String> emails = currentText
                                  .split(',')
                                  .map((e) => e.trim())
                                  .toList();
                              if (!emails.contains(newValue)) {
                                _emailController.text =
                                    '$currentText, $newValue';
                              }
                            }
                          }
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFF89CFF0), // Baby blue color
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                    ),
                    onPressed: _sendEmails,
                    child: const Text(
                      'Send Meeting Link',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Text(
                  lbl_text,
                  style: TextStyle(
                    color:
                        lbl_text.contains('Failed') ? Colors.red : Colors.green,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Colors.blue,
                        Color(0xFF4A148C), // Dark purple
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    onPressed: _handlePermissionsAndNavigate,
                    child: const Text(
                      'Join Meeting',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
