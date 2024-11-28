import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:helpdeskmains/pages/auth_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:helpdeskmains/pages/homepage.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } else {
    await Firebase.initializeApp();
  }
  // Request permissions for notifications

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      theme: themeProvider.isDark ? ThemeData.dark() : ThemeData.light(),
      home: const AuthPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ThemeProvider extends ChangeNotifier {
  bool _isDark = false;
  bool get isDark => _isDark;
  void toggleTheme(bool isOn) {
    _isDark = isOn;
    notifyListeners();
  }
}
