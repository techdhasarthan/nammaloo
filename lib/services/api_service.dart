import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'http://192.168.1.16:3000';

  static Future<void> saveUserData({
    required String name,
    required String email,
    required String photoUrl,
    required String googleId,
  }) async {
    final url = Uri.parse('$_baseUrl/api/login');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'photoUrl': photoUrl,
        'googleId': googleId,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to save user data: ${response.body}');
    }
  }

  static Future<void> updateUserProfile({
    required String googleId,
    required String name,
    required String preferences,
    required String bio,
    required String photoUrl,
  }) async {
    final url = Uri.parse('$_baseUrl/api/update/$googleId');

    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'preferences': preferences,
        'bio': bio,
        'photoUrl': photoUrl,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update profile: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>?> fetchUserProfile(String googleId) async {
    final url = Uri.parse('$_baseUrl/api/user/$googleId');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // The backend returns { message, user }, so extract user
      return data['user'] as Map<String, dynamic>?;
    } else {
      return null;
    }
  }
}
