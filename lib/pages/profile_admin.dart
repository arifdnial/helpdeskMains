import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}
class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Text controllers for the input fields
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  bool isLoading = false;
  File? _pickedImage;
  String? _uploadedImageUrl; // To store the URL of the uploaded image
  @override
  void initState() {
    super.initState();
    _loadAdminData(); // Load existing admin data when the screen initializes
  }
  // Fetch admin data from Firestore
  Future<void> _loadAdminData() async {
    setState(() {
      isLoading = true;
    });
    try {
      // Get the current user's email from FirebaseAuth
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        // Print current user's email for debugging
        print('Current user email: ${currentUser.email}');
        // Assign current admin's email to emailController
        emailController.text = currentUser.email ?? '';
        // Retrieve the document from Firestore
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('admins')
            .doc(currentUser.email)
            .get();
        if (doc.exists) {
          var data = doc.data() as Map<String, dynamic>;
          // Populate the text controllers with the existing data
          nameController.text = data['name'] ?? '';
          phoneController.text = data['phone'] ?? '';
          addressController.text = data['address'] ?? '';
          _uploadedImageUrl = data['imageUrl'] ?? ''; // Load the saved image URL
        }
      } else {
        print('No current user logged in.');
      }
    } catch (e) {
      print('Error loading admin data: $e');
    }
    setState(() {
      isLoading = false;
    });
  }
  // Pick an image from the gallery or camera
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
    }
  }
  // Upload the picked image to Firebase Storage and get the download URL
  Future<void> _uploadImage(String email) async {
    if (_pickedImage != null) {
      try {
        final ref = FirebaseStorage.instance
            .ref()
            .child('profile_images')
            .child('$email.jpg');
        await ref.putFile(_pickedImage!);
        _uploadedImageUrl = await ref.getDownloadURL();
      } catch (e) {
        print('Error uploading image: $e');
      }
    }
  }
  // Save or update admin profile data to Firestore
  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      try {
        final currentUser = FirebaseAuth.instance.currentUser;

        if (currentUser != null) {
          // Upload image if any
          await _uploadImage(currentUser.email!);
          // Save the admin data to Firestore
          await FirebaseFirestore.instance
              .collection('admins')
              .doc(currentUser.email)
              .set({
            'name': nameController.text,
            'phone': phoneController.text,
            'address': addressController.text,
            'email': emailController.text,
            'imageUrl': _uploadedImageUrl, // Save image URL
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Profile updated successfully!')),
          );
        }
      } catch (e) {
        print('Error saving admin data: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile.')),
        );
      }
      setState(() {
        isLoading = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Admin'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage, // Pick image when tapped
                child: CircleAvatar(
                  radius: 70,
                  backgroundImage: _pickedImage != null
                      ? FileImage(_pickedImage!) // Display picked image
                      : (_uploadedImageUrl != null && _uploadedImageUrl!.isNotEmpty)
                      ? NetworkImage(_uploadedImageUrl!) // Display uploaded image
                      : AssetImage('assets/images/user.JPG') as ImageProvider,
                ),
              ),
              const SizedBox(height: 20),
              _buildTextField(
                  controller: nameController,
                  label: 'Name',
                  icon: CupertinoIcons.person),
              const SizedBox(height: 10),
              _buildTextField(
                  controller: phoneController,
                  label: 'Phone',
                  icon: CupertinoIcons.phone),
              const SizedBox(height: 10),
              _buildTextField(
                  controller: addressController,
                  label: 'Address',
                  icon: CupertinoIcons.location),
              const SizedBox(height: 10),
              _buildTextField(
                controller: emailController,
                label: 'Email',
                icon: CupertinoIcons.mail,
                readOnly: true, // Set email field to read-only
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(15),
                  ),
                  child: const Text('Save Profile'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  // Helper method to create text input fields
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      readOnly: readOnly,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your $label';
        }
        return null;
      },
    );
  }
}
