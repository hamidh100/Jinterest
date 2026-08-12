import 'package:flutter/material.dart';
import 'package:jinterest/services/biometric_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/api_client.dart';
import '../services/photo_service.dart';
import '../services/user_service.dart';
import '../exceptions/exceptions.dart';

class AuthProvider extends ChangeNotifier {
  static const _sessionUserIdKey = 'session_user_id';
  static const _sessionUsernameKey = 'session_username';
  static const _sessionEmailKey = 'session_email';
  static const _sessionPhoneKey = 'session_phone';
  static const _sessionFullnameKey = 'session_fullname';
  static const _sessionFollowerIdsKey = 'session_follower_ids';
  static const _sessionFollowingIdsKey = 'session_following_ids';
  static const _sessionUserTypeKey = 'session_user_type';
  static const _sessionTokenKey = 'session_token';

  String? _sessionToken;
  User? _currentUser;
  bool _isLoggedIn = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;
  String? get errorMessage => _errorMessage;
  bool get isAdmin => _currentUser?.userType == UserType.admin;
  String? get sessionToken => _sessionToken;

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
          if (identifier.contains('@'))
            'email': identifier
          else
            'phone': identifier,
          'password': password,
          'fullname': fullname,
        },
      );
      final payload = response['payload'];
      if (payload is! Map<String, dynamic>) {
        throw ApiException(
          statusCode: 500,
          message: 'Server returned an invalid login response',
        );
      }
      final sessionToken = response['payload']['sessionToken']?.toString();
      if (sessionToken == null || sessionToken.isEmpty) {
        throw ApiException(
          statusCode: 500,
          message: 'Server did not return a session token',
        );
      }
      _sessionToken = sessionToken;
      _currentUser = _userFromResponse(response, password);
      _isLoggedIn = true;
      await _saveSession();

      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
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
      final payload = response['payload'];
      if (payload is! Map<String, dynamic>) {
        throw ApiException(
          statusCode: 500,
          message: 'Server returned an invalid login response',
        );
      }
      final sessionToken = response['payload']['sessionToken']?.toString();
      if (sessionToken == null || sessionToken.isEmpty) {
        throw ApiException(
          statusCode: 500,
          message: 'Server did not return a session token',
        );
      }
      _sessionToken = sessionToken;
      _currentUser = _userFromResponse(response, password);
      _isLoggedIn = true;
      await _saveSession();

      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
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
    _sessionToken = null;
    PhotoService.clearAllPhotoImageCache();
    UserService.clearAllProfileImageCache();
    await _clearSession();
    notifyListeners();
  }

  Future<void> updateCurrentUser(User updatedUser) async {
    _currentUser = updatedUser;
    await _saveSession();
    notifyListeners();
  }

  Future<void> restoreSession() async {
    final preferences = await SharedPreferences.getInstance();
    final userId = preferences.getString(_sessionUserIdKey);
    final token = preferences.getString(_sessionTokenKey);

    if (userId == null || userId.isEmpty || token == null || token.isEmpty) {
      return;
    }

    final biometricEnabled = preferences.getBool('biometric_enabled') ?? false;

    if (biometricEnabled) {
      final ok = await BiometricService.authenticate();
      if (!ok) return;
    }

    _sessionToken = token;

    final userTypeText = preferences.getString(_sessionUserTypeKey);

    final userType = userTypeText == 'admin' ? UserType.admin : UserType.normal;

    _currentUser = User(
      uuid: userId,
      username: preferences.getString(_sessionUsernameKey),
      email: preferences.getString(_sessionEmailKey),
      phone: preferences.getString(_sessionPhoneKey),
      fullname: preferences.getString(_sessionFullnameKey) ?? '',
      followerIDs:
          preferences.getStringList(_sessionFollowerIdsKey) ?? const [],
      followingIDs:
          preferences.getStringList(_sessionFollowingIdsKey) ?? const [],
      userType: userType,
    );
    _isLoggedIn = true;
    notifyListeners();
  }

  Future<void> _saveSession() async {
    final user = _currentUser;
    final token = _sessionToken;
    if (user == null || token == null) return;

    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_sessionUserIdKey, user.uuid);
    await _setOptionalString(preferences, _sessionUsernameKey, user.username);
    await _setOptionalString(preferences, _sessionEmailKey, user.email);
    await _setOptionalString(preferences, _sessionPhoneKey, user.phone);
    await preferences.setString(_sessionFullnameKey, user.fullname);
    await preferences.setStringList(_sessionFollowerIdsKey, user.followerIDs);
    await preferences.setStringList(_sessionFollowingIdsKey, user.followingIDs);
    await preferences.setString(_sessionUserTypeKey, user.userType.name);
    await preferences.setString(_sessionTokenKey, token);
  }

  Future<void> _clearSession() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_sessionUserIdKey);
    await preferences.remove(_sessionUsernameKey);
    await preferences.remove(_sessionEmailKey);
    await preferences.remove(_sessionPhoneKey);
    await preferences.remove(_sessionFullnameKey);
    await preferences.remove(_sessionFollowerIdsKey);
    await preferences.remove(_sessionFollowingIdsKey);
    await preferences.remove(_sessionUserTypeKey);
    await preferences.remove(_sessionTokenKey);
  }

  Future<void> _setOptionalString(
    SharedPreferences preferences,
    String key,
    String? value,
  ) async {
    if (value == null) {
      await preferences.remove(key);
      return;
    }
    await preferences.setString(key, value);
  }

  User _userFromResponse(Map<String, dynamic> response, String password) {
    final payload = response['payload'];
    if (payload is! Map<String, dynamic> ||
        payload['user'] is! Map<String, dynamic>) {
      throw ApiException(
        statusCode: 500,
        message: 'Server returned an invalid user',
      );
    }
    final user = payload['user'] as Map<String, dynamic>;
    final userTypeText = user['userType']?.toString().toUpperCase();
    final userType = switch (userTypeText) {
      'ADMIN' => UserType.admin,
      _ => UserType.normal,
    };
    return User(
      uuid: user['id']?.toString() ?? '',
      username: user['username']?.toString(),
      email: user['email']?.toString(),
      phone: user['phone']?.toString(),
      fullname: user['fullname']?.toString() ?? '',
      followerIDs: (user['followerIds'] as List? ?? const [])
          .map((id) => id.toString())
          .toList(),
      followingIDs: (user['followingIds'] as List? ?? const [])
          .map((id) => id.toString())
          .toList(),
      userType: userType,
    );
  }
}
