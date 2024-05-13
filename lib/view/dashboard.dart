import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login_sahabat_mahasiswa/view/widget/bottom.navigationbar.dart';
import 'package:login_sahabat_mahasiswa/utils/date_time.dart';
<<<<<<< Updated upstream
=======
import 'package:cloud_firestore/cloud_firestore.dart';

import 'widget/form.dart';

class Task {
  String id;
  String name;
  DateTime date;
  TimeOfDay time;
  String category;

  Task(this.id, this.name, this.date, this.time, this.category);
}
>>>>>>> Stashed changes

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<String> predefinedCategories = ['Kuliah', 'Pribadi', 'Belajar'];
  String selectedCategory = 'Kuliah'; 
  DateTime? selectedDate;
TimeOfDay? selectedTime;

Future<void> _selectDate(BuildContext context) async {
  final DateTime? pickedDate = await DateTimePicker.selectDate(context, selectedDate);
  if (pickedDate != null && pickedDate != selectedDate) {
    setState(() {
      selectedDate = pickedDate;
    });
  }
}

Future<void> _selectTime(BuildContext context) async {
  final TimeOfDay? pickedTime = await DateTimePicker.selectTime(context, selectedTime);
  if (pickedTime != null && pickedTime != selectedTime) {
    setState(() {
      selectedTime = pickedTime;
    });
  }
<<<<<<< Updated upstream
}
=======

  Future<void> _addTask(
      String? name, DateTime? date, TimeOfDay? time, String category) async {
    try {
      await _firestore.collection('tasks').add({
        'name': name ?? '',
        'date': date ?? DateTime.now(),
        'time': time != null ? '${time.hour}:${time.minute}' : '00:00',
        'category': category,
      });

      // Reset text field controllers
      nameController.clear();
      dateController.clear();
      timeController.clear();
      setState(() {
        selectedCategory = predefinedCategories[0]; // Reset selected category
      });

      Navigator.pop(context); // Close the bottom sheet after adding task
    } catch (e) {
      print('Error adding task: $e');
      // Handle error here
    }
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

  Future<void> _editTask(String id) async {
  try {
    DocumentSnapshot taskSnapshot =
        await _firestore.collection('tasks').doc(id).get();
    Map<String, dynamic> taskData = taskSnapshot.data() as Map<String, dynamic>;
    Task task = Task(
      id,
      taskData['name'],
      (taskData['date'] as Timestamp).toDate(),
      TimeOfDay(
        hour: int.parse(taskData['time'].split(':')[0]),
        minute: int.parse(taskData['time'].split(':')[1])),
      taskData['category'],
    );

    Task? editedTask = await showDialog<Task>(
      context: context,
      builder: (BuildContext context) {
        return EditTaskScreen(task: task);
      },
    );

    if (editedTask != null) {
      // Update task details in Firestore
      await _firestore.collection('tasks').doc(id).update({
        'name': editedTask.name,
        'date': editedTask.date,
        'time': '${editedTask.time.hour}:${editedTask.time.minute}',
        'category': editedTask.category,
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Task edited successfully'),
      ));
    }
  } catch (e) {
    print('Error editing task: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to edit task')),
    );
  }
}

  Future<void> _deleteTask(String id) async {
    try {
      // Show confirmation dialog
      bool confirmDelete = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Confirmation'),
            content: Text('Are you sure you want to delete this task?'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false); // Return false if canceled
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true); // Return true if confirmed
                },
                child: Text('Delete'),
              ),
            ],
          );
        },
      );

      // Delete task if confirmed
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

>>>>>>> Stashed changes
  @override
  Widget build(BuildContext context) {
    const String welcomeText = 'Halo Yoga';
    const String taskText = '3 Tugas Mendatang';
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              welcomeText,
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              taskText,
              style: TextStyle(
                fontSize: 14.0,
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
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                    width: MediaQuery.of(context).size.width / 4,
                    height: 40,
                    child: TextButton(
                      onPressed: () {},
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                          Colors.black.withOpacity(0.1),
                        ),
                        shape: MaterialStateProperty.all<OutlinedBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                      ),
                      child: const Icon(
                        Icons.filter_alt,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                    child: const Text(
                      'Semua',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                    child: const Text('Kuliah'),
                  ),
                  const SizedBox(width: 8.0),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                    child: const Text('Pribadi'),
                  ),
                  const SizedBox(width: 8.0),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                    child: const Text('Belajar'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Hari Ini',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
<<<<<<< Updated upstream
              child: ListView(
                children: const [
                  ScheduleItem(text: 'Tidur'),
                  ScheduleItem(text: 'hmm'),
                  ScheduleItem(text: 'kelas'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Selesai Hari Ini',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: const [
                  CompletedItem(text: 'Sahur'),
                  CompletedItem(text: 'tidur lagi'),
                ],
=======
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('tasks').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text("Something went wrong");
                  }

                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  List<Task> tasks = snapshot.data!.docs.map((doc) {
                    var data = doc.data() as Map<String, dynamic>;
                    var id = doc.id; // Capture the Firestore document ID
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

                  return ListView.builder(
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
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            Text(
                                task.category,
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.black,
                                ),
                              ),
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () =>
                                  _editTask(task.id), // Call delete function
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () =>
                                  _deleteTask(task.id), // Call delete function
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
>>>>>>> Stashed changes
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
              ),
              const SizedBox(height: 16),
              TextField(
                readOnly: true,
                controller: TextEditingController(
                  text: selectedDate != null
                      ? "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}"
                      : "",
                ),
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
                controller: TextEditingController(
                  text: selectedTime != null
                      ? "${selectedTime!.hour}:${selectedTime!.minute}"
                      : "",
                ),
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
                  Navigator.pop(context);
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
      ),
    );
  }
}

class ScheduleItem extends StatelessWidget {
  final String text;

  const ScheduleItem({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.grey.withOpacity(0.2),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.black,
                  width: 2.0,
                ),
              ),
              child: const Icon(
                Icons.check,
                color: Colors.transparent,
              ),
            ),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16.0),
            ),
          ),
        ],
      ),
    );
  }
}

class CompletedItem extends StatelessWidget {
  final String text;

  const CompletedItem({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.grey.withOpacity(0.2),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green,
            ),
            child: const Icon(
              Icons.check,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16.0,
                decoration: TextDecoration.lineThrough,
              ),
            ),
          ),
        ],
      ),
    );
  }
<<<<<<< Updated upstream
=======
}


class EditTaskScreen extends StatefulWidget {
  final Task task;

  const EditTaskScreen({required this.task});

  @override
  _EditTaskScreenState createState() => _EditTaskScreenState();
}
class _EditTaskScreenState extends State<EditTaskScreen> {
  late TextEditingController _titleController;
  late TextEditingController _dateController;
  late TextEditingController _timeController;
  late TextEditingController _categoryController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _dateController = TextEditingController();
    _timeController = TextEditingController();
    _categoryController = TextEditingController();

    // Schedule microtask to set initial values
    Future.microtask(() {
      _titleController.text = widget.task.name;
      _dateController.text =
          DateFormat('yyyy-MM-dd').format(widget.task.date);
      _timeController.text = widget.task.time.format(context);
      _categoryController.text = widget.task.category;
    });
  }

  @override
  void dispose() {
    // Dispose controllers when the widget is disposed
    _titleController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Task'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormGlobal(
              controller: _titleController,
              text: 'Title',
              textInputType: TextInputType.text,
              obscure: false,
            ),
            const SizedBox(height: 16),
            TextFormGlobal(
              controller: _dateController,
              text: 'Date (yyyy-MM-dd)',
              textInputType: TextInputType.datetime,
              obscure: false,
            ),
            const SizedBox(height: 16),
            TextFormGlobal(
              controller: _timeController,
              text: 'Time (HH:mm)',
              textInputType: TextInputType.datetime,
              obscure: false,
            ),
            const SizedBox(height: 16),
            TextFormGlobal(
              controller: _categoryController,
              text: 'Category',
              textInputType: TextInputType.text,
              obscure: false,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                try {
                  // Parse the entered date string
                  DateTime parsedDate =
                      DateFormat('yyyy-MM-dd').parse(_dateController.text);
                  
                  // Check if the parsed date is valid
                  if (parsedDate != null) {
                    // If valid, create the edited task and pop the screen
                    Task editedTask = Task(
                      widget.task.id,
                      _titleController.text,
                      parsedDate,
                      TimeOfDay.fromDateTime(
                          DateTime.parse('1970-01-01 ' + _timeController.text)),
                      _categoryController.text,
                    );
                    Navigator.pop(context, editedTask);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Invalid date format'),
                    ));
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Invalid date format'),
                  ));
                }
              },
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
>>>>>>> Stashed changes
}