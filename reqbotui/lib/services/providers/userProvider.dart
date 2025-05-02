import 'package:flutter/foundation.dart';

class UserDataProvider with ChangeNotifier {
  int _AnalyzerId = 0;
  bool clickable = false;
  int get AnalyzerID => _AnalyzerId;
  bool get Clickable => clickable;

  void setAnalyzerId(int AnalyzerId) {
    _AnalyzerId = AnalyzerId;
    notifyListeners();
  }

  void setClickability(bool Click) {
    clickable = Click;
    notifyListeners();
  }
}
