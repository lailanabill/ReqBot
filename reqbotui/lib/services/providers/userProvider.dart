import 'package:flutter/foundation.dart';

class UserDataProvider with ChangeNotifier {
  int _AnalyzerId = 0;
  int _ProjectId = 0;
  int _SelectedProjectId = 0;
  String _username = "";
  bool clickable = false;
  int get AnalyzerID => _AnalyzerId;
  int get ProjectId => _ProjectId;
  int get SelectedProjectId => _SelectedProjectId;
  bool get Clickable => clickable;
  String get Username => _username;

  void setAnalyzerId(int AnalyzerId) {
    _AnalyzerId = AnalyzerId;
    notifyListeners();
  }

  void setProjectId(int ProjectId) {
    _ProjectId = ProjectId;
    notifyListeners();
  }

  void setSelectedProjectId(int SelectedProjectId) {
    _SelectedProjectId = SelectedProjectId;
    notifyListeners();
  }

  void setClickability(bool Click) {
    clickable = Click;
    notifyListeners();
  }

  void setUsername(String Username) {
    _username = Username;
    notifyListeners();
  }
}
