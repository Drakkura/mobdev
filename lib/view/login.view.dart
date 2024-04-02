import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:login_sahabat_mahasiswa/utils/colors.dart';
import 'package:login_sahabat_mahasiswa/view/dashboard.dart';
import 'package:login_sahabat_mahasiswa/view/widget/alternate.login.dart';
import 'package:login_sahabat_mahasiswa/view/widget/button.dart';
import 'package:login_sahabat_mahasiswa/view/widget/form.dart';
import 'package:login_sahabat_mahasiswa/view/register.dart';

class LoginView extends StatelessWidget {
  LoginView({Key? key}) : super(key: key);
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  
 Future<void> _login(BuildContext context) async {
  String usersJson = await DefaultAssetBundle.of(context).loadString('assets/json/users.json');
  List<dynamic> users = jsonDecode(usersJson);

  String enteredEmail = emailController.text;
  String enteredPassword = passwordController.text;

  bool isValidUser = users.any((user) =>
      user['email'] == enteredEmail && user['password'] == enteredPassword);

  if (isValidUser) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Dashboard()), // Navigate to the Dashboard page
    );
  } else {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text('Invalid email or password. Please try again.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: GlobalColors.mainColor,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            'assets/images/logoaja.png',
            width: 420,
          ),
        ),
        title: Text(''), // Empty text to occupy the space and center the app bar title
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Dashboard()), // Navigate to the Dashboard page
              );
            },
            icon: Icon(Icons.login),
            tooltip: 'Anon Login',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            padding: const EdgeInsets.all(15),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 50),
                Center(
                  child: Text(
                    'Sahabat Mahasiswa',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Login to your account',
                  style: TextStyle(
                    color: GlobalColors.textColor,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 20),

                TextFormGlobal(
                  controller: emailController,
                  text: 'Email',
                  textInputType: TextInputType.emailAddress,
                  obscure: false,
                ),

                SizedBox(height: 20),
                TextFormGlobal(
                  controller: passwordController,
                  text: 'Password',
                  textInputType: TextInputType.text,
                  obscure: true,
                ),

                SizedBox(height: 20),
                GlobalButton(
                  onPressed: () => _login(context),
                ),
                SizedBox(height: 25),
                AlternateLogin(),
                SizedBox(height: 25),
                Center( // Centered button text to navigate to register page
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => RegistrationPage()));
                    },
                    child: Text(
                      'Don\'t have an account? Register here', 
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center, // Center align the button text
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
