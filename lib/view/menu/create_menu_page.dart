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
  TextEditingController foodNameController = TextEditingController();
  TextEditingController unitPriceController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  List<Map<String, TextEditingController>> foodControllers = [
    {
      'name': TextEditingController(),
      'unitPrice': TextEditingController(),
      'price': TextEditingController()
    }
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

  Count _selected = menuItemValues[0];

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
      ),
      body:Stack(
        children: [
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
                  const SizedBox(height: 10,),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text('合計金額'),
                        const SizedBox(width: 20,),
                        Text(allPrice.toString(), style: const TextStyle(fontSize: 18),),
                        const Text('円')
                        // Text('200000 円', style: TextStyle(fontSize: 18),)
                      ],
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: foodControllers.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10.0),
                              child: SizedBox(
                                width: 120,
                                child: TextField(
                                  controller: foodControllers[index]['name'],
                                  decoration: const InputDecoration(hintText: '名前'),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10.0),
                              child: SizedBox(
                                width: 100,
                                child: TextField(
                                  controller: foodControllers[index]['unitPrice'],
                                  decoration: const InputDecoration(hintText: '金額', suffix: Text('円')),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 100,
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
                                        _selected = value;
                                        var unitPrice = foodControllers[index]['unitPrice'];
                                        if (unitPrice != null) {
                                          if (unitPrice.text.isNotEmpty) {
                                            var price = int.parse(unitPrice.text);
                                            var sumPrice = (value.count * price);
                                            // allPrice = sumPrice.round() + allPrice;
                                            foodControllers[index]['price']!.text = sumPrice.round().toString();
                                            // priceController.text = sumPrice.round().toString();
                                            for (var food in foodControllers) {
                                              if (food['price'] != null) {
                                                allPrice += int.parse(food['price']!.text);
                                              }
                                            }
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
                ],
              ),
            ),
          ),
          // const SizedBox(height: 30,),
          Positioned(
            bottom: 0.0,
              child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      foodControllers.add({
                        'name': TextEditingController(),
                        'unitPrice': TextEditingController(),
                        'price': TextEditingController(),
                      });
                    });
                  } ,
                  style: ElevatedButton.styleFrom(foregroundColor: Colors.grey, backgroundColor: Colors.yellow),
                  icon: const Icon(Icons.add),
                  label: const Text('追加')
              ),
              // const SizedBox(width: 10,),
              ElevatedButton.icon(
                  onPressed: () {
                    if (foodControllers.length > 1) {
                      setState(() {
                        var lastPrice = foodControllers[foodControllers.length - 1]['price'];
                        print(lastPrice!.text);
                        foodControllers.removeLast();
                        // if (lastPrice != null ) {
                        //   allPrice = allPrice - int.parse(lastPrice.text);
                        // }

                      });
                    } else {
                      null;
                    }
                  },
                  icon: const Icon(Icons.remove),
                  label: const Text('削除')
              )

            ],
          )
          ),
        ]
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () {},
          label: const Text('保存', style: TextStyle(fontWeight: FontWeight.bold),),
        // backgroundColor: Colors.green,
        splashColor: Colors.orange,

      ),
    );
  }
}
