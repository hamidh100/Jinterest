class Comment {
  final String uuid;
  final String photoID;
  final String userID;
  final String? username;
  final String text;
  final DateTime time;

  Comment({
    required this.uuid,
    required this.photoID,
    required this.userID,
    this.username,
    required this.text,
    required this.time,
  });
}
