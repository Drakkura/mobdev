import 'package:flutter/material.dart';
import 'feedback.dart';
import 'gantiBahasa.dart';
import 'gantiTema.dart';
import 'package:login_sahabat_mahasiswa/view/widget/bottom.navigationbar.dart';
import 'package:login_sahabat_mahasiswa/utils/colors.dart';
import 'package:login_sahabat_mahasiswa/view/login.view.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Setting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CustomBottomNavigationBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 10, top: 50), // Mengatur jarak panah
          ),
          Align(
            alignment: Alignment
                .topCenter, // Menempatkan teks "Setting" dan tombol-tombol ke atas
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 50),
                Text(
                  'Settings',
                  style: TextStyle(
                    color: Color(0xFF353535),
                    fontSize: 40,
                    fontFamily: 'Nunito Sans',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ChangeLanguage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GlobalColors.mainColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 4,
                    minimumSize: Size(250, 44),
                  ),
                  child: Text(
                    'Change Language',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontFamily: 'Nunito Sans',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ChangeTheme()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GlobalColors.mainColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 4,
                    minimumSize: Size(250, 44),
                  ),
                  child: Text(
                    'Change Theme',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontFamily: 'Nunito Sans',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FeedbackPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GlobalColors.mainColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 4,
                    minimumSize: Size(250, 44),
                  ),
                  child: Text(
                    'Feedback',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontFamily: 'Nunito Sans',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await FirebaseAuth.instance.signOut(); // Log out the user
                      // Navigate back to the login page
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => LoginView()),
                        (Route<dynamic> route) => false,
                      );
                    } catch (e) {
                      // Handle any errors
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Error'),
                          content: Text('An error occurred while logging out.'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text('OK'),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    // Apply the same style as other buttons
                    backgroundColor: GlobalColors.mainColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 4,
                    minimumSize: Size(250, 44),
                  ),
                  child: Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontFamily: 'Nunito Sans',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
