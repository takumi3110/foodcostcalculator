import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:foodcost/model/Account.dart';
import 'package:foodcost/model/menu.dart';
import 'package:foodcost/utils/authentication.dart';
import 'package:foodcost/utils/firestore/foods.dart';
import 'package:foodcost/utils/widget_utils.dart';
import 'package:intl/intl.dart';

class CostPage extends StatefulWidget {
  const CostPage({super.key});

  @override
  State<CostPage> createState() => _CostPageState();
}

class _CostPageState extends State<CostPage> {
  Account myAccount = Authentication.myAccount!;

  // TODO: 読み込みごとに更新されるけど、実際は関係ない？
  num allTotalAmount = 0;
  final formatter = NumberFormat('#,###');

  // TODO: 日にちと日毎の合計金額が入る。List.generateじゃなく、Listに追加する感じ？
  final spots = List.generate(
      // 当月の日数
      31, (index) => index + 1).map((x) => FlSpot(
      x.toDouble(),
      // その日の合計金額
      x * 10
  )
  ).toList();

  // TODO: initState?
  @override
  void initState() {
    super.initState();

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
              Stack(
                children: [
                  AspectRatio(
                      // 表示してるグラフ全体のサイズ
                      aspectRatio: 1.7,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        right:18,
                        // left: 12,
                        top: 20,
                        bottom: 12
                      ),
                      child: LineChart(
                        WidgetUtils.chartMainData(spots)
                      ),
                    ),
                  ),
                  // SizedBox(
                  //   width: 60,
                  //   height: 34,
                  //   child: TextButton(
                  //     onPressed: () {
                  //       setState(() {
                  //         showAvg = !showAvg;
                  //       });
                  //     },
                  //     child: Text(
                  //       'avg',
                  //       style: TextStyle(
                  //         fontSize: 12,
                  //         color: showAvg? Colors.grey.withOpacity(0.5): Colors.grey
                  //       ),
                  //     ),
                  //   ),
                  // ),
              ]

              ),
              StreamBuilder<QuerySnapshot>(
                stream: FoodFirestore.menus.where('user_id', isEqualTo: myAccount.id).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List<Menu> menus = [];
                    var docs = snapshot.data!.docs;
                    for (var doc in docs) {
                      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                      Menu getMenu = Menu(
                          name: data['name'],
                          userId: data['user_id'],
                          totalAmount: data['total_amount'],
                          imagePath: data['image_path'],
                          createdTime: data['created_time']
                      );
                      menus.add(getMenu);
                      allTotalAmount += data['total_amount'];
                    }
                    return Column(
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
                    );
                  } else {
                    return Container();
                  }

                },
              ),
            ],
          ),
        ),
      ),
    );
  }


}
