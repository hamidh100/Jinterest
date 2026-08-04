import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_client.dart';
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

      final response = await ApiClient.instance.send(
        method: 'POST',
        route: '/auth/signup',
        payload: {
          if (identifier.contains('@')) 'email': identifier else 'phone': identifier,
          'password': password,
          'fullname': fullname,
        },
      );
      _currentUser = _userFromResponse(response, password);
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

      final response = await ApiClient.instance.send(
        method: 'POST',
        route: '/auth/login',
        payload: {'identifier': identifier, 'password': password},
      );
      _currentUser = _userFromResponse(response, password);
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

  User _userFromResponse(Map<String, dynamic> response, String password) {
    final payload = response['payload'];
    if (payload is! Map<String, dynamic> || payload['user'] is! Map<String, dynamic>) {
      throw ApiException(statusCode: 500, message: 'Server returned an invalid user');
    }
    final user = payload['user'] as Map<String, dynamic>;
    return User(
      uuid: user['id']?.toString() ?? '',
      username: user['username']?.toString(),
      email: user['email']?.toString(),
      phone: user['phone']?.toString(),
      password: password,
      fullname: user['fullname']?.toString() ?? '',
    );
  }
}
