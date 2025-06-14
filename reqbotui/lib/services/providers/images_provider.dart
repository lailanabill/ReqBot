import 'package:flutter/foundation.dart';

class ImageDataProvider with ChangeNotifier {
  String _Image = "";
  String _Puml = "";
  // String _Requirements = "";

  String get summary => _Image;
  String get transcript => _Puml;
  // String get requirements => _Requirements;

  void setImagePath(String newImagePath) {
    _Image = newImagePath;
    notifyListeners();
  }

  void setPumlCode(String newPumlCode) {
    _Puml = newPumlCode;
    notifyListeners();
  }

  // void setRequirements(String newRequirements) {
  //   _Requirements = newRequirements;
  //   notifyListeners();
  // }
}
