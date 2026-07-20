import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class FirebaseBootstrap {
  const FirebaseBootstrap._();

  static Future<FirebaseApp> initialize() async {
    final app = await Firebase.initializeApp();

    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
    );

    return app;
  }

  static Future<FirebaseBootstrapStatus> tryInitialize() async {
    try {
      final app = await initialize();
      return FirebaseBootstrapStatus.ready(app.name);
    } on Object catch (error) {
      return FirebaseBootstrapStatus.notReady(error.toString());
    }
  }
}

class FirebaseBootstrapStatus {
  const FirebaseBootstrapStatus._({
    required this.isReady,
    required this.message,
  });

  factory FirebaseBootstrapStatus.ready(String appName) {
    return FirebaseBootstrapStatus._(
      isReady: true,
      message: 'App Firebase inicializado: $appName',
    );
  }

  factory FirebaseBootstrapStatus.notReady(String message) {
    return FirebaseBootstrapStatus._(isReady: false, message: message);
  }

  final bool isReady;
  final String message;
}
