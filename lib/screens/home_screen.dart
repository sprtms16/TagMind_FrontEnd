import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  @override
  void initState() {
    super.initState();
    // Fetch tags when the screen initializes
    Provider.of<TagProvider>(context, listen: false).fetchTags();
    // Fetch diaries when the screen initializes
    Provider.of<DiaryProvider>(context, listen: false).fetchDiaries();
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
        Provider.of<DiaryProvider>(context, listen: false).fetchDiaries(); // 검색 취소 시 전체 목록 다시 불러오기
      }
    });
  }

  void _performSearch(String query) {
    if (query.isNotEmpty) {
      Provider.of<DiaryProvider>(context, listen: false).searchDiaries(query);
    } else {
      Provider.of<DiaryProvider>(context, listen: false).fetchDiaries();
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
      body: diaryProvider.diaries.isEmpty
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
    );
  }
}