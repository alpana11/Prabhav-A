import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../core/config/api_constants.dart';
import 'api_service.dart';

class ComplaintService {
  static final ComplaintService _instance = ComplaintService._internal();
  factory ComplaintService() => _instance;
  ComplaintService._internal();

  final ApiService _api = ApiService();

  /// SUBMIT COMPLAINT
  Future<Map<String, dynamic>> submitComplaint({
    required String category,
    required String title,
    required String description,
    required String severity,
    required bool anonymous,
    required List<XFile> media,
    LatLng? location,
    String? address,
  }) async {
    try {
      final token = await _api.getToken();
      final uri = Uri.parse("${ApiConstants.baseUrl}/complaints/");

      final request = http.MultipartRequest('POST', uri);

      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      request.fields['department'] = category;
      request.fields['title'] = title;
      request.fields['description'] = description;
      request.fields['severity'] = severity;
      request.fields['anonymous'] = anonymous ? 'true' : 'false';

      if (location != null) {
        request.fields['latitude'] = location.latitude.toString();
        request.fields['longitude'] = location.longitude.toString();
      }

      if (address != null) request.fields['address'] = address;

      for (var file in media) {
        if (kIsWeb) continue;

        request.files.add(
          await http.MultipartFile.fromPath(
            'images',
            file.path,
            filename: file.path.split(Platform.pathSeparator).last,
            contentType: _lookupContentType(file.path),
          ),
        );
      }

      final streamed = await request.send().timeout(const Duration(seconds: 30));
      final resp = await http.Response.fromStream(streamed);

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        return {
          'success': true,
          'data': jsonDecode(resp.body),
        };
      }

      return {
        'success': false,
        'message': "Server returned ${resp.statusCode}",
        'body': resp.body,
      };

    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// GET USER COMPLAINTS — FIXED
 

  Future<Map<String, dynamic>> getUserComplaints() async {
    try {
      final token = await _api.getToken();
      final uri = Uri.parse("${ApiConstants.baseUrl}/complaints/user/me");

      final response = await http.get(
        uri,
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        return {
          'success': true,
          'complaints': json['complaints'] ?? [],
          'total': json['total'] ?? 0,
       };
      }
      return {
      'success': false,
      'message': "Server returned ${response.statusCode}",
      };

      } catch (e) {
        return {'success': false, 'message': e.toString()};
      }
  }


  MediaType? _lookupContentType(String filename) {
    final lower = filename.toLowerCase();
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return MediaType('image', 'jpeg');
    if (lower.endsWith('.png')) return MediaType('image', 'png');
    if (lower.endsWith('.gif')) return MediaType('image', 'gif');
    if (lower.endsWith('.mp4')) return MediaType('video', 'mp4');
    if (lower.endsWith('.mov')) return MediaType('video', 'quicktime');
    if (lower.endsWith('.avi')) return MediaType('video', 'x-msvideo');
    return MediaType('application', 'octet-stream');
  }
}
