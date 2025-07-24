import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// AuthProvider manages user authentication state and interactions with the backend.
class AuthProvider with ChangeNotifier {
  // Secure storage for JWT token
  final _storage = const FlutterSecureStorage();
  String? _token; // Stores the JWT token

  // Getter for the current JWT token
  String? get token => _token;

  // Base URL for the backend API
  static const String _baseUrl =
      'http://localhost:8000'; // Backend API base URL

  // Handles user login by sending credentials to the backend and storing the JWT token.
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
        // Store the token securely for auto-login and future API calls
        await _storage.write(key: 'jwt_token', value: _token);
        notifyListeners(); // Notify listeners about state change
      } else {
        final errorData = json.decode(response.body);
        // Throw an exception with a detailed error message from the backend
        throw Exception(errorData['detail'] ?? '로그인 실패');
      }
    } catch (error) {
      rethrow; // Re-throw any other errors
    }
  }

  // Handles user signup by sending registration details to the backend.
  // Automatically logs in the user upon successful registration.
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
        // Throw an exception with a detailed error message from the backend
        throw Exception(errorData['detail'] ?? '회원가입 실패');
      }
    } catch (error) {
      rethrow; // Re-throw any other errors
    }
  }

  // Logs out the user by clearing the token from memory and secure storage.
  Future<void> logout() async {
    _token = null; // Clear token from memory
    await _storage.delete(key: 'jwt_token'); // Delete token from secure storage
    notifyListeners(); // Notify listeners about state change
  }

  // Attempts to automatically log in the user using a stored JWT token.
  Future<void> autoLogin() async {
    _token = await _storage.read(key: 'jwt_token'); // Read token from secure storage
    if (_token != null) {
      notifyListeners(); // Notify listeners if a token is found
    }
  }
}
