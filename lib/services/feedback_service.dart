// lib/services/feedback_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class FeedbackService {
  static String _baseUrl = 'http://192.168.29.50:5000/api';

  static void setBaseUrl(String url) => _baseUrl = url;

  // ---------------------------------------------------------
  // SUBMIT FEEDBACK
  // ---------------------------------------------------------
  Future<Map<String, dynamic>> submitFeedback({
    required String complaintId,
    required double rating,
    required String feedbackText,
    required Map<String, double> aspectRatings,
    required bool isAnonymous,
  }) async {
    try {
      final token = await ApiService().getToken();

      final headers = {
        'Content-Type': 'application/json',
      };

      // 👉 Send token only if NOT anonymous
      if (!isAnonymous && token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http
          .post(
            Uri.parse('$_baseUrl/feedback/submit'),
            headers: headers,
            body: jsonEncode({
              'complaintId': complaintId,
              'rating': rating,
              'feedbackText': feedbackText,
              'aspectRatings': aspectRatings,
              'isAnonymous': isAnonymous,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        return {
          'success': true,
          'message': decoded['message'] ?? 'Feedback submitted successfully',
          'data': decoded['data'],
        };
      } else {
        final decoded = jsonDecode(response.body);
        return {
          'success': false,
          'message': decoded['message'] ??
              'Failed to submit feedback (${response.statusCode})'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error submitting feedback: ${e.toString()}',
      };
    }
  }

  // ---------------------------------------------------------
  // GET FEEDBACK HISTORY
  // ---------------------------------------------------------
  Future<Map<String, dynamic>> getFeedbackHistory() async {
    try {
      final token = await ApiService().getToken();
      final uri = Uri.parse('$_baseUrl/feedback/user/me');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonRes = jsonDecode(response.body);

        final list = List<dynamic>.from(jsonRes['data'] ?? []);

        final mapped = list.map((f) {
          return {
            'id': f['_id'],
            'complaintId': f['complaintId'],
            'rating': f['rating'],
            'message': f['feedbackText'] ?? '',
            'submittedDate': f['submittedAt'] ?? '',
            'status': f['status'] ?? 'Reviewed',

            // Show anonymous or username
            'userName': (f['isAnonymous'] == true)
                ? 'Anonymous'
                : (f['user']?['username'] ?? 'User'),
          };
        }).toList();

        return {
          'success': true,
          'data': mapped,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch feedback history',
          'data': []
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error fetching feedback: ${e.toString()}',
        'data': []
      };
    }
  }

  // ---------------------------------------------------------
  // DELETE FEEDBACK
  // ---------------------------------------------------------
  Future<Map<String, dynamic>> deleteFeedback({
    required String feedbackId,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/feedback/$feedbackId');

      final response = await http.delete(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Feedback deleted successfully',
        };
      }

      return {
        'success': false,
        'message': 'Failed to delete feedback (${response.statusCode})',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error deleting feedback: ${e.toString()}'
      };
    }
  }
}
