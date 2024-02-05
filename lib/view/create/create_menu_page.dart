import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foodcost/model/food.dart';
import 'package:foodcost/model/menu.dart';
import 'package:foodcost/utils/authentication.dart';
import 'package:foodcost/utils/firestore/gets.dart';
import 'package:foodcost/utils/firestore/posts.dart';
import 'package:foodcost/utils/widget_utils.dart';
import 'package:foodcost/view/create/create_food_page.dart';

class CreateMenuPage extends StatefulWidget {
  const CreateMenuPage({super.key});

  @override
  State<CreateMenuPage> createState() => _CreateMenuPageState();
}

class _CreateMenuPageState extends State<CreateMenuPage> {
  TextEditingController menuNameController = TextEditingController();
  TextEditingController totalPriceController = TextEditingController();

  List<Food> foodList = [];

  bool _isLoading = false;

  String _menuId = '';

  final _formKey = GlobalKey<FormState>();

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
      body: Form(
        key: _formKey,
        child: SafeArea(
          child: Stack(
              children: [
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
                                  setState(() {});
                                },
                                controller: menuNameController,
                                decoration: const InputDecoration(labelText: '料理名'),
                              ),
                            ),
                            SizedBox(
                              width: 100,
                              child: TextField(
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
                    FutureBuilder(
                      future: GetFirestore.getFoodList(_menuId),
                      builder: (context, snapshot) {
                        if (snapshot.data != null) {
                          return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: snapshot.data!.length,
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
                                                      int.parse(totalPriceController.text) - foodList[index].price;
                                                  totalPriceController.text = totalPrice.toString();
                                                  foodList.removeAt(index);
                                                });
                                              },
                                              icon: const Icon(Icons.delete_forever)),
                                          Text((index + 1).toString()),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                            child: Text(
                                              snapshot.data![index].name,
                                              style: const TextStyle(fontSize: 16),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text('${snapshot.data![index].price}円'),
                                    ],
                                  ),
                                );
                              });
                        } else {
                          return Container();
                        }

                      },

                    ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 30,),
                          ElevatedButton.icon(
                            onPressed: () async{
                              if (_formKey.currentState!.validate()) {
                                setState(() {
                                  _isLoading = true;
                                });
                                Menu newMenu = Menu(
                                  name: menuNameController.text,
                                  userId: Authentication.myAccount!.id,
                                );
                                var result = await PostFirestore.addMenu(newMenu);
                                if (result is String) {
                                  // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('success')));
                                 // final foodList =  await Navigator.of(context).push(MaterialPageRoute(builder: (context) => CreateFoodPage(menuId: result,)));
                                 // if (foodList != null) {
                                 //   setState(() {
                                 //     foodList.add(foodList);
                                 //   });
                                 // }
                                  setState(() {
                                    _menuId = result;
                                  });
                                }
                                setState(() {
                                  _isLoading = false;
                                });
                              }
                            },
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
                          ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(content: Text('Processing Data')));
                              }
                            },
                            style: ElevatedButton.styleFrom(
                                minimumSize: const Size(150, 50),
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.green),
                            child: const Text(
                              '登録する',
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),

                    ],
                  ),
                ),
              ),
            ),
                WidgetUtils.loadingStack(_isLoading)
                // if (_isLoading)
                //   const Opacity(
                //     opacity: 0.8,
                //     child: ModalBarrier(
                //         dismissible: false,
                //         color: Colors.white
                //     ),
                //   ),
                // if (_isLoading)
                //   Center(
                //     child: LoadingAnimationWidget.stretchedDots(color: Colors.blue, size: 70),
                //   ),
          ]
          ),
        ),
      ),
    );
  }
}
