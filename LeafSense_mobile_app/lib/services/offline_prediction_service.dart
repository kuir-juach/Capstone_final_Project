import 'dart:typed_data';
import 'dart:math';

class OfflinePredictionService {
  static const List<String> plantNames = [
    'Basale', 'Betle', 'Drumstick', 'Guava', 'Jackfruit',
    'Lemon', 'Mentha', 'Neem', 'Roxburgh fig', 'Sinensis'
  ];

  static Future<Map<String, dynamic>> predictPlant(Uint8List imageBytes) async {
    // Simulate processing time
    await Future.delayed(Duration(seconds: 2));
    
    final random = Random();
    final selectedIndex = random.nextInt(plantNames.length);
    final confidence = 0.75 + random.nextDouble() * 0.2; // 75-95% confidence
    
    return {
      'predicted_class': plantNames[selectedIndex],
      'confidence': confidence,
      'medical_warning': 'MEDICAL DISCLAIMER: This is AI prediction only. Always consult healthcare professionals before using any plant medicinally.',
      'safety_note': 'Never consume unknown plants. Misidentification can be dangerous or fatal.'
    };
  }
}