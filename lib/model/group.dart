class Group {
  String? id;
  String name;
  String code;

  Group({this.id, required this.name, required this.code});
}

class Member {
  String id;
  String name;
  String? imagePath;
  bool isOwner;

  Member({
    this.id ='',
    required this.name,
    this.imagePath,
    required this.isOwner
  });
}