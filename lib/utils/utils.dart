import 'dart:collection';
import 'package:table_calendar/table_calendar.dart';

class Event {
  final String title;

  const Event(this.title);

  @override
  String toString() => title;
}

// 日にちをいれるとイベントゲット
final kEvents = LinkedHashMap<DateTime, List<Event>>(
  equals: isSameDay,
  hashCode: getHashCode,
)
// イベントの内容を追加する
  ..addAll(_createEvent);

// ここでデモのイベントを作っている
final _createEvent = {
  // for (var item in List.generate(300, (index) => index))
  //   DateTime.utc(kFirstDay.year, kFirstDay.month, item * 2):
  //       List.generate(item % 4 + 1, (index) => Event('Event $item | ${index + 1}'))
  DateTime.utc(kFirstDay.year, 8, 22): [Event('event')]
}..addAll({
  // 今日のイベントのみの表記
  kToday: [const Event('Today\'s Event 1'), const Event('Today\'sEvent 2')]
});



int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}

//最初から最後までの[DateTime]オブジェクトを返す
List<DateTime>  daysInRange(DateTime first, DateTime last) {
  final dayCount = last.difference(first).inDays + 1;
  return List.generate(dayCount, (index) => DateTime.utc(first.year,first.month, first.day + index));
}



final kToday = DateTime.now();
final kFirstDay = DateTime(kToday.year, kToday.month - 3, kToday.day);
final kLastDay = DateTime(kToday.year, kToday.month + 3, kToday.day);
