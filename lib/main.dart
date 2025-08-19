import 'package:flutter/material.dart';
import 'pages/demoppx.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app.dart';  // o donde tengas tu widget principal

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp()); // 👈 usa la clase que SÍ exista
}
