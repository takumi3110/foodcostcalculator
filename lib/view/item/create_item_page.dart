import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:foodcost/component/modal_header.dart';
import 'package:foodcost/component/primary_button.dart';
import 'package:foodcost/model/account.dart';
import 'package:foodcost/model/item.dart';
import 'package:foodcost/utils/authentication.dart';
import 'package:foodcost/utils/firestore/items.dart';
import 'package:foodcost/utils/widget_utils.dart';
import 'package:intl/intl.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

class CreateItemPage extends StatefulWidget {
  final DateTime? date;

  const CreateItemPage({super.key, this.date});

  @override
  State<CreateItemPage> createState() => _CreateItemPageState();
}

class _CreateItemPageState extends State<CreateItemPage> {
  final Account? _myAccount = Authentication.myAccount;
  TextEditingController dateController = TextEditingController();
  TextEditingController shopController = TextEditingController();
  TextEditingController itemNameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  List<Map<String, TextEditingController>> itemControllers = [];
  List<Map<String, String>> items = [];

  late final DateTime? _date;
  final today = DateTime.now();

  bool _isLoading = false;

  final dateFormatter = DateFormat('yyyy年 M月 d日');
  DateTime purchaseDate = DateTime.now();

  final List<int> quantityList = List.generate(10, (index) => index + 1);

  final FocusNode _node1 = FocusNode();
  final FocusNode _node2 = FocusNode();
  final FocusNode _node3 = FocusNode();

  Widget numberInputHeader(FocusNode node) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: TextButton(
            onPressed: () => node.unfocus(),
            child: const Text(
              '完了',
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            )));
  }

  KeyboardActionsConfig _buildConfig(BuildContext context) {
    return KeyboardActionsConfig(
        keyboardActionsPlatform: KeyboardActionsPlatform.ALL,
        keyboardBarColor: Colors.grey[200],
        nextFocus: true,
        actions: [
          // KeyboardActionsItem(focusNode: _node1),
          KeyboardActionsItem(focusNode: _node2, toolbarButtons: [
            (node) {
              return numberInputHeader(node);
            }
          ]),
          KeyboardActionsItem(focusNode: _node3, toolbarButtons: [
            (node) {
              return numberInputHeader(node);
            }
          ])
        ]);
  }

  @override
  void initState() {
    setState(() {
      _date = widget.date;
    });

    dateController.text = widget.date != null
        ? dateFormatter.format(widget.date!)
        : dateFormatter.format(DateTime.now());
    itemControllers.add({
      'name': TextEditingController(),
      'price': TextEditingController(),
      'quantity': TextEditingController()
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bottomSpace = MediaQuery.of(context).viewInsets.bottom;
    final minDate = DateTime(today.year, today.month, 1);
    final maxDate = DateTime(today.year, today.month + 1, 0);

    return Scaffold(
        appBar: WidgetUtils.createAppBar(_date != null ? 'ついか' : 'とうろく'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  // key: _keyColumn,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 40.0),
                      child: TextField(
                        controller: dateController,
                        decoration: const InputDecoration(label: Text('購入日')),
                        onTap: () {
                          FocusScope.of(context).requestFocus(FocusNode());
                          if (_date == null) {
                            DatePicker.showDatePicker(
                                locale: LocaleType.jp,
                                context,
                                showTitleActions: true,
                                minTime: minDate,
                                maxTime: maxDate, onConfirm: (DateTime date) {
                              setState(() {
                                dateController.text =
                                    dateFormatter.format(date);
                                purchaseDate = date;
                              });
                            });
                          }
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 40.0),
                      child: TextField(
                        keyboardType: TextInputType.text,
                        controller: shopController,
                        decoration: const InputDecoration(label: Text('購入店舗')),
                      ),
                    ),
                    PrimaryButton(
                        onPressed: () async {
                          if (dateController.text.isNotEmpty) {
                            setState(() {
                              _isLoading = true;
                            });
                            List<Item> newItems = [];
                            for (var item in itemControllers) {
                              if (item['name']!.text.isNotEmpty &&
                                  item['price']!.text.isNotEmpty) {
                                int quantity =
                                    int.parse(item['quantity']!.text);
                                Item newItem = Item(
                                    name: item['name']!.text,
                                    price: int.parse(item['price']!.text),
                                    shop: shopController.text,
                                    remainingQuantity: quantity.toDouble(),
                                    registeredUser: _myAccount!.name,
                                    quantity: quantity);
                                newItems.add(newItem);
                              }
                            }
                            var itemIds =
                                await ItemFirestore.addItems(newItems);
                            Purchase newPurchase = Purchase(
                              date: Timestamp.fromDate(purchaseDate),
                              groupId: _myAccount!.groupId,
                              itemIds: itemIds,
                            );
                            List<dynamic> newItemIds = [];
                            if (_date != null) {
                              // 日付がある時更新。item追加処理
                              // グループいる時とソロの時処理が違う
                              newItemIds = _myAccount!.groupId != null
                                  ? await ItemFirestore
                                      .updateGroupPurchaseItems(
                                          _myAccount!.groupId!, _date!, itemIds)
                                  : await ItemFirestore.updatePurchaseItems(
                                      _date!, itemIds);
                            } else {
                              // 日付がないので新規登録
                              newItemIds =
                                  await ItemFirestore.addPurchase(newPurchase);
                            }
                            setState(() {
                              _isLoading = false;
                            });
                            if (newItemIds.isNotEmpty) {
                              if (!context.mounted) return;
                              Navigator.pop(context, newItemIds);
                            } else {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('登録に失敗しました。')));
                            }
                          }
                        },
                        childText: '登録'),
                    const Divider(),
                    Expanded(
                      child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            return Dismissible(
                              key: UniqueKey(),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: ListTile(
                                  title: Text(items[index]['name']!),
                                  subtitle: Text(items[index]['price']!),
                                ),
                              ),
                            );
                          }),
                    ),
                    if (bottomSpace == 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orangeAccent),
                          onPressed: () async {
                            await showModalBottomSheet(
                                elevation: 0,
                                context: context,
                                builder: (BuildContext context) {
                                  onPressAdd() {
                                    if (itemNameController.text.isNotEmpty &&
                                        priceController.text.isNotEmpty) {
                                      setState(() {
                                        items.add({
                                          'name': itemNameController.text,
                                          'price': priceController.text,
                                          'quantity': quantityController.text
                                        });
                                      });
                                      Navigator.pop(context);
                                      itemNameController.clear();
                                      priceController.clear();
                                      quantityController.clear();
                                    }
                                  }

                                  onPressCancel() {
                                    Navigator.pop(context);
                                    itemNameController.clear();
                                    priceController.clear();
                                    quantityController.clear();
                                  }

                                  return Container(
                                    width: double.infinity,
                                    height:
                                        MediaQuery.sizeOf(context).height * 0.7,
                                    decoration: const BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(20),
                                        topRight: Radius.circular(20),
                                      ),
                                      color: Colors.white,
                                    ),
                                    child: Padding(
                                      padding:
                                          MediaQuery.of(context).viewInsets,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          ModalHeader(
                                              onPressAdd: onPressAdd,
                                              onPressCancel: onPressCancel),
                                          Expanded(
                                              child: SingleChildScrollView(
                                            child: Container(
                                              width: 300,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 20,
                                                      horizontal: 20),
                                              child: Center(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    const SizedBox(height: 20),
                                                    SizedBox(
                                                      height: MediaQuery.sizeOf(
                                                                  context)
                                                              .height *
                                                          0.7,
                                                      child: KeyboardActions(
                                                        config: _buildConfig(
                                                            context),
                                                        child: Column(
                                                          children: [
                                                            TextField(
                                                              controller:
                                                                  itemNameController,
                                                              decoration:
                                                                  const InputDecoration(
                                                                      labelText:
                                                                          '商品名'),
                                                              keyboardType:
                                                                  TextInputType
                                                                      .text,
                                                              focusNode: _node1,
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          10),
                                                              child: Row(
                                                                // mainAxisSize: MainAxisSize.min,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,

                                                                children: [
                                                                  SizedBox(
                                                                    width: 150,
                                                                    child:
                                                                        TextField(
                                                                      controller:
                                                                          priceController,
                                                                      decoration: const InputDecoration(
                                                                          labelText:
                                                                              '金額',
                                                                          suffix:
                                                                              Text('円')),
                                                                      keyboardType:
                                                                          TextInputType
                                                                              .number,
                                                                      focusNode:
                                                                          _node2,
                                                                      textAlign:
                                                                          TextAlign
                                                                              .right,
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    width: 100,
                                                                    child:
                                                                        TextField(
                                                                      controller:
                                                                          quantityController,
                                                                      decoration: const InputDecoration(
                                                                          labelText:
                                                                              '個数',
                                                                          suffix:
                                                                              Text('個')),
                                                                      keyboardType:
                                                                          TextInputType
                                                                              .number,
                                                                      focusNode:
                                                                          _node3,
                                                                      textAlign:
                                                                          TextAlign
                                                                              .right,
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ))
                                        ],
                                      ),
                                    ),
                                  );
                                });
                          },
                          label: const Text('追加'),
                          icon: const Icon(Icons.add),
                        ),
                      )
                  ],
                ),
              ),
              WidgetUtils.loadingStack(_isLoading)
            ],
          ),
        ));

    // final column = Column(
    //   // key: _keyColumn,
    //   crossAxisAlignment: CrossAxisAlignment.center,
    //   children: [
    //     Padding(
    //       padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 40.0),
    //       child: TextField(
    //         controller: dateController,
    //         decoration: const InputDecoration(
    //             label: Text('購入日')
    //         ),
    //         onTap: () {
    //           FocusScope.of(context).requestFocus(FocusNode());
    //         },
    //       ),
    //     ),
    //     Padding(
    //       padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 40.0),
    //       child: TextField(
    //         keyboardType: TextInputType.text,
    //         controller: shopController,
    //         decoration: const InputDecoration(
    //             label: Text('購入店舗')
    //         ),
    //       ),
    //     ),
    //     const Divider(),
    //     SizedBox(
    //       height: 500,
    //       child: ListView.builder(
    //           shrinkWrap: true,
    //           itemCount: itemControllers.length,
    //           itemBuilder: (context, index) {
    //             return Padding(
    //               padding: const EdgeInsets.symmetric(horizontal: 40.0),
    //               child: Row(
    //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                 children: [
    //                   SizedBox(
    //                     width: 200,
    //                     child: TextField(
    //                       keyboardType: TextInputType.text,
    //                       controller: itemControllers[index]['name'],
    //                       decoration: const InputDecoration(
    //                           label: Text('商品名')
    //                       ),
    //                       onSubmitted: (_) {
    //                         if (itemControllers.last['price']!.text.isNotEmpty) {
    //                           setState(() {
    //                             itemControllers.add({
    //                               'name': TextEditingController(),
    //                               'price': TextEditingController()
    //                             });
    //                             FocusNode addNode = FocusNode();
    //                             _nodeTextList.add(addNode);
    //                           });
    //                         }
    //                       },
    //                     ),
    //                   ),
    //                   Row(
    //                     mainAxisAlignment: MainAxisAlignment.start,
    //                     crossAxisAlignment: CrossAxisAlignment.end,
    //                     children: [
    //                       SizedBox(
    //                         width: 100,
    //                         child: TextField(
    //                           // keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
    //                           keyboardType: TextInputType.number,
    //                           focusNode: _nodeTextList[index],
    //                           controller: itemControllers[index]['price'],
    //                           decoration: const InputDecoration(
    //                               label: Text('価格'),
    //                             suffix: Text('円')
    //                           ),
    //                           onSubmitted: (_) {
    //                             if (itemControllers.last['name']!.text.isNotEmpty) {
    //                               setState(() {
    //                                 itemControllers.add({
    //                                   'name': TextEditingController(),
    //                                   'price': TextEditingController()
    //                                 });
    //                               });
    //                             }
    //                           },
    //                         ),
    //                       ),
    //                       Padding(
    //                         padding: const EdgeInsets.only(left: 10),
    //                         child: GestureDetector(
    //                           onTap: () {
    //                             if (itemControllers.length > 1) {
    //                               setState(() {
    //                                 itemControllers.removeAt(index);
    //                                 _nodeTextList.removeAt(index);
    //                               });
    //                             }
    //                           },
    //                           child: const Icon(Icons.delete_forever_rounded, color: Colors.grey,),
    //                         ),
    //                       )
    //                     ],
    //                   ),
    //
    //                 ],
    //               ),
    //             );
    //           }
    //       ),
    //     ),
    //     PrimaryButton(onPressed: () {}, childText: '登録')
    //   ],
    // );
    //
    // return Scaffold(
    //   appBar: WidgetUtils.createAppBar('とうろく'),
    //   body: SafeArea(
    //     child: Padding(
    //       padding: const EdgeInsets.symmetric(vertical: 20.0),
    //       child: _columnSize > 0 ? SizedBox(
    //         height: _columnSize,
    //         child: KeyboardActions(
    //           config: _buildConfig(context),
    //           child: column
    //         ),
    //       ): column,
    //     ),
    //   ),
    // );
  }
}
