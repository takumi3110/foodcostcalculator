import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foodcost/model/food.dart';
import 'package:foodcost/model/menu.dart';
import 'package:foodcost/utils/firestore/users.dart';
import 'package:foodcost/utils/function_utils.dart';
import 'package:foodcost/utils/widget_utils.dart';
import 'package:intl/intl.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

class CreateMenuPage extends StatefulWidget {
  final DateTime? selectedDay;
  final Menu? selectedMenu;

  const CreateMenuPage({super.key, this.selectedDay, this.selectedMenu});

  @override
  State<CreateMenuPage> createState() => _CreateMenuPageState();
}

class _CreateMenuPageState extends State<CreateMenuPage> {
  // keyboard
  final FocusNode _nodeText1 = FocusNode();

  KeyboardActionsConfig _buildConfig(BuildContext context) {
    return KeyboardActionsConfig(
        keyboardActionsPlatform: KeyboardActionsPlatform.ALL,
        keyboardBarColor: Colors.grey[200],
        nextFocus: true,
        actions: [
          KeyboardActionsItem(focusNode: _nodeText1, toolbarButtons: [
            (node) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: TextButton(onPressed: () => node.unfocus(), child: const Text('完了', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),))
                // child: GestureDetector(
                //   onTap: () => node.unfocus(),
                  // child: Container(
                  //     width: 70,
                  //     decoration: BoxDecoration(
                  //         color: Colors.blue,
                  //         borderRadius: BorderRadius.circular(10)),
                  //     padding: const EdgeInsets.all(10),
                  //     child: const Center(
                  //         child: Text(
                  //       'done',
                  //       style: TextStyle(
                  //           fontWeight: FontWeight.bold, color: Colors.white),
                  //     ))),
                // ),
              );
            }
          ]),
        ]);
  }

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

  // List<Map<String, TextEditingController>> foodControllers = [];
  List<Map<String, String>> foods = [];
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
        foods.add({
          'name': food.name,
          'unitPrice': food.unitPrice.toString(),
          'costCount': food.costCount.toString(),
          'price': food.price.toString(),
        });
        // foodControllers.add({
        //   'name': TextEditingController(text: food.name),
        //   'unitPrice': TextEditingController(text: food.unitPrice.toString()),
        //   'costCount': TextEditingController(text: food.costCount.toString()),
        //   'price': TextEditingController(text: food.price.toString()),
        // });
        allPrice += food.price;
        final Count count = menuItemValues.firstWhere(
            (Count value) => value.count == double.parse(food.costCount));
        _costCounts.add(count);

        // _costCount = food.costCount;
      });
    } else {
      // priceController.text = '0';
      // foodControllers.add({
      //   'name': TextEditingController(),
      //   'unitPrice': TextEditingController(),
      //   'costCount': TextEditingController(),
      //   'price': TextEditingController(),
      // });
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
              child:
                  Column(mainAxisAlignment: MainAxisAlignment.start, children: [
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
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // const SizedBox(width: 10.0,),
                            SizedBox(
                              width: 220,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                                    as Map<String, dynamic>;
                                            return userInfo(data, '作成者');
                                          } else {
                                            return const SizedBox();
                                          }
                                        })
                                ],
                              ),
                            ),
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
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Container(
                          alignment: Alignment.center,
                          width: double.infinity,
                          decoration: const BoxDecoration(
                              border: Border(
                                  top: BorderSide(
                                      color: Colors.orange, width: 3))),
                          // child: const Text(
                          //   '食材',
                          //   style: TextStyle(fontWeight: FontWeight.bold),
                          // ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 10, bottom: 20, right: 25.0),
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
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          child: header('金額', 90),
                        ),
                        header('使った量', 70)
                      ],
                    ),
                  ),
                // if (foodControllers.isEmpty)
                // if (foods.isEmpty)
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    // itemCount: foodControllers.length,
                    itemCount: foods.length,
                    itemBuilder: (context, index) {
                      return Dismissible(
                        key: UniqueKey(),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: ListTile(
                            title: Text(foods[index]['name']!),
                          ),
                        ),
                      );

                      // TODO: dismiss
                      // return Dismissible(
                      //   key: UniqueKey(),
                      //   background: Container(
                      //     alignment: Alignment.centerLeft,
                      //     color: Colors.greenAccent,
                      //     child: const Row(
                      //       children: [
                      //         Icon(Icons.remove_circle_outline_outlined),
                      //         Text('削除')
                      //       ],
                      //     ),
                      //
                      //   ),
                      //   onDismissed: (DismissDirection direction) {
                      //       setState(() {
                      //         var price = foodControllers[index]['price'];
                      //         if (price != null && price.text.isNotEmpty) {
                      //           allPrice -= int.parse(price.text);
                      //         }
                      //       });
                      //       foodControllers.removeAt(index);
                      //   },
                      //   direction: foodControllers.length > 1 ? DismissDirection.startToEnd: DismissDirection.none,
                      //   child: Container(
                      //     padding: const EdgeInsets.symmetric(
                      //         vertical: 5, horizontal: 10),
                      //     child: Row(
                      //       mainAxisAlignment: MainAxisAlignment.center,
                      //       children: [
                      //         SizedBox(
                      //           width: 130,
                      //           child: TextField(
                      //             controller: foodControllers[index]['name'],
                      //             decoration:
                      //                 const InputDecoration(hintText: '名前'),
                      //           ),
                      //         ),
                      //         Padding(
                      //           padding: const EdgeInsets.symmetric(
                      //               horizontal: 15.0),
                      //           child: SizedBox(
                      //             width: 90,
                      //             child: TextField(
                      //               controller: foodControllers[index]
                      //                   ['unitPrice'],
                      //               keyboardType: TextInputType.number,
                      //               decoration: const InputDecoration(
                      //                   hintText: '金額', suffix: Text('円')),
                      //               onChanged: (String value) {
                      //                 setState(() {
                      //                   var price =
                      //                       foodControllers[index]['price'];
                      //                   if (value != '') {
                      //                     var costCount = foodControllers[index]
                      //                         ['costCount'];
                      //                     if (costCount != null &&
                      //                         costCount.text.isNotEmpty) {
                      //                       var sumPrice = (int.parse(value) *
                      //                               double.parse(
                      //                                   costCount.text))
                      //                           .round();
                      //                       if (price != null) {
                      //                         if (price.text.isNotEmpty) {
                      //                           if (sumPrice !=
                      //                               int.parse(price.text)) {
                      //                             allPrice += (sumPrice -
                      //                                 int.parse(price.text));
                      //                           }
                      //                         } else {
                      //                           allPrice += sumPrice;
                      //                         }
                      //                         foodControllers[index]['price']!
                      //                             .text = sumPrice.toString();
                      //                         price.text = sumPrice.toString();
                      //                       }
                      //                     }
                      //                   } else {
                      //                     if (price != null &&
                      //                         price.text.isNotEmpty) {
                      //                       allPrice -= int.parse(price.text);
                      //                     }
                      //                     price!.text = '0';
                      //                   }
                      //                 });
                      //               },
                      //             ),
                      //           ),
                      //         ),
                      //         SizedBox(
                      //           width: 70,
                      //           child: DropdownButtonFormField(
                      //               decoration:
                      //                   const InputDecoration(hintText: '量'),
                      //               value: foodControllers[index]['costCount']!
                      //                       .text
                      //                       .isNotEmpty
                      //                   ? _costCounts[index]
                      //                   : null,
                      //               // value: _costCounts.length == foodControllers.length ? _costCounts[index] : ,
                      //               items: menuItemValues.map((value) {
                      //                 return DropdownMenuItem(
                      //                   value: value,
                      //                   child: Text(value.name),
                      //                 );
                      //               }).toList(),
                      //               onChanged: (Count? value) {
                      //                 setState(() {
                      //                   if (value != null) {
                      //                     _costCounts.add(value);
                      //                     var costCount = foodControllers[index]
                      //                         ['costCount'];
                      //                     if (costCount != null) {
                      //                       costCount.text =
                      //                           value.count.toString();
                      //                     }
                      //                     // foodControllers[index]['costCount']!.text = value.count.toString();
                      //                     var unitPrice = foodControllers[index]
                      //                         ['unitPrice'];
                      //                     // sumPriceとfoodControllers[index]['price']が同じなら何もしない。
                      //                     // 違ったらallPriceからfoodControllers[index]['price']を引いて、sumPriceを追加
                      //                     if (unitPrice != null &&
                      //                         unitPrice.text.isNotEmpty) {
                      //                       var sumPrice = (value.count *
                      //                               int.parse(unitPrice.text))
                      //                           .round();
                      //                       var price =
                      //                           foodControllers[index]['price'];
                      //                       if (price != null) {
                      //                         if (price.text.isNotEmpty) {
                      //                           if (sumPrice !=
                      //                               int.parse(price.text)) {
                      //                             // すでに登録されている時は差額を登録
                      //                             allPrice += (sumPrice -
                      //                                 int.parse(price.text));
                      //                           }
                      //                         } else {
                      //                           // priceに何も登録されてない場合
                      //                           allPrice += sumPrice;
                      //                         }
                      //                         foodControllers[index]['price']!
                      //                             .text = sumPrice.toString();
                      //                       }
                      //                       // 最後尾の名前が入力されてれば行を追加
                      //                       if (foodControllers.last['name']!
                      //                               .text.isNotEmpty &&
                      //                           costCount!.text.isNotEmpty) {
                      //                         foodControllers.add({
                      //                           'name': TextEditingController(),
                      //                           'unitPrice':
                      //                               TextEditingController(),
                      //                           'costCount':
                      //                               TextEditingController(),
                      //                           'price':
                      //                               TextEditingController(),
                      //                         });
                      //                       }
                      //                     }
                      //                   }
                      //                 });
                      //               }),
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      // );
                    },
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orangeAccent,
                          // foregroundColor: Colors.white
                        ),
                        onPressed: () async {
                          await showModalBottomSheet(
                              isScrollControlled: true,
                              context: context,
                              builder: (BuildContext context) {
                                return Container(
                                  width: double.infinity,
                                  height:
                                      MediaQuery.sizeOf(context).height * 0.6,
                                  // padding: const EdgeInsets.all(10),
                                  // height: MediaQuery.sizeOf(context).height * 0.8,
                                  decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(20),
                                        topRight: Radius.circular(20)),
                                    color: Colors.white,
                                  ),
                                  child: Padding(
                                    padding: MediaQuery.of(context).viewInsets,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 5, horizontal: 10),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                const BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(20),
                                                    topRight:
                                                        Radius.circular(20)),
                                            color: Colors.orangeAccent[100],
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    nameController.clear();
                                                    unitPriceController.clear();
                                                    costCountController.clear();
                                                    priceController.clear();
                                                  },
                                                  child: const Text(
                                                    'キャンセル',
                                                    style: TextStyle(
                                                        color: Colors.red),
                                                  )),
                                              TextButton(
                                                  onPressed: () {
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

                                                      Navigator.pop(context);nameController.clear();
                                                    unitPriceController.clear();
                                                    costCountController.clear();
                                                    priceController.clear();
                                                    }
                                                  },
                                                  child: const Text('登録',
                                                      style: TextStyle(
                                                          color: Colors.black)))
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: SingleChildScrollView(
                                            child: Container(
                                              width: 300,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 20,
                                                      horizontal: 30),
                                              // color: Colors.white,
                                              child: Center(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .stretch,
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    SizedBox(
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              0.3,
                                                      child: KeyboardActions(
                                                        config: _buildConfig(
                                                            context),
                                                        child: Column(
                                                          children: [
                                                            TextField(
                                                              controller:
                                                                  nameController,
                                                              decoration:
                                                                  const InputDecoration(
                                                                      labelText:
                                                                          '材料名'),
                                                              keyboardType:
                                                                  TextInputType
                                                                      .text,
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          10),
                                                              child: TextField(
                                                                  controller:
                                                                      unitPriceController,
                                                                  keyboardType:
                                                                      TextInputType
                                                                          .number,
                                                                  textAlign: TextAlign.right,
                                                                  focusNode:
                                                                      _nodeText1,
                                                                  decoration: const InputDecoration(
                                                                      labelText:
                                                                          '金額',
                                                                      suffix: Text(
                                                                          '円')),
                                                                onChanged: (String value) {
                                                                    if (value != '' && costCountController.text.isNotEmpty) {
                                                                      var sumPrice = (int.parse(value) * double.parse(costCountController.text)).round();
                                                                      priceController.text = sumPrice.toString();
                                                                    }
                                                                },
                                                              ),
                                                            ),
                                                            DropdownButtonFormField(
                                                                decoration:
                                                                    const InputDecoration(
                                                                        labelText:
                                                                            '使った量'),
                                                                items: menuItemValues
                                                                    .map(
                                                                        (value) {
                                                                  return DropdownMenuItem(
                                                                    value:
                                                                        value,
                                                                    child: Text(
                                                                        value
                                                                            .name),
                                                                  );
                                                                }).toList(),
                                                                onChanged:
                                                                    (Count?
                                                                        value) {
                                                                  setState(() {
                                                                    if (value !=
                                                                        null) {
                                                                      costCountController.text = value.toString();
                                                                      if (unitPriceController.text.isNotEmpty) {
                                                                        var sumPrice = (value.count * int.parse(unitPriceController.text)).round();
                                                                        priceController.text = sumPrice.toString();
                                                                      }
                                                                    }
                                                                  });
                                                                }),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.end,
                                                      children: [
                                                        const Text('合計'),
                                                        const SizedBox(width: 20),
                                                        SizedBox(
                                                          width: 130,
                                                          child: TextField(
                                                            readOnly: true,
                                                            controller: priceController,
                                                            textAlign: TextAlign.right,
                                                            decoration: const InputDecoration(
                                                              suffix: Text('円')
                                                            )
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              });
                        },
                        icon: const Icon(
                          Icons.add,
                        ),
                        label: const Text('材料を追加する')),
                  ),
              ]),
            ),
            WidgetUtils.loadingStack(_isLoading)
          ],
        ),
      ),
    );
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
