import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:archive/archive.dart';
import 'package:universal_html/html.dart' as html;
import 'package:url_launcher/url_launcher.dart';
import 'package:reqbot/services/providers/userProvider.dart';
import 'dart:convert';

class SRSScreen extends StatefulWidget {
  const SRSScreen({super.key});

  @override
  _SRSScreenState createState() => _SRSScreenState();
}

class _SRSScreenState extends State<SRSScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  bool _isLoading = false;
  String _statusMessage = '';
  List<String> _includedImages = []; // Track included images

  // List of diagram types to include
  final List<String> _diagramTypes = [
    'class',
    'context',
    'database',
    'sequence',
    'usecase'
  ];

}