import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class ProfileService {
  static const String _baseUrl = 'http://192.168.29.50:5000/api';

  Future<Map<String, dynamic>> uploadProfilePicture({
    required String userId,
    required File imageFile,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/user/upload-profile-picture'),
      );

      request.fields['userId'] = userId;
      request.files.add(
        await http.MultipartFile.fromPath(
          'profilePicture',
          imageFile.path,
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        return {
          'success': true,
          'message': 'Profile picture updated successfully',
          'imageUrl': responseData['imageUrl'],
          'data': responseData,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to upload profile picture',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error uploading profile picture: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    required String userId,
    required Map<String, dynamic> profileData,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/user/profile/$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(profileData),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Profile updated successfully',
          'data': jsonDecode(response.body),
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to update profile',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error updating profile: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> getUserProfile({
    required String userId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/user/profile/$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        return {
          'success': true,
          'data': userData,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch user profile',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error fetching profile: ${e.toString()}',
      };
    }
  }
}
