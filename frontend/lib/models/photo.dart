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
  final bool commentsAllowed;

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
    this.commentsAllowed = true,
  });

  Photo copyWith({
    String? uuid,
    String? ownerID,
    String? path,
    String? name,
    List<String>? categoryList,
    String? captionText,
    DateTime? photoAge,
    List<String>? likeIDs,
    List<String>? commentIDs,
    bool? isPublic,
    bool? commentsAllowed,
  }) {
    return Photo(
      uuid: uuid ?? this.uuid,
      ownerID: ownerID ?? this.ownerID,
      path: path ?? this.path,
      name: name ?? this.name,
      categoryList: categoryList ?? this.categoryList,
      captionText: captionText ?? this.captionText,
      photoAge: photoAge ?? this.photoAge,
      likeIDs: likeIDs ?? this.likeIDs,
      commentIDs: commentIDs ?? this.commentIDs,
      isPublic: isPublic ?? this.isPublic,
      commentsAllowed: commentsAllowed ?? this.commentsAllowed,
    );
  }
}
