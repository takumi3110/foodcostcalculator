import 'package:flutter/material.dart';
import 'package:foodcost/model/food.dart';

class CreateFoodPage extends StatefulWidget {
  const CreateFoodPage({super.key});

  @override
  State<CreateFoodPage> createState() => _CreateFoodPageState();
}

class _CreateFoodPageState extends State<CreateFoodPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController unitPriceController = TextEditingController();
  TextEditingController costCountController = TextEditingController();
  TextEditingController priceController = TextEditingController();

  // static var menuItemValues = [
  //   Count('Alice'),
  //   Count('bob')
  // ];

  static List<Count> menuItemValues = [
    Count(
      name: 'all',
      count: '1'
    ),
    Count(
      name: 'half',
      count: '0.5'
    )
  ];

  Count? _selected = menuItemValues[0];

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
                controller: nameController,
                decoration: const InputDecoration(labelText: '金額', border: OutlineInputBorder()),
              ),
              const SizedBox(
                height: 20,
              ),
              // TextField(
              //   controller: nameController,
              //   decoration: const InputDecoration(
              //       labelText: '使った量',
              //     border: OutlineInputBorder()
              //   ),
              // ),
              SizedBox(
                width: 400,
                child: DropdownButtonFormField(
                  decoration: const InputDecoration(labelText: '使った量', border: OutlineInputBorder()),
                  value: _selected,
                    items: menuItemValues.map(
                        (value) {
                          return DropdownMenuItem(
                            child: Text('${value.name}'),
                            value: value,
                          );
                        }
                    ).toList(),
                    onChanged: (value) {
                    setState(() {
                      _selected = value;
                    });
                    print(value?.count);
                    }
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: '使った金額', border: OutlineInputBorder()),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('保存'))
            ],
          ),
        ),
      ),
    );
  }
}

class Person {
  String name;
  Person(this.name);
}