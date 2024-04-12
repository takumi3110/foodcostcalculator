import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foodcost/component/cancel_button.dart';
import 'package:foodcost/component/primary_button.dart';
import 'package:foodcost/model/account.dart';
import 'package:foodcost/model/menu.dart';
import 'package:foodcost/model/target.dart';
import 'package:foodcost/presentation/resources/app_colors.dart';
import 'package:foodcost/utils/authentication.dart';
import 'package:foodcost/utils/calendar_utils.dart';
import 'package:foodcost/utils/chart_utils.dart';
import 'package:foodcost/utils/firestore/menus.dart';
import 'package:foodcost/utils/firestore/targets.dart';
import 'package:foodcost/utils/widget_utils.dart';
import 'package:foodcost/view/calendar/calendar_page.dart';
import 'package:intl/intl.dart';

class CostPage extends StatefulWidget {
  const CostPage({super.key});

  @override
  State<CostPage> createState() => _CostPageState();
}

class _CostPageState extends State<CostPage> {
  Account myAccount = Authentication.myAccount!;
  List<Menu> menus = [];
  List<Map<String, dynamic>> menuRankings = [];
  bool _isLoading = false;

  // グラフの色
  List<Color> gradientColors = [
    AppColors.contentColorBlue,
    AppColors.contentColorCyan,
  ];

  // 目標金額
  String targetId = '';
  double targetDayAmount = 0;
  int targetMonthAmount = 0;
  TextEditingController targetDayAmountController = TextEditingController();
  TextEditingController targetMonthAmountController = TextEditingController();

  // 週の初めの日
  int weekStartDay = 1;

  // 週のリスト
  List<DateTime> dateList = [];

  // 合計金額とその月の最高額
  num allTotalAmount = 0;
  num maxDayAmount = 0;

  // 金額の桁区切り
  final numberFormatter = NumberFormat('#,###');

  // 日付のフォーマット
  final dateFormatter = DateFormat('M月d日');

  void createDayList(int startDay) {
    // 引数dayが0より小さい時は1
    final day = startDay > 0 ? startDay : 1;
    // 1日のとき、1日が月曜じゃない場合
    if (day == 1) {
      // 先月の最終日
      final prevMonthLastDate = DateTime(kToday.year, kToday.month, 0);
      // final prevMonthLastDate = DateTime(kToday.year, 5, 0);
      // 1日の曜日取得
      final firstDate = DateTime(kToday.year, kToday.month, 1);
      final weekDay = firstDate.weekday;
      // 月曜じゃないとき
      if (weekDay != 1) {
        // 月曜までの差分　月曜は1
        final differenceOfMonday = startDay - 1;
        // 先月最終日から先月最終週の月曜を取得
        final notEnoughDate = prevMonthLastDate.add(Duration(days: differenceOfMonday));
        // final notEnoughDate = prevMonthLastDate.add(Duration(days: startDay));
        final prevWeekLength = prevMonthLastDate.day - notEnoughDate.day;
        // final List<int> prevDates = List.generate(prevWeekLength, (index) => index + 1 + notEnoughDate.day);
        final List<DateTime> prevDates = List.generate(prevWeekLength,
            (index) => DateTime(prevMonthLastDate.year, prevMonthLastDate.month, index + 1 + notEnoughDate.day));
        //   当月1日から日曜日までの距離
        final weekLength = 7 - weekDay;
        //   日曜日までのリスト
        // final List<int> dates = List.generate(weekLength + 1, (index) => index + 1);
        final List<DateTime> dates =
            List.generate(weekLength + 1, (index) => DateTime(kToday.year, kToday.month, index + 1));
        prevDates.addAll(dates);
        dateList = prevDates;
        // weekList = prevDates.addAll(dates);
      } else {
        dateList = List.generate(7, (index) => DateTime(kToday.year, kToday.month, index + day));
      }
    } else {
      // 基本はこれ
      // dateList = List.generate(7, (index) => index + day);
      dateList = List.generate(7, (index) => DateTime(kToday.year, kToday.month, index + day));
    }
  }

  static getCurrentMonday() {
    // 当日がある1週間を取得
    final weekDay = kToday.weekday;
    final monday = kToday.add(Duration(days: int.parse('-$weekDay') + 1));
    return monday.day;
  }

  // グラフの数値を作成
  void createAmounts() async {
    final results = myAccount.groupId != null ? await MenuFirestore.getMenus(myAccount.groupId!, true)
        : await MenuFirestore.getMenus(myAccount.id, false);
    if (results != null) {
      setState(() {
        List<num> amounts = [];
        menus = results;
        // List<Map<String, dynamic>> rankings = [];
        // Map<String, int> ranking = {};
        // 当日がある1週間を取得
        // final weekDay = kToday.weekday;
        // final monday = kToday.add(Duration(days: int.parse('-$weekDay') + 1));
        final monday = getCurrentMonday();
        weekStartDay = monday;
        createDayList(monday);
        for (var i = 1; i <= currentMonthLastDay; i++) {
          final filterMenu = results.where((result) => result.createdTime.toDate().day == i).toList();
          num totalAmount = 0;
          filterMenu.forEach((Menu menu) {
            totalAmount += menu.totalAmount as num;
            allTotalAmount += menu.totalAmount as int;
          });
          // rankingを作成
          if (totalAmount > 0) {
            menuRankings.add({
              'dateTime': DateTime(kToday.year, kToday.month, i),
              'totalAmount': totalAmount,
            });
          }
          // 日毎の合計金額をリストへ
          amounts.add(totalAmount);
        }
        // リスト化した日毎の合計金額を大きい順にソート
        amounts.sort((a, b) => b.compareTo(a));
        // rankingを金額順にソート
        menuRankings.sort((a, b) => b['totalAmount'].compareTo(a['totalAmount']));

        // 最大の金額を設定
        maxDayAmount = amounts[0];
      });
    }
  }

  // 目標金額を取得
  void getTargetAmounts() async {
    var result = await TargetFirestore.getTarget(myAccount.id);
    if (result != null) {
      // if (myAccount.groupId != null && myAccount.groupId == result.groupId) {
      //   await TargetFirestore.addTargetToUserCollection(myAccount.id, result.id);
      // }
      setState(() {
        targetDayAmountController.text = result.dayAmount.toString();
        targetMonthAmountController.text = result.monthAmount.toString();
        targetId = result.id;
        targetDayAmount = result.dayAmount.toDouble();
        targetMonthAmount = result.monthAmount;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    createAmounts();
    getTargetAmounts();
  }

  @override
  Widget build(BuildContext context) {
    final double deviceHeight = MediaQuery.of(context).size.height;
    void showTargetDialog() async {
      await showDialog(
          context: context,
          builder: (_) {
            return Stack(
              children: [
                AlertDialog(
                  backgroundColor: Colors.white,
                  surfaceTintColor: Colors.transparent,
                  title: const Text('目標金額の設定'),
                  actions: [
                    PrimaryButton(onPressed: () async {
                      if (
                      targetMonthAmountController.text.isNotEmpty
                          && targetDayAmountController.text.isNotEmpty
                          && targetDayAmount != double.parse(targetDayAmountController.text)
                          && targetMonthAmount != int.parse(targetMonthAmountController.text)
                      ) {
                        setState(() {
                          _isLoading = true;
                        });

                        Target newTarget = Target(
                          id: targetId,
                          monthAmount: int.parse(targetMonthAmountController.text),
                          dayAmount: int.parse(targetDayAmountController.text),
                          createdUserId: myAccount.id,
                          groupId: myAccount.groupId,
                        );
                        // resultに代入
                        bool result = false;
                        if (targetId.isNotEmpty) {
                          result = await TargetFirestore.updateTarget(newTarget);
                        } else {
                          var getResult = await TargetFirestore.addTarget(newTarget);
                          setState(() {
                            if (getResult != null) {
                              result = true;
                              targetId = getResult.id;
                            }
                          });
                        }
                        if (result == true) {
                          setState(() {
                            targetDayAmount = double.parse(targetDayAmountController.text);
                            targetMonthAmount = int.parse(targetMonthAmountController.text);
                            _isLoading = false;
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('目標金額を更新しました。'))
                            );
                          });
                        }

                      }
                    }, childText: '保存'),
                    CancelButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        text: 'キャンセル'
                    )
                  ],
                  content: SizedBox(
                    height: deviceHeight * 0.2,
                    child: Column(
                      children: [
                        TextField(
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          controller: targetDayAmountController,
                          decoration: const InputDecoration(labelText: '1日の金額', suffix: Text('円')),
                          onChanged: (String value) {
                            if (value.isNotEmpty) {
                              setState(() {
                                targetMonthAmountController.text = (int.parse(value) * currentMonthLastDay).toString();
                              });
                            }
                          },
                        ),
                        TextField(
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          controller: targetMonthAmountController,
                          decoration: const InputDecoration(labelText: '今月', suffix: Text('円')),
                        )
                      ],
                    ),
                  ),
                ),
                WidgetUtils.loadingStack(_isLoading)
              ]
            );
          });
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: WidgetUtils.createAppBar('今月のグラフ'),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0, bottom: 40.0),
              child: SingleChildScrollView(
                child: Column(
                  // crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      child: ElevatedButton(onPressed: showTargetDialog, child: const Text('目標金額を設定')),
                    ),
                    AspectRatio(
                      aspectRatio: 1.66,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 16, left: 12, right: 12),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            // final barsSpace = 8.0 * constraints.maxWidth / 400;
                            final barsSpace = 5.0 * constraints.maxWidth / 100;
                            // final barsSpace = 15.0;
                            final barsWidth = 9.0 * constraints.maxWidth / 100;
                            return BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.center,
                                barTouchData: BarTouchData(
                                    enabled: true,
                                    touchTooltipData: BarTouchTooltipData(
                                        maxContentWidth: 100,
                                        tooltipBgColor: Colors.orangeAccent,
                                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                          return BarTooltipItem(
                                            '${group.x}日 ',
                                            const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                            ),
                                            children: <TextSpan>[
                                              TextSpan(
                                                // text: (rod.toY - 1).toString(),
                                                text: '${(rod.toY.toStringAsFixed(0)).toString()}円',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          );
                                        })),
                                titlesData: FlTitlesData(
                                  show: true,
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 28,
                                      getTitlesWidget: bottomTitleWidgets,
                                    ),
                                  ),
                                  leftTitles: const AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 40,
                                      getTitlesWidget: ChartUtils.leftTitleWidgets,
                                    ),
                                  ),
                                  topTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  rightTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                ),
                                gridData: FlGridData(
                                  show: true,
                                  horizontalInterval: 1,
                                  // checkToShowHorizontalLine: (value) => numberFormatter.format(value) == numberFormatter.format(targetDayAmount),
                                  checkToShowHorizontalLine: (value) => value == targetDayAmount,
                                  // getDrawingHorizontalLine: (value) => FlLine(
                                  //   color: AppColors.borderColor.withOpacity(0.1),
                                  //   strokeWidth: 1,
                                  // ),
                                  drawVerticalLine: false,
                                ),
                                // borderData: FlBorderData(
                                //   show: true,
                                //   border: Border.all(color: const Color(0xff78857e))
                                // ),
                                borderData: FlBorderData(show: false),
                                groupsSpace: barsSpace,
                                barGroups: getData(barsWidth, barsSpace),
                                minY: 0,
                                // プラス100を区切りよく。一回100で割って小数点を消してまた100をかけてキリよく
                                maxY: double.parse(((maxDayAmount + 100) / 100).toStringAsFixed(0)) * 100,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (weekStartDay > 1)
                          SizedBox(
                            // width: 90,
                            height: 40,
                            child: TextButton(
                                onPressed: () {
                                  // 週初めの日にちが1より大きくないと動作しないように
                                  if (weekStartDay > 1) {
                                    // 前週の月曜
                                    final prevWeekStartDay = weekStartDay - 7;
                                    setState(() {
                                      // 前週の月曜が1より小さい場合
                                      createDayList(prevWeekStartDay);
                                      weekStartDay = prevWeekStartDay;
                                    });
                                  }
                                },
                                child: const Text('前週')),
                          ),
                        if (weekStartDay == 1)
                          const SizedBox(width: 60,),
                        if (weekStartDay <= 0)
                          const SizedBox(
                            height: 40,
                            width: 60,
                          ),
                        SizedBox(
                          // width: 90,
                          height: 40,
                          child: TextButton(
                              onPressed: () {
                                //   当日がある週に戻る
                                setState(() {
                                  final monday = getCurrentMonday();
                                  createDayList(monday);
                                  weekStartDay = monday;
                                });
                              },
                              child: const Text('当日')),
                        ),
                        if (weekStartDay + 7 <= currentMonthLastDay)
                          SizedBox(
                            // width: 90,
                              height: 40,
                              child: TextButton(
                                  onPressed: () {
                                    final nextWeekStartDay = weekStartDay + 7;
                                    if (nextWeekStartDay <= currentMonthLastDay) {
                                      setState(() {
                                        createDayList(nextWeekStartDay);
                                        weekStartDay = nextWeekStartDay;
                                      });
                                    }
                                  },
                                  child: const Text('次週'))),
                        if (weekStartDay + 7 >= currentMonthLastDay)
                          const SizedBox(
                            height: 40,
                            width: 60,
                          ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Column(
                        children: [
                          Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(horizontal: 5.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '合計金額: ${numberFormatter.format(allTotalAmount)} 円',
                                  style: const TextStyle(fontSize: 20.0),
                                ),
                                const SizedBox(
                                  width: 20.0,
                                ),
                                Text(
                                  (targetMonthAmount - allTotalAmount) > 0 ? 'あと': '＋',
                                  style: TextStyle(
                                      color: (targetMonthAmount - allTotalAmount) > 0 ? Colors.blueAccent: Colors.red
                                    // fontSize: 12
                                  ),
                                ),
                                Text(
                                  '${numberFormatter.format(targetMonthAmount - allTotalAmount)}円',
                                  style: TextStyle(
                                      color: (targetMonthAmount - allTotalAmount) > 0 ? Colors.blueAccent: Colors.red
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // 金額高い日付順にリスト欲しいかも
                          ListView.builder(
                              shrinkWrap: true,
                              itemCount: menuRankings.length > 6 ? 5 : menuRankings.length,
                              itemBuilder: (context, index) {
                                final dateTime = menuRankings[index]['dateTime'];
                                final totalAmount = menuRankings[index]['totalAmount'];
                                final isOver = totalAmount >= targetDayAmount;
                                return Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: ListTile(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) => CalendarPage(
                                                    selectedDay: dateTime,
                                                  )));
                                        },
                                        title: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text((index + 1).toString()),
                                                const SizedBox(
                                                  width: 30,
                                                ),
                                                Text(dateFormatter.format(dateTime)),
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text('${numberFormatter.format(totalAmount)} 円'),
                                                // Text('${numberFormatter.format(10000000)} 円'),
                                                const SizedBox(width: 10,),
                                                SizedBox(
                                                  width: 50,
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    children: [
                                                      Icon(
                                                        isOver ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                                                        // isOver ? Icons.add : Icons.minimize,
                                                        color: isOver ? Colors.red : Colors.blue,
                                                        size: 15,
                                                      ),
                                                      Text(
                                                        numberFormatter.format(totalAmount - targetDayAmount),
                                                        // numberFormatter.format(1000),
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: isOver ? Colors.red : Colors.blue,
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                // Text('${formatter.format(menuRankings[index]['diffAmount'])}')
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const Divider(),
                                  ],
                                );
                              })
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            WidgetUtils.loadingStack(_isLoading)
          ]
        ),
      ),
    );
  }

  List<BarChartGroupData> getData(double barsWidth, double barsSpace) {
    List<BarChartGroupData> barGroups = [];
    for (var date in dateList) {
      final filterMenus =
          menus.where((menu) => menu.createdTime.toDate().day == date.day).toList();
      double dayAmount = 0;
      for (var menu in filterMenus) {
        if (menu.totalAmount != null) {
          dayAmount += menu.totalAmount!.toInt();
        }
      }
      List<BarChartRodStackItem> rodStackItems = [];
      if (targetDayAmount <= dayAmount) {
        // 1日の目標金額から1日の金額まで
        rodStackItems.add(BarChartRodStackItem(targetDayAmount, dayAmount, AppColors.contentColorRed));
      }

      barGroups.add(BarChartGroupData(
        x: date.day,
        barsSpace: barsSpace,
        barRods: [
          BarChartRodData(
              // 1日の金額
              toY: dayAmount,
              // gradient: LinearGradient(
              //     colors: gradientColors.map((color) => color.withOpacity(0.8)).toList()
              // ),
              color: AppColors.contentColorCyan,
              width: barsWidth,
              rodStackItems: rodStackItems,
              borderRadius: BorderRadius.circular(8))
        ],
      ));
    }

    return barGroups;
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    // 当日は太字、土日は色つける
    String text;
    final weekday = dateList.indexWhere((date) => date.day == value.toInt());
    switch (weekday + 1) {
      case 1:
        text = '${meta.formattedValue} 月';
        break;
      case 2:
        text = '${meta.formattedValue} 火';
        break;
      case 3:
        text = '${meta.formattedValue} 水';
        break;
      case 4:
        text = '${meta.formattedValue} 木';
        break;
      case 5:
        text = '${meta.formattedValue} 金';
        break;
      case 6:
        text = '${meta.formattedValue} 土';
        break;
      case 7:
        text = '${meta.formattedValue} 日';
        break;
      default:
        text = meta.formattedValue;
        break;
    }

    final isToday = dateList.any((date) => value.toInt() == date.day && date.day == kToday.day);
    final isSaturday = dateList.any((date) => value.toInt() == date.day && date.weekday == 6);
    final isSunday = dateList.any((date) => value.toInt() == date.day && date.weekday == 7);
    // 当月じゃないものは灰色
    final isCurrentMonth = dateList.any((date) => value.toInt() == date.day && date.month == kToday.month);

    // 当日ならオレンジの下線つける
    BoxDecoration? boxDecoration =
        isToday ? const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.orangeAccent, width: 4))) : null;
    if (!isCurrentMonth) {
      return SideTitleWidget(
          axisSide: meta.axisSide,
          child: Text(
            text,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ));
    } else if (isSaturday) {
      return SideTitleWidget(
          axisSide: meta.axisSide,
          child: Container(
            decoration: boxDecoration,
            child: Text(
              text,
              style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ));
    } else if (isSunday) {
      return SideTitleWidget(
          axisSide: meta.axisSide,
          child: Container(
            decoration: boxDecoration,
            child: Text(
              text,
              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ));
    } else {
      return SideTitleWidget(
          axisSide: meta.axisSide,
          child: Container(
            decoration: boxDecoration,
            child: Text(
              text,
              style: const TextStyle(color: Colors.black, fontSize: 12),
            ),
          ));
    }
  }
}
