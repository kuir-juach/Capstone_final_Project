import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';

class PlantService {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8000';
    } else {
      return 'http://10.0.2.2:8000';
    }
  }

  static Future<Map<String, dynamic>?> getPlantInfo(String plantName) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/plant/${plantName.toLowerCase()}'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 404) {
        return null; // Plant not found
      } else {
        throw Exception('Failed to fetch plant info: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching plant info: $e');
      return null;
    }
  }
}