import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'auth_service.dart';

class QuestService {
  static const String _baseUrl = '${ApiConfig.apiBaseUrl}/quests';

  // Get user's daily quest
  static Future<Map<String, dynamic>?> getDailyQuest() async {
    try {
      final token = AuthService.currentToken;
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/daily'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['return_code'] == 'SUCCESS') {
        return data['quest'];
      } else {
        throw Exception(data['message'] ?? 'Failed to get daily quest');
      }
    } catch (e) {
      print('Error getting daily quest: $e');
      return null;
    }
  }

  // Get user's weekly quests
  static Future<List<Map<String, dynamic>>?> getWeeklyQuests() async {
    try {
      final token = AuthService.currentToken;
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/weekly'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['return_code'] == 'SUCCESS') {
        return List<Map<String, dynamic>>.from(data['quests']);
      } else {
        throw Exception(data['message'] ?? 'Failed to get weekly quests');
      }
    } catch (e) {
      print('Error getting weekly quests: $e');
      return null;
    }
  }

  // Get user's weekly quests with reroll info
  static Future<Map<String, dynamic>?> getWeeklyQuestsWithRerollInfo() async {
    try {
      final token = AuthService.currentToken;
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/weekly'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['return_code'] == 'SUCCESS') {
        return {
          'quests': List<Map<String, dynamic>>.from(data['quests']),
          'can_reroll': data['can_reroll'] ?? false,
          'week_start': data['week_start'],
        };
      } else {
        throw Exception(data['message'] ?? 'Failed to get weekly quests');
      }
    } catch (e) {
      print('Error getting weekly quests: $e');
      return null;
    }
  }

  // Reroll daily quest
  static Future<Map<String, dynamic>?> rerollDailyQuest() async {
    try {
      final token = AuthService.currentToken;
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/daily/reroll'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['return_code'] == 'SUCCESS') {
        return data['quest'];
      } else {
        throw Exception(data['message'] ?? 'Failed to reroll daily quest');
      }
    } catch (e) {
      print('Error rerolling daily quest: $e');
      return null;
    }
  }

  // Reroll weekly quests
  static Future<List<Map<String, dynamic>>?> rerollWeeklyQuests() async {
    try {
      final token = AuthService.currentToken;
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/weekly/reroll'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['return_code'] == 'SUCCESS') {
        return List<Map<String, dynamic>>.from(data['quests']);
      } else {
        throw Exception(data['message'] ?? 'Failed to reroll weekly quests');
      }
    } catch (e) {
      print('Error rerolling weekly quests: $e');
      return null;
    }
  }

  // Get quest details by ID
  static Future<Map<String, dynamic>?> getQuestDetails(String questId) async {
    try {
      // Validate quest ID
      if (questId.isEmpty || questId == 'null' || questId == 'undefined') {
        throw Exception('Invalid quest ID: $questId');
      }

      // Try to parse as integer to validate
      final parsedId = int.tryParse(questId);
      if (parsedId == null || parsedId <= 0) {
        throw Exception('Quest ID must be a positive integer: $questId');
      }

      final token = AuthService.currentToken;
      if (token == null) {
        throw Exception('No authentication token found');
      }

      print('Getting quest details for ID: $questId'); // Debug
      final response = await http.get(
        Uri.parse('$_baseUrl/$questId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['return_code'] == 'SUCCESS') {
        return data['quest'];
      } else {
        throw Exception(data['message'] ?? 'Failed to get quest details');
      }
    } catch (e) {
      print('Error getting quest details: $e');
      return null;
    }
  }

  // Complete a quest
  static Future<Map<String, dynamic>?> completeQuest(
    int assignmentId, {
    String? completionNotes,
  }) async {
    try {
      final token = AuthService.currentToken;
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final body = <String, dynamic>{
        'assignment_id': assignmentId,
      };

      if (completionNotes != null && completionNotes.isNotEmpty) {
        body['completion_notes'] = completionNotes;
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/complete'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 30));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['return_code'] == 'SUCCESS') {
        return {
          'completion': data['completion'],
          'newly_earned_badges': data['newly_earned_badges'] ?? [],
        };
      } else {
        throw Exception(data['message'] ?? 'Failed to complete quest');
      }
    } catch (e) {
      print('Error completing quest: $e');
      return null;
    }
  }

  // Uncomplete a quest (undo completion)
  static Future<Map<String, dynamic>?> uncompleteQuest(int assignmentId) async {
    try {
      final token = AuthService.currentToken;
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/uncomplete'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'assignment_id': assignmentId,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['return_code'] == 'SUCCESS') {
          return data;
        } else {
          throw Exception(data['message'] ?? 'Failed to unmark quest');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to unmark quest');
      }
    } catch (e) {
      print('Error uncompleting quest: $e');
      return null;
    }
  }

  // Helper method to get category icon based on category name
  static String getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'cafe':
        return '☕';
      case 'exercise':
        return '🏃';
      case 'kindness':
        return '💛';
      case 'culture':
        return '🎭';
      case 'nature':
        return '🌿';
      case 'learning':
        return '📚';
      default:
        return '🎯';
    }
  }

  // Helper method to get difficulty color
  static String getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return '#4CAF50'; // Green
      case 'medium':
        return '#FF9800'; // Orange
      case 'hard':
        return '#F44336'; // Red
      default:
        return '#2196F3'; // Blue
    }
  }

  // Helper method to format duration
  static String formatDuration(int? minutes) {
    if (minutes == null || minutes == 0) return 'Flexible';
    if (minutes < 60) return '${minutes} min';
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (remainingMinutes == 0) return '${hours}h';
    return '${hours}h ${remainingMinutes}m';
  }

  // Get quest history with pagination
  static Future<Map<String, dynamic>?> getQuestHistory({
    String? filter, // 'all', 'completed', 'favorites'
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final token = AuthService.currentToken;
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final queryParams = <String, String>{
        'limit': limit.toString(),
        'offset': offset.toString(),
      };
      if (filter != null && filter != 'all') {
        queryParams['filter'] = filter;
      }

      final uri = Uri.parse('$_baseUrl/history').replace(queryParameters: queryParams);
      print('Making quest history request to: $uri'); // Debug
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      print('Quest history response status: ${response.statusCode}'); // Debug
      print('Quest history response body: ${response.body}'); // Debug

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['return_code'] == 'SUCCESS') {
        return {
          'history': List<Map<String, dynamic>>.from(data['history'] ?? []),
          'pagination': data['pagination'] ?? {},
        };
      } else {
        print('Quest history API error: ${data['message']}'); // Debug
        throw Exception(data['message'] ?? 'Failed to get quest history');
      }
    } catch (e) {
      print('Error getting quest history: $e');
      return null;
    }
  }
}
