import 'package:flutter/material.dart';
import 'package:foodcost/model/menu.dart';
import 'package:foodcost/utils/firestore/posts.dart';
import 'package:foodcost/view/create/create_menu_page.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:foodcost/utils/widget_utils.dart';
import 'package:foodcost/utils/calendar_utils.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
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
    _selectedDay = _focusedDay;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: WidgetUtils.createAppBar('カレンダー', _scaffoldKey),
      drawer: WidgetUtils.sideMenuDrawer(context),
      body: Padding(
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
              headerStyle: const HeaderStyle(
                  formatButtonVisible: false
              ),
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
                child: ValueListenableBuilder<List<Event>>(
                  valueListenable: _selectedEvents,
                  builder: (context, value, _) {
                    return FutureBuilder<List<Menu>?>(
                      // TODO: selectした日付でメニューを取得？
                      future: PostFirestore.getPostMenuMap(_selectedDay),
                      builder: (context, snapshot) {
                        return ListView.builder(
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              return Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: ListTile(
                                    onTap: () => {
                                      // とりあえず
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateMenuPage()))
                                    },
                                    title: Text(snapshot.data![index].name),
                                  ));
                            });
                      }

                    );
                  },
                ))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateMenuPage()));
        },
        child: const Icon(Icons.add_outlined),
      ),
    );
  }
}
