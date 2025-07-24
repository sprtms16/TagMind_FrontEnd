import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:table_calendar/table_calendar.dart'; // Import for isSameDay utility
import '../models/diary.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// DiaryProvider manages diary-related data and interactions with the backend.
class DiaryProvider with ChangeNotifier {
  List<Diary> _diaries = []; // List of diaries currently displayed (filtered by date/search)
  List<Diary> _allDiaries = []; // Full list of all diaries for the user (used for calendar events)
  List<Diary> _searchedDiariesForCalendar = []; // List of diaries matching search query (for calendar events)
  final _storage = const FlutterSecureStorage(); // Secure storage for JWT token

  // Getters for diary lists
  List<Diary> get diaries {
    return [..._diaries];
  }

  List<Diary> get allDiaries {
    return [..._allDiaries];
  }

  List<Diary> get searchedDiariesForCalendar {
    return [..._searchedDiariesForCalendar];
  }

  // Base URL for the backend API
  static const String _baseUrl =
      'http://localhost:8000'; // Backend API base URL

  // Fetches all diaries for the current user from the backend.
  // This list is primarily used for populating calendar events.
  Future<void> fetchDiaries() async {
    final url = Uri.parse('$_baseUrl/diaries');
    final token = await _storage.read(key: 'jwt_token');

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        _allDiaries = responseData.map((json) => Diary.fromJson(json)).toList();
        notifyListeners(); // Notify listeners about state change
      } else {
        throw Exception('Failed to load diaries');
      }
    } catch (error) {
      rethrow; // Re-throw any other errors
    }
  }

  // Fetches diaries for a specific date for the current user from the backend.
  // This updates the displayed diary list (_diaries).
  Future<void> fetchDiariesByDate(DateTime date) async {
    final formattedDate =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    final url = Uri.parse('$_baseUrl/diaries?date=$formattedDate');
    final token = await _storage.read(key: 'jwt_token');

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        _diaries = responseData.map((json) => Diary.fromJson(json)).toList();
        notifyListeners(); // Notify listeners about state change
      } else {
        throw Exception('Failed to load diaries by date');
      }
    } catch (error) {
      rethrow; // Re-throw any other errors
    }
  }

  // Searches diary entries by query string for the current user.
  // Updates both the displayed diary list (_diaries) and the calendar search results (_searchedDiariesForCalendar).
  Future<void> searchDiaries(String query, DateTime? selectedDate) async {
    String urlString = '$_baseUrl/search?query=$query';
    final url = Uri.parse(urlString);
    final token = await _storage.read(key: 'jwt_token');

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        _searchedDiariesForCalendar = responseData.map((json) => Diary.fromJson(json)).toList();
        // Filter displayed diaries by selected date from the search results
        _diaries = _searchedDiariesForCalendar.where((diary) => isSameDay(diary.createdAt, selectedDate ?? DateTime.now())).toList();
        notifyListeners(); // Notify listeners about state change
      } else {
        throw Exception('Failed to search diaries');
      }
    } catch (error) {
      rethrow; // Re-throw any other errors
    }
  }

  // Adds a new diary entry to the backend.
  Future<void> addDiary(Diary diary) async {
    final url = Uri.parse('$_baseUrl/diaries');
    final token = await _storage.read(key: 'jwt_token');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'title': diary.title,
          'content': diary.content,
          'image_url': diary.imageUrl,
          'tags': diary.tags.map((tag) => tag.id).toList(), // Send tag IDs
        }),
      );

      if (response.statusCode == 200) {
        final newDiary = Diary.fromJson(json.decode(response.body));
        _diaries.add(newDiary); // Add to displayed list
        // Also add to _allDiaries and _searchedDiariesForCalendar if applicable
        _allDiaries.add(newDiary);
        if (_searchedDiariesForCalendar.isNotEmpty) {
          // If currently in search mode, add to search results as well
          _searchedDiariesForCalendar.add(newDiary);
        }
        notifyListeners(); // Notify listeners about state change
      } else {
        print('Failed to add diary: ${response.statusCode} ${response.body}');
        throw Exception('Failed to add diary');
      }
    } catch (error) {
      rethrow; // Re-throw any other errors
    }
  }

  // Updates an existing diary entry in the backend.
  Future<void> updateDiary(int id, Diary newDiary) async {
    final url = Uri.parse('$_baseUrl/diaries/$id');
    final token = await _storage.read(key: 'jwt_token');

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'title': newDiary.title,
          'content': newDiary.content,
          'image_url': newDiary.imageUrl,
          'tags': newDiary.tags.map((tag) => tag.id).toList(), // Send tag IDs
        }),
      );

      if (response.statusCode == 200) {
        final updatedDiary = Diary.fromJson(json.decode(response.body));
        // Update in displayed list
        final diaryIndex = _diaries.indexWhere((diary) => diary.id == id);
        if (diaryIndex >= 0) {
          _diaries[diaryIndex] = updatedDiary;
        }
        // Update in all diaries list
        final allDiaryIndex = _allDiaries.indexWhere((diary) => diary.id == id);
        if (allDiaryIndex >= 0) {
          _allDiaries[allDiaryIndex] = updatedDiary;
        }
        // Update in searched diaries list if applicable
        final searchedDiaryIndex = _searchedDiariesForCalendar.indexWhere((diary) => diary.id == id);
        if (searchedDiaryIndex >= 0) {
          _searchedDiariesForCalendar[searchedDiaryIndex] = updatedDiary;
        }
        notifyListeners(); // Notify listeners about state change
      } else {
        throw Exception('Failed to update diary');
      }
    } catch (error) {
      rethrow; // Re-throw any other errors
    }
  }

  // Deletes a diary entry from the backend.
  Future<void> deleteDiary(int id) async {
    final url = Uri.parse('$_baseUrl/diaries/$id');
    final token = await _storage.read(key: 'jwt_token');

    try {
      final response = await http.delete(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 204) {
        _diaries.removeWhere((diary) => diary.id == id);
        _allDiaries.removeWhere((diary) => diary.id == id);
        _searchedDiariesForCalendar.removeWhere((diary) => diary.id == id);
        notifyListeners(); // Notify listeners about state change
      } else {
        throw Exception('Failed to delete diary');
      }
    } catch (error) {
      rethrow; // Re-throw any other errors
    }
  }
}

