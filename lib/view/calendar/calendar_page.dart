import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foodcost/model/account.dart';
import 'package:foodcost/model/food.dart';
import 'package:foodcost/model/menu.dart';
import 'package:foodcost/utils/authentication.dart';
import 'package:foodcost/utils/firestore/menus.dart';
import 'package:foodcost/view/menu/create_menu_page.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:foodcost/utils/widget_utils.dart';
import 'package:foodcost/utils/calendar_utils.dart';

class CalendarPage extends StatefulWidget {
  final DateTime? selectedDay;

  const CalendarPage({super.key, this.selectedDay});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  Account myAccount = Authentication.myAccount!;
  late final ValueNotifier<List<Event>> _selectedEvents;

  // CalendarFormat _calendarFormat = CalendarFormat.month;
  // RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // DateTime? _rangeStart;
  // DateTime? _rangeEnd;

  @override
  void initState() {
    super.initState();
    if (widget.selectedDay != null) {
      _selectedDay = widget.selectedDay;
    } else {
      _selectedDay = _focusedDay;
    }
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  // ここでイベントをゲット
  List<Event> _getEventsForDay(DateTime day) {
    return kEvents[day] ?? [];
    // return [];
  }

  // イベントをレンジで表示？
  // List<Event> _getEventsForRange(DateTime start, DateTime end) {
  //   final days = daysInRange(start, end);
  //   return [
  //     for (final d in days) ..._getEventsForDay(d),
  //   ];
  // }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        // _rangeStart = null;
        // _rangeEnd = null;
        // _rangeSelectionMode = RangeSelectionMode.toggledOff;
      });
      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

  // レンジを選択
  // void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
  //   setState(() {
  //     _selectedDay = null;
  //     _focusedDay = focusedDay;
  //     _rangeStart = start;
  //     _rangeEnd = end;
  //     _rangeSelectionMode = RangeSelectionMode.toggledOff;
  //   });
  //   // start or end はnullの可能性がある
  //   if (start != null && end != null) {
  //     _selectedEvents.value = _getEventsForRange(start, end);
  //   } else if (start != null) {
  //     _selectedEvents.value = _getEventsForDay(start);
  //   } else if (end != null) {
  //     _selectedEvents.value = _getEventsForDay(end);
  //   }
  // }

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final formatter = NumberFormat('#,###');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: WidgetUtils.createAppBar('カレンダー', _scaffoldKey),
      drawer: WidgetUtils.sideMenuDrawer(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              TableCalendar(
                locale: 'ja_JP',
                firstDay: kFirstDay,
                lastDay: kLastDay,
                focusedDay: _focusedDay,
                // calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) {
                  // `selectedDayPredicate`を使用して、現在選択されている日を決定します。
                  // これが true を返す場合、`day` は選択済みとしてマークされます。
                  // `isSameDay`の使用は無視することをお勧めします
                  // 比較されたDateTimeオブジェクトの時間部分。
                  return isSameDay(_selectedDay, day);
                },
                // rangeStartDay: _rangeStart,
                // rangeEndDay: _rangeEnd,
                // rangeSelectionMode: _rangeSelectionMode,
                // eventLoader: _getEventsForDay,
                startingDayOfWeek: StartingDayOfWeek.monday,
                calendarStyle: const CalendarStyle(outsideDaysVisible: false),
                onDaySelected: _onDaySelected,
                // onRangeSelected: _onRangeSelected,
                // onFormatChanged: (format) {
                //   if (_calendarFormat != format) {
                //     // formatを更新するときに `setState()` を呼び出します
                //     setState(() {
                //       _calendarFormat = format;
                //     });
                //   }
                // },
                onPageChanged: (focusedDay) {
                  // ここで`setState()`を呼び出す必要はありません
                  _focusedDay = focusedDay;
                },
                // format buttonを消す
                headerStyle: const HeaderStyle(formatButtonVisible: false),
                calendarBuilders: CalendarBuilders(dowBuilder: (_, day) {
                  final text = DateFormat.E('ja').format(day);
                  if (day.weekday == DateTime.sunday) {
                    return Center(
                      child: Text(text, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    );
                  } else if (day.weekday == DateTime.saturday) {
                    return Center(
                      child: Text(
                        text,
                        style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                      ),
                    );
                  }
                  return null;
                }),
              ),
              const SizedBox(
                height: 8.0,
              ),
              const Divider(),
              Expanded(
                  child: SingleChildScrollView(
                child: ValueListenableBuilder<List<Event>>(
                    // Eventは{title: ''}
                    // Eventがvalueに入ってくる
                    // _selectedEventsでvalueを指定
                    valueListenable: _selectedEvents,
                    builder: (context, value, _) {
                      return StreamBuilder<QuerySnapshot>(
                          stream: MenuFirestore.menus.where('user_id', isEqualTo: myAccount.id).snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              num allTotalAmount = 0;
                              List<Menu> getMenus = [];
                              DateFormat dateFormat = DateFormat('yyyy-MM-dd');
                              for (var doc in snapshot.data!.docs) {
                                Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                                List<Food> foods = [];
                                if (data['foods'] != null) {
                                  for (var food in data['foods']) {
                                    Food getFood = Food(
                                        name: food['name'],
                                        unitPrice: food['unit_price'],
                                        costCount: food['cost_count'],
                                        price: food['price']);
                                    foods.add(getFood);
                                  }
                                }
                                Menu getMenu = Menu(
                                    id: doc.id,
                                    name: data['name'],
                                    userId: data['user_id'],
                                    totalAmount: data['total_amount'],
                                    imagePath: data['image_path'],
                                    createdTime: data['created_time'],
                                    foods: foods);
                                Timestamp createdTime = data['created_time'];
                                if (dateFormat.format(_selectedDay!) == dateFormat.format(createdTime.toDate())) {
                                  getMenus.add(getMenu);
                                  allTotalAmount += data['total_amount'];
                                }
                              }
                              // return WidgetUtils.menuListTile(getMenus, allTotalAmount);
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                    child: Text(
                                      '合計金額: ${formatter.format(allTotalAmount)} 円',
                                      style: const TextStyle(fontSize: 18.0),
                                    ),
                                  ),
                                  WidgetUtils.menuListTile(getMenus)
                                ],
                              );
                            } else {
                              return Container();
                            }
                          });
                    }),
              ))
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => CreateMenuPage(selectedDay: _selectedDay)));
        },
        child: const Icon(Icons.add_outlined),
      ),
    );
  }
}
