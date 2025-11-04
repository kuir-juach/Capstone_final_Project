import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _topicController = TextEditingController();
  
  String? _selectedExpertId;
  String? _selectedExpertName;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: const Color.fromRGBO(0, 101, 46, 1.0),
            ),
          ),
          child: child!,
        );
      },
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: const Color.fromRGBO(0, 101, 46, 1.0),
            ),
          ),
          child: child!,
        );
      },
    );
    if (time != null) {
      setState(() => _selectedTime = time);
    }
  }

  Future<void> _bookSession() async {
    if (_selectedExpertId == null || _selectedDate == null || 
        _selectedTime == null || _topicController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields'), backgroundColor: Colors.red),
      );
      return;
    }

    try {
      final dateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      await _firestore.collection('bookings').add({
        'userId': _auth.currentUser?.uid,
        'userEmail': _auth.currentUser?.email,
        'expertId': _selectedExpertId,
        'expertName': _selectedExpertName,
        'date': Timestamp.fromDate(dateTime),
        'topic': _topicController.text.trim(),
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        _selectedExpertId = null;
        _selectedExpertName = null;
        _selectedDate = null;
        _selectedTime = null;
        _topicController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('✅ Session booked successfully!'),
            ],
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book One-on-One Session'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Select Expert', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Column(
              children: [
                Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color.fromRGBO(0, 101, 46, 1.0),
                      child: Text('D', style: TextStyle(color: Colors.white)),
                    ),
                    title: const Text('Dr. Achol Dut Amol'),
                    subtitle: const Text('Medicinal Plants Expert'),
                    trailing: Radio<String>(
                      value: 'achol_amol',
                      groupValue: _selectedExpertId,
                      onChanged: (value) {
                        setState(() {
                          _selectedExpertId = value;
                          _selectedExpertName = 'Dr. Achol Dut Amol';
                        });
                      },
                    ),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color.fromRGBO(0, 101, 46, 1.0),
                      child: Text('R', style: TextStyle(color: Colors.white)),
                    ),
                    title: const Text('Dr. Rebecca Agot Makuach'),
                    subtitle: const Text('Plant Biology Specialist'),
                    trailing: Radio<String>(
                      value: 'rebecca_makuach',
                      groupValue: _selectedExpertId,
                      onChanged: (value) {
                        setState(() {
                          _selectedExpertId = value;
                          _selectedExpertName = 'Dr. Rebecca Agot Makuach';
                        });
                      },
                    ),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color.fromRGBO(0, 101, 46, 1.0),
                      child: Text('A', style: TextStyle(color: Colors.white)),
                    ),
                    title: const Text('Dr. Ayuel Bol'),
                    subtitle: const Text('Herbal Medicine Consultant'),
                    trailing: Radio<String>(
                      value: 'ayuel_bol',
                      groupValue: _selectedExpertId,
                      onChanged: (value) {
                        setState(() {
                          _selectedExpertId = value;
                          _selectedExpertName = 'Dr. Ayuel Bol';
                        });
                      },
                    ),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color.fromRGBO(0, 101, 46, 1.0),
                      child: Text('A', style: TextStyle(color: Colors.white)),
                    ),
                    title: const Text('Dr. Akech Awan Adit'),
                    subtitle: const Text('Plant Pathology Expert'),
                    trailing: Radio<String>(
                      value: 'akech_adit',
                      groupValue: _selectedExpertId,
                      onChanged: (value) {
                        setState(() {
                          _selectedExpertId = value;
                          _selectedExpertName = 'Dr. Akech Awan Adit';
                        });
                      },
                    ),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color.fromRGBO(0, 101, 46, 1.0),
                      child: Text('D', style: TextStyle(color: Colors.white)),
                    ),
                    title: const Text('Dr. Dhieu Thuch'),
                    subtitle: const Text('Ethnobotany Specialist'),
                    trailing: Radio<String>(
                      value: 'dhieu_thuch',
                      groupValue: _selectedExpertId,
                      onChanged: (value) {
                        setState(() {
                          _selectedExpertId = value;
                          _selectedExpertName = 'Dr. Dhieu Thuch';
                        });
                      },
                    ),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color.fromRGBO(0, 101, 46, 1.0),
                      child: Text('O', style: TextStyle(color: Colors.white)),
                    ),
                    title: const Text('Dr. Okot Paul Philip'),
                    subtitle: const Text('Traditional Medicine Expert'),
                    trailing: Radio<String>(
                      value: 'okot_philip',
                      groupValue: _selectedExpertId,
                      onChanged: (value) {
                        setState(() {
                          _selectedExpertId = value;
                          _selectedExpertName = 'Dr. Okot Paul Philip';
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _selectDate,
                    icon: const Icon(Icons.calendar_today),
                    label: Text(_selectedDate == null 
                        ? 'Select Date' 
                        : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _selectTime,
                    icon: const Icon(Icons.access_time),
                    label: Text(_selectedTime == null 
                        ? 'Select Time' 
                        : _selectedTime!.format(context)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _topicController,
              decoration: const InputDecoration(
                labelText: 'Session Topic',
                hintText: 'What would you like to discuss?',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _bookSession,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(0, 101, 46, 1.0),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'Book Session',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}