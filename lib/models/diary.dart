import 'package:flutter/foundation.dart';

class Diary {
  final int id;
  final String title;
  final String content;
  final DateTime createdAt;
  final String? imageUrl;
  final List<String> tags;

  Diary({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.imageUrl,
    this.tags = const [],
  });

  factory Diary.fromJson(Map<String, dynamic> json) {
    return Diary(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
      imageUrl: json['image_url'],
      tags: List<String>.from(json['tags'].map((tag) => tag['name'])),
    );
  }
}
