import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foodcost/model/item.dart';
import 'package:foodcost/utils/calendar_utils.dart';
import 'package:foodcost/utils/widget_utils.dart';
import 'package:intl/intl.dart';


class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  DateTimeRange? _dateTimeRange;

  // TODO: 日付でソートして、まとめて表示。日付クリックで買ったものの中身
  final List<RegisteredItems> registeredItems = [
    RegisteredItems(
        registeredDate: '2024年4月15日', items: [
      Item(name: 'item1', userId: 'userId', price: 100),
      Item(name: 'item2', userId: 'userId', price: 400),
      Item(name: 'item3', userId: 'userId', price: 300)
    ]
    ),
    RegisteredItems(
        registeredDate: '2024年4月16日', items: [
      Item(name: 'item1', userId: 'userId', price: 100),
      Item(name: 'item2', userId: 'userId', price: 400),
      Item(name: 'item3', userId: 'userId', price: 300)
    ]
    ),
  ];

  final dateFormat = DateFormat('yyyy-MM-dd');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WidgetUtils.createAppBar('買ったもの'),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                  onTap: () {
                    // _showSearchModal(context);
                    _showDateRangePicker(context);
                  },
                  child: Row(
                    children: [
                      const Text('購入日で検索', style: TextStyle(color: Colors.blue)),
                      const Icon(
                        Icons.arrow_drop_down_rounded,
                        color: Colors.blue,
                      ),
                      if (_dateTimeRange != null)
                        Row(
                          children: [
                            const SizedBox(width: 10,),
                            Text(dateFormat.format(_dateTimeRange!.start)),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text('~'),
                            ),
                            Text(dateFormat.format(_dateTimeRange!.end)),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _dateTimeRange = null;
                                  });
                                },
                                  child: const Icon(
                                      Icons.highlight_remove_rounded,
                                      size: 16,
                                    color: Colors.grey,
                                  )
                              ),
                            )
                          ],
                        )
                    ],
                  )),
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: registeredItems.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        // padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: const BorderRadius.all(Radius.circular(10))),
                        child: ListTile(
                            onTap: () {},
                            // title: Text('4月15日')
                            title: Text(registeredItems[index].registeredDate)
                        ),
                      );
                    }),
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
        onPressed: () {},
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
              datePickerTheme: const DatePickerThemeData(
                backgroundColor: Colors.white
              ),
            ),
            child: child!,
          );
      }
    );
    if (range != null) {
      setState(() {
        _dateTimeRange = range;
      });
    }
  }
}
