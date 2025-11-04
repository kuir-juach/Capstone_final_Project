import 'package:cloud_firestore/cloud_firestore.dart';

class ExpertsService {
  static final _firestore = FirebaseFirestore.instance;

  static Future<void> addExperts() async {
    final experts = [
      {
        'name': 'Dr. Achol Dut Amol',
        'specialty': 'Medicinal Plants Expert',
        'email': 'achol.amol@leafsense.com',
      },
      {
        'name': 'Dr. Rebecca Agot Makuach',
        'specialty': 'Plant Biology Specialist',
        'email': 'rebecca.makuach@leafsense.com',
      },
      {
        'name': 'Dr. Ayuel Bol',
        'specialty': 'Herbal Medicine Consultant',
        'email': 'ayuel.bol@leafsense.com',
      },
      {
        'name': 'Dr. Akech Awan Adit',
        'specialty': 'Plant Pathology Expert',
        'email': 'akech.adit@leafsense.com',
      },
      {
        'name': 'Dr. Dhieu Thuch',
        'specialty': 'Ethnobotany Specialist',
        'email': 'dhieu.thuch@leafsense.com',
      },
      {
        'name': 'Dr. Okot Paul Philip',
        'specialty': 'Traditional Medicine Expert',
        'email': 'okot.philip@leafsense.com',
      },
    ];

    for (final expert in experts) {
      final existingExpert = await _firestore
          .collection('experts')
          .where('name', isEqualTo: expert['name'])
          .get();
      
      if (existingExpert.docs.isEmpty) {
        await _firestore.collection('experts').add(expert);
      }
    }
  }
}