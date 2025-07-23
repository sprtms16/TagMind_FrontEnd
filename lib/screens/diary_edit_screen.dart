import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/diary_provider.dart';
import '../providers/tag_provider.dart';
import '../models/diary.dart';
import '../models/tag.dart';

class DiaryEditScreen extends StatefulWidget {
  static const routeName = '/edit-diary';

  @override
  _DiaryEditScreenState createState() => _DiaryEditScreenState();
}

class _DiaryEditScreenState extends State<DiaryEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  var _editedDiary = Diary(
    id: 0,
    userId: 0,
    title: '',
    content: '', // Content will be derived from tags or deprecated
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    imageUrl: null,
    tags: [],
  );
  var _isInit = true;
  var _isLoading = false;
  List<Tag> _selectedTags = [];

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final diaryId = ModalRoute.of(context)!.settings.arguments as int?;
      if (diaryId != null) {
        _editedDiary = Provider.of<DiaryProvider>(context, listen: false).diaries.firstWhere((diary) => diary.id == diaryId);
        _titleController.text = _editedDiary.title;
        _selectedTags = _editedDiary.tags;
      }
      // Fetch available tags
      // Provider.of<TagProvider>(context, listen: false).fetchTags();
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _saveForm() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });

    try {
      final diaryToSave = Diary(
        id: _editedDiary.id,
        userId: _editedDiary.userId,
        title: _titleController.text,
        content: _selectedTags.map((t) => t.name).join(', '), // Create content from tags
        createdAt: _editedDiary.id != 0 ? _editedDiary.createdAt : DateTime.now(),
        updatedAt: DateTime.now(),
        imageUrl: _editedDiary.imageUrl,
        tags: _selectedTags,
      );

      if (_editedDiary.id != 0) {
        await Provider.of<DiaryProvider>(context, listen: false).updateDiary(_editedDiary.id, diaryToSave);
      } else {
        await Provider.of<DiaryProvider>(context, listen: false).addDiary(diaryToSave);
      }
    } catch (error) {
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('An error occurred!'),
          content: Text('Something went wrong.'),
          actions: <Widget>[
            TextButton(
              child: Text('Okay'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            )
          ],
        ),
      );
    }

    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    // Dummy Data for Tags - Replace with Provider data
    final allTags = Provider.of<TagProvider>(context).tags;
    final groupedTags = _groupTagsByCategory(allTags);

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Diary'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveForm,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Title'),
                      textInputAction: TextInputAction.next,
                      controller: _titleController,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please provide a title.';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    Expanded(
                      child: _buildTagSelection(groupedTags),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Map<String, List<Tag>> _groupTagsByCategory(List<Tag> tags) {
    final Map<String, List<Tag>> grouped = {};
    for (var tag in tags) {
      if (!grouped.containsKey(tag.category)) {
        grouped[tag.category] = [];
      }
      grouped[tag.category]!.add(tag);
    }
    return grouped;
  }

  Widget _buildTagSelection(Map<String, List<Tag>> groupedTags) {
    if (groupedTags.isEmpty) {
      return Center(
        child: Text('No tags available. Go to the Tag Store to get more!'),
      );
    }

    return ListView.builder(
      itemCount: groupedTags.keys.length,
      itemBuilder: (context, index) {
        String category = groupedTags.keys.elementAt(index);
        List<Tag> tags = groupedTags[category]!;

        return ExpansionTile(
          title: Text(category, style: Theme.of(context).textTheme.headlineMedium),
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: tags.map((tag) {
                  final isSelected = _selectedTags.any((selected) => selected.id == tag.id);
                  return FilterChip(
                    label: Text(tag.name),
                    selected: isSelected,
                    showCheckmark: false,
                    onSelected: (bool selected) {
                      setState(() {
                        if (selected) {
                          _selectedTags.add(tag);
                        } else {
                          _selectedTags.removeWhere((t) => t.id == tag.id);
                        }
                      });
                    },
                    selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.8),
                    checkmarkColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.secondary.withOpacity(0.5),
                      ),
                    ),
                  );
                }).toList().cast<Widget>(), // Add .cast<Widget>() here
              ),
            ),
          ],
        );
      },
    );
  }
}
