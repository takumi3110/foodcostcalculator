import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foodcost/component/primary_button.dart';
import 'package:foodcost/model/item.dart';
import 'package:foodcost/utils/firestore/items.dart';
import 'package:foodcost/utils/widget_utils.dart';
import 'package:foodcost/view/item/create_item_page.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ItemListPage extends StatefulWidget {
  final String purchaseId;
  final DateTime selectedDate;
  // final List<dynamic> itemIds;

  // const ItemListPage({super.key, required this.selectedDate, required this.itemIds});
  const ItemListPage({super.key, required this.purchaseId, required this.selectedDate});

  @override
  State<ItemListPage> createState() => _ItemListPageState();
}

class _ItemListPageState extends State<ItemListPage> {
  late final DateTime _date;
  // late final List<dynamic> _itemIds;
  // List<Item> _defaultItems = [];
  // List<Item> _filteredItems = [];

  TextEditingController searchNameController = TextEditingController();
  TextEditingController searchShopController = TextEditingController();

  final dateFormatter = DateFormat('yyyy年 M月 d日');
  final numberFormatter = NumberFormat('#,###');

  // Future getItems(List<dynamic> itemIds) async {
  //   List<Item> results = await ItemFirestore.getItems(itemIds);
  //   if (results.isNotEmpty) {
  //     setState(() {
  //       _defaultItems = results;
  //       _filteredItems = results;
  //     });
  //   }
  // }

  @override
  void initState() {
    _date = widget.selectedDate;
  //   _itemIds = widget.itemIds;
  //   getItems(widget.itemIds);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // final Stream<List<Item>> stream = ((List<dynamic> itemIds) {
    //   late final StreamController<List<Item>> controller;
    //   controller = StreamController(
    //       onListen: () async {
    //         var result = await ItemFirestore.getItems(itemIds);
    //         if (result != null) {
    //           controller.add(result);
    //           controller.close();
    //         } else {
    //           controller.close();
    //         }
    //       }
    //   );
    //   return controller.stream;
    // })(_itemIds);
    return Scaffold(
      // appBar: WidgetUtils.createAppBar(dateFormatter.format(_date)),
      appBar: WidgetUtils.createAppBar('買ったもの'),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: StreamBuilder<DocumentSnapshot>(
                  stream: ItemFirestore.purchases.doc(widget.purchaseId).snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
                      Purchase purchase = Purchase(
                        id: snapshot.data!.id,
                        date: data['date'],
                        itemIds: data['item_ids'],
                        groupId: data['group_id'],
                      );
                      return FutureBuilder<dynamic>(
                        future: ItemFirestore.getItems(purchase.itemIds),
                        // future: getItems(purchase.itemIds),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            var filteredItems = [];
                            for (var data in snapshot.data) {
                              if (searchNameController.text.isEmpty && searchShopController.text.isEmpty) {
                                filteredItems.add(data);
                              } else {
                                if (searchNameController.text.isNotEmpty) {
                                  var result = snapshot.data.where((item) => item.name.contains(searchNameController.text));
                                  filteredItems.addAll(result);
                                }
                                if (searchShopController.text.isNotEmpty) {
                                  var result = snapshot.data.where((item) => item.shop.contains(searchShopController.text));
                                  filteredItems.addAll(result);
                                }
                              }
                            }
                            // TODO: 重複削除
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    // dateFormatter.format(_date),
                                    dateFormatter.format(purchase.date.toDate()),
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      showModalBottomSheet(
                                          backgroundColor: Colors.white,
                                          context: context,
                                          isScrollControlled: true,
                                          builder: (context) {
                                            return Container(
                                              // color: Colors.white,
                                              padding: const EdgeInsets.all(20),
                                              // height: MediaQuery.sizeOf(context).height,
                                              height: 800,
                                              width: double.infinity,
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  WidgetUtils.modalCloseIcon(context),
                                                  const Text(
                                                    '絞り込み検索',
                                                    style: TextStyle(fontSize: 20),
                                                  ),
                                                  SingleChildScrollView(
                                                    child: Column(
                                                      children: [
                                                        Padding(
                                                          padding: const EdgeInsets.symmetric(horizontal: 30.0),
                                                          child: TextField(
                                                            controller: searchNameController,
                                                            decoration: const InputDecoration(
                                                              label: Text('商品名'),
                                                            ),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding: const EdgeInsets.all(30.0),
                                                          child: TextField(
                                                            controller: searchShopController,
                                                            decoration: const InputDecoration(label: Text('購入店舗')),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: 100,
                                                          child: PrimaryButton(
                                                              onPressed: () {
                                                                // List<Item> filteredItems = [];
                                                                // if (searchNameController.text.isNotEmpty) {
                                                                //   var result = _defaultItems
                                                                //       .where((Item item) => item.name.contains(searchNameController.text));
                                                                //   filteredItems.addAll(result);
                                                                // }
                                                                // if (searchShopController.text.isNotEmpty) {
                                                                //   var result = _defaultItems.where((Item item) =>
                                                                //       item.shop != null && item.shop!.contains(searchShopController.text));
                                                                //   filteredItems.addAll(result);
                                                                // }
                                                                // if (filteredItems.isNotEmpty) {
                                                                //   filteredItems.toSet().toList();
                                                                //   setState(() {
                                                                //     _filteredItems = filteredItems;
                                                                //   });
                                                                // }
                                                                Navigator.pop(context);
                                                              },
                                                              childText: '検索'
                                                          ),
                                                        ),
                                                        SizedBox(
                                                            width: 100,
                                                            child: ElevatedButton(
                                                                onPressed: () {
                                                                  searchNameController.text = '';
                                                                  searchShopController.text = '';
                                                                  // setState(() {
                                                                  //   _filteredItems = _defaultItems;
                                                                  // });
                                                                },
                                                                style: ElevatedButton.styleFrom(
                                                                    backgroundColor: Colors.grey,
                                                                    foregroundColor: Colors.white
                                                                ),
                                                                child: const Text('クリア')
                                                            )
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          });
                                    },
                                    child: Row(children: [
                                      const Text(
                                        '絞り込み検索',
                                        style: TextStyle(color: Colors.blue),
                                      ),
                                      const Icon(
                                        Icons.arrow_drop_down_rounded,
                                        color: Colors.blue,
                                      ),
                                      if (filteredItems.length != snapshot.data.length)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                                          child: GestureDetector(
                                            onTap: () {
                                              // setState(() {
                                              //   _filteredItems = _defaultItems;
                                              // });
                                              filteredItems = snapshot.data;
                                            },
                                            child: const Row(
                                              children: [
                                                Icon(
                                                  Icons.highlight_remove_outlined,
                                                  size: 14,
                                                  color: Colors.grey,
                                                ),
                                                Text(
                                                  '検索を解除',
                                                  style: TextStyle(color: Colors.grey, fontSize: 14),
                                                )
                                              ],
                                            ),
                                          ),
                                        )
                                    ]),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                  // child: StreamBuilder<List<Item>>(
                                  //   stream: stream,
                                  //   builder: (context, snapshot) {
                                  //     Widget page = Container();
                                  //     if (snapshot.hasError) {
                                  //       return const Text('エラーがあり取得できませんでした。');
                                  //     } else {
                                  //       switch (snapshot.connectionState) {
                                  //         case ConnectionState.none:
                                  //           page = Container();
                                  //         case ConnectionState.waiting:
                                  //           page = loadingWidget();
                                  //         case ConnectionState.active:
                                  //           page = loadingWidget();
                                  //         case ConnectionState.done:
                                  //           if (snapshot.hasData) {
                                  //             // TODO: ここでfilterの処理
                                  //             List<Item> filteredItems = snapshot.data!;
                                  //             if (searchNameController.text.isNotEmpty) {
                                  //               var result = snapshot.data!
                                  //                   .where((Item item) => item.name.contains(searchNameController.text));
                                  //               filteredItems.addAll(result);
                                  //             }
                                  //             if (searchShopController.text.isNotEmpty) {
                                  //               var result = snapshot.data!.where((Item item) =>
                                  //               item.shop != null && item.shop!.contains(searchShopController.text));
                                  //               filteredItems.addAll(result);
                                  //             }
                                  //             filteredItems.toSet().toList();
                                  //             page = ListView.builder(
                                  //                 shrinkWrap: true,
                                  //                 itemCount: filteredItems.length,
                                  //                 itemBuilder: (context, index) {
                                  //                   return WidgetUtils.itemCard(
                                  //                       ListTile(
                                  //                         onTap: () {
                                  //                           showModalBottomSheet(
                                  //                               backgroundColor: Colors.white,
                                  //                               isScrollControlled: true,
                                  //                               context: context,
                                  //                               builder: (context) {
                                  //                                 return Container(
                                  //                                   padding: const EdgeInsets.all(20.0),
                                  //                                   // height: MediaQuery.sizeOf(context).height,
                                  //                                   height: 800,
                                  //                                   width: double.infinity,
                                  //                                   child: Column(
                                  //                                     children: [
                                  //                                       WidgetUtils.modalCloseIcon(context),
                                  //                                       detailItem('商品名', filteredItems[index].name),
                                  //                                       const Divider(),
                                  //                                       detailItem('価格', '${numberFormatter.format(filteredItems[index].price)}円'),
                                  //                                       const Divider(),
                                  //                                       detailItem('残り', filteredItems[index].remainingQuantity.toString()),
                                  //                                       const Divider(),
                                  //                                       detailItem('購入店舗', filteredItems[index].shop),
                                  //                                       const Divider(),
                                  //                                       detailItem('登録者', filteredItems[index].registeredUser),
                                  //                                       const Divider()
                                  //                                     ],
                                  //                                   ),
                                  //                                 );
                                  //                               });
                                  //                         },
                                  //                         title: Text(filteredItems[index].name),
                                  //                         subtitle: Row(
                                  //                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  //                           children: [
                                  //                             Padding(
                                  //                               padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  //                               child: Text('購入金額: ${numberFormatter.format(filteredItems[index].price)}円'),
                                  //                             ),
                                  //                             Text('残り: ${filteredItems[index].remainingQuantity}')
                                  //                           ],
                                  //                         ),
                                  //                       )
                                  //                   );
                                  //                 });
                                  //           } else {
                                  //             page = const Text('登録がありません。');
                                  //           }
                                  //       }
                                  //     }
                                  //     return page;
                                  //   }
                                  // ),
                                  child: ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: filteredItems.length,
                                      itemBuilder: (context, index) {
                                        return WidgetUtils.itemCard(
                                            ListTile(
                                              onTap: () {
                                                showModalBottomSheet(
                                                    backgroundColor: Colors.white,
                                                    isScrollControlled: true,
                                                    context: context,
                                                    builder: (context) {
                                                      return Container(
                                                        padding: const EdgeInsets.all(20.0),
                                                        // height: MediaQuery.sizeOf(context).height,
                                                        height: 800,
                                                        width: double.infinity,
                                                        child: Column(
                                                          children: [
                                                            WidgetUtils.modalCloseIcon(context),
                                                            detailItem('商品名', filteredItems[index].name),
                                                            const Divider(),
                                                            detailItem('価格', '${numberFormatter.format(filteredItems[index].price)}円'),
                                                            const Divider(),
                                                            detailItem('残り', filteredItems[index].remainingQuantity.toString()),
                                                            const Divider(),
                                                            detailItem('購入店舗', filteredItems[index].shop),
                                                            const Divider(),
                                                            detailItem('登録者', filteredItems[index].registeredUser),
                                                            const Divider()
                                                          ],
                                                        ),
                                                      );
                                                    });
                                              },
                                              title: Text(filteredItems[index].name),
                                              subtitle: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                                    child: Text('購入金額: ${numberFormatter.format(filteredItems[index].price)}円'),
                                                  ),
                                                  Text('残り: ${filteredItems[index].remainingQuantity}')
                                                ],
                                              ),
                                            )
                                        );
                                      }),
                                ),
                                if (filteredItems.isEmpty)
                                // const Text('登録がありません。')
                                  Container()
                              ],
                            );
                          } else {
                            return Container();
                          }
                        }
                      );
                    } else {
                      return Container();
                    }

                  }
                ),
              ),
            ),
            // WidgetUtils.loadingStack(_isLoading)
          ]
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(
          Icons.add_rounded,
          size: 30,
        ),
        onPressed: () async{
          await Navigator.push(context, MaterialPageRoute(builder: (context) => CreateItemPage(date: _date,)));
          // setState(() {
          //   _itemIds = result;
          // });
        },
      ),
    );
  }

  static detailItem(String label, String? content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 40.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text(label, style: const TextStyle(fontSize: 16),)),
          if (content != null)
            Text(content, style: const TextStyle(fontSize: 20))
        ],
      ),
    );
  }

  static loadingWidget () {
    return Center(
      child: LoadingAnimationWidget.fourRotatingDots(color: Colors.lightGreen, size: 50),
    );
}
}
