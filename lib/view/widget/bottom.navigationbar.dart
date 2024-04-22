import 'package:flutter/material.dart';
import 'package:login_sahabat_mahasiswa/utils/colors.dart';
import 'package:login_sahabat_mahasiswa/view/dashboard.dart'; 
import 'package:login_sahabat_mahasiswa/view/calendar.dart'; 
import 'package:login_sahabat_mahasiswa/settings/setting.dart';
import 'package:login_sahabat_mahasiswa/view/profile.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  @override
  _CustomBottomNavigationBarState createState() =>
      _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: GlobalColors.mainColor,
      selectedItemColor: Colors.grey[300],
      unselectedItemColor: Colors.grey[300],
      currentIndex: _selectedIndex,
      selectedFontSize: 14.0, // Set the font size for selected item
      unselectedFontSize: 14.0, // Set the font size for unselected items
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
          // Navigate to the corresponding screen
          if (_selectedIndex == 0) {
            Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => Dashboard(),
              transitionDuration: Duration.zero, 
            ),
          );
          } else if (_selectedIndex == 1) {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
              pageBuilder: (_, __, ___) => CalendarScreen(),
              transitionDuration: Duration.zero, 
            ),
            );
          } else if (_selectedIndex == 2) {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
              pageBuilder: (_, __, ___) => ProfilePage(),
              transitionDuration: Duration.zero, 
            ),
            );
          }
        });
      },
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.assignment),
          label: 'Tugas',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'Kalender',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Saya',
        ),
      ],
    );
  }
}
