import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foodcost/utils/firestore/foods.dart';
import 'package:foodcost/utils/firestore/menus.dart';

class EditMenuPage extends StatefulWidget {
  final String menuId;
  const EditMenuPage({super.key, required this.menuId});

  @override
  State<EditMenuPage> createState() => _EditMenuPageState();
}

class _EditMenuPageState extends State<EditMenuPage> {

  late String _menuId;

  @override
  void initState() {
    super.initState();
    _menuId = widget.menuId;
  }

  // final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          // title: const Text(
          //   '食費計算',
          //   style: TextStyle(fontWeight: FontWeight.bold),
          // ),
          // backgroundColor: ,
          elevation: 1,
        ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.only(right: 15, left: 15, top:20),
                  height: 200,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(_menuId)
                        ],
                      )
                    ],
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(
                      color: Colors.orange, width: 3
                    ))
                  ),
                  child: const Text('材料'),
                ),
                Expanded(child: StreamBuilder<QuerySnapshot>(
                    stream: MenuFirestore.menus
                        .doc(_menuId)
                        .collection('foods')
                        .orderBy('created_at', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        List<String> foodIds =
                        List.generate(snapshot.data!.docs.length, (index) => snapshot.data!.docs[index].id);
                        return FutureBuilder(
                          future: FoodFirestore.getFoodFromIds(foodIds),
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
                        );
                      } else {
                        return Container();
                      }
                    }),)
              ],
            ),
          ),
        ),
      )
    );
  }
}
