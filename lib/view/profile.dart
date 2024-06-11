import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login_sahabat_mahasiswa/settings/setting.dart';
import 'package:login_sahabat_mahasiswa/utils/colors.dart';
import 'package:login_sahabat_mahasiswa/view/edit_profile_page.dart';
import 'package:login_sahabat_mahasiswa/view/widget/bottom.navigationbar.dart';

class Task {
  String id;
  String name;
  DateTime date;
  TimeOfDay time;
  String category;

  Task(this.id, this.name, this.date, this.time, this.category);
}


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
  late final Function(int)? onCountUpdated;
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late String name = "";
  late String username = "";
  String profileImageUrl = "assets/images/logoaja.png";
  late int nearDeadlineTasksCount;
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Task> tasks = [];
  String sortMode = 'week';

  @override
  void initState() {
    super.initState();
    getUserDataFromFirestore();
  }

  List<Task> getTasksForWeek() {
  DateTime now = DateTime.now();
  DateTime endOfWeek = now.add(Duration(days: 7 - now.weekday));

  return tasks.where((task) =>
      task.date.isAfter(now) && task.date.isBefore(endOfWeek)).toList();
  }

  Future<void> _fetchTasks() async {
    var querySnapshot = await _firestore.collection('tasks').get();
    for (var doc in querySnapshot.docs) {
      var data = doc.data();
      tasks.add(Task(
        doc.id,
        data['name'],
        (data['date'] as Timestamp).toDate(),
        TimeOfDay(
            hour: int.parse(data['time'].split(':')[0]),
            minute: int.parse(data['time'].split(':')[1])),
        data['category'],
      ));
    }
    setState(() {
      int pendingTaskCount = filterTasksByDeadline(tasks).length;
      widget.onCountUpdated?.call(pendingTaskCount);
    });
  }

  Map<DateTime, List<Task>> groupTasksByDate(List<Task> tasks) {
    Map<DateTime, List<Task>> map = {};
    for (var task in tasks) {
      DateTime date = DateTime(task.date.year, task.date.month, task.date.day);
      if (!map.containsKey(date)) {
        map[date] = [];
      }
      map[date]!.add(task);
    }
    return map;
  }

  List<Task> filterTasksByDeadline(List<Task> tasks) {
    DateTime now = DateTime.now();
    DateTime endOfWeek = now.add(Duration(days: 7 - now.weekday));
    DateTime endOfMonth = DateTime(now.year, now.month + 1, 0);

    if (sortMode == 'week') {
      return tasks
          .where((task) =>
              task.date.isAfter(now) && task.date.isBefore(endOfWeek))
          .toList();
    } else if (sortMode == 'month') {
      return tasks
          .where((task) =>
              task.date.isAfter(now) && task.date.isBefore(endOfMonth))
          .toList();
    } else {
      return tasks.where((task) => task.date.isAfter(now)).toList();
    }
  }


  Future<int> getTaskCountForWeek() async {
    User? user = _auth.currentUser;
    if (user != null) {
      QuerySnapshot snapshot = await _db
          .collection('tasks')
          .where('date', isGreaterThanOrEqualTo: DateTime.now(), isLessThan: DateTime.now().add(Duration(days: 7)))
          .get();

      return snapshot.docs.length;
    } else {
      return 0;
    }
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
            profileImageUrl = snapshot.data()!['profileImageUrl'];
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
      //backgroundColor: Color.fromARGB(255, 58, 53, 53),
      bottomNavigationBar: CustomBottomNavigationBar(),
      appBar: AppBar(
        backgroundColor: GlobalColors.mainColor,
        elevation: 0,
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
      body: SingleChildScrollView(child: Container(
        color: Color.fromARGB(255, 255, 255, 255),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: <Widget>[
              const SizedBox(height: 25),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      width: 120,
                      height: 120,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 60, // Mengatur radius lingkaran gambar profil
                            backgroundColor: Colors.transparent,
                            backgroundImage: profileImageUrl.isNotEmpty
                                ? NetworkImage(profileImageUrl)
                                : AssetImage('assets/images/logoaja.png') as ImageProvider,
                          ),
                          Positioned(
                            bottom: 5,
                            right: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color.fromARGB(255, 242, 243, 241),
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
                  const SizedBox(width: 16,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),
                      Text(
                        name,
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(height: 0),
                      Text(
                        username,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey, // Warna lebih pudar
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      //Navigator.pushReplacement(
                        //context,
                        //PageRouteBuilder(
                          //pageBuilder: (_, __, ___) => TaskListPage(),
                          //transitionDuration: Duration.zero,
                        //)
                      //);
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: FutureBuilder<int>(
                        future: getTaskCountForWeek(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Near Deadline:' + ' ${snapshot.data}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[900],
                                  ),
                                ),
                              ],
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ]
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                spacing: 8.0,
                children: [
                  ChoiceChip(
                    label: Text('Minggu Ini'),
                    selected: sortMode == 'week',
                    onSelected: (value) {
                      setState(() {
                        sortMode = 'week';
                      });
                    },
                  ),
                  ChoiceChip(
                    label: Text('Bulan Ini'),
                    selected: sortMode == 'month',
                    onSelected: (value) {
                      setState(() {
                        sortMode = 'month';
                      });
                    },
                  ),
                  ChoiceChip(
                    label: Text('Semua Tugas'),
                    selected: sortMode == 'all',
                    onSelected: (value) {
                      setState(() {
                        sortMode = 'all';
                      });
                    },
                  ),
                ],
                            ),
                            const SizedBox(height: 16),
                            Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore.collection('tasks').orderBy('date').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text("Something went wrong");
                    }
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }
                
                    List<Task> tasks = snapshot.data!.docs.map((doc) {
                      var data = doc.data() as Map<String, dynamic>;
                      return Task(
                        doc.id,
                        data['name'],
                        (data['date'] as Timestamp).toDate(),
                        TimeOfDay(
                            hour: int.parse(data['time'].split(':')[0]),
                            minute: int.parse(data['time'].split(':')[1])),
                        data['category'],
                      );
                    }).toList();
                
                    tasks = filterTasksByDeadline(tasks);
                
                    var groupedTasks = groupTasksByDate(tasks);
                    var sortedDates = groupedTasks.keys.toList()
                      ..sort((a, b) => a.compareTo(b));
                
                    return ListView.builder(
                      itemCount: sortedDates.length,
                      itemBuilder: (context, index) {
                        var date = sortedDates[index];
                        var tasksForDate = groupedTasks[date]!;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                DateFormat('EEEE, dd MMMM').format(date),
                                style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[600]),
                              ),
                            ),
                            ...tasksForDate
                              .map((task) => Container(
                                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                                  padding: const EdgeInsets.all(16.0),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              task.name,
                                              style: TextStyle(
                                                fontSize: 18.0,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                            Text(
                                              '${task.time.format(context)}',
                                              style: TextStyle(
                                                fontSize: 14.0,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ))
                              .toList(),
                            ],
                          );
                          }
                        );
                      },
                     ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    )  
    );
  }
}

