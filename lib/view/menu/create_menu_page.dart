import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foodcost/component/item_modal.dart';
import 'package:foodcost/model/food.dart';
import 'package:foodcost/model/menu.dart';
import 'package:foodcost/utils/firestore/users.dart';
import 'package:foodcost/utils/function_utils.dart';
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
  TextEditingController nameController = TextEditingController();
  TextEditingController unitPriceController = TextEditingController();
  TextEditingController costCountController = TextEditingController();
  TextEditingController priceController = TextEditingController(text: '0');
  double _currentSliderValue = 0;

  // List<Map<String, TextEditingController>> foodControllers = [];
  List<Map<String, String>> foods = [];
  int allPrice = 0;
  final bool _isLoading = false;
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

  void onPressAdd() {
    if (nameController.text.isNotEmpty && priceController.text.isNotEmpty) {
      setState(() {
        foods.add({
          'name': nameController.text,
          'unitPrice': unitPriceController.text,
          'costCount': costCountController.text,
          'price': priceController.text
        });
        allPrice += int.parse(priceController.text);
      });

      Navigator.pop(context);
      nameController.clear();
      unitPriceController.clear();
      costCountController.clear();
      priceController.clear();
    }
  }

  void onChangeSliderValue(double value) {
    setState(() {
      _currentSliderValue = value;
    });
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
        foods.add({
          'name': food.name,
          'unitPrice': food.unitPrice.toString(),
          'costCount': food.costCount.toString(),
          'price': food.price.toString(),
        });
        allPrice += food.price;
        final Count count = menuItemValues.firstWhere(
            (Count value) => value.count == double.parse(food.costCount));
        _costCounts.add(count);
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
        // backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text(
            'メニュー',
            style: TextStyle(fontFamily: 'AmeChan', fontSize: 28),
          ),
          elevation: 1,
        ),
        body: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding:
                    EdgeInsets.only(bottom: bottomSpace > 0 ? bottomSpace : 50),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
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
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 10.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      setImage(String path) {
                                        setState(() {
                                          image = File(path);
                                        });
                                      }

                                      WidgetUtils.selectPictureModalBottomSheet(
                                          context, setImage);
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
                                  SizedBox(
                                    width: 220,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        TextField(
                                          keyboardType: TextInputType.text,
                                          controller: menuController,
                                          decoration: const InputDecoration(
                                              hintText: 'メニュー名'),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        if (selectedMenu != null)
                                          StreamBuilder<DocumentSnapshot>(
                                              stream: UserFirestore.users
                                                  .doc(selectedMenu!.userId)
                                                  .snapshots(),
                                              builder: (context, snapshot) {
                                                if (snapshot.hasData) {
                                                  Map<String, dynamic> data =
                                                      snapshot.data!.data()
                                                          as Map<String,
                                                              dynamic>;
                                                  return userInfo(data, '作成者');
                                                } else {
                                                  return const SizedBox();
                                                }
                                              })
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 10.0),
                              child: Container(
                                alignment: Alignment.center,
                                width: double.infinity,
                                decoration: const BoxDecoration(
                                    border: Border(
                                        top: BorderSide(
                                            color: Colors.orange, width: 3))),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  bottom: 20, right: 25.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  const Text(
                                    '合計金額',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  Text(
                                    formatter.format(allPrice).toString(),
                                    style: const TextStyle(fontSize: 22),
                                  ),
                                  const Text(
                                    '円',
                                    style: TextStyle(fontSize: 16),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // if (foodControllers.isNotEmpty)
                      if (foods.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // const SizedBox(width: 50,),
                              header('材料名', 130),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15.0),
                                child: header('金額', 90),
                              ),
                              header('使った量', 70)
                            ],
                          ),
                        ),
                      if (bottomSpace == 0)
                        Expanded(
                          child: ListView.builder(
                            shrinkWrap: true,
                            // itemCount: foodControllers.length,
                            itemCount: foods.length,
                            itemBuilder: (context, index) {
                              return Dismissible(
                                key: UniqueKey(),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: ListTile(
                                    title: Text(foods[index]['name']!),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      if (bottomSpace == 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orangeAccent,
                                // foregroundColor: Colors.white
                              ),
                              onPressed: () {},
                              icon: const Icon(
                                Icons.add,
                              ),
                              label: const Text('登録する')),
                        ),
                    ]),
              ),
              WidgetUtils.loadingStack(_isLoading)
            ],
          ),
        ),
        floatingActionButton: ItemModal(
          nameController: nameController,
          priceController: priceController,
          unitPriceController: unitPriceController,
          costCountController: costCountController,
          sliderValue: _currentSliderValue,
          onPressAdd: onPressAdd,
          onChangeSliderValue: onChangeSliderValue,
        ));
  }

  Widget userInfo(Map<String, dynamic> data, title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          '$title:',
          style: const TextStyle(fontSize: 12),
        ),
        const SizedBox(
          width: 5,
        ),
        CircleAvatar(
          radius: 10,
          foregroundImage: data['image_path'] != null
              ? FunctionUtils.getForeGroundImage(data['image_path'])
              : null,
          child: const Icon(
            Icons.person,
            size: 10,
          ),
        ),
        const SizedBox(
          width: 2,
        ),
        Text(
          '${data['name']} さん',
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget header(String title, double width) {
    return SizedBox(
        width: width,
        child: Align(
            alignment: Alignment.center,
            child: Text(
              title,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            )));
  }
}
