import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/diary_provider.dart';
import '../models/diary.dart';

class DiaryEditScreen extends StatefulWidget {
  static const routeName = '/edit-diary';

  @override
  _DiaryEditScreenState createState() => _DiaryEditScreenState();
}

class _DiaryEditScreenState extends State<DiaryEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _tagsController = TextEditingController();
  var _editedDiary = Diary(
    id: 0,
    title: '',
    content: '',
    createdAt: DateTime.now(),
    imageUrl: null,
    tags: [],
  );
  var _isInit = true;
  var _isLoading = false;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final diaryId = ModalRoute.of(context)!.settings.arguments as int?;
      if (diaryId != null) {
        _editedDiary = Provider.of<DiaryProvider>(context, listen: false).diaries.firstWhere((diary) => diary.id == diaryId);
        _titleController.text = _editedDiary.title;
        _contentController.text = _editedDiary.content;
        _tagsController.text = _editedDiary.tags.join(', ');
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
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
      final List<String> tags = _tagsController.text.split(',').map((tag) => tag.trim()).where((tag) => tag.isNotEmpty).toList();

      if (_editedDiary.id != 0) {
        await Provider.of<DiaryProvider>(context, listen: false).updateDiary(
          _editedDiary.id,
          Diary(
            id: _editedDiary.id,
            title: _titleController.text,
            content: _contentController.text,
            createdAt: _editedDiary.createdAt,
            imageUrl: _editedDiary.imageUrl,
            tags: tags,
          ),
        );
      } else {
        await Provider.of<DiaryProvider>(context, listen: false).addDiary(
          Diary(
            id: 0,
            title: _titleController.text,
            content: _contentController.text,
            createdAt: DateTime.now(),
            imageUrl: null,
            tags: tags,
          ),
        );
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
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
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
                      onSaved: (value) {
                        _editedDiary = Diary(
                          id: _editedDiary.id,
                          title: value!,
                          content: _editedDiary.content,
                          createdAt: _editedDiary.createdAt,
                          imageUrl: _editedDiary.imageUrl,
                          tags: _editedDiary.tags,
                        );
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Content'),
                      maxLines: 10,
                      keyboardType: TextInputType.multiline,
                      controller: _contentController,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter some content.';
                        }
                        if (value.length < 10) {
                          return 'Should be at least 10 characters long.';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedDiary = Diary(
                          id: _editedDiary.id,
                          title: _editedDiary.title,
                          content: value!,
                          createdAt: _editedDiary.createdAt,
                          imageUrl: _editedDiary.imageUrl,
                          tags: _editedDiary.tags,
                        );
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Tags (comma-separated)'),
                      controller: _tagsController,
                      onSaved: (value) {
                        // Tags are processed in _saveForm
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
