class Food {
  // String id;
  // String menuId;
  String name;
  int unitPrice;
  String costCount;
  int price;

  Food({
    // this.id = '',
    // this.menuId = '',
    required this.name,
    this.unitPrice = 0,
    required this.costCount,
    this.price = 0
  });
}

class Count {
  String name;
  double count;

  Count({this.name = '', this.count = 0.0});
}
