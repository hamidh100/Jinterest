import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/user_service.dart';
import '../exceptions/exceptions.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoggedIn = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;
  String? get errorMessage => _errorMessage;

  Future<bool> signup({
    required String identifier,
    required String password,
    required String fullname,
  }) async {
    try {
      _errorMessage = null;

      User tempUser = User(
        uuid: DateTime.now().millisecondsSinceEpoch.toString(),
        email: identifier.contains('@') ? identifier : null,
        phone: identifier.contains('@') ? null : identifier,
        username: null,
        password: password,
        fullname: fullname,
      );

      User newUser = UserService.signup(tempUser);
      _currentUser = newUser;
      _isLoggedIn = true;

      notifyListeners();
      return true;
    } on JinterestException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Unexpected error: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> login({
    required String identifier,
    required String password,
  }) async {
    try {
      _errorMessage = null;

      User user = UserService.login(identifier, password);
      _currentUser = user;
      _isLoggedIn = true;

      notifyListeners();
      return true;
    } on JinterestException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Unexpected error: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    _isLoggedIn = false;
    _errorMessage = null;
    notifyListeners();
  }

  void updateCurrentUser(User updatedUser) {
    _currentUser = updatedUser;
    notifyListeners();
  }
}
