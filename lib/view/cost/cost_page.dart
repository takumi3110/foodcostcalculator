import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:foodcost/model/Account.dart';
import 'package:foodcost/presentation/resources/app_colors.dart';
import 'package:foodcost/utils/authentication.dart';
import 'package:foodcost/utils/chart_utils.dart';
import 'package:foodcost/utils/firestore/menus.dart';
import 'package:foodcost/utils/widget_utils.dart';
import 'package:intl/intl.dart';

class CostPage extends StatefulWidget {
  const CostPage({super.key});

  @override
  State<CostPage> createState() => _CostPageState();
}

class _CostPageState extends State<CostPage> {
  Account myAccount = Authentication.myAccount!;
  List menus = [];
  List<Color> gradientColors = [
    AppColors.contentColorGreen,
    AppColors.contentColorBlue,
  ];

  // TODO: 1日の目標金額
  // 当月の最終日を取得
  int currentMonthLastDay = 0;
  num allTotalAmount = 0;
  List<FlSpot> flSpots = [];
  final formatter = NumberFormat('#,###');
  final cutOfYValue = 300.0;

  void getMenus() async {
    final results = await MenuFirestore.getMenus(myAccount.id);
    if (results != null) {
      setState(() {
        DateTime now = DateTime.now();
        int lastDay = DateTime(now.year, (now.month + 1), 0).day;
        currentMonthLastDay = lastDay;
        List<FlSpot> spots = [];
        menus = results;
        for (var i = 1; i <= lastDay; i++) {
          num totalAmount = 0;
          results.forEach((result) {
            DateTime createdTime = result.createdTime.toDate();
            //
            if (createdTime.day == i) {
              totalAmount += result.totalAmount;
              allTotalAmount += result.totalAmount;
            }
          });
          spots.add(FlSpot(i.toDouble(), totalAmount.toDouble()));
        }
        flSpots = spots;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getMenus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('今月の食費'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Stack(children: [
                AspectRatio(
                  // 表示してるグラフ全体のサイズ
                  aspectRatio: 1.7,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        right: 18,
                        // left: 12,
                        top: 20,
                        bottom: 12),
                    // child: LineChart(ChartUtils.chartMainData(flSpots)),
                    child: LineChart(LineChartData(
                        lineTouchData: LineTouchData(
                            touchTooltipData: LineTouchTooltipData(
                                maxContentWidth: 100,
                                tooltipBgColor: Colors.black,
                                getTooltipItems: (touchedSpots) {
                                  return touchedSpots.map((LineBarSpot touchedSpot) {
                                    final textStyle = TextStyle(
                                      color: touchedSpot.bar.gradient?.colors[0] ?? touchedSpot.bar.color,
                                      fontWeight: FontWeight.bold,
                                      // fontSize: 24
                                    );
                                    return LineTooltipItem(
                                        '${touchedSpot.x.toStringAsFixed(0)}日, ${touchedSpot.y.toStringAsFixed(0)}円',
                                        textStyle);
                                  }).toList();
                                }),
                            handleBuiltInTouches: true,
                            getTouchLineStart: (data, index) => 0),
                        gridData: FlGridData(
                          show: false,
                          drawVerticalLine: true,
                          horizontalInterval: 1.5,
                          verticalInterval: 5,
                          // checkToShowHorizontalLine: (value) {
                          //   return value.toInt() == 0;
                          // },
                          // getDrawingHorizontalLine: (_) => FlLine(
                          //   color: AppColors.contentColorBlue.withOpacity(1),
                          //   dashArray: [0, 2],
                          //   strokeWidth: 0.8
                          // ),
                          getDrawingHorizontalLine: (value) {
                            return const FlLine(
                              color: AppColors.mainGridLineColor,
                              strokeWidth: 1,
                            );
                          },
                          getDrawingVerticalLine: (value) {
                            return const FlLine(
                              color: AppColors.mainGridLineColor,
                              strokeWidth: 1,
                            );
                          },
                        ),
                        titlesData: const FlTitlesData(
                          show: true,
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              interval: 8,
                              getTitlesWidget: ChartUtils.bottomTitleWidgets,
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                                showTitles: true,
                                interval: 100,
                                getTitlesWidget: ChartUtils.leftTitleWidgets,
                                reservedSize: 42),
                          ),
                        ),
                        borderData: FlBorderData(show: true, border: Border.all(color: const Color(0xff37433d))),
                        // TODO: 日付によって変える
                        minX: 1,
                        maxX: currentMonthLastDay.toDouble(),
                        //   TODO:　食費によってmaxを変える
                        minY: 0,
                        // プラス100を区切りよく。一回100で割って小数点を消してまた100をかけてキリよく
                        maxY: double.parse(((allTotalAmount + 100) / 100).toStringAsFixed(0)) * 100,
                        lineBarsData: [
                          LineChartBarData(
                              spots: flSpots,
                              isCurved: true,
                              // gradient: LinearGradient(
                              //   colors: gradientColors,
                              // ),
                              color: Colors.deepOrangeAccent,
                              barWidth: 2,
                              isStrokeCapRound: true,
                              dotData: const FlDotData(show: false),
                              belowBarData: BarAreaData(
                                  show: true,
                                  cutOffY: cutOfYValue,
                                  applyCutOffY: true,
                                  // gradient: LinearGradient(
                                  //   colors: gradientColors.map((color) => color.withOpacity(0.2)).toList()
                                  // )
                                  color: AppColors.contentColorRed.withOpacity(0.7)),
                              aboveBarData: BarAreaData(
                                  show: true,
                                  gradient: LinearGradient(
                                      colors: gradientColors.map((color) => color.withOpacity(0.2)).toList()),
                                  // color: AppColors.contentColorGreen.withOpacity(0.7),
                                  cutOffY: cutOfYValue,
                                  applyCutOffY: true))
                        ])),
                  ),
                ),
              ]),
              Column(
                children: [
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: Text(
                      '合計金額: ${formatter.format(allTotalAmount)} 円',
                      style: const TextStyle(fontSize: 20.0),
                    ),
                  ),
                  WidgetUtils.menuListTile(menus, null),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
