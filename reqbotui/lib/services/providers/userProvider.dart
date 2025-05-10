import 'package:flutter/foundation.dart';

class UserDataProvider with ChangeNotifier {
  int _AnalyzerId = 0;
  int _ProjectId = 0;
  int _SelectedProjectId = 0;
  bool clickable = false;
  int get AnalyzerID => _AnalyzerId;
  int get ProjectId => _ProjectId;
  int get SelectedProjectId => _SelectedProjectId;
  bool get Clickable => clickable;

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
}
