import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smartreminders/env/config.dart';

class ApiClient {

  final String baseUrl = Config.env.apiBaseUrl;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  ApiClient();

  /// Get the Firebase ID token for the current user
  Future<String?> _getToken() async {
    final user = _auth.currentUser;
    return await user?.getIdToken();
  }

  /// Helper for authenticated requests
  Future<http.Response> _request(
      String method,
      String endpoint, {
        Map<String, String>? headers,
        dynamic body,
      }) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('User not authenticated');
    }

    final uri = Uri.parse('$baseUrl$endpoint');
    final defaultHeaders = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      ...?headers,
    };

    switch (method.toUpperCase()) {
      case 'GET':
        return http.get(uri, headers: defaultHeaders);
      case 'POST':
        return http.post(uri, headers: defaultHeaders, body: jsonEncode(body));
      case 'PUT':
        return http.put(uri, headers: defaultHeaders, body: jsonEncode(body));
      case 'DELETE':
        return http.delete(uri, headers: defaultHeaders);
      default:
        throw Exception('Unsupported HTTP method: $method');
    }
  }

  // Public API methods
  Future<http.Response> get(String endpoint) => _request('GET', endpoint);
  Future<http.Response> post(String endpoint, dynamic body) => _request('POST', endpoint, body: body);
  Future<http.Response> put(String endpoint, dynamic body) => _request('PUT', endpoint, body: body);
  Future<http.Response> delete(String endpoint) => _request('DELETE', endpoint);
}
