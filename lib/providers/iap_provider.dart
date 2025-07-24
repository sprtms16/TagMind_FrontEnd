import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/tag_pack.dart';

// IapProvider manages in-app purchase related data and interactions with the backend.
class IapProvider with ChangeNotifier {
  bool _isPremium = false; // Flag to indicate if the user has premium features
  List<TagPack> _availableTagPacks = []; // List of tag packs available for purchase
  final _storage = const FlutterSecureStorage(); // Secure storage for JWT token

  // Getters for premium status and available tag packs
  bool get isPremium => _isPremium;
  List<TagPack> get availableTagPacks => [..._availableTagPacks];

  // Base URL for the backend API
  static const String _baseUrl =
      'http://localhost:8000'; // Backend API base URL

  // Fetches the list of available tag packs from the backend store.
  Future<void> fetchTagPacks() async {
    final url = Uri.parse('$_baseUrl/tags/store');
    final token = await _storage.read(key: 'jwt_token');

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        _availableTagPacks =
            responseData.map((json) => TagPack.fromJson(json)).toList();
        notifyListeners(); // Notify listeners about state change
      } else {
        throw Exception('Failed to load tag packs');
      }
    } catch (error) {
      rethrow; // Re-throw any other errors
    }
  }

  // Handles the purchase of a tag pack.
  // In a real application, this would involve validating a receipt with the App Store/Google Play.
  Future<bool> purchaseTagPack(String productId) async {
    final url = Uri.parse('$_baseUrl/iap/purchase');
    final token = await _storage.read(key: 'jwt_token');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'product_id': productId}),
      );

      if (response.statusCode == 200) {
        // For simplicity, assume any successful purchase makes user premium.
        // In a real app, you'd check specific product IDs or user entitlements.
        _isPremium = true; // This should be more granular based on purchased packs
        // TODO: Backend should return user's current entitlements after purchase for a more robust solution.
        notifyListeners(); // Notify listeners about state change
        return true;
      } else {
        final errorData = json.decode(response.body);
        // Throw an exception with a detailed error message from the backend
        throw Exception(errorData['detail'] ?? 'Purchase failed');
      }
    } catch (error) {
      rethrow; // Re-throw any other errors
    }
  }
}
