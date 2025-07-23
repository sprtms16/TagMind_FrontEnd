import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/tag_provider.dart';
import '../providers/diary_provider.dart';
import './diary_edit_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  bool _isCalendarVisible = false;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    // Fetch tags when the screen initializes
    Provider.of<TagProvider>(context, listen: false).fetchTags();
    // Fetch diaries for today's date initially
    _selectedDay = DateTime.now();
    Provider.of<DiaryProvider>(context, listen: false).fetchDiariesByDate(_selectedDay!); // Initial load for today
    Provider.of<DiaryProvider>(context, listen: false).fetchDiaries(); // Fetch all diaries for calendar events
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        Provider.of<DiaryProvider>(context, listen: false).fetchDiariesByDate(_selectedDay ?? DateTime.now()); // 검색 취소 시 현재 선택된 날짜의 일기 다시 불러오기
      }
    });
  }

  void _toggleCalendar() {
    setState(() {
      _isCalendarVisible = !_isCalendarVisible;
    });
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
    if (_isSearching && _searchController.text.isNotEmpty) {
      Provider.of<DiaryProvider>(context, listen: false).searchDiaries(_searchController.text, selectedDay);
    } else {
      Provider.of<DiaryProvider>(context, listen: false).fetchDiariesByDate(selectedDay);
    }
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    final diaryProvider = Provider.of<DiaryProvider>(context, listen: false);
    if (_isSearching) {
      return diaryProvider.searchedDiariesForCalendar.where((diary) => isSameDay(diary.createdAt, day)).toList();
    } else {
      return diaryProvider.allDiaries.where((diary) => isSameDay(diary.createdAt, day)).toList();
    }
  }

  void _performSearch(String query) {
    if (query.isNotEmpty) {
      Provider.of<DiaryProvider>(context, listen: false).searchDiaries(query, _selectedDay); // Pass selectedDay
    } else {
      Provider.of<DiaryProvider>(context, listen: false).fetchDiariesByDate(_selectedDay ?? DateTime.now()); // 검색어 없이 검색 시 현재 선택된 날짜의 일기 표시
    }
  }

  @override
  Widget build(BuildContext context) {
    final diaryProvider = Provider.of<DiaryProvider>(context);
    final tags = Provider.of<TagProvider>(context).tags;

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search diaries...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
                ),
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                onSubmitted: _performSearch,
              )
            : const Text('TagMind'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: _toggleSearch,
          ),
          IconButton(
            icon: Icon(_isCalendarVisible ? Icons.calendar_today : Icons.calendar_today_outlined),
            onPressed: _toggleCalendar,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(DiaryEditScreen.routeName);
            },
          ),
          IconButton(
            icon: const Icon(Icons.store),
            onPressed: () {
              // Navigate to Tag Store Screen
              Navigator.of(context).pushNamed('/tag-store');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isCalendarVisible)
            TableCalendar(
              firstDay: DateTime.utc(2010, 10, 16),
              lastDay: DateTime.utc(2030, 3, 14),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: _onDaySelected,
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              calendarStyle: CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: Theme.of(context).textTheme.headlineMedium!,
              ),
              eventLoader: _getEventsForDay,
            ),
          Expanded(
            child: diaryProvider.diaries.isEmpty
                ? const Center(
                    child: Text('No diaries yet. Start by adding one!'),
                  )
                : ListView.builder(
                    itemCount: diaryProvider.diaries.length,
                    itemBuilder: (ctx, i) => Card(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: ListTile(
                          title: Text(
                            diaryProvider.diaries[i].title,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          subtitle: Text(
                            diaryProvider.diaries[i].content ?? 'No content',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                          trailing: IconButton(
                            icon: Icon(Icons.edit, color: Theme.of(context).colorScheme.secondary),
                            onPressed: () {
                              Navigator.of(context).pushNamed(
                                DiaryEditScreen.routeName,
                                arguments: diaryProvider.diaries[i].id,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}