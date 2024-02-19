import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:foodcost/presentation/resources/app_colors.dart';

class ChartUtils {



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

    // String text;
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

  // static LineChartData chartMainData(List<FlSpot> spots) {
  //   List<Color> gradientColors = [
  //     AppColors.contentColorGreen,
  //     AppColors.contentColorBlue,
  //   ];
  //   // TODO: 1日の目標金額
  //   const cutOfYValue = 300.0;
  //
  //
  //   return LineChartData(
  //       lineTouchData: LineTouchData(
  //           touchTooltipData: LineTouchTooltipData(
  //               maxContentWidth: 100,
  //               tooltipBgColor: Colors.black,
  //               getTooltipItems: (touchedSpots) {
  //                 return touchedSpots.map((LineBarSpot touchedSpot) {
  //                   final textStyle = TextStyle(
  //                     color: touchedSpot.bar.gradient?.colors[0] ?? touchedSpot.bar.color,
  //                     fontWeight: FontWeight.bold,
  //                     // fontSize: 24
  //                   );
  //                   return LineTooltipItem(
  //                       '${touchedSpot.x.toStringAsFixed(0)}日, ${touchedSpot.y.toStringAsFixed(0)}円',
  //                       textStyle
  //                   );
  //                 }).toList();
  //               }
  //           ),
  //           handleBuiltInTouches: true,
  //           getTouchLineStart: (data, index) => 0
  //       ),
  //       gridData: FlGridData(
  //         show: false,
  //         drawVerticalLine: true,
  //         horizontalInterval: 1.5,
  //         verticalInterval: 5,
  //         // checkToShowHorizontalLine: (value) {
  //         //   return value.toInt() == 0;
  //         // },
  //         // getDrawingHorizontalLine: (_) => FlLine(
  //         //   color: AppColors.contentColorBlue.withOpacity(1),
  //         //   dashArray: [0, 2],
  //         //   strokeWidth: 0.8
  //         // ),
  //         getDrawingHorizontalLine: (value) {
  //           return const FlLine(
  //             color: AppColors.mainGridLineColor,
  //             strokeWidth: 1,
  //           );
  //         },
  //         getDrawingVerticalLine: (value) {
  //           return const FlLine(
  //             color: AppColors.mainGridLineColor,
  //             strokeWidth: 1,
  //           );
  //         },
  //       ),
  //       titlesData: const FlTitlesData(
  //         show: true,
  //         rightTitles: AxisTitles(
  //             sideTitles: SideTitles(showTitles: false)
  //         ),
  //         topTitles: AxisTitles(
  //             sideTitles: SideTitles(showTitles: false)
  //         ),
  //         bottomTitles: AxisTitles(
  //           sideTitles: SideTitles(
  //             showTitles: true,
  //             reservedSize: 30,
  //             interval: 8,
  //             getTitlesWidget: bottomTitleWidgets,
  //           ),
  //         ),
  //         leftTitles: AxisTitles(
  //           sideTitles: SideTitles(
  //               showTitles: true,
  //               interval: 100,
  //               getTitlesWidget: leftTitleWidgets,
  //               reservedSize: 42
  //           ),
  //         ),
  //       ),
  //       borderData: FlBorderData(
  //           show: true,
  //           border: Border.all(color: const Color(0xff37433d))
  //       ),
  //       // TODO: 日付によって変える
  //       minX: 1,
  //       maxX: 31,
  //       //   TODO:　食費によってmaxを変える
  //       minY: 0,
  //       maxY: 600,
  //       lineBarsData: [
  //         LineChartBarData(
  //             spots: spots,
  //             isCurved: true,
  //             // gradient: LinearGradient(
  //             //   colors: gradientColors,
  //             // ),
  //             color: Colors.deepOrangeAccent,
  //             barWidth: 2,
  //             isStrokeCapRound: true,
  //             dotData: const FlDotData(
  //                 show: false
  //             ),
  //             belowBarData: BarAreaData(
  //                 show: true,
  //                 cutOffY: cutOfYValue,
  //                 applyCutOffY: true,
  //                 // gradient: LinearGradient(
  //                 //   colors: gradientColors.map((color) => color.withOpacity(0.2)).toList()
  //                 // )
  //                 color: AppColors.contentColorRed.withOpacity(0.7)
  //             ),
  //             aboveBarData: BarAreaData(
  //                 show: true,
  //                 gradient: LinearGradient(
  //                     colors: gradientColors.map((color) => color.withOpacity(0.2)).toList()
  //                 ),
  //                 // color: AppColors.contentColorGreen.withOpacity(0.7),
  //                 cutOffY: cutOfYValue,
  //                 applyCutOffY: true
  //             )
  //         )
  //       ]
  //   );
  // }

}