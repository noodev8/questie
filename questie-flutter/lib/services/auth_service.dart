// Authentication Service - Handles API communication for user authentication
// Provides methods for login, register, email verification, password reset, and JWT token management

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/api_config.dart';

class AuthService {
  // Use simple API configuration
  static String get _baseUrl => ApiConfig.authApiUrl;
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  // Storage keys
  static const String _tokenKey = 'access_token';
  static const String _userKey = 'user_data';

  // User model
  static Map<String, dynamic>? _currentUser;
  static String? _currentToken;

  // Get current user
  static Map<String, dynamic>? get currentUser => _currentUser;
  static String? get currentToken => _currentToken;
  static bool get isLoggedIn => _currentToken != null && _currentUser != null;
  static bool get isAnonymous => _currentUser?['is_anonymous'] == true;
  static bool get isEmailVerified => _currentUser?['email_verified'] == true;

  // Initialize service (load stored token and user data)
  static Future<bool> initialize() async {
    try {
      _currentToken = await _storage.read(key: _tokenKey);
      final userData = await _storage.read(key: _userKey);

      if (_currentToken != null && userData != null) {
        _currentUser = jsonDecode(userData);

        // Verify token is still valid
        final isValid = await verifyToken();
        if (!isValid) {
          await logout();
          return false;
        }
        return true;
      }
      return false;
    } catch (e) {
      await logout(); // Clear any corrupted data
      return false;
    }
  }

  // Store authentication data
  static Future<void> _storeAuthData(String token, Map<String, dynamic> user) async {
    _currentToken = token;
    _currentUser = user;
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _userKey, value: jsonEncode(user));
  }

  // Clear authentication data
  static Future<void> _clearAuthData() async {
    _currentToken = null;
    _currentUser = null;
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
  }

  // Make authenticated HTTP request
  static Future<http.Response> _makeRequest(
    String endpoint,
    String method, {
    Map<String, dynamic>? body,
    bool requireAuth = false,
  }) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    final headers = {
      'Content-Type': 'application/json',
    };

    if (requireAuth && _currentToken != null) {
      headers['Authorization'] = 'Bearer $_currentToken';
    }

    http.Response response;
    switch (method.toLowerCase()) {
      case 'post':
        response = await http.post(
          url,
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        ).timeout(const Duration(seconds: 30));
        break;
      case 'get':
        response = await http.get(url, headers: headers)
            .timeout(const Duration(seconds: 30));
        break;
      default:
        throw Exception('Unsupported HTTP method: $method');
    }

    return response;
  }

  // Parse API response
  static Map<String, dynamic> _parseResponse(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      return data;
    } catch (e) {
      throw Exception('Failed to parse response: $e');
    }
  }

  // Register new user
  static Future<Map<String, dynamic>> register({
    required String email,
    required String displayName,
    required String password,
  }) async {
    try {
      final response = await _makeRequest('/register', 'POST', body: {
        'email': email,
        'display_name': displayName,
        'password': password,
      });

      final data = _parseResponse(response);

      if (data['return_code'] == 'SUCCESS') {
        return {
          'success': true,
          'message': data['message'],
          'user': data['user'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Registration failed',
          'return_code': data['return_code'],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
        'return_code': 'NETWORK_ERROR',
      };
    }
  }

  // Login user
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _makeRequest('/login', 'POST', body: {
        'email': email,
        'password': password,
      });

      final data = _parseResponse(response);
      
      if (data['return_code'] == 'SUCCESS') {
        await _storeAuthData(data['access_token'], data['user']);
        return {
          'success': true,
          'message': data['message'],
          'user': data['user'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Login failed',
          'return_code': data['return_code'],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
        'return_code': 'NETWORK_ERROR',
      };
    }
  }

  // Guest login
  static Future<Map<String, dynamic>> guestLogin({
    required String displayName,
  }) async {
    try {
      final response = await _makeRequest('/guest-login', 'POST', body: {
        'display_name': displayName,
      });

      final data = _parseResponse(response);
      
      if (data['return_code'] == 'SUCCESS') {
        await _storeAuthData(data['access_token'], data['user']);
        return {
          'success': true,
          'message': data['message'],
          'user': data['user'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Guest login failed',
          'return_code': data['return_code'],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
        'return_code': 'NETWORK_ERROR',
      };
    }
  }

  // Resend verification email
  static Future<Map<String, dynamic>> resendVerificationEmail({
    required String email,
  }) async {
    try {
      final response = await _makeRequest('/resend-verification', 'POST', body: {
        'email': email,
      });

      final data = _parseResponse(response);
      
      return {
        'success': data['return_code'] == 'SUCCESS',
        'message': data['message'] ?? 'Request processed',
        'return_code': data['return_code'],
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
        'return_code': 'NETWORK_ERROR',
      };
    }
  }

  // Forgot password
  static Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) async {
    try {
      final response = await _makeRequest('/forgot-password', 'POST', body: {
        'email': email,
      });

      final data = _parseResponse(response);
      
      return {
        'success': data['return_code'] == 'SUCCESS',
        'message': data['message'] ?? 'Request processed',
        'return_code': data['return_code'],
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
        'return_code': 'NETWORK_ERROR',
      };
    }
  }

  // Reset password
  static Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      final response = await _makeRequest('/reset-password', 'POST', body: {
        'token': token,
        'new_password': newPassword,
      });

      final data = _parseResponse(response);
      
      return {
        'success': data['return_code'] == 'SUCCESS',
        'message': data['message'] ?? 'Password reset processed',
        'return_code': data['return_code'],
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
        'return_code': 'NETWORK_ERROR',
      };
    }
  }

  // Update profile
  static Future<Map<String, dynamic>> updateProfile({
    String? displayName,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (displayName != null) body['display_name'] = displayName;

      final response = await _makeRequest('/update-profile', 'POST', 
        body: body, 
        requireAuth: true
      );

      final data = _parseResponse(response);
      
      if (data['return_code'] == 'SUCCESS') {
        // Update stored user data
        _currentUser = data['user'];
        await _storage.write(key: _userKey, value: jsonEncode(_currentUser));
        
        return {
          'success': true,
          'message': data['message'],
          'user': data['user'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Profile update failed',
          'return_code': data['return_code'],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
        'return_code': 'NETWORK_ERROR',
      };
    }
  }

  // Verify token
  static Future<bool> verifyToken() async {
    try {
      if (_currentToken == null) return false;

      final response = await _makeRequest('/verify-token', 'POST', requireAuth: true);
      final data = _parseResponse(response);
      
      if (data['return_code'] == 'SUCCESS') {
        // Update user data if provided
        if (data['user'] != null) {
          _currentUser = data['user'];
          await _storage.write(key: _userKey, value: jsonEncode(_currentUser));
        }
        return true;
      } else {
        return false;
      }
    } catch (e) {
      // In production, use a proper logging framework
      assert(() {
        print('Token verification error: $e');
        return true;
      }());
      return false;
    }
  }

  // Logout
  static Future<void> logout() async {
    await _clearAuthData();
  }
}
