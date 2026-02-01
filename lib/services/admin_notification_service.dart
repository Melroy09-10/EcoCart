import 'dart:convert';
import 'package:http/http.dart' as http;

class AdminNotificationService {
  static Future<void> sendNotification({
    required String title,
    required String message,
  }) async {
    const String oneSignalAppId = 'YOUR_ONESIGNAL_APP_ID';
    const String restApiKey = 'YOUR_REST_API_KEY';

    await http.post(
      Uri.parse('https://onesignal.com/api/v1/notifications'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Basic $restApiKey',
      },
      body: jsonEncode({
        'app_id': oneSignalAppId,
        'included_segments': ['All'],
        'headings': {'en': title},
        'contents': {'en': message},
      }),
    );
  }
}
