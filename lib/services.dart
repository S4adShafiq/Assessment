import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'models.dart';

// -- Isar Provider --
final isarProvider = FutureProvider<Isar>((ref) async {
  final dir = await getApplicationDocumentsDirectory();
  return await Isar.open([UserDraft33720Schema], directory: dir.path);
});

// -- Dio Provider --
final dioProvider = Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      baseUrl: 'https://example.com/api/',
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 8),
    ),
  );
});

// -- Feature Flags Provider --
class FeatureFlags {
  final bool enableNativeBridges;
  FeatureFlags({this.enableNativeBridges = false});
}

final featureFlagsProvider = Provider<FeatureFlags>((ref) {
  // Reading from compilation env vars, or defaulting to true for demo
  return FeatureFlags(
    enableNativeBridges: const bool.fromEnvironment(
      'FF_NATIVE_BRIDGES',
      defaultValue: true,
    ),
  );
});

// -- Firebase Services --
final firebaseAuthProvider = Provider<FirebaseAuth>(
  (ref) => FirebaseAuth.instance,
);

// -- Native Bridge Service --
class NativeServices {
  NativeServices(
    this._picker,
    this._storage,
    this._firestore,
    this._notifications,
  );

  final ImagePicker _picker;
  final FirebaseStorage _storage;
  final FirebaseFirestore _firestore;
  final FlutterLocalNotificationsPlugin _notifications;

  Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _notifications.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );
  }

  Future<void> showLocalNotification(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'main_channel',
      'Main Channel',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );
    await _notifications.show(0, title, body, details);
  }

  Future<void> demoCameraUpload() async {
    final file = await _picker.pickImage(source: ImageSource.camera);
    if (file == null) return;

    // Simulate upload
    final filename = file.path.split('/').last;
    final ref = _storage.ref().child('avatars/$filename');
    await ref.putFile(File(file.path));
    final url = await ref.getDownloadURL();

    await _firestore.collection('avatars').add({
      'url': url,
      'timestamp': FieldValue.serverTimestamp(),
    });
    await showLocalNotification(
      'Upload successful',
      'Your avatar was uploaded!',
    );
  }
}

final nativeServiceProvider = Provider<NativeServices>((ref) {
  return NativeServices(
    ImagePicker(),
    FirebaseStorage.instance,
    FirebaseFirestore.instance,
    FlutterLocalNotificationsPlugin(),
  );
});
