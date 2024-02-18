import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:foodcost/model/Account.dart';
import 'package:foodcost/model/menu.dart';
import 'package:foodcost/presentation/resources/app_colors.dart';
import 'package:foodcost/utils/authentication.dart';
import 'package:foodcost/view/account/account_page.dart';
import 'package:foodcost/view/calendar/calendar_page.dart';
import 'package:foodcost/view/cost/cost_page.dart';
import 'package:foodcost/view/start_up/login_page.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class WidgetUtils {
  static Account myAccount = Authentication.myAccount!;

  static AppBar createAppBar(String title, GlobalKey<ScaffoldState> key) {
    // Account myAccount = Authentication.myAccount!;

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.black),
      title: Text(
        title,
        style: const TextStyle(color: Colors.black),
      ),
      leading: IconButton(
        icon: CircleAvatar(
          foregroundImage: myAccount.imagePath != null ? NetworkImage(myAccount.imagePath!): null,
          child: const Icon(Icons.person),
        ),
        onPressed: () {
          key.currentState!.openDrawer();
        },
      ),
    );
  }

  static SizedBox sideMenuDrawer(BuildContext context) {
    return SizedBox(
      width: 250,
      child: Drawer(
        child: Container(
          color: Colors.white,
          child: ListView(
            children: [
              UserAccountsDrawerHeader(
                accountName: Text(
                  myAccount.name,
                  style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 18, color: Colors.black),
                ),
                accountEmail: Text(
                  myAccount.email,
                  style: const TextStyle(color: Colors.black),
                ),
                currentAccountPicture: CircleAvatar(
                  foregroundImage: myAccount.imagePath != null ? NetworkImage(myAccount.imagePath!): null,
                  child: const Icon(Icons.person, size: 50,),
                ),
                decoration: const BoxDecoration(color: Colors.white),
              ),
              ListTile(
                title: const Row(
                  children: [
                    Icon(Icons.calendar_month),
                    SizedBox(
                      width: 10.0,
                    ),
                    Text('カレンダー')
                  ],
                ),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const CalendarPage()));
                },
              ),
              ListTile(
                title: const Row(
                  children: [
                    Icon(Icons.bar_chart),
                    SizedBox(
                      width: 10.0,
                    ),
                    Text('今月の食費'),
                  ],
                ),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const CostPage()));
                },
              ),
              ListTile(
                title: const Row(
                  children: [
                    Icon(Icons.account_box),
                    SizedBox(
                      width: 10.0,
                    ),
                    Text('マイページ'),
                  ],
                ),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const AccountPage()));
                },
              ),
              ListTile(
                title: const Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(
                      width: 10.0,
                    ),
                    Text('ログアウト'),
                  ],
                ),
                onTap: () {
                  Authentication.signOut();
                  while (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Stack loadingStack(isLoading) {
    return Stack(
      children: [
        if (isLoading)
          const Opacity(
            opacity: 0.8,
            child: ModalBarrier(dismissible: false, color: Colors.white),
          ),
        if (isLoading)
          Center(
            child: LoadingAnimationWidget.stretchedDots(color: Colors.blue, size: 70),
          ),
      ],
    );
  }

  static Column menuListTile(menus, allTotalAmount) {
    final formatter = NumberFormat('#,###');

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        if (allTotalAmount != null)
        Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          child: Text(
            '合計金額: ${formatter.format(allTotalAmount)} 円',
            style: const TextStyle(fontSize: 18.0),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              ListView.builder(
                  shrinkWrap: true,
                  itemCount: menus.length,
                  itemBuilder: (context, index) {
                    // Map<String, dynamic> data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                    return Column(
                      children: [
                        ListTile(
                          onTap: () {},
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(menus[index].name),
                              Text('${formatter.format(menus[index].totalAmount)} 円')
                            ],
                          ),
                        ),
                        // if (index == getMenus.length) const Divider()
                        const Divider(),
                      ],
                    );
                  }),
              if (allTotalAmount == null && menus.length > 6)
                Container(
                    alignment: Alignment.centerRight,
                    child: const Text('and more...')
                )

            ],
          ),
        ),
      ],
    );
  }

  static Widget bottomTitleWidgets(double value, TitleMeta meta) {
    // if (value % 1 != 0) {
    //   return Container();
    // }

    const style = TextStyle(
      color: AppColors.contentColorBlue,
        // fontWeight: FontWeight.bold,
    );

    // TODO: 当月の日付を取得
    // Widget text;
    // switch (value.toInt()) {
    //   case 0:
    //     text = const Text('Mar', style: style);
    //     break;
    //   case 5:
    //     text = const Text('Jun', style: style,);
    //     break;
    //   case 30:
    //     text = const Text('Sep', style: style,);
    //     break;
    //   default:
    //     text = const Text('', style: style,);
    //     break;
    // }

    // return SideTitleWidget(axisSide: meta.axisSide, child: text);
    return SideTitleWidget(axisSide: meta.axisSide, child: Text(meta.formattedValue, style: style,));
  }

  static Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      // fontSize: 15,
    );

    // TODO: 金額をvalueによって表示させる
    // 100円刻み？

    String text;
    // switch (value.toInt()) {
    //   case 1:
    //     text = '10K';
    //     break;
    //   case 3:
    //     text = '30K';
    //     break;
    //   case 5:
    //     text = '50K';
    //     break;
    //   default:
    //     return Container();
    // }

    // return Text(text, style: style, textAlign: TextAlign.left,);
    return SideTitleWidget(axisSide: meta.axisSide, child: Text(meta.formattedValue, style: style,),);
  }

  static LineChartData chartMainData(List<FlSpot> spots) {
    List<Color> gradientColors = [
      AppColors.contentColorGreen,
      AppColors.contentColorBlue,
    ];
    // TODO: 1日の目標金額
    const cutOfYValue = 200.0;

    return LineChartData(
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
                  textStyle
              );
            }).toList();
          }
        ),
        handleBuiltInTouches: true,
        getTouchLineStart: (data, index) => 0
      ),
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
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false)
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false)
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 8,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 100,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 42
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37433d))
      ),
      // TODO: 日付によって変える
      minX: 1,
      maxX: 31,
      //   TODO:　食費によってmaxを変える
      minY: 0,
      maxY: 500,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          // gradient: LinearGradient(
          //   colors: gradientColors,
          // ),
            color: Colors.deepOrangeAccent,
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: false
          ),
          belowBarData: BarAreaData(
            show: true,
            cutOffY: cutOfYValue,
            applyCutOffY: true,
            // gradient: LinearGradient(
            //   colors: gradientColors.map((color) => color.withOpacity(0.2)).toList()
            // )
            color: AppColors.contentColorRed.withOpacity(0.7)
          ),
          aboveBarData: BarAreaData(
            show: true,
              gradient: LinearGradient(
                  colors: gradientColors.map((color) => color.withOpacity(0.2)).toList()
              ),
            // color: AppColors.contentColorGreen.withOpacity(0.7),
            cutOffY: cutOfYValue,
            applyCutOffY: true
          )
        )
      ]
    );
  }

}
