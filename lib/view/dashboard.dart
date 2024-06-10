import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login_sahabat_mahasiswa/utils/colors.dart';
import 'package:login_sahabat_mahasiswa/view/widget/bottom.navigationbar.dart';

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
  String selectedCategory = 'All';
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
    selectedCategory = 'All';
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
    for (var task in tasks) {
      DateTime date = DateTime(task.date.year, task.date.month, task.date.day);
      if (!map.containsKey(date)) {
        map[date] = [];
      }
      map[date]!.add(task);
    }
    return map;
  }

  List<Task> filterTasksByCategory(String category, List<Task> tasks) {
    if (category == 'All') {
      return tasks;
    }
    return tasks.where((task) => task.category == category).toList();
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
              children: [
                ...predefinedCategories.map((category) => Padding(
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
                    )),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ChoiceChip(
                    label: Text('All'),
                    selected: selectedCategory == 'All',
                    onSelected: (bool selected) {
                      setState(() {
                        selectedCategory = 'All';
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    _firestore.collection('tasks').orderBy('date').snapshots(),
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

                  tasks = filterTasksByCategory(selectedCategory, tasks);

                  var groupedTasks = groupTasksByDate(tasks);
                  var sortedDates = groupedTasks.keys.toList()
                    ..sort((b, a) => a.compareTo(b));

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
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 8.0),
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
                                                '${task.time.format(context)}', // Ensure TimeOfDay is formatted correctly
                                                style: TextStyle(
                                                  fontSize: 14.0,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.edit,
                                              color: Colors.blue),
                                          onPressed: () {
                                            currentTask = task;
                                            nameController.text = task.name;
                                            dateController.text =
                                                '${task.date.day}/${task.date.month}/${task.date.year}';
                                            timeController.text =
                                                '${task.time.hour}:${task.time.minute}';
                                            selectedCategory = task.category;
                                            selectedDate = task.date;
                                            selectedTime = task.time;
                                            showModalBottomSheet(
                                              context: context,
                                              isScrollControlled: true,
                                              builder: (BuildContext context) {
                                                return _buildBottomSheet();
                                              },
                                            );
                                          },
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.delete,
                                              color: Colors.red),
                                          onPressed: () => _deleteTask(task.id),
                                        ),
                                      ],
                                    ),
                                  ))
                              .toList(),
                        ],
                      );
                    },
                  );
                },
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
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Task Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: dateController,
              decoration: InputDecoration(
                labelText: 'Date',
                border: OutlineInputBorder(),
              ),
              onTap: () async {
                FocusScope.of(context).requestFocus(new FocusNode());
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate ?? DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2101),
                );
                if (picked != null) {
                  setState(() {
                    selectedDate = picked;
                    dateController.text =
                        "${picked.day}/${picked.month}/${picked.year}";
                  });
                }
              },
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: timeController,
              decoration: InputDecoration(
                labelText: 'Time',
                border: OutlineInputBorder(),
              ),
              onTap: () async {
                FocusScope.of(context).requestFocus(new FocusNode());
                TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: selectedTime ?? TimeOfDay.now(),
                );
                if (picked != null) {
                  setState(() {
                    selectedTime = picked;
                    timeController.text =
                        "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
                  });
                }
              },
            ),
            const SizedBox(height: 16.0),
            DropdownButtonFormField<String>(
              value: selectedCategory,
              onChanged: (newValue) {
                setState(() {
                  selectedCategory = newValue!;
                });
              },
              items: predefinedCategories
                  .map((category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      ))
                  .toList(),
              decoration: InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                name = nameController.text; // Assign value to name
                _addOrEditTask(currentTask);
              },
              child: Text(currentTask == null ? 'Add Task' : 'Update Task'),
            ),
          ],
        ),
      ),
    );
  }
}
