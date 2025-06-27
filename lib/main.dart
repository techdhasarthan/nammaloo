import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:nearby_toilet_finder/app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}
