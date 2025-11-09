import 'package:flutter/material.dart';

class PlantInfoScreen extends StatelessWidget {
  final Map<String, dynamic> plantInfo;
  final bool isArabic;

  const PlantInfoScreen({
    super.key,
    required this.plantInfo,
    this.isArabic = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(plantInfo['name'] ?? (isArabic ? 'معلومات النبات' : 'Plant Information')),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plantInfo['name'] ?? 'Plant Information',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(0, 101, 46, 1.0),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (plantInfo['scientific_name'] != null)
                      Text(
                        plantInfo['scientific_name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            if (plantInfo['medicinal_values'] != null) ...[
              _buildSection(
                title: isArabic ? 'القيم الطبية' : 'Medicinal Values',
                content: plantInfo['medicinal_values'],
                icon: Icons.healing,
              ),
              const SizedBox(height: 16),
            ],
            
            if (plantInfo['preparations'] != null) ...[
              _buildSection(
                title: isArabic ? 'طرق التحضير' : 'Preparations',
                content: plantInfo['preparations'],
                icon: Icons.science,
              ),
              const SizedBox(height: 16),
            ],
            
            if (plantInfo['dosage_guidance'] != null) ...[
              _buildSection(
                title: isArabic ? 'إرشادات الجرعة' : 'Dosage Guidance',
                content: plantInfo['dosage_guidance'],
                icon: Icons.medication,
                isWarning: true,
              ),
              const SizedBox(height: 16),
            ],
            
            Card(
              color: Colors.orange[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.orange),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isArabic 
                          ? 'تحذير: استشر طبيباً مختصاً قبل استخدام أي نبات طبي'
                          : 'Warning: Consult a healthcare professional before using any medicinal plant',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String content,
    required IconData icon,
    bool isWarning = false,
  }) {
    return Card(
      color: isWarning ? Colors.red[50] : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: isWarning ? Colors.red : const Color.fromRGBO(0, 101, 46, 1.0),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isWarning ? Colors.red : const Color.fromRGBO(0, 101, 46, 1.0),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}