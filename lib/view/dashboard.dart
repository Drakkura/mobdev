import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:login_sahabat_mahasiswa/utils/colors.dart';
import 'package:login_sahabat_mahasiswa/utils/date_time.dart';
import 'package:login_sahabat_mahasiswa/view/widget/bottom.navigationbar.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class Task {
  String id;
  String name;
  DateTime date;
  TimeOfDay time;
  String category;

  Task(this.id, this.name, this.date, this.time, this.category);
}

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late String namauser = "";
  late String username = "";
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();

  List<String> predefinedCategories = ['Kuliah', 'Pribadi', 'Belajar'];
  String selectedCategory = 'Kuliah';
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  String? name; // Declare name variable here
  Task? currentTask; // To hold the task being edited

  List<Task> tasks = [];

  @override
  void initState() {
    super.initState();
    _fetchTasks();
    getUserDataFromFirestore();
  }

  String capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  Future<void> getUserDataFromFirestore() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        final snapshot =
            await _firestore.collection("users").doc(user.uid).get();

        if (snapshot.exists) {
          setState(() {
            username = capitalize(snapshot.data()!['username']);
            name =
                "${snapshot.data()!['firstName']} ${snapshot.data()!['lastName']}";
          });
        }
      }
    } catch (e) {
      print("Error getting user data: $e");
    }
  }

  Future<void> _fetchTasks() async {
    var querySnapshot = await _firestore.collection('tasks').get();
    tasks = querySnapshot.docs.map((doc) {
      var data = doc.data();
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
    setState(() {});
  }

  Future<void> _addOrEditTask(Task? task) async {
    DateTime fullDateTime = DateTime(
      selectedDate?.year ?? DateTime.now().year,
      selectedDate?.month ?? DateTime.now().month,
      selectedDate?.day ?? DateTime.now().day,
      selectedTime?.hour ?? 0,
      selectedTime?.minute ?? 0,
    );

    var docRef = task == null
        ? _firestore.collection('tasks').doc()
        : _firestore.collection('tasks').doc(task.id);

    await docRef.set({
      'name': name ?? '',
      'date': selectedDate ?? DateTime.now(),
      'time': selectedTime != null
          ? '${selectedTime!.hour}:${selectedTime!.minute}'
          : '00:00',
      'category': selectedCategory,
    });

    // Convert document reference to task object
    task = Task(docRef.id, name ?? '', selectedDate ?? DateTime.now(),
        selectedTime ?? TimeOfDay(hour: 0, minute: 0), selectedCategory);

    _resetForm();
    Navigator.pop(
        context); // Close the bottom sheet after adding or editing task
  }

  void _resetForm() {
    nameController.clear();
    dateController.clear();
    timeController.clear();
    selectedCategory = predefinedCategories[0];
    currentTask = null;
    setState(() {});
  }

  Future<void> _deleteTask(String id) async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text('Are you sure you want to delete this task?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      await _firestore.collection('tasks').doc(id).delete();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Task deleted successfully'),
      ));
    }
  }

  Map<DateTime, List<Task>> groupTasksByDate(List<Task> tasks) {
    Map<DateTime, List<Task>> map = {};
    for (var task in tasks.where((task) => task.category == selectedCategory)) {
      DateTime date = DateTime(task.date.year, task.date.month, task.date.day);
      if (!map.containsKey(date)) {
        map[date] = [];
      }
      map[date]!.add(task);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: GlobalColors.mainColor,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Halo " + username,
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              '3 Tugas Mendatang',
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: predefinedCategories
                  .map((category) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: ChoiceChip(
                          label: Text(category),
                          selected: selectedCategory == category,
                          onSelected: (bool selected) {
                            setState(() {
                              selectedCategory = category;
                            });
                          },
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: tasks.isNotEmpty
                  ? ListView.builder(
                      itemCount: groupTasksByDate(tasks).length,
                      itemBuilder: (context, index) {
                        var groupedTasks = groupTasksByDate(tasks);
                        var sortedDates = groupedTasks.keys.toList()
                          ..sort((b, a) => a.compareTo(b));

                        var date = sortedDates[index];
                        var tasksForDate = groupedTasks[date]!;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                DateFormat('EEEE, dd MMMM').format(date),
                                style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[600]),
                              ),
                            ),
                            ...tasksForDate
                                .where(
                                    (task) => task.category == selectedCategory)
                                .map((task) => Container(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 8.0),
                                      padding: const EdgeInsets.all(16.0),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.5),
                                            offset: Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
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
                                          // Edit and Delete buttons
                                        ],
                                      ),
                                    ))
                                .toList(),
                          ],
                        );
                      },
                    )
                  : Center(
                      child: Text('No tasks found'),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (BuildContext context) {
              return _buildBottomSheet();
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBottomSheet() {
    return SingleChildScrollView(
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Nama',
                  border: OutlineInputBorder(),
                ),
                controller: nameController,
                onChanged: (value) => name = value,
              ),
              const SizedBox(height: 16),
              TextField(
                readOnly: true,
                controller: dateController,
                onTap: () => _selectDate(context),
                decoration: const InputDecoration(
                  labelText: 'Tanggal',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                readOnly: true,
                controller: timeController,
                onTap: () => _selectTime(context),
                decoration: const InputDecoration(
                  labelText: 'Jam',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.access_time),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedCategory = newValue!;
                  });
                },
                items: predefinedCategories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _addOrEditTask(currentTask),
                child: Text(currentTask == null ? 'Add Task' : 'Update Task'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate =
        await DateTimePicker.selectDate(context, selectedDate);
    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
        dateController.text =
            "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}";
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime =
        await DateTimePicker.selectTime(context, selectedTime);
    if (pickedTime != null && pickedTime != selectedTime) {
      setState(() {
        selectedTime = pickedTime;
        timeController.text = "${selectedTime!.hour}:${selectedTime!.minute}";
      });
    }
  }
}
