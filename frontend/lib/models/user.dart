enum UserType { normal, admin }

class User {
  final String uuid;
  final String? username;
  final String? email;
  final String? phone;
  final String password;
  final String fullname;
  final bool banned;
  final List<String> followerIDs;
  final List<String> followingIDs;
  final UserType userType;

  User({
    required this.uuid,
    this.username,
    this.email,
    this.phone,
    required this.password,
    this.fullname = '',
    this.banned = false,
    this.followerIDs = const [],
    this.followingIDs = const [],
    required this.userType,
  });
}
