import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foodcost/model/dish_material.dart';
import 'package:foodcost/view/calendar/calendar_page.dart';


class CreateCostPage extends StatefulWidget {
  const CreateCostPage({super.key});

  @override
  State<CreateCostPage> createState() => _CreateCostPageState();
}

class _CreateCostPageState extends State<CreateCostPage> {
  TextEditingController foodNameController = TextEditingController();
  TextEditingController materialController = TextEditingController();
  TextEditingController unitPriceController = TextEditingController();
  TextEditingController usedCountController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController totalPriceController = TextEditingController();

  List<DishMaterial> materialList = [];
  double selectedUsedCount = 1.0;

  final _formKey = GlobalKey<FormState>();


  @override
  Widget build(BuildContext context) {
    final List<DropdownMenuEntry> usedCountEntries = [
      const DropdownMenuEntry(value: 1.0, label: '全部'),
      const DropdownMenuEntry(value: 0.5, label: '半分'),
      const DropdownMenuEntry(value: 0.33, label: '1/3'),
      const DropdownMenuEntry(value: 0.25, label: '1/4'),
      const DropdownMenuEntry(value: 0.125, label: '1/8'),
    ];

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
          child: Stack(
            children: [Padding(
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
                                validator: (String? value) {
                                  if (value == null || value.isEmpty) {
                                    return '料理名を入力してください';
                                  } else {
                                    return null;
                                  }
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
                             padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                             child: Row(
                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                               children: [
                                 Row(
                                   children: [
                                     IconButton(
                                         onPressed: () {
                                           setState(() {
                                             var totalPrice = int.parse(totalPriceController.text) - materialList[index].price;
                                             totalPriceController.text = totalPrice.toString();
                                             materialList.removeAt(index);
                                           });
                                         },
                                         icon: const Icon(Icons.delete_forever)
                                     ),
                                     Text((index + 1).toString()),
                                     Padding(
                                       padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                       child: Text(
                                         materialList[index].name,
                                         style: const TextStyle(
                                             fontSize: 16
                                         ),),
                                     ),
                                   ],
                                 ),
                                 Text('${materialList[index].price}円'),
                               ],
                             ),
                           );
                      }),

                      const SizedBox(
                        height: 20.0,
                      ),
                      SizedBox(
                        width: 300,
                        child: TextFormField(
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return '材料名を入力してください';
                            }
                            return null;
                          },
                          controller: materialController,
                          decoration: const InputDecoration(border: OutlineInputBorder(), labelText: '材料'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                        child: SizedBox(
                          width: 300,
                          child: TextFormField(
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return '金額を入力してください';
                              } else {
                                return null;
                              }
                            },
                            controller: unitPriceController,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              FilteringTextInputFormatter.deny(RegExp(r'^0+'))
                            ],
                            decoration:
                            const InputDecoration(labelText: '金額', border: OutlineInputBorder(), suffix: Text('円')),
                            onChanged: (text) {
                              if (text.isNotEmpty) {
                                var sumPrice = int.parse(text) * selectedUsedCount;
                                priceController.text = sumPrice.round().toString();
                              }
                            },
                          ),
                        ),
                      ),
                      SizedBox(
                          width: 300,
                          child: DropdownMenu(
                            controller: usedCountController,
                            label: const Text('使った量'),
                            dropdownMenuEntries: usedCountEntries,
                            onSelected: (count) {
                              setState(() {
                                selectedUsedCount = count;
                              });
                              if (unitPriceController.text.isNotEmpty) {
                                var price = int.parse(unitPriceController.text);
                                var sumPrice = count * price;
                                priceController.text = sumPrice.round().toString();
                              }
                            },
                          )),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                        child: SizedBox(
                          width: 300,
                          child: TextFormField(
                            readOnly: true,
                            controller: priceController,
                            decoration: const InputDecoration(
                              labelText: '合計',
                              border: OutlineInputBorder(),
                              suffix: Text('円'),
                            ),
                          ),
                        ),
                      ),
                      // TODO: 行を追加できるようにする
                      const SizedBox(
                        height: 10,
                      ),
                      ElevatedButton.icon(
                        onPressed: isEnabled ? () {
                            setState(() {
                              selectedUsedCount = 1.0;
                            });
                            if (totalPriceController.text.isNotEmpty) {
                              var totalPrice = int.parse(totalPriceController.text) + int.parse(priceController.text);
                              totalPriceController.text = totalPrice.toString();
                            } else {
                              totalPriceController.text = priceController.text;
                            }
                            materialList.add(
                                DishMaterial(
                                    id: (materialList.length + 1).toString(),
                                    name: materialController.text,
                                    unitPrice: int.parse(unitPriceController.text),
                                    costCount: usedCountController.text,
                                    price: int.parse(priceController.text)
                                )
                            );
                            materialController.text = '';
                            unitPriceController.text = '';
                            usedCountController.text = '';
                            priceController.text = '';
                        }: null,
                        style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white, backgroundColor: Colors.amber
                        ),
                        icon: const Icon(Icons.add),
                        label: const Text('材料を追加する', style: TextStyle(fontWeight: FontWeight.bold),),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: ElevatedButton(
                            onPressed: isEnabled || materialList.isNotEmpty ? () {
                              if (_formKey.currentState!.validate()) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Processing Data'))
                                );
                              }
                              // Navigator.push(context, MaterialPageRoute(builder: (context) => const CalendarPage()));
                            }: null,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(150, 50),
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.green
                          ),
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
        ]
          ),
        ),
      ),
    );
  }
}
