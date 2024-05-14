import 'package:flutter/material.dart';
import 'package:login_sahabat_mahasiswa/view/widget/bottom.navigationbar.dart';
import 'package:login_sahabat_mahasiswa/utils/colors.dart';
import 'package:login_sahabat_mahasiswa/utils/date_time.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();

  List<String> predefinedCategories = ['Kuliah', 'Pribadi', 'Belajar'];
  String selectedCategory = 'Kuliah';
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  String? name;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Task> tasks = [];

  @override
  void initState() {
    super.initState();
    _fetchTasks();
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

  Future<void> _addTask(String? name, DateTime? date, TimeOfDay? time, String category) async {
    try {
      await _firestore.collection('tasks').add({
        'name': name ?? '',
        'date': date ?? DateTime.now(),
        'time': time != null ? '${time.hour}:${time.minute}' : '00:00',
        'category': category,
      });

      nameController.clear();
      dateController.clear();
      timeController.clear();
      setState(() {
        selectedCategory = predefinedCategories[0];
      });

      Navigator.pop(context);
    } catch (e) {
      print('Error adding task: $e');
    }
  }

  Future<void> _editTask(Task task) async {
    nameController.text = task.name;
    dateController.text = "${task.date.day}/${task.date.month}/${task.date.year}";
    timeController.text = "${task.time.hour}:${task.time.minute}";
    selectedCategory = task.category;
    selectedDate = task.date;
    selectedTime = task.time;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
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
                    onPressed: () {
                      _updateTask(task.id, nameController.text, selectedDate, selectedTime, selectedCategory);
                    },
                    child: const Text('Save Changes'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _updateTask(String id, String? name, DateTime? date, TimeOfDay? time, String category) async {
    try {
      await _firestore.collection('tasks').doc(id).update({
        'name': name ?? '',
        'date': date ?? DateTime.now(),
        'time': time != null ? '${time.hour}:${time.minute}' : '00:00',
        'category': category,
      });

      nameController.clear();
      dateController.clear();
      timeController.clear();
      setState(() {
        selectedCategory = predefinedCategories[0];
      });

      Navigator.pop(context);
    } catch (e) {
      print('Error updating task: $e');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await DateTimePicker.selectDate(context, selectedDate);
    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
        dateController.text = "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}";
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await DateTimePicker.selectTime(context, selectedTime);
    if (pickedTime != null && pickedTime != selectedTime) {
      setState(() {
        selectedTime = pickedTime;
        timeController.text = "${selectedTime!.hour}:${selectedTime!.minute}";
      });
    }
  }

  Future<void> _deleteTask(String id) async {
    try {
      bool confirmDelete = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Confirmation'),
            content: Text('Are you sure you want to delete this task?'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
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
    } catch (e) {
      print('Error deleting task: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete task')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const String welcomeText = 'Halo Yoga';
    const String taskText = '3 Tugas Mendatang';
    return Scaffold(
      appBar: AppBar(
        backgroundColor: GlobalColors.mainColor,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              welcomeText,
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              taskText,
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
            SizedBox(
              height: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Cari tugas Hari ini',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: GlobalColors.mainColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  Task task = tasks[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            task.name,
                            style: const TextStyle(
                              fontSize: 16.0,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _editTask(task), // Call edit function
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteTask(task.id), // Call delete function
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (BuildContext context) {
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
                          onPressed: () {
                            _addTask(nameController.text, selectedDate, selectedTime, selectedCategory);
                          },
                          child: const Text('Add Task'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
        child: const Icon(Icons.add),
        backgroundColor: GlobalColors.mainColor,
      ),
      bottomNavigationBar: CustomBottomNavigationBar(), // Removed const and selectedIndex
    );
  }
}
