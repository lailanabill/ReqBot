import 'package:flutter/foundation.dart';

class DataProvider with ChangeNotifier {
  String _Summary = "";
  String _Transcript = "";
  String _Requirements = "";
  List<Map<String, dynamic>> _DetailedRequirements = [];

  String get summary => _Summary;
  String get transcript => _Transcript;
  String get requirements => _Requirements;
  List<Map<String, dynamic>> get detailedRequirements => _DetailedRequirements;

  void setSummary(String newSummary) {
    _Summary = newSummary;
    notifyListeners();
  }

  void setTranscript(String newTranscript) {
    _Transcript = newTranscript;
    notifyListeners();
  }

  void setRequirements(String newRequirements) {
    _Requirements = newRequirements;
    notifyListeners();
  }

  void setDetailedRequirements(
      List<Map<String, dynamic>> newDetailedRequirement) {
    _DetailedRequirements = newDetailedRequirement;
    notifyListeners();
  }
}
