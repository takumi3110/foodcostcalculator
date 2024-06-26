import 'package:flutter/material.dart';
import 'package:foodcost/model/food.dart';
import 'package:foodcost/utils/firestore/post_material.dart';

class CreateFoodPage extends StatefulWidget {
  const CreateFoodPage({super.key});

  @override
  State<CreateFoodPage> createState() => _CreateFoodPageState();
}

class _CreateFoodPageState extends State<CreateFoodPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController unitPriceController = TextEditingController();
  // TextEditingController costCountController = TextEditingController();
  TextEditingController priceController = TextEditingController();

  // static var menuItemValues = [
  //   Count('Alice'),
  //   Count('bob')
  // ];

  static List<Count> menuItemValues = [
    Count(
      name: '全部',
      count: 1.0
    ),
    Count(
      name: '1/2',
      count: 0.5
    ),
    Count(
      name: '1/3',
      count: 0.3
    ),
    Count(
      name: '1/4',
      count: 0.25
    ),
    Count(
      name: '1/8',
      count: 0.125
    )
  ];

  Count _selected = menuItemValues[0];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          '材料を追加する',
          style: TextStyle(color: Colors.black),
        ),
      ),
      //   TODO: 追加する項目を作成
      body: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: '材料', border: OutlineInputBorder()),
              ),
              const SizedBox(
                height: 20,
              ),
              TextField(
                controller: unitPriceController,
                decoration: const InputDecoration(labelText: '金額', border: OutlineInputBorder(), suffix: Text('円')),
                keyboardType: TextInputType.number,
                onChanged: (String value) {
                  if (value.isNotEmpty) {
                    int price = int.parse(value);
                    var sumPrice = price * _selected.count;
                    priceController.text = sumPrice.round().toString();
                  } else {
                    priceController.text = '0';
                  }
                },
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                width: 400,
                child: DropdownButtonFormField(
                  decoration: const InputDecoration(labelText: '使った量', border: OutlineInputBorder()),
                  value: _selected,
                    items: menuItemValues.map(
                        (value) {
                          return DropdownMenuItem(
                            value: value,
                            child: Text(value.name),
                          );
                        }
                    ).toList(),
                    onChanged: (Count? value) {
                    setState(() {
                      if (value != null) {
                        _selected = value;
                        if (unitPriceController.text.isNotEmpty) {
                          var price = int.parse(unitPriceController.text);
                          var sumPrice = value.count * price;
                          priceController.text = sumPrice.round().toString();
                        }
                      }
                    });
                    }
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: '使った金額', border: OutlineInputBorder(), suffix: Text('円')),
                readOnly: true,
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                  onPressed: () async{
                    if(nameController.text.isNotEmpty && unitPriceController.text.isNotEmpty) {
                      Food newFood = Food(
                        name: nameController.text,
                        unitPrice: int.parse(unitPriceController.text),
                        costCount: _selected.name,
                        price: int.parse(priceController.text)
                      );
                      var result = await FoodsFirestore.addFood(newFood);
                      if (result == true) {
                        Navigator.pop(context);
                      }
                    } else {
                      null;
                    }
                  },
                  child: const Text('保存'))
            ],
          ),
        ),
      ),
    );
  }
}