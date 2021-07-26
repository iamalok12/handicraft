import 'package:handicraft/auth/login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:handicraft/splashScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/alert_box.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  App.sharedPreferences = await SharedPreferences.getInstance();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
