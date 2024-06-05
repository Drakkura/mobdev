import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:login_sahabat_mahasiswa/settings/setting.dart';
import 'package:login_sahabat_mahasiswa/utils/colors.dart';
import 'package:login_sahabat_mahasiswa/view/calendar.dart';
import 'package:login_sahabat_mahasiswa/view/dashboard.dart';
import 'package:login_sahabat_mahasiswa/view/edit_profile_page.dart';
import 'package:login_sahabat_mahasiswa/view/widget/bottom.navigationbar.dart';

void main() {
  runApp(ProfileApp());
}

class ProfileApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Profile App',
      home: ProfilePage(),
    );
  }
}

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late String name = "";
  late String username = "";
  String profileImageUrl = "assets/images/logoaja.png";
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final Map<String, int> weeklyTaskCompletion = {
    'Senin': 2,
    'Selasa': 4,
    'Rabu': 3,
    'Kamis': 5,
    'Jumat': 1,
    'Sabtu': 6,
    'Minggu': 3,
  };

  @override
  void initState() {
    super.initState();
    getUserDataFromFirestore();
  }

  String capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  String capitalizeName(String fullName) {
    return fullName.split(' ').map((word) => capitalize(word)).join(' ');
  }

  Future<void> getUserDataFromFirestore() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        final snapshot = await _db.collection("users").doc(user.uid).get();

        if (snapshot.exists) {
          setState(() {
            username = capitalize(snapshot.data()!['username']);
            //name = capitalize(snapshot.data()!['name']);
            name = capitalizeName("${snapshot.data()!['firstName']} ${snapshot.data()!['lastName']}");
            profileImageUrl = snapshot.data()!['profileImageUrl']; // Ensure the profile image URL is fetched
          });
        }
      }
    } catch (e) {
      print("Error getting user data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CustomBottomNavigationBar(),
      appBar: AppBar(
        backgroundColor: GlobalColors.mainColor,
        automaticallyImplyLeading: false,
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              color: Colors.white,
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => Setting(),
                    transitionDuration: Duration.zero,
                  ),
                );
              },
            ),
          )
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: <Widget>[
              const SizedBox(height: 25,),
              Text(
                username,
                style: const TextStyle(fontSize: 20),
              ),
              Container(
                padding: const EdgeInsets.all(1),
                width: 100,
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: const Color.fromARGB(255, 71, 76, 80),
                      backgroundImage: profileImageUrl.isNotEmpty 
                        ? NetworkImage(profileImageUrl) // Use NetworkImage for URL
                        : AssetImage('assets/images/logoaja.png') as ImageProvider,
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
                        child: GestureDetector(
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditProfilePage(
                                  firstName: name.split(' ')[0],
                                  lastName: name.split(' ').sublist(1).join(' '),
                                  username: username,
                                  profileImageUrl: profileImageUrl,
                                ),
                              ),
                            );

                            if (result != null && result is Map<String, String>) {
                              setState(() {
                                name = "${result['firstName']} ${result['lastName']}";
                                username = result['username']!;
                                profileImageUrl = result['profileImageUrl']!;
                              });
                            }
                          },
                          child: const Icon(Icons.edit),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 20),
                padding: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 0, 0, 0),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 5,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => const Dashboard(),
                          transitionDuration: Duration.zero,
                        )
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 20),
                      padding: const EdgeInsets.all(20),
                      width: MediaQuery.of(context).size.width / 2 - 10,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Deadline Tugas!',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
                          ),
                          Text(
                            ' 2',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => const CalendarScreen(),
                          transitionDuration: Duration.zero,
                        )
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 20),
                      padding: const EdgeInsets.all(20),
                      width: MediaQuery.of(context).size.width / 2 - 50,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Meeting: 8',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Task: 3',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5,),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Weekly Task Completion',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      // Bar for each day
                      Container(
                        height: 150,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            // Y-axis
                            Container(
                              padding: const EdgeInsets.only(right: 10),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  for (int i = 10; i >= 0; i -= 2)
                                    Container(
                                      height: 15,
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        '$i',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            // Bar Graph
                            ...weeklyTaskCompletion.keys.map((day) {
                              return Flexible(
                                child: Column(
                                  children: [
                                    SizedBox(height: 5),
                                    Expanded(
                                      child: FractionallySizedBox(
                                        heightFactor: weeklyTaskCompletion[day]! / 10,
                                        child: Container(
                                          width: 20,
                                          color: Colors.blue,
                                          alignment: Alignment.bottomCenter,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      day,
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
