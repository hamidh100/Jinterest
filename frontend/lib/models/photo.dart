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
  final int width;
  final int height;

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
    this.width = 1,
    this.height = 1,
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
    int? width,
    int? height,
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
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }

  double get aspectRatio {
    if (width <= 0 || height <= 0) {
      return 1.0;
    }
    return width / height;
  }
}
