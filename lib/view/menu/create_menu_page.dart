import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foodcost/component/primary_button.dart';
import 'package:foodcost/model/food.dart';
import 'package:foodcost/model/menu.dart';
import 'package:foodcost/utils/authentication.dart';
import 'package:foodcost/utils/firestore/menus.dart';
import 'package:foodcost/utils/firestore/users.dart';
import 'package:foodcost/utils/functionUtils.dart';
import 'package:foodcost/utils/widget_utils.dart';
import 'package:intl/intl.dart';

class CreateMenuPage extends StatefulWidget {
  final DateTime? selectedDay;
  final Menu? selectedMenu;

  const CreateMenuPage({super.key, this.selectedDay, this.selectedMenu});

  @override
  State<CreateMenuPage> createState() => _CreateMenuPageState();
}

class _CreateMenuPageState extends State<CreateMenuPage> {
  // menu
  TextEditingController menuController = TextEditingController();
  File? image;
  bool isImageEdit = false;
  Menu? selectedMenu;
  String menuId = '';

  // food
  List<Map<String, TextEditingController>> foodControllers = [];
  int allPrice = 0;
  bool _isLoading = false;
  final List<Count> _costCounts = [];

  final List<Count> menuItemValues = [
    Count(name: '全部', count: 1.0),
    Count(name: '3/4', count: 0.75),
    Count(name: '2/3', count: 0.6),
    Count(name: '1/2', count: 0.5),
    Count(name: '1/3', count: 0.3),
    Count(name: '1/4', count: 0.25),
    Count(name: '1/5', count: 0.2),
    Count(name: '1/6', count: 0.17),
    Count(name: '1/8', count: 0.125),
    Count(name: '1/10', count: 0.01)
  ];

  late DateTime _selectedDay;

  final formatter = NumberFormat('#,###');
  final dateFormatter = DateFormat('yyyy年 M月 d日');

  ImageProvider? getImage() {
    if (image == null) {
      if (widget.selectedMenu != null) {
        if (widget.selectedMenu!.imagePath != null) {
          return NetworkImage(widget.selectedMenu!.imagePath!);
        } else {
          return null;
        }
      } else {
        return null;
      }
    } else {
      return FileImage(image!);
    }
  }

  @override
  void initState() {
    super.initState();
    final menu = widget.selectedMenu;
    if (menu != null) {
      menuId = menu.id;
      selectedMenu = menu;
      menuController.text = menu.name;
      menu.foods.asMap().forEach((int index, Food food) {
        foodControllers.add({
          'name': TextEditingController(text: food.name),
          'unitPrice': TextEditingController(text: food.unitPrice.toString()),
          'costCount': TextEditingController(text: food.costCount.toString()),
          'price': TextEditingController(text: food.price.toString()),
        });
        // foodControllers[index]['name']!.text = food.name;
        // foodControllers[index]['unitPrice']!.text = food.unitPrice.toString();
        // foodControllers[index]['costCount']!.text = food.costCount.toString();
        // foodControllers[index]['price']!.text = food.price.toString();
        allPrice += food.price;
        final Count count = menuItemValues.firstWhere((Count value) => value.count == double.parse(food.costCount));
        _costCounts.add(count);

        // _costCount = food.costCount;
      });
    } else {
      foodControllers.add({
        'name': TextEditingController(),
        'unitPrice': TextEditingController(),
        'costCount': TextEditingController(),
        'price': TextEditingController(),
      });
    }
    if (widget.selectedDay != null) {
      _selectedDay = widget.selectedDay!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomSpace = MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(
          'メニュー登録',
        ),
        elevation: 1,
        actions: [
          PrimaryButton(
              onPressed: () async {
                // menuにfoodをネストする
                List<Food> newFoods = [];
                for (var food in foodControllers) {
                  if (food['name']!.text.isNotEmpty &&
                      food['unitPrice']!.text.isNotEmpty &&
                      food['costCount']!.text.isNotEmpty &&
                      food['price']!.text.isNotEmpty) {
                    Food newFood = Food(
                      name: food['name']!.text,
                      unitPrice: int.parse(food['unitPrice']!.text),
                      costCount: food['costCount']!.text,
                      price: int.parse(food['price']!.text),
                    );
                    newFoods.add(newFood);
                  }
                }
                if (menuController.text.isNotEmpty && newFoods.isNotEmpty) {
                  setState(() {
                    _isLoading = true;
                  });
                  Menu newMenu = Menu(
                      id: menuId,
                      name: menuController.text,
                      userId: Authentication.myAccount!.id,
                      groupId: Authentication.myAccount!.groupId,
                      totalAmount: allPrice,
                      createdTime: Timestamp.fromDate(_selectedDay),
                      imagePath: selectedMenu?.imagePath,
                      foods: newFoods);
                  bool result = false;
                  if (selectedMenu != null) {
                    // TODO:foodの変更をチェック
                    if (selectedMenu!.name != menuController.text || isImageEdit == true) {
                      if (image != null || isImageEdit == true) {
                        var result = await FunctionUtils.uploadImage(menuId, image!);
                        newMenu.imagePath = result;
                      }
                      result = await MenuFirestore.updateMenu(newMenu);
                    }
                  } else {
                    result = await MenuFirestore.addMenu(newMenu, image);
                  }
                  if (result == true) {
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('登録に失敗しました。')));
                  }
                  setState(() {
                    _isLoading = false;
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('メニューと1つ以上の食材を登録してください。')));
                  null;
                }
              },
              childText: '保存')
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: bottomSpace > 0 ? bottomSpace : 50),
              child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                SizedBox(
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        dateFormatter.format(_selectedDay).toString(),
                        style: const TextStyle(fontSize: 18),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setImage(String path) {
                                  setState(() {
                                    image = File(path);
                                  });
                                }

                                WidgetUtils.selectPictureModalBottomSheet(context, setImage);
                              },
                              child: CircleAvatar(
                                foregroundImage: getImage(),
                                radius: 40,
                                child: const Icon(
                                  Icons.add_a_photo_outlined,
                                  size: 30,
                                ),
                              ),
                            ),
                            // const SizedBox(width: 10.0,),
                            SizedBox(
                              width: 220,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextField(
                                    keyboardType: TextInputType.text,
                                    controller: menuController,
                                    decoration: const InputDecoration(hintText: 'メニュー名'),
                                  ),
                                  const SizedBox(height: 10,),
                                  if (selectedMenu != null)
                                  StreamBuilder<DocumentSnapshot>(
                                    stream: UserFirestore.users.doc(selectedMenu!.userId).snapshots(),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
                                        return userInfo(data, '作成者');
                                      } else {
                                        return const SizedBox();
                                      }
                                    }
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Container(
                          alignment: Alignment.center,
                          width: double.infinity,
                          decoration:
                              const BoxDecoration(border: Border(top: BorderSide(color: Colors.orange, width: 3))),
                          // child: const Text(
                          //   '食材',
                          //   style: TextStyle(fontWeight: FontWeight.bold),
                          // ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 20, right: 25.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Text('合計金額', style: TextStyle(fontSize: 16),),
                            const SizedBox(
                              width: 20,
                            ),
                            Text(
                              formatter.format(allPrice).toString(),
                              style: const TextStyle(fontSize: 22),
                            ),
                            const Text('円', style: TextStyle(fontSize: 16),)
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      const SizedBox(width: 50,),
                      header('材料名', 110),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: header('金額', 70),
                      ),
                      header('使った量', 90)
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: foodControllers.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            IconButton(
                                onPressed: () {
                                  setState(() {
                                    var price = foodControllers[index]['price'];
                                    if (price != null && price.text.isNotEmpty) {
                                      allPrice -= int.parse(price.text);
                                    }
                                  });
                                  foodControllers.removeAt(index);
                                },
                                icon: const Icon(Icons.remove_circle_outline_outlined)),
                            SizedBox(
                              width: 110,
                              child: TextField(
                                controller: foodControllers[index]['name'],
                                decoration: const InputDecoration(hintText: '名前'),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20.0),
                              child: SizedBox(
                                width: 70,
                                child: TextField(
                                  controller: foodControllers[index]['unitPrice'],
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(hintText: '金額', suffix: Text('円')),
                                  onChanged: (String value) {
                                    setState(() {
                                      var price = foodControllers[index]['price'];
                                      if (value != '') {
                                        var costCount = foodControllers[index]['costCount'];
                                        if (costCount != null && costCount.text.isNotEmpty) {
                                          var sumPrice = (int.parse(value) * double.parse(costCount.text)).round();
                                          if (price != null) {
                                            if (price.text.isNotEmpty) {
                                              if (sumPrice != int.parse(price.text)) {
                                                allPrice += (sumPrice - int.parse(price.text));
                                              }
                                            } else {
                                              allPrice += sumPrice;
                                            }
                                            foodControllers[index]['price']!.text = sumPrice.toString();
                                            price.text = sumPrice.toString();
                                          }
                                        }
                                      } else {
                                        if (price != null && price.text.isNotEmpty) {
                                          allPrice -= int.parse(price.text);
                                        }
                                        price!.text = '0';
                                      }
                                    });
                                  },
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 90,
                              child: DropdownButtonFormField(
                                  decoration: const InputDecoration(hintText: '量'),
                                  value:
                                      foodControllers[index]['costCount']!.text.isNotEmpty ? _costCounts[index] : null,
                                  // value: _costCounts.length == foodControllers.length ? _costCounts[index] : ,
                                  items: menuItemValues.map((value) {
                                    return DropdownMenuItem(
                                      value: value,
                                      child: Text(value.name),
                                    );
                                  }).toList(),
                                  onChanged: (Count? value) {
                                    setState(() {
                                      if (value != null) {
                                        _costCounts.add(value);
                                        var costCount = foodControllers[index]['costCount'];
                                        if (costCount != null) {
                                          costCount.text = value.count.toString();
                                        }
                                        // foodControllers[index]['costCount']!.text = value.count.toString();
                                        var unitPrice = foodControllers[index]['unitPrice'];
                                        // sumPriceとfoodControllers[index]['price']が同じなら何もしない。
                                        // 違ったらallPriceからfoodControllers[index]['price']を引いて、sumPriceを追加
                                        if (unitPrice != null && unitPrice.text.isNotEmpty) {
                                          var sumPrice = (value.count * int.parse(unitPrice.text)).round();
                                          var price = foodControllers[index]['price'];
                                          if (price != null) {
                                            if (price.text.isNotEmpty) {
                                              if (sumPrice != int.parse(price.text)) {
                                                // すでに登録されている時は差額を登録
                                                allPrice += (sumPrice - int.parse(price.text));
                                              }
                                            } else {
                                              // priceに何も登録されてない場合
                                              allPrice += sumPrice;
                                            }
                                            foodControllers[index]['price']!.text = sumPrice.toString();
                                          }
                                          // 最後尾の名前が入力されてれば行を追加
                                          if (foodControllers.last['name']!.text.isNotEmpty &&
                                              costCount!.text.isNotEmpty) {
                                            foodControllers.add({
                                              'name': TextEditingController(),
                                              'unitPrice': TextEditingController(),
                                              'costCount': TextEditingController(),
                                              'price': TextEditingController(),
                                            });
                                          }
                                        }
                                      }
                                    });
                                  }),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                if (bottomSpace == 0)
                  SizedBox(
                    width: 300,
                    child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            foodControllers.add({
                              'name': TextEditingController(),
                              'unitPrice': TextEditingController(),
                              'costCount': TextEditingController(),
                              'price': TextEditingController(),
                            });
                          });
                        },
                        style: ElevatedButton.styleFrom(foregroundColor: Colors.black, backgroundColor: Colors.amber),
                        icon: const Icon(Icons.add),
                        label: const Text('食材を追加')),
                  ),
              ]),
            ),
            WidgetUtils.loadingStack(_isLoading)
          ],
        ),
      ),
    );
  }

  Widget userInfo (Map<String, dynamic> data, title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text('$title:', style: const TextStyle(fontSize: 12),),
        const SizedBox(width: 5,),
        CircleAvatar(
          radius: 10,
          foregroundImage: data['image_path'] != null ? FunctionUtils.getForeGroundImage(data['image_path']): null,
          child: const Icon(Icons.person, size: 10,),
        ),
        const SizedBox(width: 2,),
        Text('${data['name']} さん', style: const TextStyle(fontSize: 12),),
      ],
    );
  }

  Widget header(String title, double width) {
    return SizedBox(
        width: width,
        child: Align(
            alignment: Alignment.center,
            child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),))
    );
  }
}
