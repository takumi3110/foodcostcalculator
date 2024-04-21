import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// import 'package:foodcost/model/account.dart';
import 'package:foodcost/model/item.dart';
import 'package:foodcost/utils/authentication.dart';
import 'package:foodcost/utils/calendar_utils.dart';
import 'package:foodcost/utils/firestore/items.dart';
import 'package:foodcost/utils/widget_utils.dart';
import 'package:foodcost/view/item/create_item_page.dart';
import 'package:foodcost/view/item/item_list_page.dart';
import 'package:intl/intl.dart';

class DateListPage extends StatefulWidget {
  const DateListPage({super.key});

  @override
  State<DateListPage> createState() => _DateListPageState();
}

class _DateListPageState extends State<DateListPage> {
  DateTimeRange? _dateTimeRange;
  // List<Purchase> _defaultPurchases = [];
  // List<Purchase> _filteredPurchases = [];

  final dateFormatter = DateFormat('yyyy年M月d日');
  
  // void getPurchases(Account myAccount) async {
  //   List<Purchase> results = [];
  //   if (myAccount.groupId != null) {
  //     results = await ItemFirestore.getGroupPurchase(myAccount.groupId!);
  //   } else {
  //     results = await ItemFirestore.getMyPurchase(myAccount.id);
  //   }
  //   setState(() {
  //     _defaultPurchases = results;
  //     _filteredPurchases = results;
  //   });
  // }
  
  @override
  void initState() {
    // if (Authentication.myAccount != null)  {
    //   getPurchases(Authentication.myAccount!);
    // }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WidgetUtils.createAppBar('買った日'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                  onTap: () {
                    // _showSearchModal(context);
                    _showDateRangePicker(context);
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text('購入日で検索', style: TextStyle(color: Colors.blue)),
                          Icon(
                            Icons.arrow_drop_down_rounded,
                            color: Colors.blue,
                          ),
                        ],
                      ),
                      if (_dateTimeRange != null)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(dateFormatter.format(_dateTimeRange!.start)),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text('~'),
                            ),
                            Text(dateFormatter.format(_dateTimeRange!.end)),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _dateTimeRange = null;
                                      // _filteredPurchases = _defaultPurchases;
                                    });
                                  },
                                  child: const Icon(
                                    Icons.highlight_remove_rounded,
                                    size: 20,
                                    color: Colors.grey,
                                  )),
                            )
                          ],
                        )
                    ],
                  )),
              Padding(
                padding: const EdgeInsets.only(top: 30.0),
                child: StreamBuilder<QuerySnapshot>(
                  stream: ItemFirestore.purchases.where('group_id', isEqualTo: Authentication.myAccount!.groupId!).snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List<Purchase> getPurchases = [];
                      for (var doc in snapshot.data!.docs) {
                        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                        Purchase purchase = Purchase(
                          id: doc.id,
                          date: data['date'],
                          itemIds: data['item_ids'],
                          groupId: data['group_id'],
                        );
                        if (_dateTimeRange != null) {
                          if (purchase.date.toDate().isAfter(_dateTimeRange!.start)) {
                            getPurchases.add(purchase);
                          }
                        }else {
                          getPurchases.add(purchase);
                        }
                      }
                      return ListView.builder(
                          shrinkWrap: true,
                          itemCount: getPurchases.length,
                          itemBuilder: (context, index) {
                            return WidgetUtils.itemCard(ListTile(
                              onTap: () {
                                Navigator.push(
                                    context, MaterialPageRoute(builder: (context) => ItemListPage(purchaseId: getPurchases[index].id, selectedDate: getPurchases[index].date.toDate(),)));
                                    // MaterialPageRoute(
                                    //     builder: (context) => ItemListPage(
                                    //         selectedDate: getPurchases[index].date.toDate(),
                                    //         itemIds: getPurchases[index].itemIds)));
                              },
                              // title: Text('4月15日')
                              title: Text(dateFormatter.format(getPurchases[index].date.toDate())),
                            ));
                          });
                    } else {
                      return const Text('登録がありません。');
                    }
                  }
                )
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(
          Icons.add_rounded,
          size: 30,
        ),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateItemPage()));
        },
      ),
    );
  }

  Future<void> _showDateRangePicker(BuildContext context) async {
    final DateTimeRange? range = await showDateRangePicker(
        context: context,
        initialDateRange: _dateTimeRange,
        firstDate: kFirstDay,
        lastDate: kLastDay,
        confirmText: 'OK',
        saveText: 'OK',
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: Theme.of(context).copyWith(
              datePickerTheme: const DatePickerThemeData(backgroundColor: Colors.white),
            ),
            child: child!,
          );
        });
    if (range != null) {
      setState(() {
        _dateTimeRange = range;
      //  startの日付とendの日付を検索。のちset().toList()
      //   List<Purchase> filteredPurchase = [];
        // var startResult = _defaultPurchases.where((Purchase purchase) => purchase.date.toDate().isAfter(range.start));
        // var endResult = _defaultPurchases.where((Purchase purchase) => purchase.date.toDate().isBefore(range.end));
        // filteredPurchase.addAll([...startResult, ...endResult]);
        // filteredPurchase.toSet().toList();
        // _filteredPurchases = filteredPurchase;
      });
    }
  }
}
