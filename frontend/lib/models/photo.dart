class Photo {
  final String uuid;
  final String ownerID;
  final String path;
  final String name;
  final List<String> categoryList;
  final String? captionText;
  final DateTime photoAge;
  final List<String> likeIDs;
  final List<String> commentIDs;
  final bool isPublic;

  Photo({
    required this.uuid,
    required this.ownerID,
    required this.path,
    required this.name,
    this.categoryList = const [],
    this.captionText,
    required this.photoAge,
    this.likeIDs = const [],
    this.commentIDs = const [],
    this.isPublic = false,
  });
}
