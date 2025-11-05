import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart' as http_parser;

class PredictionService {
  // Different URLs for different platforms
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8001';
    } else {
      return 'http://10.0.2.2:8001';
    }
  }

  static Future<Map<String, dynamic>> predictPlant(Uint8List imageBytes) async {
    print('Attempting to connect to: $baseUrl');
    
    try {
      // Test server health first
      final healthResponse = await http.get(
        Uri.parse('$baseUrl/health'),
      ).timeout(Duration(seconds: 5));
      
      if (healthResponse.statusCode != 200) {
        throw Exception('Server health check failed');
      }
      
      print('Server is healthy, making prediction...');
      
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/predict'));
      
      request.headers.addAll({
        'Accept': 'application/json',
      });
      
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        imageBytes,
        filename: 'plant.jpg',
        contentType: http_parser.MediaType('image', 'jpeg'),
      ));
      
      var response = await request.send().timeout(Duration(seconds: 30));
      var responseBody = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        print('Prediction successful');
        return json.decode(responseBody);
      } else {
        throw Exception('Server returned ${response.statusCode}: $responseBody');
      }
    } catch (e) {
      print('Connection failed: $e');
      throw Exception('Cannot connect to server at $baseUrl. Please ensure:\n1. FastAPI server is running\n2. Server is accessible from your device\n3. No firewall blocking port 8000');
    }
  }
}