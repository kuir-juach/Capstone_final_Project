import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MeetLauncher {
  static Future<void> showJoinOptions(BuildContext context, String meetLink) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Join Google Meet'),
        content: const Text('How would you like to join the meeting?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _joinWithMeetApp(context, meetLink);
            },
            child: const Text('Join with Meet App'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _openInBrowser(context, meetLink);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
            ),
            child: const Text('Open in Browser'),
          ),
        ],
      ),
    );
  }

  static Future<void> _joinWithMeetApp(BuildContext context, String meetLink) async {
    final Uri url = Uri.parse(meetLink);
    try {
      if (await launchUrl(url, mode: LaunchMode.externalApplication)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Opening in Google Meet app..."),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Opening in your browser...")),
        );
        await launchUrl(url, mode: LaunchMode.inAppBrowserView);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Could not launch meeting link."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  static Future<void> _openInBrowser(BuildContext context, String meetLink) async {
    final Uri url = Uri.parse(meetLink);
    try {
      if (await launchUrl(url, mode: LaunchMode.inAppBrowserView)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Opening in browser..."),
            backgroundColor: Colors.blue,
          ),
        );
      } else {
        throw Exception('Could not launch URL');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Could not open in browser."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}