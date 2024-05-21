import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:login_sahabat_mahasiswa/utils/colors.dart';

class EditProfilePage extends StatefulWidget {
  final String name;
  final String username;
  final String profileImageUrl;

  EditProfilePage({
    required this.name,
    required this.username,
    required this.profileImageUrl,
  });

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final ImagePicker _picker = ImagePicker();
  late TextEditingController nameController;
  late TextEditingController usernameController;
  TextEditingController passwordController = TextEditingController();
  String profileImageUrl = "";
  String newPassword = "";

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.name);
    usernameController = TextEditingController(text: widget.username);
    profileImageUrl = widget.profileImageUrl;
  }

  Future<void> _uploadImageToFirebase(String userId, String filePath) async {
    File file = File(filePath);

    try {
      // Upload file to Firebase Storage
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child("profile_images")
          .child(userId)
          .child("profilepic.jpg"); // Change "profilepic.jpg" to appropriate file name
      await ref.putFile(file);

      // Get the uploaded image URL
      String imageUrl = await ref.getDownloadURL();

      // Update profileImageUrl with the uploaded image URL
      setState(() {
        profileImageUrl = imageUrl;
      });
    } catch (e) {
      print('Error uploading image to Firebase Storage: $e');
    }
  }

  Future<void> _getImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      await _uploadImageToFirebase(FirebaseAuth.instance.currentUser!.uid, pickedFile.path);
    }
  }

  Future<void> _getImageFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      await _uploadImageToFirebase(FirebaseAuth.instance.currentUser!.uid, pickedFile.path);
    }
  }

  Future<void> _selectImage() async {
    await _showImageSourceDialog();
  }

  Future<void> _showImageSourceDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Pilih Sumber Gambar"),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    _getImageFromGallery();
                  },
                  child: Text("Galeri"),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    _getImageFromCamera();
                  },
                  child: Text("Kamera"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _updateUserProfile(String userId, Map<String, dynamic> updatedData) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update(updatedData);
    } catch (e) {
      print('Error updating user profile: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onTap: _selectImage,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: const Color.fromARGB(255, 71, 76, 80),
                    backgroundImage: profileImageUrl.isNotEmpty ? NetworkImage(profileImageUrl) : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      padding: const EdgeInsets.all(4),
                      child: const Icon(Icons.edit),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'New Password'),
              obscureText: true,
              onChanged: (value) {
                newPassword = value;
              },
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  // Save changes to Firestore
                  Map<String, String> updatedData = {
                    'name': nameController.text,
                    'username': usernameController.text,
                    'profileImageUrl': profileImageUrl,
                  };

                  if (user != null) {
                    await _updateUserProfile(user.uid, updatedData);
                  }

                  // Return to ProfilePage with updated data
                  Navigator.pop(context, updatedData);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: GlobalColors.secondColor,
                ),
                child: Text(
                  'Save',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
