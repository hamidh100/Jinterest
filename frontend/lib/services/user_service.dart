import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import '../exceptions/exceptions.dart';
import '../models/user.dart';
import 'api_client.dart';

class UserService {
  static final Map<String, Future<Uint8List?>> _profileImageCache = {};
  static final Map<String, Future<User?>> _userCache = {};
  static Future<User?> getUserById(String userId) async {
    final cached = _userCache[userId];

    if (cached != null) {
      return cached;
    }

    final future = _downloadUser(userId);

    _userCache[userId] = future;

    try {
      return await future;
    } catch (_) {
      _userCache.remove(userId);
      rethrow;
    }
  }

  static Future<User?> _downloadUser(String userId) async {
    try {
      final response = await ApiClient.instance.send(
        method: 'GET',
        route: '/users/$userId',
      );

      return _userFromResponse(response);
    } on ApiException catch (error) {
      if (error.statusCode != 404) rethrow;
      return null;
    }
  }

  static void clearUserCache(String userId) {
    _userCache.remove(userId);
  }

  static void clearAllUserCache() {
    _userCache.clear();
  }

  static Future<User> updateUser({
    required User user,
    required String username,
    required String fullname,
  }) async {
    final response = await ApiClient.instance.send(
      method: 'PUT',
      route: '/users/${user.uuid}',
      payload: {'username': username, 'fullname': fullname},
    );
    final updatedUser = _userFromResponse(response, password: user.password);
    _userCache[user.uuid] = Future.value(updatedUser);
    return updatedUser;
  }

  static Future<void> changePassword({
    required String userId,
    required String password,
  }) async {
    await ApiClient.instance.send(
      method: 'PUT',
      route: '/users/$userId',
      payload: {'password': password},
    );
  }

  static Future<void> deleteUser(String userId) async {
    await ApiClient.instance.send(method: 'DELETE', route: '/users/$userId');
  }

  static Future<void> follow({
    required String followerId,
    required String followedId,
  }) async {
    await ApiClient.instance.send(
      method: 'POST',
      route: '/users/$followedId/follow',
      payload: {'followerId': followerId},
    );
    clearUserCache(followerId);
    clearUserCache(followedId);
  }

  static Future<void> unfollow({
    required String followerId,
    required String followedId,
  }) async {
    await ApiClient.instance.send(
      method: 'DELETE',
      route: '/users/$followedId/follow',
      payload: {'followerId': followerId},
    );
    clearUserCache(followerId);
    clearUserCache(followedId);
  }

  static Future<void> updateProfileImage(String userId, File image) async {
    final bytes = await image.readAsBytes();
    await ApiClient.instance.send(
      method: 'PUT',
      route: '/users/$userId',
      payload: {
        'profileImageBase64': base64Encode(bytes),
        'profileImageFileName': image.path
            .replaceAll('\\', '/')
            .split('/')
            .last,
      },
    );
    clearProfileImageCache(userId);
    clearUserCache(userId);
  }

  static Future<Uint8List?> getProfileImage(String userId) async {
    final cached = _profileImageCache[userId];

    if (cached != null) {
      return cached;
    }

    final future = _downloadProfileImage(userId);

    _profileImageCache[userId] = future;

    try {
      return await future;
    } catch (_) {
      _profileImageCache.remove(userId);
      rethrow;
    }
  }

  static Future<Uint8List?> _downloadProfileImage(String userId) async {
    try {
      final response = await ApiClient.instance.send(
        method: 'GET',
        route: '/users/$userId/image',
      );

      final payload = response['payload'];

      if (payload is! Map<String, dynamic> ||
          payload['imageBase64'] is! String) {
        return null;
      }

      return base64Decode(payload['imageBase64'] as String);
    } on ApiException catch (error) {
      if (error.statusCode == 404) {
        return null;
      }

      rethrow;
    }
  }

  static void clearProfileImageCache(String userId) {
    _profileImageCache.remove(userId);
  }

  static void clearAllProfileImageCache() {
    _profileImageCache.clear();
  }

  static User _userFromResponse(
    Map<String, dynamic> response, {
    String password = '',
  }) {
    final payload = response['payload'];
    if (payload is! Map<String, dynamic> ||
        payload['user'] is! Map<String, dynamic>) {
      throw StateError('Server returned an invalid user');
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
      password: password,
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
