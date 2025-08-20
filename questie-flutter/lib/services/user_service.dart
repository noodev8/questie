import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/api_config.dart';
import 'auth_service.dart';

class UserService {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'auth_token';

  // Cache for user stats and badges
  static Map<String, dynamic>? _cachedStats;
  static List<Map<String, dynamic>>? _cachedBadges;
  static DateTime? _statsLastFetched;
  static DateTime? _badgesLastFetched;
  static const _cacheValidityDuration = Duration(minutes: 5);

  // Helper method to get auth token
  static Future<String?> _getAuthToken() async {
    return AuthService.currentToken;
  }

  // Helper method to make authenticated requests
  static Future<http.Response> _makeRequest(String endpoint, String method, {
    Map<String, dynamic>? body,
  }) async {
    final token = await _getAuthToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    final url = Uri.parse('${ApiConfig.apiBaseUrl}$endpoint');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    switch (method.toUpperCase()) {
      case 'GET':
        return await http.get(url, headers: headers);
      case 'POST':
        return await http.post(
          url,
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        );
      default:
        throw Exception('Unsupported HTTP method: $method');
    }
  }

  // Helper method to parse API response
  static Map<String, dynamic> _parseResponse(http.Response response) {
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Request failed');
    }
  }

  // Get user statistics
  static Future<Map<String, dynamic>> getUserStats({bool forceRefresh = false}) async {
    try {
      // Check cache first
      if (!forceRefresh && 
          _cachedStats != null && 
          _statsLastFetched != null &&
          DateTime.now().difference(_statsLastFetched!) < _cacheValidityDuration) {
        return {
          'success': true,
          'stats': _cachedStats,
        };
      }

      final response = await _makeRequest('/user/stats', 'GET');
      final data = _parseResponse(response);
      
      if (data['return_code'] == 'SUCCESS') {
        // Cache the results
        _cachedStats = data['stats'];
        _statsLastFetched = DateTime.now();
        
        return {
          'success': true,
          'stats': data['stats'],
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to get user stats',
          'return_code': data['return_code'],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to get user stats: ${e.toString()}',
      };
    }
  }

  // Get all badges with user progress
  static Future<Map<String, dynamic>> getBadges({bool forceRefresh = false}) async {
    try {
      // Check cache first
      if (!forceRefresh && 
          _cachedBadges != null && 
          _badgesLastFetched != null &&
          DateTime.now().difference(_badgesLastFetched!) < _cacheValidityDuration) {
        return {
          'success': true,
          'badges': _cachedBadges,
        };
      }

      final response = await _makeRequest('/user/badges', 'GET');
      final data = _parseResponse(response);
      
      if (data['return_code'] == 'SUCCESS') {
        // Cache the results
        _cachedBadges = List<Map<String, dynamic>>.from(data['badges'] ?? []);
        _badgesLastFetched = DateTime.now();
        
        return {
          'success': true,
          'badges': data['badges'],
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to get badges',
          'return_code': data['return_code'],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to get badges: ${e.toString()}',
      };
    }
  }

  // Get only earned badges
  static Future<Map<String, dynamic>> getEarnedBadges({bool forceRefresh = false}) async {
    try {
      final response = await _makeRequest('/user/badges/earned', 'GET');
      final data = _parseResponse(response);
      
      if (data['return_code'] == 'SUCCESS') {
        return {
          'success': true,
          'badges': data['badges'],
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to get earned badges',
          'return_code': data['return_code'],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to get earned badges: ${e.toString()}',
      };
    }
  }

  // Clear cache (useful after quest completion)
  static void clearCache() {
    _cachedStats = null;
    _cachedBadges = null;
    _statsLastFetched = null;
    _badgesLastFetched = null;
  }

  // Clear only stats cache
  static void clearStatsCache() {
    _cachedStats = null;
    _statsLastFetched = null;
  }

  // Clear only badges cache
  static void clearBadgesCache() {
    _cachedBadges = null;
    _badgesLastFetched = null;
  }

  // Get cached stats without making API call
  static Map<String, dynamic>? getCachedStats() {
    if (_cachedStats != null && 
        _statsLastFetched != null &&
        DateTime.now().difference(_statsLastFetched!) < _cacheValidityDuration) {
      return _cachedStats;
    }
    return null;
  }

  // Get cached badges without making API call
  static List<Map<String, dynamic>>? getCachedBadges() {
    if (_cachedBadges != null && 
        _badgesLastFetched != null &&
        DateTime.now().difference(_badgesLastFetched!) < _cacheValidityDuration) {
      return _cachedBadges;
    }
    return null;
  }
}
