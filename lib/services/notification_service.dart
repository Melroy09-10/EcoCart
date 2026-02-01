import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class NotificationService {
  static Future<void> savePlayerId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final deviceState = await OneSignal.User.pushSubscription;
    final playerId = deviceState.id;

    if (playerId != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
        'oneSignalId': playerId,
      }, SetOptions(merge: true));
    }
  }
}
