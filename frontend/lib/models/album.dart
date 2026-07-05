class Album {
  final String uuid;
  final String ownerID;
  final String name;
  final String? description;
  final List<String> photoIDs;
  final DateTime albumAge;
  final bool isPublic;

  Album({
    required this.uuid,
    required this.ownerID,
    required this.name,
    this.description,
    this.photoIDs = const [],
    required this.albumAge,
    this.isPublic = false,
  });

  Album copyWith({
    String? uuid,
    String? ownerID,
    String? name,
    String? description,
    List<String>? photoIDs,
    DateTime? albumAge,
    bool? isPublic,
  }) {
    return Album(
      uuid: uuid ?? this.uuid,
      ownerID: ownerID ?? this.ownerID,
      name: name ?? this.name,
      description: description ?? this.description,
      photoIDs: photoIDs ?? this.photoIDs,
      albumAge: albumAge ?? this.albumAge,
      isPublic: isPublic ?? this.isPublic,
    );
  }
}
