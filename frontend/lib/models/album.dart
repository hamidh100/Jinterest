class Album {
  final String uuid;
  final String ownerID;
  final List<String> photoIDs;
  final DateTime albumAge;

  Album({
    required this.uuid,
    required this.ownerID,
    this.photoIDs = const [],
    required this.albumAge,
  });
}
