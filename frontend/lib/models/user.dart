class User {
  final String uuid;
  final String? username;
  final String? email;
  final String? phone;
  final String password;
  final String fullname;
  final bool banned;

  User({
    required this.uuid,
    this.username,
    this.email,
    this.phone,
    required this.password,
    this.fullname = '',
    this.banned = false,
  });
}
