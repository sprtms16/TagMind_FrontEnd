import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthProvider with ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  String? _token;

  String? get token => _token;

  static const String _baseUrl = 'http://localhost:8000'; // Backend API base URL

  Future<void> login(String email, String password) async {
    final url = Uri.parse('$_baseUrl/auth/token');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'username': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        _token = responseData['access_token'];
        await _storage.write(key: 'jwt_token', value: _token);
        notifyListeners();
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['detail'] ?? '로그인 실패');
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<void> signup(String email, String password, String? nickname) async {
    final url = Uri.parse('$_baseUrl/auth/signup');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
          'nickname': nickname,
        }),
      );

      if (response.statusCode == 200) {
        // After successful signup, attempt to log in the user
        await login(email, password);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['detail'] ?? '회원가입 실패');
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<void> logout() async {
    _token = null;
    await _storage.delete(key: 'jwt_token');
    notifyListeners();
  }

  Future<void> autoLogin() async {
    _token = await _storage.read(key: 'jwt_token');
    if (_token != null) {
      notifyListeners();
    }
  }
}
