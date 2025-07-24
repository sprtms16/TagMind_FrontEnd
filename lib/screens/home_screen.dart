import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart'; // Import for TableCalendar widget
import '../providers/tag_provider.dart';
import '../providers/diary_provider.dart';
import './diary_edit_screen.dart';

// HomeScreen displays the list of diary entries and provides search/calendar functionalities.
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController(); // Controller for search input
  bool _isSearching = false; // Flag to indicate if search mode is active
  bool _isCalendarVisible = false; // Flag to control calendar visibility
  DateTime _focusedDay = DateTime.now(); // The currently focused day in the calendar
  DateTime? _selectedDay; // The currently selected day in the calendar

  @override
  void initState() {
    super.initState();
    // Fetch tags when the screen initializes
    Provider.of<TagProvider>(context, listen: false).fetchTags();
    // Fetch diaries for today's date initially to populate the list
    _selectedDay = DateTime.now();
    Provider.of<DiaryProvider>(context, listen: false)
        .fetchDiariesByDate(_selectedDay!); // Initial load for today's diaries
    // Fetch all diaries for calendar events (dots on calendar)
    Provider.of<DiaryProvider>(context, listen: false)
        .fetchDiaries(); // Fetch all diaries for calendar events
  }

  @override
  void dispose() {
    _searchController.dispose(); // Dispose controller to prevent memory leaks
    super.dispose();
  }

  // Toggles the search bar visibility and clears search if closing.
  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear(); // Clear search text
        // When search is closed, revert to displaying diaries for the currently selected day
        Provider.of<DiaryProvider>(context, listen: false).fetchDiariesByDate(
            _selectedDay ?? DateTime.now()); // Re-fetch diaries for selected/today's date
      }
    });
  }

  // Toggles the calendar visibility.
  void _toggleCalendar() {
    setState(() {
      _isCalendarVisible = !_isCalendarVisible;
    });
  }

  // Callback for when a day is selected in the calendar.
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay; // Update selected day
      _focusedDay = focusedDay; // Update focused day
    });
    // If in search mode, apply search query with new date; otherwise, just fetch by date.
    if (_isSearching && _searchController.text.isNotEmpty) {
      Provider.of<DiaryProvider>(context, listen: false)
          .searchDiaries(_searchController.text, selectedDay);
    } else {
      Provider.of<DiaryProvider>(context, listen: false)
          .fetchDiariesByDate(selectedDay);
    }
  }

  // Returns a list of events (diaries) for a given day to display on the calendar.
  List<dynamic> _getEventsForDay(DateTime day) {
    final diaryProvider = Provider.of<DiaryProvider>(context, listen: false);
    // If searching, show dots only for diaries matching the search query
    if (_isSearching) {
      return diaryProvider.searchedDiariesForCalendar
          .where((diary) => isSameDay(diary.createdAt, day))
          .toList();
    } else {
      // Otherwise, show dots for all diaries
      return diaryProvider.allDiaries
          .where((diary) => isSameDay(diary.createdAt, day))
          .toList();
    }
  }

  // Performs a search based on the input query.
  void _performSearch(String query) {
    if (query.isNotEmpty) {
      // Perform search with query and current selected date
      Provider.of<DiaryProvider>(context, listen: false)
          .searchDiaries(query, _selectedDay); // Pass selectedDay
    } else {
      // If query is empty, revert to displaying diaries for the currently selected day
      Provider.of<DiaryProvider>(context, listen: false).fetchDiariesByDate(
          _selectedDay ?? DateTime.now()); // Re-fetch diaries for selected/today's date
    }
  }

  @override
  Widget build(BuildContext context) {
    final diaryProvider = Provider.of<DiaryProvider>(context); // Access DiaryProvider

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController, // Controller for search input
                decoration: InputDecoration(
                  hintText: 'Search diaries...', // Hint text for search field
                  border: InputBorder.none, // No border for search field
                  hintStyle: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7)), // Hint text style
                ),
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onSurface), // Input text style
                onSubmitted: _performSearch, // Callback when search is submitted
              )
            : const Text('TagMind'), // App title when not searching
        actions: [
          // Search/Close button
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search), // Icon changes based on search mode
            onPressed: _toggleSearch, // Toggle search mode
          ),
          // Calendar visibility toggle button
          IconButton(
            icon: Icon(_isCalendarVisible
                ? Icons.calendar_today
                : Icons.calendar_today_outlined), // Icon changes based on calendar visibility
            onPressed: _toggleCalendar, // Toggle calendar visibility
          ),
          // Add new diary button
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(DiaryEditScreen.routeName); // Navigate to diary edit screen
            },
          ),
          // Tag Store button
          IconButton(
            icon: const Icon(Icons.store),
            onPressed: () {
              Navigator.of(context).pushNamed('/tag-store'); // Navigate to tag store screen
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Calendar widget (visible when _isCalendarVisible is true)
          if (_isCalendarVisible)
            TableCalendar(
              firstDay: DateTime.utc(2010, 10, 16), // Start date for calendar
              lastDay: DateTime.utc(2030, 3, 14), // End date for calendar
              focusedDay: _focusedDay, // Currently focused day
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day), // Predicate for selected day
              onDaySelected: _onDaySelected, // Callback for day selection
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay; // Update focused day on page change
              },
              calendarStyle: CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary, // Style for selected day
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color:
                      Theme.of(context).colorScheme.secondary.withOpacity(0.5), // Style for today's date
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false, // Hide format button
                titleCentered: true, // Center calendar title
                titleTextStyle: Theme.of(context).textTheme.headlineMedium!, // Style for calendar title
              ),
              eventLoader: _getEventsForDay, // Function to load events for days
            ),
          // Expanded widget to take remaining space for diary list
          Expanded(
            child: diaryProvider.diaries.isEmpty
                ? const Center(
                    child: Text('No diaries yet. Start by adding one!'),
                  ) // Message when no diaries are available
                : ListView.builder(
                    itemCount: diaryProvider.diaries.length, // Number of diary entries
                    itemBuilder: (ctx, i) => Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5), // Card margin
                      elevation: 3, // Card elevation
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)), // Card shape
                      child: Padding(
                        padding: const EdgeInsets.all(8), // Padding inside card
                        child: ListTile(
                          title: Text(
                            diaryProvider.diaries[i].title,
                            style: Theme.of(context).textTheme.headlineMedium, // Title style
                          ),
                          subtitle: Text(
                            diaryProvider.diaries[i].content ?? 'No content',
                            style: Theme.of(context).textTheme.bodyMedium, // Subtitle style
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 5), // Content padding
                          trailing: IconButton(
                            icon: Icon(Icons.edit,
                                color: Theme.of(context).colorScheme.secondary), // Edit icon
                            onPressed: () {
                              Navigator.of(context).pushNamed(
                                DiaryEditScreen.routeName,
                                arguments: diaryProvider.diaries[i].id, // Pass diary ID for editing
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
