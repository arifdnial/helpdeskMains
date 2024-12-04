import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/colors/gf_color.dart';
import 'package:getwidget/components/toast/gf_toast.dart';
import 'package:getwidget/position/gf_toast_position.dart';
import 'package:helpdeskmains/components/my_button.dart';
import 'package:helpdeskmains/components/my_textfield.dart';
import 'package:helpdeskmains/pages/admin_panel.dart';
import 'package:helpdeskmains/pages/adminregisterpage.dart';
import 'package:helpdeskmains/pages/forgotpassword.dart';
import 'package:helpdeskmains/pages/homepage.dart';
import 'package:helpdeskmains/pages/register_page.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;
  LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void signUserIn() async {
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    if (emailController.text == 'ariff@gmail.com' && passwordController.text == 'ariff123') {
      // Navigate to AdminPanel for Ariff
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AdminPanel(adminName: 'Shahera')),
      );
      return;
    } else if (emailController.text == 'hidayah@gmail.com' && passwordController.text == 'hidayah123') {
      // Navigate to AdminPanel for Hidayah
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AdminPanel(adminName: 'Hidayah')),
      );
      return;
    } else if (emailController.text == 'suriaty@gmail.com' && passwordController.text == 'suriaty123') {
      // Navigate to AdminPanel for Suriaty
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AdminPanel(adminName: 'Suriaty')),
      );
      return;
    } else if (emailController.text == 'erma@gmail.com' && passwordController.text == 'erma123') {
      // Navigate to AdminPanel for Erma & Fikri
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AdminPanel(adminName: 'Erma ')),
      );
      return;
    } else if (emailController.text == 'izzati@gmail.com' && passwordController.text == 'izzati123') {
      // Navigate to AdminPanel for Erma & Fikri
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AdminPanel(adminName: 'Izzati')),
      );
      return;
    }

    try {
      // Log the user in
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      // Check if user is an admin
      final userDoc = await FirebaseFirestore.instance
          .collection('admins')
          .doc(userCredential.user!.uid)
          .get();
      Navigator.pop(context);
      if (userDoc.exists) {
        // Admin user found, check approval status
        if (userDoc['approved'] == true) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AdminPanel(adminName: userDoc['name'])),
          );
        } else {
          // Show toast notification using GetWidget
          GFToast.showToast(
            'Admin approval is pending. Please wait for approval.',
            context,
            toastPosition: GFToastPosition.BOTTOM,
            textStyle: TextStyle(fontSize: 16, color: GFColors.DARK),
            backgroundColor: GFColors.LIGHT,
            trailing: Icon(
              Icons.notifications,
              color: GFColors.SUCCESS,
            ),
          );

          FirebaseAuth.instance.signOut();
        }
      }
      else {
        // Normal user, allow immediate access to homepage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ResponsiveNavBarPage()),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      genericErrorMessage(e.toString());
    }
  }

  void genericErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 243, 243, 243),
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
                  width: 150,
                  height: 150,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 10),
                Text(
                  'Welcome back, you\'ve been missed',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 25),
                Container(
                  width: screenWidth * 0.9,
                  child: MyTextField(
                    controller: emailController,
                    hintText: 'Username or email',
                    obscureText: false,
                    borderColor: Colors.black,
                    textColor: Colors.black87,
                  ),
                ),
                const SizedBox(height: 15),
                Container(
                  width: screenWidth * 0.9,
                  child: MyTextField(
                    controller: passwordController,
                    hintText: 'Password',
                    obscureText: true,
                    borderColor: Colors.black,
                    textColor: Colors.black87,
                  ),
                ),
                const SizedBox(height: 15),
                MyButton(
                  onTap: signUserIn,
                  text: 'Sign In',
                ),
                const SizedBox(height: 15),
                // Admin Login Button
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdminRegisterPage(),
                      ),
                    );
                  },
                  icon: Icon(Icons.admin_panel_settings),
                  label: Text("Admin Register"),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue[900], // Button color
                    onPrimary: Colors.white, // Text color
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Forget your password? ',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ForgotPasswordPage()),
                          );
                        },
                        child: Text(
                          'Forget Password.',
                          style: TextStyle(
                            color: Colors.blue.shade900,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Not a member? ',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RegisterPage(
                              onTap: widget.onTap,
                            ),
                          ),
                        );
                      },
                      child: Text(
                        'Register now',
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