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

  User copyWith({
    String? uuid,
    String? username,
    String? email,
    String? phone,
    String? password,
    String? fullname,
    bool? banned,
    List<String>? followerIDs,
    List<String>? followingIDs,
    UserType? userType,
  }) {
    return User(
      uuid: uuid ?? this.uuid,
      username: username ?? this.username,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      password: password ?? this.password,
      fullname: fullname ?? this.fullname,
      banned: banned ?? this.banned,
      followerIDs: followerIDs ?? List<String>.from(this.followerIDs),
      followingIDs: followingIDs ?? List<String>.from(this.followingIDs),
      userType: userType ?? this.userType,
    );
  }
}
