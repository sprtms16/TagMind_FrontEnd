import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/diary_provider.dart';
import '../models/diary.dart';
import './diary_edit_screen.dart';

class DiaryListScreen extends StatefulWidget {
  @override
  _DiaryListScreenState createState() => _DiaryListScreenState();
}

class _DiaryListScreenState extends State<DiaryListScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _showCalendar = false; // State to toggle between calendar and list view
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    // Fetch diaries when the screen initializes
    Provider.of<DiaryProvider>(context, listen: false).fetchDiaries();
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
      // Optionally, filter diaries based on selectedDay here
    }
  }

  void _onSearchSubmitted(String query) {
    Provider.of<DiaryProvider>(context, listen: false).searchDiaries(query);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Diaries'),
        actions: <Widget>[
          IconButton(
            icon: Icon(_showCalendar ? Icons.list : Icons.calendar_today),
            onPressed: () {
              setState(() {
                _showCalendar = !_showCalendar;
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(DiaryEditScreen.routeName);
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search diaries...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () => _onSearchSubmitted(_searchController.text),
                ),
              ),
              onSubmitted: _onSearchSubmitted,
            ),
          ),
        ),
      ),
      body: Consumer<DiaryProvider>(
        builder: (context, diaryProvider, child) {
          if (diaryProvider.diaries.isEmpty) {
            return Center(
              child: Text('No diaries yet. Start writing!'),
            );
          }

          final _getEventsForDay = (DateTime day) {
            return diaryProvider.diaries.where((diary) => isSameDay(diary.createdAt, day)).toList();
          };

          return Column(
            children: [
              if (_showCalendar)
                TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: _onDaySelected,
                  onFormatChanged: (format) {
                    if (_calendarFormat != format) {
                      setState(() {
                        _calendarFormat = format;
                      });
                    }
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                  },
                  eventLoader: _getEventsForDay,
                ),
              Expanded(
                child: ListView.builder(
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () {
                                  Navigator.of(context).pushNamed(
                                    DiaryEditScreen.routeName,
                                    arguments: diaryProvider.diaries[i].id,
                                  );
                                },
                                color: Theme.of(context).primaryColor,
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () async {
                                  await diaryProvider.deleteDiary(diaryProvider.diaries[i].id);
                                },
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(DiaryEditScreen.routeName);
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
