import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/tag.dart'; // Import the Tag model from models/tag.dart

// TagProvider manages tag-related data and interactions with the backend.
class TagProvider with ChangeNotifier {
  List<Tag> _tags = []; // List of available tags
  final _storage = const FlutterSecureStorage(); // Secure storage for JWT token

  // Getter for the list of tags
  List<Tag> get tags => [..._tags];

  // Base URL for the backend API
  static const String _baseUrl =
      'http://localhost:8000'; // Backend API base URL

  // Fetches all available tags from the backend for the current user.
  Future<void> fetchTags() async {
    final url = Uri.parse('$_baseUrl/tags');
    final token = await _storage.read(key: 'jwt_token');

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        _tags = responseData.map((json) => Tag.fromJson(json)).toList();
        notifyListeners(); // Notify listeners about state change
      } else {
        throw Exception('Failed to load tags');
      }
    } catch (error) {
      rethrow; // Re-throw any other errors
    }
  }
}
