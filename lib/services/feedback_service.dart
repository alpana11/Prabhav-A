import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api_service.dart';

class FeedbackService {
  static const String _baseUrl = 'https://10.227.94.92:3000';


  Future<Map<String, dynamic>> submitFeedback({
    required String complaintId,
    required double rating,
    required String feedbackText,
    required Map<String, double> aspectRatings,
    required bool isAnonymous,
  }) async {
    try {
      final token = await ApiService().getToken();
      final response = await http.post(
        Uri.parse('$_baseUrl/feedback/submit'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'complaintId': complaintId,
          'rating': rating,
          'feedbackText': feedbackText,
          'aspectRatings': aspectRatings,
          'isAnonymous': isAnonymous,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Feedback submitted successfully',
          'data': jsonDecode(response.body),
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to submit feedback',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error submitting feedback: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> getFeedbackHistory() async {
    try {
      final token = await ApiService().getToken();
      final response = await http.get(
        Uri.parse('$_baseUrl/feedback/user/me'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonRes = jsonDecode(response.body);
        final List<dynamic> feedbackList = jsonRes['data'] ?? [];
        return {
          'success': true,
          'data': feedbackList.map((f) => {
            'id': f['_id'],
            'complaintId': f['complaintId'],
            'serviceTitle': f['serviceTitle'] ?? 'Service',
            'rating': f['rating'],
            'submittedDate': f['submittedAt'] ?? f['submittedDate'],
            'status': f['status'] ?? 'Reviewed',
            'message': f['feedbackText'] ?? '',
            'userName': f['isAnonymous'] == true ? 'Anonymous' : (f['userName'] ?? 'User'),
          }).toList(),
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch feedback history',
          'data': [],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error fetching feedback: ${e.toString()}',
        'data': [],
      };
    }
  }

  Future<Map<String, dynamic>> deleteFeedback({
    required String feedbackId,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/feedback/$feedbackId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Feedback deleted successfully',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to delete feedback',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error deleting feedback: ${e.toString()}',
      };
    }
  }
}
