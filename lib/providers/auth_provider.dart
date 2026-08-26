import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _currentUser;
  String _userRole = "";
  bool _isLoading = false;

  AuthProvider() {
    _currentUser = _authService.currentUser;
  }

  User? get currentUser => _currentUser;
  String get userRole => _userRole;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;

  Future<String?> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    final error = await _authService.loginUser(email: email, password: password);
    if (error == null && _authService.currentUser != null) {
      _currentUser = _authService.currentUser;
      _userRole = await _authService.getUserRole(_currentUser!.uid);
    }

    _isLoading = false;
    notifyListeners();
    return error;
  }

  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    _userRole = "";
    notifyListeners();
  }
}
