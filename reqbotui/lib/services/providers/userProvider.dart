import 'package:flutter/foundation.dart';

class UserDataProvider with ChangeNotifier {
  int _AnalyzerId = 0;
  int _ProjectId = 0;
  bool clickable = false;
  int get AnalyzerID => _AnalyzerId;
  int get ProjectId => _ProjectId;
  bool get Clickable => clickable;

  void setAnalyzerId(int AnalyzerId) {
    _AnalyzerId = AnalyzerId;
    notifyListeners();
  }

  void setProjectId(int ProjectId) {
    _ProjectId = ProjectId;
    notifyListeners();
  }

  void setClickability(bool Click) {
    clickable = Click;
    notifyListeners();
  }
}
