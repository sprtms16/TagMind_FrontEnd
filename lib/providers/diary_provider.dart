import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/diary.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DiaryProvider with ChangeNotifier {
  List<Diary> _diaries = [];
  final _storage = const FlutterSecureStorage();

  List<Diary> get diaries {
    return [..._diaries];
  }

  static const String _baseUrl = 'http://localhost:8000'; // Backend API base URL

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
        _diaries = responseData.map((json) => Diary.fromJson(json)).toList();
        notifyListeners();
      } else {
        throw Exception('Failed to load diaries');
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<void> addDiary(Diary diary, {XFile? imageFile}) async {
    final url = Uri.parse('$_baseUrl/diaries');
    final token = await _storage.read(key: 'jwt_token');

    try {
      final request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = 'Bearer $token';

      request.fields['title'] = diary.title;
      request.fields['content'] = diary.content;
      request.fields['tags'] = json.encode(diary.tags); // Tags as JSON string

      if (imageFile != null) {
        request.files.add(await http.MultipartFile.fromXFile(imageFile));
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final newDiary = Diary.fromJson(json.decode(responseBody));
        _diaries.add(newDiary);
        notifyListeners();
      } else {
        print('Failed to add diary: ${response.statusCode} $responseBody');
        throw Exception('Failed to add diary');
      }
    } catch (error) {
      rethrow;
    }
  }

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
          'tags': newDiary.tags,
        }),
      );

      if (response.statusCode == 200) {
        final updatedDiary = Diary.fromJson(json.decode(response.body));
        final diaryIndex = _diaries.indexWhere((diary) => diary.id == id);
        if (diaryIndex >= 0) {
          _diaries[diaryIndex] = updatedDiary;
          notifyListeners();
        }
      } else {
        throw Exception('Failed to update diary');
      }
    } catch (error) {
      rethrow;
    }
  }

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
        notifyListeners();
      } else {
        throw Exception('Failed to delete diary');
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<void> searchDiaries(String query) async {
    final url = Uri.parse('$_baseUrl/search?query=$query');
    final token = await _storage.read(key: 'jwt_token');

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        _diaries = responseData.map((json) => Diary.fromJson(json)).toList();
        notifyListeners();
      } else {
        throw Exception('Failed to search diaries');
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<List<String>> fetchSuggestedTags(int diaryId) async {
    final url = Uri.parse('$_baseUrl/ai/tagging');
    final token = await _storage.read(key: 'jwt_token');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'diary_id': diaryId}),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        // Assuming the backend returns the updated diary with new tags
        final updatedDiary = Diary.fromJson(responseData);
        return updatedDiary.tags.map((tag) => tag.name).toList();
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['detail'] ?? 'Failed to fetch suggested tags');
      }
    } catch (error) {
      rethrow;
    }
  }
}
