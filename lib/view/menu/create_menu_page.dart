import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:foodcost/model/food.dart';

class CreateMenuPage extends StatefulWidget {
  const CreateMenuPage({super.key});

  @override
  State<CreateMenuPage> createState() => _CreateMenuPageState();
}

class _CreateMenuPageState extends State<CreateMenuPage> {
  // menu
  TextEditingController menuController = TextEditingController();
  TextEditingController totalPriceController = TextEditingController();

  // food
  List<Map<String, TextEditingController>> foodControllers = [
    {'name': TextEditingController(), 'unitPrice': TextEditingController(), 'price': TextEditingController()}
  ];

  int allPrice = 0;
  bool _isLoading = false;

  static List<Count> menuItemValues = [
    Count(name: '全部', count: 1.0),
    Count(name: '3/4', count: 0.75),
    Count(name: '2/3', count: 0.6),
    Count(name: '1/2', count: 0.5),
    Count(name: '1/3', count: 0.3),
    Count(name: '1/4', count: 0.25),
    Count(name: '1/8', count: 0.125)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '食費計算',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        // backgroundColor: ,
        elevation: 1,
        actions: [
          ElevatedButton(
            onPressed: () {
              print(foodControllers[0]['name']!.text);
              print(menuController.text);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text(
              '保存',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
      body: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
        SingleChildScrollView(
          child: SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 50,
                ),
                SizedBox(
                  width: 300,
                  child: TextField(
                    controller: menuController,
                    decoration: const InputDecoration(hintText: 'メニュー名'),
                  ),
                  //   TODO: 写真ものっけたい
                ),
                const SizedBox(
                  height: 30,
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
                        allPrice.toString(),
                        style: const TextStyle(fontSize: 18),
                      ),
                      const Text('円')
                      // Text('200000 円', style: TextStyle(fontSize: 18),)
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
                                    print(value);
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
                                        var unitPrice = foodControllers[index]['unitPrice'];
                                        // sumPriceとfoodControllers[index]['price']が同じなら何もしない。
                                        // 違ったらallPriceからfoodControllers[index]['price']を引いて、sumPriceを追加
                                        if (unitPrice != null && unitPrice.text.isNotEmpty) {
                                          var sumPrice = (value.count * int.parse(unitPrice.text)).round();
                                          var price = foodControllers[index]['price'];
                                          if (price != null && price.text.isNotEmpty) {
                                            if (sumPrice != int.parse(price.text)) {
                                              // allPrice -= int.parse(price.text);
                                              // allPrice += sumPrice;
                                              allPrice += (sumPrice - int.parse(price.text));
                                            }
                                          } else {
                                            allPrice += sumPrice;
                                          }
                                          foodControllers[index]['price']!.text = sumPrice.toString();
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
      ]),
    );
  }
}
