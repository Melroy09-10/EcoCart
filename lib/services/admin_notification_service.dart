import 'dart:convert';
import 'package:http/http.dart' as http;

class AdminNotificationService {
  static const String _oneSignalAppId =
      '42e1a0b9-ab1d-4c80-8a7d-00c0d1cb9fec';

  static const String _restApiKey =
      'os_v2_app_ilq2bonldvgibct5adands475q66wxrcmb4ulwuke2zpws3ddkfwkwtus4wrc23yzk4uykgjv36ra57emypp6dxfe5kzxwdxgngd5yy';

  static Future<void> sendToAll({
    required String title,
    required String message,
  }) async {
    final response = await http.post(
      Uri.parse('https://onesignal.com/api/v1/notifications'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Basic $_restApiKey',
      },
      body: jsonEncode({
        'app_id': _oneSignalAppId,
        'included_segments': ['All'],
        'headings': {'en': title},
        'contents': {'en': message},
      }),
    );

    if (response.statusCode >= 400) {
      throw Exception('Notification failed');
    }
  }
}
