import 'package:flutter/material.dart';
import 'package:foodcost/component/cancel_button.dart';
import 'package:foodcost/model/news.dart';
import 'package:foodcost/utils/firestore/news.dart';
import 'package:foodcost/utils/widget_utils.dart';
import 'package:intl/intl.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  final dateFormatter = DateFormat('yyyy年M月d日 HH:mm');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.white,
      appBar: WidgetUtils.createAppBar('お知らせ'),
      body: Container(
        padding: const EdgeInsets.all(15.0),
        child: FutureBuilder(
          future: NewsFirestore.getNews(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        ListTile(
                          title: Text(snapshot.data[index].title),
                          onTap: () {
                            _showDialog(snapshot.data[index]);
                          },
                        ),
                        const Divider()
                      ],
                    );
                  });
            } else {
              return Container();
            }

          },
        ),
      ),
    );
  }

  void _showDialog(News news) async {
    await showDialog(context: context, builder: (_) {
      return AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: Text(news.title),
        content: SizedBox(
          height: 100,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                    child: Text(dateFormatter.format(news.createdDate.toDate()))
                ),
                const SizedBox(height: 20,),
                Text(news.description),
              ],
            ),
          ),
        ),
        actions: [
          CancelButton(
              onPressed: () {
                Navigator.pop(context);
              },
              text: '閉じる'
          )
        ],

      );
    });
  }
}
