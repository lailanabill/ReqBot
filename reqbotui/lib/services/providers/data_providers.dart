import 'package:flutter/foundation.dart';

class DataProvider with ChangeNotifier {
  String _Summary = "";
  String _Transcript = "";
  String _Requirements = "";

  String get summary => _Summary;
  String get transcript => _Transcript;
  String get requirements => _Requirements;

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
}
