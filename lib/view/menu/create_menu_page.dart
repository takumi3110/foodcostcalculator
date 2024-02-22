import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:foodcost/model/food.dart';
import 'package:foodcost/model/menu.dart';
import 'package:foodcost/utils/authentication.dart';
import 'package:foodcost/utils/firestore/foods.dart';
import 'package:foodcost/utils/firestore/menus.dart';
import 'package:foodcost/utils/functionUtils.dart';
import 'package:foodcost/utils/widget_utils.dart';
import 'package:intl/intl.dart';

class CreateMenuPage extends StatefulWidget {
  final DateTime? selectedDay;
  const CreateMenuPage({super.key, this.selectedDay});

  @override
  State<CreateMenuPage> createState() => _CreateMenuPageState();
}

class _CreateMenuPageState extends State<CreateMenuPage> {
  // menu
  TextEditingController menuController = TextEditingController();
  TextEditingController totalPriceController = TextEditingController();
  File? image;

  // food
  List<Map<String, TextEditingController>> foodControllers = [
    {
      'name': TextEditingController(),
      'unitPrice': TextEditingController(),
      'costCount': TextEditingController(),
      'price': TextEditingController()
    }
  ];

  int allPrice = 0;
  bool _isLoading = false;
  final formatter = NumberFormat('#,###');
  final dateFormatter = DateFormat('yyyy-MM-dd');

  static List<Count> menuItemValues = [
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

  @override
  void initState() {
    super.initState();
    if (widget.selectedDay != null) {
      _selectedDay = widget.selectedDay!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(
          'メニュー登録',
        ),
        // title: Text(Timestamp.now().toDate().toString()),
        // backgroundColor: ,
        elevation: 1,
        actions: [
          ElevatedButton(
            onPressed: () async{
              if (menuController.text.isNotEmpty) {
                setState(() {
                  _isLoading = true;
                });
                Menu newMenu = Menu(
                  name: menuController.text,
                  userId: Authentication.myAccount!.id,
                  totalAmount: allPrice,
                  createdTime: Timestamp.fromDate(_selectedDay)
                );
                var result = await MenuFirestore.addMenu(newMenu);
                if (result != null) {
                //   imageあれば登録
                  if (image != null) {
                    String imagePath = await FunctionUtils.uploadImage(result, image!);
                    await MenuFirestore.updateMenuImage(result, imagePath);
                  }
                // food登録
                  List<Food> newFoods = [];
                  for (var food in foodControllers) {
                    if (
                        food['name']!.text.isNotEmpty
                        && food['unitPrice']!.text.isNotEmpty
                        && food['costCount']!.text.isNotEmpty
                        && food['price']!.text.isNotEmpty
                    ) {
                      Food newFood = Food(
                        name: food['name']!.text,
                        unitPrice: int.parse(food['unitPrice']!.text),
                        costCount: food['costCount']!.text,
                        price: int.parse(food['price']!.text),
                        menuId: result,
                      );
                      newFoods.add(newFood);
                    }
                  }
                  var foodResult = await FoodFirestore.addFood(newFoods);
                  if (foodResult == true) {
                    Navigator.pop(context);
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('登録に失敗しました。'))
                  );
                }
                setState(() {
                  _isLoading = false;
                });
              } else {
                null;
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text(
              '保存',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(mainAxisAlignment: MainAxisAlignment.start, children: [
            SingleChildScrollView(
              reverse: true,
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10,),
                    Text(dateFormatter.format(_selectedDay).toString(), style: const TextStyle(fontSize: 18),),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: () async{
                              var result = await FunctionUtils.getImageFromGallery();
                              if (result != null) {
                                setState(() {
                                  image = File(result.path);
                                });
                              }
                            },
                            child: CircleAvatar(
                              foregroundImage: image == null ? null: FileImage(image!),
                              radius: 40,
                              child: const Icon(Icons.add_a_photo_outlined),
                            ),
                          ),
                          // const SizedBox(width: 10.0,),
                          SizedBox(
                            width: 220,
                            child: Column(
                              children: [
                                TextField(
                                  controller: menuController,
                                  decoration: const InputDecoration(hintText: 'メニュー名'),
                                ),
                                // TextField(
                                //   keyboardType: TextInputType.number,
                                //   inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                //   decoration: const InputDecoration(hintText: '日付'),
                                // )

                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      width: double.infinity,
                      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.orange, width: 3))),
                      child: const Text(
                        '食材',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Text('合計金額'),
                          const SizedBox(
                            width: 20,
                          ),
                          Text(
                            formatter.format(allPrice).toString(),
                            style: const TextStyle(fontSize: 18),
                          ),
                          const Text('円')
                        ],
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.5,
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
                                      // decoration: const InputDecoration(labelText: '使った量', ),
                                      decoration: const InputDecoration(hintText: '量'),
                                      // value: _selected,
                                      items: menuItemValues.map((value) {
                                        return DropdownMenuItem(
                                          value: value,
                                          child: Text(value.name),
                                        );
                                      }).toList(),
                                      onChanged: (Count? value) {
                                        setState(() {
                                          if (value != null) {
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
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10,),
            ElevatedButton.icon(
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
                style: ElevatedButton.styleFrom(foregroundColor: Colors.black, backgroundColor: Colors.yellow),
                icon: const Icon(Icons.add),
                label: const Text('追加')),
            const SizedBox(
              width: 10,
            ),
          ]
        ),
            WidgetUtils.loadingStack(_isLoading)
          ],
        ),
      ),
    );
  }
}
