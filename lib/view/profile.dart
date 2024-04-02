import 'dart:io';
import 'package:login_sahabat_mahasiswa/settings/setting.dart';
import 'package:login_sahabat_mahasiswa/view/widget/bottom.navigationbar.dart';
import 'package:flutter/material.dart';


void main() {
  runApp(ProfileApp());
}

class ProfileApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Profile App',
      initialRoute: '/',
      routes: {
        '/': (context) => ProfilePage(),
        '/edit': (context) => EditProfilePage(),
      },
    );
  }
}

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String name = "Yoga Ananta Elfaraby";
  String username = "Tobanga";
  String profileImageUrl = "assets/images/logoaja.png";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CustomBottomNavigationBar(),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Profile'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: <Widget>[SizedBox(height: 50),
              CircleAvatar(
                radius: 50,
                backgroundImage: FileImage(File(profileImageUrl)),
              ),
              SizedBox(height: 20),
              Text(
                'Name: $name',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 10),
              Text(
                'Username: $username',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  var result = await Navigator.pushNamed(context, '/edit', arguments: {
                    'name': name,
                    'username': username,
                    'profileImageUrl': profileImageUrl,
                  });
                  if (result != null && result is Map<String, String>) {
                    setState(() {
                      name = result['name']!;
                      username = result['username']!;
                      profileImageUrl = result['profileImageUrl']!;
                    });
                  }
                },
                child: Text('Edit Profile'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => Setting()),
                  );
                },
                child: Text('Settings'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String profileImageUrl = "assets/profile_image.png";
  String newPassword = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final Map<String, String>? args = ModalRoute.of(context)!.settings.arguments as Map<String, String>?;
      if (args != null) {
        nameController.text = args['name']!;
        usernameController.text = args['username']!;
        profileImageUrl = args['profileImageUrl']!;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage(profileImageUrl),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                //_selectImage();
              },
              child: Text('Change Profile Image'),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'New Password'),
              obscureText: true,
              onChanged: (value) {
                newPassword = value;
              },
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Simpan perubahan profil ke server atau lokal database
                  Navigator.pop(context, {
                    'name': nameController.text,
                    'username': usernameController.text,
                    'profileImageUrl': profileImageUrl,
                  });
                },
                child: Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
