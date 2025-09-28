import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'http://localhost:7800';
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';

  // Login user and store JWT token
  Future<Map<String, dynamic>?> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['access_token'];
        final user = data['user'];

        // Store token and user data
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(tokenKey, token);
        await prefs.setString(userKey, jsonEncode(user));

        return {
          'token': token,
          'user': user,
        };
      } else {
        throw Exception('Invalid credentials');
      }
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  // Get stored token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  // Get stored user data
  Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString(userKey);
    if (userString != null) {
      return jsonDecode(userString);
    }
    return null;
  }

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Logout user
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
    await prefs.remove(userKey);
  }

  // Get authorization headers
  Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Validate token with backend
  Future<bool> validateToken() async {
    try {
      final headers = await getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/auth/profile'),
        headers: headers,
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
