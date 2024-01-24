import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foodcost/model/food.dart';
import 'package:foodcost/model/menu.dart';
import 'package:foodcost/view/calendar/calendar_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodcost/view/create/create_food_page.dart';

class CreateCostPage extends StatefulWidget {
  const CreateCostPage({super.key});

  @override
  State<CreateCostPage> createState() => _CreateCostPageState();
}

class _CreateCostPageState extends State<CreateCostPage> {
  TextEditingController foodNameController = TextEditingController();
  TextEditingController totalPriceController = TextEditingController();

  // double selectedUsedCount = 1.0;
  String? foodName;

  // String? dropdownValue;
  // List<Material> materialList = [];

  List<Food> materialList = [Food(id: '1', menuId: '1', name: 'kome', unitPrice: 100, costCount: '', price: 100)];

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    bool isEnabled = _formKey.currentState?.validate() ?? false;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '食費計算',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        // backgroundColor: ,
        elevation: 1,
      ),
      body: Form(
        key: _formKey,
        child: SafeArea(
          child: Stack(children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: SizedBox(
                width: double.infinity,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 30,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 200,
                              child: TextFormField(
                                keyboardType: TextInputType.text,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return '料理名を入力してください';
                                  }
                                  return null;
                                  // bool _result = value!.contains(
                                  //   RegExp(
                                  //       r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"),
                                  // );
                                  // return _result ? null : "Please enter a valid email";
                                },
                                onSaved: (String? value) {
                                  setState(() {
                                    foodName = value;
                                  });
                                },
                                controller: foodNameController,
                                decoration: const InputDecoration(labelText: '料理名'),
                              ),
                            ),
                            SizedBox(
                              width: 100,
                              child: TextFormField(
                                textAlign: TextAlign.right,
                                readOnly: true,
                                controller: totalPriceController,
                                decoration: const InputDecoration(
                                  labelText: '合計金額',
                                  suffix: Text('円'),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: materialList.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 1.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      IconButton(
                                          onPressed: () {
                                            setState(() {
                                              var totalPrice =
                                                  int.parse(totalPriceController.text) - materialList[index].price;
                                              totalPriceController.text = totalPrice.toString();
                                              materialList.removeAt(index);
                                            });
                                          },
                                          icon: const Icon(Icons.delete_forever)),
                                      Text((index + 1).toString()),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                        child: Text(
                                          materialList[index].name,
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text('${materialList[index].price}円'),
                                ],
                              ),
                            );
                          }),

                      // const SizedBox(
                      //   height: 20.0,
                      // ),
                      // SizedBox(
                      //   width: 300,
                      //   child: TextFormField(
                      //     keyboardType: TextInputType.text,
                      //     validator: (String? value) {
                      //       if (value == null || value.isEmpty) {
                      //         return '材料名を入力してください';
                      //       }
                      //       return null;
                      //     },
                      //     controller: materialController,
                      //     decoration: const InputDecoration(border: OutlineInputBorder(), labelText: '材料'),
                      //   ),
                      // ),
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(vertical: 20.0),
                      //   child: SizedBox(
                      //     width: 300,
                      //     child: TextFormField(
                      //       keyboardType: TextInputType.number,
                      //       validator: (String? value) {
                      //         if (value == null || value.isEmpty) {
                      //           return '金額を入力してください';
                      //         } else {
                      //           return null;
                      //         }
                      //       },
                      //       controller: unitPriceController,
                      //       inputFormatters: [
                      //         FilteringTextInputFormatter.digitsOnly,
                      //         FilteringTextInputFormatter.deny(RegExp(r'^0+'))
                      //       ],
                      //       decoration:
                      //           const InputDecoration(labelText: '金額', border: OutlineInputBorder(), suffix: Text('円')),
                      //       onChanged: (text) {
                      //         if (text.isNotEmpty) {
                      //           var sumPrice = int.parse(text) * selectedUsedCount;
                      //           priceController.text = sumPrice.round().toString();
                      //         } else {
                      //           priceController.text = '0';
                      //           dropdownValue = '1';
                      //         }
                      //       },
                      //     ),
                      //   ),
                      // ),
                      // SizedBox(
                      //   width: 300,
                      //   // child: DropdownMenu(
                      //   //   controller: usedCountController,
                      //   //   label: const Text('使った量'),
                      //   //   dropdownMenuEntries: usedCountEntries,
                      //   //   onSelected: (count) {
                      //   //     setState(() {
                      //   //       selectedUsedCount = count;
                      //   //     });
                      //   //     if (unitPriceController.text.isNotEmpty) {
                      //   //       var price = int.parse(unitPriceController.text);
                      //   //       var sumPrice = count * price;
                      //   //       priceController.text = sumPrice.round().toString();
                      //   //     }
                      //   //   },
                      //   // )
                      //   child: DropdownButtonFormField(
                      //     validator: (String? value) {
                      //       if (value == null || value.isEmpty) {
                      //         return '選択してください';
                      //       }
                      //       return null;
                      //     },
                      //     value: dropdownValue,
                      //     // items: list.map<DropdownMenuItem<String>>((String value) {
                      //     //   return DropdownMenuItem<String>(
                      //     //       value: value,
                      //     //       child: Text(value)
                      //     //   );
                      //     // }).toList(),
                      //     items: const [
                      //       DropdownMenuItem(value: '1', child: Text('全部')),
                      //       DropdownMenuItem(value: '0.5', child: Text('半分')),
                      //       DropdownMenuItem(value: '0.33', child: Text('1/3')),
                      //       DropdownMenuItem(value: '0.25', child: Text('1/4')),
                      //       DropdownMenuItem(value: '0.125', child: Text('1/8')),
                      //     ],
                      //     onChanged: (String? value) {
                      //       setState(() {
                      //         dropdownValue = value!;
                      //       });
                      //       if (unitPriceController.text.isNotEmpty) {
                      //         var price = int.parse(unitPriceController.text);
                      //         var sumPrice = double.parse(value!) * price;
                      //         priceController.text = sumPrice.round().toString();
                      //       }
                      //     },
                      //     decoration: const InputDecoration(labelText: '使った量', border: OutlineInputBorder()),
                      //   ),
                      // ),
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(vertical: 20.0),
                      //   child: SizedBox(
                      //     width: 300,
                      //     child: TextFormField(
                      //       readOnly: true,
                      //       controller: priceController,
                      //       decoration: const InputDecoration(
                      //         labelText: '合計',
                      //         border: OutlineInputBorder(),
                      //         suffix: Text('円'),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      // const SizedBox(
                      //   height: 10,
                      // ),
                      ElevatedButton.icon(
                        onPressed: isEnabled
                            ? () {
                                Navigator.push(
                                    context, MaterialPageRoute(builder: (context) => const CreateFoodPage()));
                              }
                            : null,
                        style: ElevatedButton.styleFrom(foregroundColor: Colors.white, backgroundColor: Colors.amber),
                        icon: const Icon(Icons.add),
                        label: const Text(
                          '材料を追加する',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: ElevatedButton(
                          onPressed: isEnabled
                              ? () {
                                  if (_formKey.currentState!.validate()) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(const SnackBar(content: Text('Processing Data')));
                                  }
                                  Navigator.push(
                                      context, MaterialPageRoute(builder: (context) => const CalendarPage()));
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                              minimumSize: const Size(150, 50),
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.green),
                          child: const Text(
                            '登録する',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
