import 'dart:io';
import 'package:login_sahabat_mahasiswa/settings/setting.dart';
import 'package:login_sahabat_mahasiswa/view/widget/bottom.navigationbar.dart';
<<<<<<< Updated upstream
import 'package:flutter/material.dart';

=======
import 'package:intl/intl.dart';
>>>>>>> Stashed changes

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
<<<<<<< Updated upstream
=======
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

  int todayTaskCount = 0;
  int weeklyTaskCount = 0;

  @override
  void initState() {
    super.initState();
    getUserDataFromFirestore();
    fetchTaskData();
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
            name = capitalizeName("${snapshot.data()!['firstName']} ${snapshot.data()!['lastName']}");
<<<<<<< Updated upstream
            profileImageUrl = snapshot.data()!['profileImageUrl']; 
=======
            profileImageUrl = snapshot.data()!['profileImageUrl'];
>>>>>>> Stashed changes
          });
        }
      }
    } catch (e) {
      print("Error getting user data: $e");
    }
  }
>>>>>>> Stashed changes

  Future<void> fetchTaskData() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DateTime now = DateTime.now();
        String today = DateFormat('yyyy-MM-dd').format(now);
        String startOfWeek = DateFormat('yyyy-MM-dd').format(now.subtract(Duration(days: now.weekday - 1)));
        String endOfWeek = DateFormat('yyyy-MM-dd').format(now.add(Duration(days: DateTime.daysPerWeek - now.weekday)));

        // Fetch today's tasks
        final todayTasksQuery = await _db
            .collection('tasks')
            .where('userId', isEqualTo: user.uid)
            .where('deadline', isEqualTo: today)
            .get();

        setState(() {
          todayTaskCount = todayTasksQuery.docs.length;
        });

        // Fetch this week's tasks
        final weeklyTasksQuery = await _db
            .collection('tasks')
            .where('userId', isEqualTo: user.uid)
            .where('deadline', isGreaterThanOrEqualTo: startOfWeek)
            .where('deadline', isLessThanOrEqualTo: endOfWeek)
            .get();

        setState(() {
          weeklyTaskCount = weeklyTasksQuery.docs.length;
        });
      }
    } catch (e) {
      print("Error fetching task data: $e");
    }
  }

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
<<<<<<< Updated upstream
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
=======
              const SizedBox(height: 20),
              GestureDetector(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: const Color.fromARGB(255, 71, 76, 80),
                      backgroundImage: profileImageUrl.isNotEmpty 
                        ? NetworkImage(profileImageUrl) 
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Today\'s Deadlines',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
                          ),
                          Text(
                            '$todayTaskCount',
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
                      width: MediaQuery.of(context).size.width / 2 - 10,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Weekly Deadlines',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '$weeklyTaskCount',
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
                      Container(
                        height: 150,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
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
>>>>>>> Stashed changes
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
