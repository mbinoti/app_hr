import 'package:flutter/widgets.dart';

import 'app/hr_app.dart';
import 'firebase/firebase_bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final firebaseStatus = await FirebaseBootstrap.tryInitialize();
  runApp(MainApp(firebaseStatus: firebaseStatus));
}
