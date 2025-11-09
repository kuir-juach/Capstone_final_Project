import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart' as http_parser;

class ApiService {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8000';
    } else {
      return 'http://10.0.2.2:8000';
    }
  }

  // Send Feedback
  static Future<Map<String, dynamic>> sendFeedback({
    required String userId,
    required String message,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/feedback/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': userId,
          'message': message,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to send feedback: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Send Prediction Request
  static Future<Map<String, dynamic>> predictPlant({
    required Uint8List imageBytes,
    required String userId,
  }) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/predict'));
      
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        imageBytes,
        filename: 'plant.jpg',
        contentType: http_parser.MediaType('image', 'jpeg'),
      ));

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return json.decode(responseBody);
      } else {
        throw Exception('Prediction failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Book Appointment
  static Future<Map<String, dynamic>> bookAppointment({
    required String userId,
    required String name,
    required String email,
    required String date,
    required String time,
    required String doctor,
    required String reason,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/appointments/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': userId,
          'name': name,
          'email': email,
          'date': date,
          'time': time,
          'doctor': doctor,
          'reason': reason,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to book appointment: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get User's Appointments
  static Future<List<dynamic>> getUserAppointments(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/appointments/user/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to fetch appointments: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Cancel Appointment
  static Future<Map<String, dynamic>> cancelAppointment(int appointmentId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/cancel_appointment/$appointmentId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to cancel appointment: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Delete Appointment
  static Future<Map<String, dynamic>> deleteAppointment(int appointmentId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/appointments/$appointmentId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to delete appointment: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get All Feedbacks
  static Future<List<dynamic>> getFeedbacks() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/feedback/'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to fetch feedbacks: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}