import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:login_sahabat_mahasiswa/view/dashboard.dart';
import 'package:login_sahabat_mahasiswa/view/widget/bottom.navigationbar.dart';
import 'package:login_sahabat_mahasiswa/utils/colors.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Task> _tasks = [];
  List<Task> _visibleTasks = [];
  int _visibleCount = 3; // Number of tasks to show initially

  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    var querySnapshot = await _firestore.collection('tasks').get();
    var fetchedTasks = querySnapshot.docs.map((doc) {
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

    setState(() {
      _tasks = fetchedTasks;
    });
  }

  void _updateVisibleTasks() {
    var tasksForSelectedDate = _getTasksForSelectedDate();
    _visibleTasks = tasksForSelectedDate.take(_visibleCount).toList();
  }

  List<Task> _getTasksForSelectedDate() {
    return _tasks.where((task) {
      return task.date.year == _selectedDay?.year &&
          task.date.month == _selectedDay?.month &&
          task.date.day == _selectedDay?.day;
    }).toList();
  }

  void _loadMoreTasks() {
    var allTasks = _getTasksForSelectedDate();
    if (_visibleCount < allTasks.length) {
      setState(() {
        _visibleCount = _visibleCount + 3; // Load 3 more tasks at a time
        _updateVisibleTasks();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _updateVisibleTasks(); // Update visible tasks whenever the state updates

    return Scaffold(
      appBar: AppBar(
        backgroundColor: GlobalColors.mainColor,
        automaticallyImplyLeading: false,
        title: Text(
          'Kalendar',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: TableCalendar(
              firstDay: DateTime.utc(2010, 10, 16),
              lastDay: DateTime.utc(2030, 3, 14),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                  _visibleCount =
                      3; // Reset visible count on new date selection
                  _updateVisibleTasks();
                });
              },
              onFormatChanged: (format) {
                if (_calendarFormat != format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                }
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _visibleTasks.length +
                  1, // Adding one for the load more button
              itemBuilder: (context, index) {
                if (index == _visibleTasks.length) {
                  return _visibleTasks.length <
                          _getTasksForSelectedDate().length
                      ? ElevatedButton(
                          onPressed: _loadMoreTasks, child: Text("Load More"))
                      : SizedBox
                          .shrink(); // Show button only if there are more items to load
                }
                Task task = _visibleTasks[index];
                return ListTile(
                  title: Text(task.name),
                  subtitle: Text('${task.date} - ${task.time.format(context)}'),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(),
    );
  }
}
