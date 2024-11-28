import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:helpdeskmains/components/my_button.dart';
import 'package:helpdeskmains/components/my_textfield.dart';
import 'package:helpdeskmains/pages/homepage.dart';
import 'package:helpdeskmains/pages/login_page.dart';
import '../auth_service.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  void signUserUp() async {
    // Show loading circle
    showDialog(
        context: context,
        builder: (context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        });

    try {
      // Check if both password and confirm password match
      if (passwordController.text == confirmPasswordController.text) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );
      } else {
        // Show error if passwords don't match
        genericErrorMessage("Passwords don't match!");
      }

      // Pop the loading circle
      Navigator.pop(context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ResponsiveNavBarPage()),
      );
    } on FirebaseAuthException catch (e) {
      // Pop the loading circle
      Navigator.pop(context);

      genericErrorMessage(e.code);
    }
  }

  void genericErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Calculate screen width
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 243, 243, 243),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                Image.asset(
                  'assets/logomains.png',
                  width: 150, // Set desired width
                  height: 150, // Set desired height
                  fit: BoxFit.cover, // Adjust image scaling
                ), // Logo

                const SizedBox(height: 10),

                const SizedBox(height: 25),

                // Username or email text field
                Container(
                  width: screenWidth * 0.9, // 90% of screen width
                  child: MyTextField(
                    controller: emailController,
                    hintText: 'Username or email',
                    obscureText: false,
                  ),
                ),
                const SizedBox(height: 15),

                // Password text field
                Container(
                  width: screenWidth * 0.9, // 90% of screen width
                  child: MyTextField(
                    controller: passwordController,
                    hintText: 'Password',
                    obscureText: true,
                  ),
                ),
                const SizedBox(height: 15),

                // Confirm Password text field
                Container(
                  width: screenWidth * 0.9, // 90% of screen width
                  child: MyTextField(
                    controller: confirmPasswordController,
                    hintText: 'Confirm Password',
                    obscureText: true,
                  ),
                ),
                const SizedBox(height: 15),

                // Sign up button
                Container(
                  width: screenWidth * 0.9, // 90% of screen width
                  child: MyButton(
                    onTap: signUserUp,
                    text: 'Sign Up',
                  ),
                ),
                const SizedBox(height: 20),

                // Continue with
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.grey.shade400,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          'OR',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 60),

                const SizedBox(height: 100),

                // Already have an account? Login now
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginPage(
                              onTap: widget.onTap,
                            ),
                          ),
                        );
                      },
                      child: Text(
                        'Login now',
                        style: TextStyle(
                          color: Colors.blue[900],
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
