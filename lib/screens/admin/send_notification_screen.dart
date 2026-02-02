import 'package:flutter/material.dart';
import '../../services/admin_notification_service.dart';

class SendNotificationScreen extends StatefulWidget {
  const SendNotificationScreen({super.key});

  @override
  State<SendNotificationScreen> createState() =>
      _SendNotificationScreenState();
}

class _SendNotificationScreenState
    extends State<SendNotificationScreen> {
  final _formKey = GlobalKey<FormState>();

  final titleController = TextEditingController();
  final messageController = TextEditingController();

  String type = 'Offer';
  bool loading = false;

  String _emojiByType(String type) {
    switch (type) {
      case 'Offer':
        return '🛍️';
      case 'Announcement':
        return '📢';
      case 'Maintenance':
        return '🛠️';
      default:
        return '';
    }
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      await AdminNotificationService.sendToAll(
        title: '${_emojiByType(type)} ${titleController.text.trim()}',
        message: messageController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification sent successfully ✅'),
          ),
        );
        titleController.clear();
        messageController.clear();
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to send notification ❌'),
        ),
      );
    }

    if (mounted) setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Notification'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const Icon(
                        Icons.notifications_active,
                        size: 48,
                        color: Colors.green,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Send notification to all users',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // TYPE
                      DropdownButtonFormField<String>(
                        value: type,
                        decoration: const InputDecoration(
                          labelText: 'Notification Type',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Offer',
                            child: Text('New Offer 🛍️'),
                          ),
                          DropdownMenuItem(
                            value: 'Announcement',
                            child: Text('Announcement 📢'),
                          ),
                          DropdownMenuItem(
                            value: 'Maintenance',
                            child: Text('Maintenance 🛠️'),
                          ),
                        ],
                        onChanged: (v) =>
                            setState(() => type = v!),
                      ),

                      const SizedBox(height: 16),

                      // TITLE
                      TextFormField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: 'Title',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) =>
                            v == null || v.isEmpty
                                ? 'Title is required'
                                : null,
                      ),

                      const SizedBox(height: 16),

                      // MESSAGE
                      TextFormField(
                        controller: messageController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: 'Message',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) =>
                            v == null || v.isEmpty
                                ? 'Message is required'
                                : null,
                      ),

                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: loading ? null : _send,
                          child: loading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  'Send Notification',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
