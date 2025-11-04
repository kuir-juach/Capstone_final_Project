import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _commentController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  String _selectedType = 'General';

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    if (_commentController.text.trim().isEmpty) return;

    try {
      await _firestore.collection('feedback').add({
        'userId': _auth.currentUser?.uid ?? 'anonymous',
        'userEmail': _auth.currentUser?.email ?? 'anonymous',
        'type': _selectedType,
        'comment': _commentController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      });

      _commentController.clear();
      setState(() {
        _selectedType = 'General';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Your feedback is sent successfully! Thanks for using LeafSense',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Feedback'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  _firestore
                      .collection('feedback')
                      .orderBy('timestamp', descending: true)
                      .limit(50)
                      .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final feedbacks = snapshot.data!.docs;
                if (feedbacks.isEmpty) {
                  return const Center(child: Text('No feedback yet'));
                }

                return ListView.builder(
                  itemCount: feedbacks.length,
                  itemBuilder: (context, index) {
                    final feedback =
                        feedbacks[index].data() as Map<String, dynamic>;
                    final timestamp = feedback['timestamp'] as Timestamp?;

                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        title: Text(feedback['comment'] ?? ''),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Type: ${feedback['type'] ?? 'General'}'),
                            Text('By: ${feedback['userEmail'] ?? 'Anonymous'}'),
                            if (timestamp != null)
                              Text(timestamp.toDate().toString().split('.')[0]),
                          ],
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border(top: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Feedback Type',
                    border: OutlineInputBorder(),
                  ),
                  items:
                      ['General', 'Model Accuracy', 'Bug Report', 'Suggestion']
                          .map(
                            (type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ),
                          )
                          .toList(),
                  onChanged: (value) => setState(() => _selectedType = value!),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        decoration: const InputDecoration(
                          hintText: 'Share your feedback...',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _submitFeedback,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(0, 101, 46, 1.0),
                      ),
                      child: const Text(
                        'Send',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
