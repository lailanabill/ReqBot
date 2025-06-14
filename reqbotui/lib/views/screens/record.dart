import 'dart:html' as html;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reqbot/services/providers/data_providers.dart';
import 'package:reqbot/views/screens/waiting.dart';
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/providers/userProvider.dart';
import 'package:reqbot/views/screens/upload_confirmation.dart';
import '../widgets/dark_mode_toggle.dart';

class Record extends StatefulWidget {
  const Record({super.key});

  @override
  _RecordState createState() => _RecordState();
}

class _RecordState extends State<Record> with SingleTickerProviderStateMixin {
  String _transcription = '';
  String req_sumURI =
      "https://main-server-last-1016128810332.us-central1.run.app/reqsneww/";
  String sumURI =
      "https://main-server-last-1016128810332.us-central1.run.app/summarize/";
  String diagramsURI =
      "https://main-server-last-1016128810332.us-central1.run.app/diagrams/";
  bool _uploaded = false;
  bool _isLoading = false;
  int? _selectedMeetingIndex;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    // _animationController.dispose();
    super.dispose();
  }

  void SaveToDb(String Column, int Pid, int AnalyzerId, String Data) async {
    await Supabase.instance.client
        .from('projects')
        .update({Column: Data})
        .eq('id', Pid)
        .eq('analyzer_id', AnalyzerId)
        .select();
  }

  void _updateTranscription(List<dynamic> transcription) {
    setState(() {
      _transcription = transcription
          .map((item) => "${item['speaker']}: ${item['text']}")
          .join("\n");
      context.read<DataProvider>().setTranscript(_transcription);

      SaveToDb(
          'transcription',
          context.read<UserDataProvider>().ProjectId,
          context.read<UserDataProvider>().AnalyzerID,
          context.read<DataProvider>().transcript);

      _isLoading = false;
      _uploaded = true;

      // Navigate to confirmation screen after successful upload
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => UploadConfirmationScreen()),
      );
    });
  }

  Future<void> _handleUploadAudio() async {
    setState(() {
      _isLoading = true;
    });
    html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'audio/*';
    uploadInput.click();

    uploadInput.onChange.listen((e) {
      final file = uploadInput.files?.first;
      if (file != null) {
        final reader = html.FileReader();
        reader.readAsArrayBuffer(file);
        reader.onLoadEnd.listen((e) async {
          final bytes = reader.result as List<int>;

          var uri = Uri.parse(
              'https://main-server-last-1016128810332.us-central1.run.app/whisper/');
          var request = http.MultipartRequest('POST', uri);
          request.files.add(http.MultipartFile.fromBytes(
            'file',
            bytes,
            filename: file.name,
            contentType: MediaType('audio', 'wav'),
          ));

          var response = await request.send();
          var responseData = await http.Response.fromStream(response);

          if (responseData.statusCode == 200) {
            var transcription = jsonDecode(responseData.body)['transcription'];
            // print("Transcription do we even get a trans");
            _updateTranscription(transcription);
            // print("Transcription from update: ${_transcription}");
            // print("Transcription source update: ${transcription}");
            _getTransciptSummary(_transcription);
            print("Upload successful");
          } else {
            setState(() {
              _isLoading = false;
            });
            _showErrorSnackBar("Upload failed: ${responseData.statusCode}");
            print("Upload failed: ${responseData.statusCode}");
            print("Error body: ${responseData.body}");
          }
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _Diagrams(String Trans) async {
    var DiagramsURI = Uri.parse(diagramsURI);

    final diagramsBody = jsonEncode({
      'transcript': Trans,
      'pid': context.read<UserDataProvider>().ProjectId
    });
    var DiagramsRequest = await http.post(DiagramsURI, body: diagramsBody);
    if (DiagramsRequest.statusCode == 200) {
      context.read<UserDataProvider>().setClickability(true);
    } else {
      print("Server error: ${DiagramsRequest.statusCode}");
    }
  }

  Future<void> _getTransciptSummary(String WhisperTranscript) async {
    var SumURI = Uri.parse(sumURI);
    final body = jsonEncode({
      "text": WhisperTranscript,
    });
    try {
      var SumRequest = await http.post(SumURI, body: body);
      if (SumRequest.statusCode == 200) {
        final responseData = jsonDecode(SumRequest.body);
        context.read<DataProvider>().setSummary(responseData['summary']);

        SaveToDb(
            'summary',
            context.read<UserDataProvider>().ProjectId,
            context.read<UserDataProvider>().AnalyzerID,
            context.read<DataProvider>().summary);

        _getRrequirements(WhisperTranscript, responseData['summary']);
      } else {
        print("Server error: ${SumRequest.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> _getRrequirements(
      String WhisperTranscript, String SummaryText) async {
    var ReqSumURI = Uri.parse(req_sumURI);
    final body = jsonEncode({
      "summ": SummaryText,
      "orig": WhisperTranscript,
    });
    try {
      var ReqSumRequest = await http.post(ReqSumURI, body: body);
      if (ReqSumRequest.statusCode == 200) {
        final responseData = jsonDecode(ReqSumRequest.body);
        context.read<DataProvider>().setRequirements(responseData['reqs']);
        SaveToDb(
            'status',
            context.read<UserDataProvider>().ProjectId,
            context.read<UserDataProvider>().AnalyzerID,
            context.read<DataProvider>().requirements);
        _Diagrams(WhisperTranscript);
      } else {
        print("Server error: ${ReqSumRequest.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  void _showTranscriptionDialog(String title) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: EdgeInsets.all(20),
            width: MediaQuery.of(context).size.width * 0.8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$title Transcription',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close, 
                        color: Theme.of(context).colorScheme.onSurfaceVariant
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                Divider(
                  thickness: 1,
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
                SizedBox(height: 10),
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.all(12),
                  child: SingleChildScrollView(
                    child: Text(
                      _transcription.isEmpty
                          ? 'No transcription available'
                          : _transcription,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        height: 1.5,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.primary,
                    ),
                    child: Text('Close', style: GoogleFonts.inter()),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        title: Column(
          children: [
            Text(
              'Meetings & Audio Records',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            Text(
              'Step 3 of 3',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.7),
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: CompactDarkModeToggle(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildHeaderSection(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildMeetingsGrid(),
            ),
          ),
          _buildFooterSection(),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select a Meeting',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Choose a meeting to upload its audio recording',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeetingsGrid() {
    return GridView.builder(
      padding: EdgeInsets.symmetric(vertical: 16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.1,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        List<Map<String, dynamic>> meetings = [
          {
            'title': 'Project Kickoff',
            'date': 'April 25, 2024',
            'status': 'Pending',
            'icon': Icons.bolt,
          },
          {
            'title': 'Design Review',
            'date': 'April 20, 2024',
            'status': 'Completed',
            'icon': Icons.palette,
            'showAudio': true,
          },
          {
            'title': 'Sprint Planning',
            'date': 'April 15, 2024',
            'status': 'In Progress',
            'icon': Icons.calendar_today,
          },
          {
            'title': 'Retrospective',
            'date': 'April 10, 2024',
            'status': 'Completed',
            'icon': Icons.assessment,
          },
        ];

        return _buildMeetingCard(
          meetings[index]['title'],
          meetings[index]['date'],
          meetings[index]['status'],
          icon: meetings[index]['icon'],
          showAudio: meetings[index]['showAudio'] ?? false,
          index: index,
        );
      },
    );
  }

  Widget _buildMeetingCard(String title, String date, String status,
      {IconData icon = Icons.meeting_room,
      bool showAudio = false,
      int index = 0}) {
    Color statusColor;
    switch (status) {
      case 'Completed':
        statusColor = Colors.green;
        break;
      case 'In Progress':
        statusColor = Colors.amber;
        break;
      default:
        statusColor = Theme.of(context).colorScheme.onSurfaceVariant;
    }

    bool isSelected = _selectedMeetingIndex == index;

    return GestureDetector(
      onTapDown: (_) => _animationController.forward(),
      onTapUp: (_) {
        _animationController.reverse();
        setState(() {
          _selectedMeetingIndex = index;
        });
      },
      onTapCancel: () => _animationController.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected 
                  ? Theme.of(context).colorScheme.primary 
                  : Colors.transparent,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        icon,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            date,
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                if (showAudio)
                  Container(
                    height: 28,
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.play_arrow, 
                          color: Theme.of(context).colorScheme.primary, 
                          size: 18
                        ),
                        SizedBox(width: 4),
                        Expanded(
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 70,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 4),
                        Text(
                          "2:45",
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        status,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: statusColor,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.info_outline,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      size: 16,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooterSection() {
    return Container(
      padding: EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: _selectedMeetingIndex != null && !_uploaded
              ? _handleUploadAudio
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            disabledBackgroundColor: Theme.of(context).colorScheme.surfaceVariant,
            disabledForegroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _isLoading
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.onPrimary
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Processing...',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.cloud_upload_outlined,
                      color: Theme.of(context).colorScheme.onPrimary,
                      size: 24,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Upload Audio File',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
