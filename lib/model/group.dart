class Group {
  String id;
  String name;
  String code;
  String owner;

  Group({this.id = '', required this.name, required this.code, required this.owner});
}

class Member {
  String name;
  String? imagePath;
  bool isOwner;

  Member({
    required this.name,
    this.imagePath,
    required this.isOwner
  });
}