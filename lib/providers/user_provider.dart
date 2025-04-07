import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  Map<String, dynamic>? _user;

  Map<String, dynamic>? get user => _user;

  void setUser(Map<String, dynamic> userData) {
    _user = userData;
    notifyListeners();
  }
  void setUserImage(String imageUrl) {
    if (_user != null) {
      _user!["image"] = imageUrl;
      notifyListeners();
    }
  }
  void clearUser() {
    _user = null;
    notifyListeners();
  }
}
