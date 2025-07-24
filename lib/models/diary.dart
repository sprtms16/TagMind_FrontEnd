import 'package:tagmind_frontend/models/tag.dart'; // Assuming you have a tag model

// Represents a diary entry with its details and associated tags.
class Diary {
  final int id; // Unique identifier for the diary entry
  final int userId; // ID of the user who owns this diary
  final String title; // Title of the diary entry
  final String content; // Main content of the diary entry
  final String? imageUrl; // Optional URL for an associated image
  final DateTime createdAt; // Timestamp when the diary was created
  final DateTime updatedAt; // Timestamp when the diary was last updated
  final List<Tag> tags; // List of Tag objects associated with this diary

  // Constructor for the Diary model
  Diary({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.tags,
  });

  // Factory constructor to create a Diary object from a JSON map.
  factory Diary.fromJson(Map<String, dynamic> json) {
    // Safely parse the 'tags' field, handling null or empty lists.
    var tagsFromJson = json['tags'];
    List<Tag> tagList = tagsFromJson != null
        ? (tagsFromJson as List).map((i) => Tag.fromJson(i)).toList()
        : [];

    return Diary(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      content: json['content'],
      imageUrl: json['image_url'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      tags: tagList,
    );
  }
}
