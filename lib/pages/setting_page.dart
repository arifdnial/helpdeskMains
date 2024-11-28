import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:helpdeskmains/main.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'login_page.dart';

class SettingsPage extends StatefulWidget {
  final ValueChanged<String?> onProfileImageChanged;

  const SettingsPage({Key? key, required this.onProfileImageChanged}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isDark = false;
  String? _profileImageUrl;
  final ImagePicker _picker = ImagePicker();
  final _storage = FirebaseStorage.instance;
  final _auth = FirebaseAuth.instance;
  String? _userEmail;

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
    _loadProfileImage();
  }

  Future<void> _loadUserDetails() async {
    final user = _auth.currentUser;
    if (user != null) {
      setState(() {
        _userEmail = user.email ?? "No email provided";
      });
    }
  }
  Future<void> _loadProfileImage() async {
    final user = _auth.currentUser;
    if (user != null) {
      final ref = _storage.ref().child('users/${_auth.currentUser?.uid}/profile.jpg');
      try {
        final url = await ref.getDownloadURL();
        setState(() {
          _profileImageUrl = url;
        });
        widget.onProfileImageChanged(url);
      } catch (e) {
        print('Error loading profile image: $e');
      }
    }
  }

  Future<void> _uploadProfileImage(File imageFile) async {
    final userId = _auth.currentUser?.uid;
    final ref = _storage.ref().child('users/$userId/profile.jpg');
    try {
      await ref.putFile(imageFile);
      final url = await ref.getDownloadURL();
      print('Image uploaded successfully. URL: $url');

      setState(() {
        _profileImageUrl = url;
      });

      widget.onProfileImageChanged(url);

      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'profileImageUrl': url,
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error uploading profile image: $e');
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      await _uploadProfileImage(file); // Upload the picked image
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Theme(
      data: _isDark ? ThemeData.dark() : ThemeData.light(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Settings"),
        ),
        body: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: ListView(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.deepPurple, Colors.deepPurpleAccent],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.white,
                          backgroundImage: _profileImageUrl != null
                              ? NetworkImage(_profileImageUrl!)
                              : const AssetImage('assets/profile_pic.png') as ImageProvider,
                          child: const Stack(
                            children: [
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: CircleAvatar(
                                  radius: 18,
                                  backgroundColor: Colors.white,
                                  child: Icon(Icons.camera_alt, size: 20, color: Colors.black54),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _userEmail ?? 'Loading...',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        "Work hard in silence. Let your success be the noise.",
                        style: TextStyle(fontSize: 14, color: Colors.white70),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildSettingsSection("General", [
                  _buildCustomListTile(
                    "Dark Mode",
                    Icons.dark_mode_outlined,
                    trailing: Switch(
                      value: themeProvider.isDark,
                      onChanged: (value) {
                        themeProvider.toggleTheme(value);
                      },
                    ),
                  ),
                  _buildCustomListTile("Notifications", Icons.notifications_none_rounded),
                  _buildCustomListTile("Security Status", Icons.lock_outline),
                ]),
                const SizedBox(height: 20),
                _buildSettingsSection("Organization", [
                  _buildCustomListTile("Profile", Icons.person_outline_rounded),
                  _buildCustomListTile("Messaging", Icons.message_outlined),
                  _buildCustomListTile("Calling", Icons.phone_outlined),
                  _buildCustomListTile("People", Icons.contacts_outlined),
                  _buildCustomListTile("Calendar", Icons.calendar_today_rounded),
                ]),
                const SizedBox(height: 20),
                _buildSettingsSection("Support", [
                  _buildCustomListTile("Help & Feedback", Icons.help_outline_rounded),
                  _buildCustomListTile("About", Icons.info_outline_rounded),
                  _buildCustomListTile("Sign out", Icons.exit_to_app_rounded, onTap: () {
                    _handleSignOut(context);
                  }),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleSignOut(BuildContext context) async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage(onTap: () {})),
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> children) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepPurple),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildCustomListTile(String title, IconData icon, {Widget? trailing, VoidCallback? onTap}) {
    return ListTile(
      title: Text(title, style: TextStyle(color: Colors.grey[700])),
      leading: Icon(icon, color: Colors.grey[600]),
      trailing: trailing,
      onTap: onTap,
    );
  }
}
