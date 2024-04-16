class Item {
  String? id;
  String name;
  String userId;
  String? groupId;
  int price;
  double remainingQuantity;

  Item({
    this.id = '',
    required this.name,
    required this.userId,
    required this.price,
    this.remainingQuantity = 1,
  });
}

class RegisteredItems {
  String registeredDate;
  List<Item> items;

  RegisteredItems({required this.registeredDate, required this.items});
}
