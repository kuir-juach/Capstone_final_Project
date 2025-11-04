import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PredictionService {
  static const String baseUrl = 'http://127.0.0.1:8000';

  static Future<Map<String, dynamic>> predictPlant(Uint8List imageBytes) async {
    print('🔄 Starting prediction...');
    print('📊 Image size: ${imageBytes.length} bytes');
    
    try {
      // Test server first
      print('🏥 Testing server health...');
      final healthCheck = await http.get(Uri.parse('$baseUrl/health'));
      print('🏥 Health check status: ${healthCheck.statusCode}');
      
      if (healthCheck.statusCode != 200) {
        throw Exception('Server not responding');
      }
      
      print('📤 Creating prediction request...');
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/predict'));
      
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        imageBytes,
        filename: 'plant.jpg',
      ));
      
      print('🚀 Sending request to server...');
      var response = await request.send();
      print('📥 Response status: ${response.statusCode}');
      
      var responseBody = await response.stream.bytesToString();
      print('📄 Response body: $responseBody');
      
      if (response.statusCode == 200) {
        final result = json.decode(responseBody);
        print('✅ Prediction successful: ${result['predicted_class']}');
        return result;
      } else {
        print('❌ Server error: ${response.statusCode}');
        print('❌ Error body: $responseBody');
        throw Exception('Server error: ${response.statusCode} - $responseBody');
      }
    } catch (e) {
      print('💥 Prediction failed: $e');
      throw Exception('$e');
    }
  }
}