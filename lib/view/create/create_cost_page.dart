import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foodcost/view/calendar/calendar_page.dart';

class CreateCostPage extends StatefulWidget {
  const CreateCostPage({super.key});

  @override
  State<CreateCostPage> createState() => _CreateCostPageState();
}

class _CreateCostPageState extends State<CreateCostPage> {
  TextEditingController foodNameController = TextEditingController();
  TextEditingController materialController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController usedCountController = TextEditingController();
  TextEditingController sumPriceController = TextEditingController();
  double selectedUsedCount = 1.0;

  @override
  Widget build(BuildContext context) {
    final List<DropdownMenuEntry> usedCountEntries = [
      const DropdownMenuEntry(value: 1.0, label: '全部'),
      const DropdownMenuEntry(value: 0.5, label: '半分'),
      const DropdownMenuEntry(value: 0.25, label: '1/4個'),
      const DropdownMenuEntry(value: 0.125, label: '1/8個'),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '食費計算',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        // backgroundColor: ,
        elevation: 1,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                const SizedBox(
                  height: 30,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1.0),
                  child: SizedBox(
                    width: 200,
                    child: TextFormField(
                      controller: foodNameController,
                      decoration: const InputDecoration(label: Text('料理名')),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20.0,
                ),
                // Row(
                //   children: [
                //     Container(
                //         width: 110,
                //         child: const Center(
                //             child: Text('材料', style: TextStyle(fontWeight: FontWeight.bold),
                //             ))),
                //     // SizedBox(width: 30,),
                //     Container(
                //         width: 90,
                //         child: const Center(
                //             child: Text('金額', style: TextStyle(fontWeight: FontWeight.bold),
                //             ))),
                //     // SizedBox(width: 30,),
                //     Container(
                //         width: 80,
                //         child: Center(child: Text('量', style: TextStyle(fontWeight: FontWeight.bold),))),
                //     // SizedBox(width: 30,),
                //     Container(
                //       width: 90,
                //         child: Center(child: Text('合計', style: TextStyle(fontWeight: FontWeight.bold),)))
                //   ],
                // ),
                // Expanded(
                //   child: ListView.builder(
                //     // TODO:　カウントは増やせるようにする
                //     itemCount: 1,
                //       itemBuilder: (context, index) {
                //     return Row(
                //       children: [
                //         Container(
                //           width: 110,
                //           child: Center(
                //             child: Padding(
                //               padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
                //               child: TextFormField(
                //                 controller: materialController,
                //                 decoration: const InputDecoration(
                //                     border: OutlineInputBorder()
                //                 ),
                //               ),
                //             ),
                //           ),
                //         ),
                //         Container(
                //           width: 90,
                //           child: Center(
                //             child: Padding(
                //               padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
                //               child: TextFormField(
                //                 controller: moneyController,
                //                 decoration: const InputDecoration(
                //                     border: OutlineInputBorder()
                //                 ),
                //               ),
                //             ),
                //           ),
                //         ),
                //         Container(
                //           width: 80,
                //           child: Center(
                //             child: Padding(
                //               padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
                //               child: TextFormField(
                //                 controller: countController,
                //                 decoration: const InputDecoration(
                //                     border: OutlineInputBorder()
                //                 ),
                //               ),
                //             ),
                //           ),
                //         ),
                //         Container(
                //           width: 90,
                //           child: Center(
                //             child: Padding(
                //               padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
                //               child: TextFormField(
                //                 controller: sumController,
                //                 decoration: const InputDecoration(
                //                   border: OutlineInputBorder(),
                //                 ),
                //               ),
                //             ),
                //           ),
                //         )
                //       ],
                //     );
                //   }),
                // ),
                SizedBox(
                  width: 300,
                  child: TextFormField(
                    controller: materialController,
                    decoration: const InputDecoration(border: OutlineInputBorder(), labelText: '材料'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: SizedBox(
                    width: 300,
                    child: TextFormField(
                      controller: priceController,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        FilteringTextInputFormatter.deny(RegExp(r'^0+'))
                      ],
                      decoration:
                          const InputDecoration(labelText: '金額', border: OutlineInputBorder(), suffix: Text('円')),
                      onChanged: (text) {
                        // if (usedCountController.text.isNotEmpty) {
                        //   var usedCount = int.parse(usedCountController.text);
                        //   var sumPrice = int.parse(text) * usedCount;
                        //   sumPriceController.text = sumPrice.toString();
                        // }
                        var sumPrice = int.parse(text) * selectedUsedCount;
                        sumPriceController.text = sumPrice.round().toString();
                      },
                    ),
                  ),
                ),
                SizedBox(
                    width: 300,
                    child: DropdownMenu(
                      controller: usedCountController,
                      initialSelection: 1.0,
                      label: const Text('使った量'),
                      dropdownMenuEntries: usedCountEntries,
                      onSelected: (count) {
                        setState(() {
                          selectedUsedCount = count;
                        });
                        if (priceController.text.isNotEmpty) {
                          var price = int.parse(priceController.text);
                          var sumPrice = count * price;
                          sumPriceController.text = sumPrice.round().toString();
                        }
                      },
                    )),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: SizedBox(
                    width: 300,
                    child: TextFormField(
                      readOnly: true,
                      controller: sumPriceController,
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
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Colors.amber
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text('材料を追加する', style: TextStyle(fontWeight: FontWeight.bold),),
                ),
                const SizedBox(
                  height: 80,
                ),
                SizedBox(
                  width: 150,
                  height: 60,
                  child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const CalendarPage()));
                      },
                    style: ElevatedButton.styleFrom(
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
    );
  }
}
