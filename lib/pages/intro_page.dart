import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_page.dart';

class IntroPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      pages: [
        PageViewModel(
          title: "Welcome",
          body: "This is the first introduction screen.",
          image: Center(child: Icon(Icons.ac_unit, size: 175.0)),
        ),
        PageViewModel(
          title: "Explore",
          body: "Discover the features of our app.",
          image: Center(child: Icon(Icons.accessibility, size: 175.0)),
        ),
        PageViewModel(
          title: "Get Started",
          body: "Let's get started!",
          image: Center(child: Icon(Icons.battery_alert, size: 175.0)),
        ),
      ],
      onDone: () async {
        // Set introSeen to true in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('introSeen', true);

        // Navigate to AuthPage
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => AuthPage()),
        );
      },
      onSkip: () async {
        // Set introSeen to true in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('introSeen', true);

        // Navigate to AuthPage
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => AuthPage()),
        );
      },
      showSkipButton: true,
      skip: const Icon(Icons.skip_next),
      next: const Icon(Icons.arrow_forward),
      done: const Text("Done", style: TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}
