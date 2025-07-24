import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/diary_provider.dart';
import '../providers/tag_provider.dart';
import '../models/diary.dart';
import '../models/tag.dart';

// DiaryEditScreen allows users to create or edit diary entries.
class DiaryEditScreen extends StatefulWidget {
  static const routeName = '/edit-diary';

  @override
  _DiaryEditScreenState createState() => _DiaryEditScreenState();
}

class _DiaryEditScreenState extends State<DiaryEditScreen> {
  final _formKey = GlobalKey<FormState>(); // GlobalKey for form validation
  final _titleController = TextEditingController(); // Controller for diary title input
  var _editedDiary = Diary(
    id: 0,
    userId: 0,
    title: '',
    content: '', // Content will be derived from tags or deprecated
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    imageUrl: null,
    tags: [],
  ); // Stores the diary data being edited or created
  var _isInit = true; // Flag to control initial data loading
  var _isLoading = false; // Controls loading indicator visibility
  List<Tag> _selectedTags = []; // List of tags selected for the current diary

  @override
  void didChangeDependencies() {
    if (_isInit) {
      // Check if a diary ID is passed as an argument (for editing existing diary)
      final diaryId = ModalRoute.of(context)!.settings.arguments as int?;
      if (diaryId != null) {
        // Load existing diary data if ID is provided
        _editedDiary = Provider.of<DiaryProvider>(context, listen: false)
            .diaries
            .firstWhere((diary) => diary.id == diaryId);
        _titleController.text = _editedDiary.title;
        _selectedTags = _editedDiary.tags; // Pre-select tags of the existing diary
      }
      // Fetch available tags (commented out as it's usually done once at app startup)
      // Provider.of<TagProvider>(context, listen: false).fetchTags();
    }
    _isInit = false; // Set flag to false after initial load
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _titleController.dispose(); // Dispose controller to prevent memory leaks
    super.dispose();
  }

  // Handles saving the diary entry (create or update).
  Future<void> _saveForm() async {
    final isValid = _formKey.currentState!.validate(); // Validate form fields
    if (!isValid) {
      return; // If form is not valid, do not proceed
    }
    _formKey.currentState!.save(); // Save form field values
    setState(() {
      _isLoading = true; // Show loading indicator
    });

    try {
      // Create a Diary object with current form data
      final diaryToSave = Diary(
        id: _editedDiary.id,
        userId: _editedDiary.userId, // User ID is typically handled by backend authentication
        title: _titleController.text,
        content: _selectedTags
            .map((t) => t.name)
            .join(', '), // Generate content from selected tag names
        createdAt:
            _editedDiary.id != 0 ? _editedDiary.createdAt : DateTime.now(), // Preserve creation date for existing diaries
        updatedAt: DateTime.now(), // Update timestamp to current time
        imageUrl: _editedDiary.imageUrl,
        tags: _selectedTags, // Pass selected Tag objects
      );

      if (_editedDiary.id != 0) {
        // If editing an existing diary, call updateDiary
        await Provider.of<DiaryProvider>(context, listen: false)
            .updateDiary(_editedDiary.id, diaryToSave);
      } else {
        // If creating a new diary, call addDiary
        await Provider.of<DiaryProvider>(context, listen: false)
            .addDiary(diaryToSave);
      }
    } catch (error) {
      // Show error dialog if saving fails
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
      _isLoading = false; // Hide loading indicator
    });
    Navigator.of(context).pop(); // Navigate back after saving
  }

  @override
  Widget build(BuildContext context) {
    // Get all available tags from TagProvider
    final allTags = Provider.of<TagProvider>(context).tags;
    // Group tags by category for display
    final groupedTags = _groupTagsByCategory(allTags);

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Diary'), // AppBar title
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save), // Save icon button
            onPressed: _saveForm, // Call save function on press
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator()) // Show loading indicator
          : Padding(
              padding: const EdgeInsets.all(16.0), // Padding for the form
              child: Form(
                key: _formKey, // Assign form key
                child: Column(
                  children: <Widget>[
                    // Title input field
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Title'),
                      textInputAction: TextInputAction.next, // Move to next field on enter
                      controller: _titleController, // Controller for title input
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please provide a title.';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16), // Spacer
                    // Expanded widget to take available space for tag selection
                    Expanded(
                      child: _buildTagSelection(groupedTags), // Build tag selection UI
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // Helper function to group tags by category
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

  // Builds the tag selection UI using ExpansionTile and FilterChip
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
          title:
              Text(category, style: Theme.of(context).textTheme.headlineMedium), // Category title
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0), // Padding for chips
              child: Wrap(
                spacing: 8.0, // Horizontal spacing between chips
                runSpacing: 4.0, // Vertical spacing between chip rows
                children: tags
                    .map((tag) {
                      final isSelected = _selectedTags
                          .any((selected) => selected.id == tag.id); // Check if tag is selected
                      return FilterChip(
                        label: Text(tag.name), // Tag name as label
                        selected: isSelected, // Selection state
                        showCheckmark: false, // Hide default checkmark
                        onSelected: (bool selected) {
                          setState(() {
                            if (selected) {
                              _selectedTags.add(tag); // Add tag if selected
                            } else {
                              _selectedTags.removeWhere((t) => t.id == tag.id); // Remove tag if unselected
                            }
                          });
                        },
                        selectedColor: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.8), // Color when selected
                        checkmarkColor: Colors.white, // Checkmark color (even if hidden, good practice)
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : Theme.of(context).colorScheme.onSurface, // Label color based on selection
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20), // Rounded corners for chip
                          side: BorderSide(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context)
                                    .colorScheme
                                    .secondary
                                    .withOpacity(0.5), // Border color based on selection
                          ),
                        ),
                      );
                    })
                    .toList()
                    .cast<Widget>(), // Convert to List<Widget>
              ),
            ),
          ],
        );
      },
    );
  }
}
