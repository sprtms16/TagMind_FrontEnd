import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/diary_provider.dart';
import '../models/diary.dart';

class DiaryListScreen extends StatefulWidget {
  @override
  _DiaryListScreenState createState() => _DiaryListScreenState();
}

class _DiaryListScreenState extends State<DiaryListScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch diaries when the screen initializes
    Provider.of<DiaryProvider>(context, listen: false).fetchDiaries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Diaries'),
      ),
      body: Consumer<DiaryProvider>(
        builder: (context, diaryProvider, child) {
          if (diaryProvider.diaries.isEmpty) {
            return Center(
              child: Text('No diaries yet. Start writing!'),
            );
          }
          return ListView.builder(
            itemCount: diaryProvider.diaries.length,
            itemBuilder: (ctx, i) => Card(
              margin: EdgeInsets.all(8),
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      diaryProvider.diaries[i].title,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 5),
                    Text(diaryProvider.diaries[i].content),
                    SizedBox(height: 5),
                    Text(
                      diaryProvider.diaries[i].createdAt.toLocal().toString().split(' ')[0],
                      style: TextStyle(color: Colors.grey),
                    ),
                    if (diaryProvider.diaries[i].tags.isNotEmpty)
                      Wrap(
                        spacing: 6.0,
                        runSpacing: 6.0,
                        children: diaryProvider.diaries[i].tags
                            .map((tag) => Chip(label: Text(tag)))
                            .toList(),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to Diary Creation Screen
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
