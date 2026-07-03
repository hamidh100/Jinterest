import 'package:flutter/material.dart';
import '../models/user.dart';
import '../utils/validators.dart';
import '../utils/helper.dart';
import '../exceptions/exceptions.dart';

class UserService {
  static final Map<String, User> _users = {};
  static final Map<String, String> _usersLowercase = {};
  static final Map<String, String> _emailToUserID = {};
  static final Map<String, String> _phoneToUserID = {};

  static final Map<String, Set<String>> _followingMap = {};
  static final Map<String, Set<String>> _followerMap = {};
  static final Map<String, Set<String>> _savedPhotosMap = {};
  static final Map<String, Set<String>> _savedAlbumsMap = {};

  static void follow(User? follower, User? followed) {
    if (follower == null || followed == null) return;
    if (follower.uuid == followed.uuid) return;
    if (isFollowing(follower, followed)) return;

    _followingMap.putIfAbsent(follower.uuid, () => {});
    _followerMap.putIfAbsent(followed.uuid, () => {});

    _followingMap[follower.uuid]!.add(followed.uuid);
    _followerMap[followed.uuid]!.add(follower.uuid);
  }

  static void unfollow(User? follower, User? followed) {
    if (follower == null || followed == null) return;
    if (follower.uuid == followed.uuid) return;
    if (!isFollowing(follower, followed)) return;

    _followingMap[follower.uuid]?.remove(followed.uuid);
    _followerMap[followed.uuid]?.remove(follower.uuid);
  }

  static bool isFollowing(User follower, User followed) {
    return _followingMap[follower.uuid]?.contains(followed.uuid) ?? false;
  }

  static int followersCount(User user) {
    return _followerMap[user.uuid]?.length ?? 0;
  }

  static int followingCount(User user) {
    return _followingMap[user.uuid]?.length ?? 0;
  }

  static void saveAlbum(User user, String albumUuid) {
    _savedAlbumsMap.putIfAbsent(user.uuid, () => {});
    _savedAlbumsMap[user.uuid]!.add(albumUuid);
  }

  static void savePhoto(User user, String photoUuid) {
    _savedPhotosMap.putIfAbsent(user.uuid, () => {});
    _savedPhotosMap[user.uuid]!.add(photoUuid);
  }

  static void checkUsername(User user) {
    checkUsernameString(user.username ?? '');
  }

  static void checkUsernameString(String username) {
    if (username.isEmpty || username.length < 3) {
      throw InvalidUsername(InvalidUsernameTypes.TOOSHORT);
    }
    if (username.length > 20) {
      throw InvalidUsername(InvalidUsernameTypes.TOOLONG);
    }
    if (!RegExp(Validators.USERNAME_PATTERN).hasMatch(username)) {
      throw InvalidUsername(InvalidUsernameTypes.PATTERNMISMATCH);
    }
  }

  static String? getEmailName(User? user) {
    if (user == null || user.email == null) return null;
    if (!RegExp(Validators.EMAIL_PATTERN).hasMatch(user.email!)) return null;
    return user.email!.split('@')[0];
  }

  static void checkPassword(User user) {
    String password = user.password;

    if (password.isEmpty || password.length < 8) {
      throw WeakPassword(WeakPasswordTypes.TOOSHORT);
    }

    String? emailName = getEmailName(user);
    if (emailName != null && password.contains(emailName)) {
      throw WeakPassword(WeakPasswordTypes.CONTAINSUSER);
    }
    if (user.username != null && password.contains(user.username!)) {
      throw WeakPassword(WeakPasswordTypes.CONTAINSUSER);
    }

    if (!RegExp(Validators.PASSWORD_PATTERN).hasMatch(password)) {
      throw WeakPassword(WeakPasswordTypes.PATTERNMISMATCH);
    }
  }

  static User signup(User user) {
    bool hasEmail = user.email != null && user.email!.isNotEmpty;
    bool hasPhone = user.phone != null && user.phone!.isNotEmpty;

    if (!hasEmail && !hasPhone) {
      throw InvalidSignupMethod();
    }
    if (hasEmail && hasPhone) {
      throw InvalidSignupMethod();
    }

    if (hasEmail && _emailToUserID.containsKey(user.email)) {
      throw UserAlreadyExists(user.email!);
    }
    if (hasPhone && _phoneToUserID.containsKey(user.phone)) {
      throw UserAlreadyExists(user.phone!);
    }

    checkPassword(user);

    String randomUsername = Helper.generateRandUniqUsername(
      _usersLowercase.keys.toSet(),
    );

    User newUser = User(
      uuid: user.uuid,
      email: user.email,
      phone: user.phone,
      username: randomUsername,
      password: user.password,
      fullname: user.fullname,
      banned: false,
    );

    _users[newUser.uuid] = newUser;
    _usersLowercase[Helper.toLower(randomUsername)] = newUser.uuid;
    if (newUser.email != null) _emailToUserID[newUser.email!] = newUser.uuid;
    if (newUser.phone != null) _phoneToUserID[newUser.phone!] = newUser.uuid;

    _followingMap[newUser.uuid] = {};
    _followerMap[newUser.uuid] = {};
    _savedPhotosMap[newUser.uuid] = {};
    _savedAlbumsMap[newUser.uuid] = {};

    return newUser;
  }

  static User login(String identifier, String password) {
    bool isEmail = identifier.contains('@');
    bool isPhone = !isEmail && Validators.validatePhone(identifier) == null;
    bool isUsername = !isEmail && !isPhone;

    int identifierCount =
        (isEmail ? 1 : 0) + (isPhone ? 1 : 0) + (isUsername ? 1 : 0);
    if (identifierCount != 1) {
      throw InvalidLoginMethod();
    }

    User? realUser;

    if (isEmail) {
      if (!_emailToUserID.containsKey(identifier)) {
        throw UserDoesNotExist(identifier);
      }
      realUser = _users[_emailToUserID[identifier]];
    } else if (isPhone) {
      if (!_phoneToUserID.containsKey(identifier)) {
        throw UserDoesNotExist(identifier);
      }
      realUser = _users[_phoneToUserID[identifier]];
    } else {
      String lowerUsername = Helper.toLower(identifier);
      if (!_usersLowercase.containsKey(lowerUsername)) {
        throw UserDoesNotExist(identifier);
      }
      realUser = _users[_usersLowercase[lowerUsername]];
    }

    if (realUser == null) {
      throw UserDoesNotExist(identifier);
    }

    if (realUser.banned) {
      throw UserBanned(identifier);
    }

    if (realUser.password != password) {
      throw IncorrectPassword();
    }

    return realUser;
  }

  static User changeUsername(User user, String newUsername) {
    String oldUsername = user.username ?? '';

    try {
      checkUsernameString(newUsername);

      User tempUser = User(
        uuid: user.uuid,
        email: user.email,
        phone: user.phone,
        username: newUsername,
        password: user.password,
        fullname: user.fullname,
        banned: user.banned,
      );
      checkPassword(tempUser);
    } catch (e) {
      rethrow;
    }

    String newUsernameLower = Helper.toLower(newUsername);
    String? existingUserID = _usersLowercase[newUsernameLower];
    if (existingUserID != null && existingUserID != user.uuid) {
      throw UserAlreadyExists(newUsername);
    }

    if (oldUsername.isNotEmpty) {
      _usersLowercase.remove(Helper.toLower(oldUsername));
    }
    _usersLowercase[newUsernameLower] = user.uuid;

    User updatedUser = User(
      uuid: user.uuid,
      email: user.email,
      phone: user.phone,
      username: newUsername,
      password: user.password,
      fullname: user.fullname,
      banned: user.banned,
    );

    _users[user.uuid] = updatedUser;

    return updatedUser;
  }

  static User changePassword(User user, String newPassword) {
    User tempUser = User(
      uuid: user.uuid,
      email: user.email,
      phone: user.phone,
      username: user.username,
      password: newPassword,
      fullname: user.fullname,
      banned: user.banned,
    );

    checkPassword(tempUser);

    User updatedUser = User(
      uuid: user.uuid,
      email: user.email,
      phone: user.phone,
      username: user.username,
      password: newPassword,
      fullname: user.fullname,
      banned: user.banned,
    );

    _users[user.uuid] = updatedUser;

    return updatedUser;
  }

  // ==================== Helper Methods ====================
  static User? getUserByEmail(String email) => _users[_emailToUserID[email]];
  static User? getUserByPhone(String phone) => _users[_phoneToUserID[phone]];
  static User? getUserByUsername(String username) =>
      _users[_usersLowercase[Helper.toLower(username)]];
  static User? getUserById(String uuid) => _users[uuid];

  static Set<String>? getFollowing(User user) => _followingMap[user.uuid];
  static Set<String>? getFollowers(User user) => _followerMap[user.uuid];
  static Set<String>? getSavedPhotos(User user) => _savedPhotosMap[user.uuid];
  static Set<String>? getSavedAlbums(User user) => _savedAlbumsMap[user.uuid];
}
