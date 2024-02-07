import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  final List<Food> _foodList = [];

  bool _isLoading = false;

  // String _menuId = '';

  final _formKey = GlobalKey<FormState>();

  // TODO: カレンダーから来た場合、料理名を表示

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
      body: SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 50,),
              SizedBox(
                width: 300,
                child: TextField(
                  controller: menuController,
                  decoration: const InputDecoration(
                    hintText: 'メニュー名'
                  ),
                ),
              //   TODO: 写真ものっけたい
              ),
              const SizedBox(height: 30,),
              Container(
                alignment: Alignment.center,
                width: double.infinity,
                decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(
                        color: Colors.orange, width: 3
                    ))
                ),
                child: const Text('食材', style: TextStyle(fontWeight: FontWeight.bold),),
              ),
              const SizedBox(height: 20,),
              SizedBox(
                width: 300,
                child: TextField(
                  controller: menuController,
                  decoration: const InputDecoration(
                      hintText: '名前'
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 30.0),
                child: SizedBox(
                  width: 300,
                  child: TextField(
                    controller: unitPriceController,
                    decoration: const InputDecoration(
                        hintText: '金額',
                      suffix: Text('円')
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 300,
                child: TextField(
                  controller: priceController,
                ),
              )

            ],
          ),
        ),
      ),
      // body: Form(
      //   key: _formKey,
      //   child: SafeArea(
      //     child: Stack(children: [
      //       Padding(
      //         padding: const EdgeInsets.all(10.0),
      //         child: SizedBox(
      //           width: double.infinity,
      //           child: SingleChildScrollView(
      //             child: Column(
      //               children: [
      //                 const SizedBox(
      //                   height: 30,
      //                 ),
      //                 Padding(
      //                   padding: const EdgeInsets.symmetric(horizontal: 20.0),
      //                   child: Row(
      //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //                     children: [
      //                       SizedBox(
      //                         width: 200,
      //                         child: TextFormField(
      //                           keyboardType: TextInputType.text,
      //                           validator: (value) {
      //                             if (value == null || value.isEmpty) {
      //                               return '料理名を入力してください';
      //                             }
      //                             return null;
      //                             // bool _result = value!.contains(
      //                             //   RegExp(
      //                             //       r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"),
      //                             // );
      //                             // return _result ? null : "Please enter a valid email";
      //                           },
      //                           onSaved: (String? value) {
      //                             setState(() {});
      //                           },
      //                           controller: menuNameController,
      //                           decoration: const InputDecoration(labelText: '料理名'),
      //                         ),
      //                       ),
      //                       SizedBox(
      //                         width: 100,
      //                         child: TextField(
      //                           textAlign: TextAlign.right,
      //                           readOnly: true,
      //                           controller: totalPriceController,
      //                           decoration: const InputDecoration(
      //                             labelText: '合計金額',
      //                             suffix: Text('円'),
      //                           ),
      //                         ),
      //                       )
      //                     ],
      //                   ),
      //                 ),
      //                 Column(
      //                   mainAxisAlignment: MainAxisAlignment.center,
      //                   children: [
      //                     const SizedBox(
      //                       height: 30,
      //                     ),
      //                     ElevatedButton.icon(
      //                       onPressed: () async {
      //                         if (_formKey.currentState!.validate()) {
      //                           setState(() {
      //                             _isLoading = true;
      //                           });
      //                           Menu newMenu = Menu(
      //                             name: menuNameController.text,
      //                             userId: Authentication.myAccount!.id,
      //                           );
      //                           var result = await PostFirestore.addMenu(newMenu);
      //                           if (result is String) {
      //                             // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('success')));
      //                             final newFood = await Navigator.of(context).push(MaterialPageRoute(
      //                                 builder: (context) => CreateFoodPage(
      //                                       menuId: result,
      //                                     )));
      //                             if (newFood != null) {
      //                               setState(() {
      //                                 _foodList.add(newFood);
      //                               });
      //                             }
      //                           }
      //                           setState(() {
      //                             _isLoading = false;
      //                           });
      //                         }
      //                       },
      //                       style:
      //                           ElevatedButton.styleFrom(foregroundColor: Colors.white, backgroundColor: Colors.amber),
      //                       icon: const Icon(Icons.add),
      //                       label: const Text(
      //                         '材料を追加する',
      //                         style: TextStyle(fontWeight: FontWeight.bold),
      //                       ),
      //                     ),
      //                     const SizedBox(
      //                       height: 20,
      //                     ),
      //                     ElevatedButton(
      //                       onPressed: () {
      //                         if (_formKey.currentState!.validate()) {
      //                           ScaffoldMessenger.of(context)
      //                               .showSnackBar(const SnackBar(content: Text('Processing Data')));
      //                         }
      //                       },
      //                       style: ElevatedButton.styleFrom(
      //                           minimumSize: const Size(150, 50),
      //                           foregroundColor: Colors.white,
      //                           backgroundColor: Colors.green),
      //                       child: const Text(
      //                         '登録する',
      //                         style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      //                       ),
      //                     ),
      //                   ],
      //                 ),
      //               ],
      //             ),
      //           ),
      //         ),
      //       ),
      //       WidgetUtils.loadingStack(_isLoading)
      //       // if (_isLoading)
      //       //   const Opacity(
      //       //     opacity: 0.8,
      //       //     child: ModalBarrier(
      //       //         dismissible: false,
      //       //         color: Colors.white
      //       //     ),
      //       //   ),
      //       // if (_isLoading)
      //       //   Center(
      //       //     child: LoadingAnimationWidget.stretchedDots(color: Colors.blue, size: 70),
      //       //   ),
      //     ]),
      //   ),
      // ),
    );
  }
}
