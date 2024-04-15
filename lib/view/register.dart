import 'package:flutter/material.dart';
import 'package:login_sahabat_mahasiswa/view/login.view.dart';
import 'package:login_sahabat_mahasiswa/utils/colors.dart';
import 'package:login_sahabat_mahasiswa/models/mysql.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

Future<void> registerUser(String firstName, String lastName, String username,
    String email, String password) async {
  try {
    // Get a connection to the database
    var conn = await MySQL().getConnection();

    // Prepare the insert query with named parameters
    var result = await conn.execute(
      "INSERT INTO users (first_name, last_name, username, email, password) VALUES (:firstName, :lastName, :username, :email, :password)",
      {
        'firstName': firstName,
        'lastName': lastName,
        'username': username,
        'email': email,
        'password': password,
      },
    );

    print('Inserted row id=${result.lastInsertID}');

    // Close the connection
    await conn.close();
  } catch (e) {
    print("Error: $e");
    // Handle the error, e.g., show an alert dialog with the error message
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const RegistrationPage(),
      routes: const {
        // Enable the route
        // '/login': (context) => LoginPage(),
      },
    );
  }
}

class RegistrationPage extends StatefulWidget {
  // ignore: use_super_parameters
  const RegistrationPage({Key? key}) : super(key: key); // Fix the constructor

  @override
  // ignore: library_private_types_in_public_api
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  // ignore: unused_field
  late String _firstName,
      // ignore: unused_field
      _lastName,
      // ignore: unused_field
      _username,
      // ignore: unused_field
      _email;
  String _password = '';

  bool _passwordContainsUppercase = false;
  bool _passwordContainsNumber = false;
  bool _passwordContainsSpecialCharacter = false;
  bool _passwordLengthValid = false;

  bool _obscureText = true;
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Call the registerUser method with the user details
      registerUser(_firstName, _lastName, _username, _email, _password)
          .then((_) {
        // Show a success dialog or navigate to another page
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: const Text('Registration successful'),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('OK'),
                )
              ],
            );
          },
        );
      }).catchError((error) {
        // Handle errors, e.g., show an error dialog
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text('Registration failed: $error'),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('OK'),
                )
              ],
            );
          },
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: GlobalColors.mainColor,
        leading: Image.asset('assets/images/logoaja.png', height: 80),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => LoginView()));
            },
            child: const Text(
              'Login',
              style: TextStyle(color: Colors.white),
            ),
          )
        ],
      ),
      body: Stack(
        children: <Widget>[
          Center(
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Center(
                        child: Text(
                          'Sahabat Mahasiswa',
                          style: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5.0), // Spacer
                      const Text(
                        'Register your account',
                        style: TextStyle(
                          fontSize: 14.0, // Ukuran teks lebih kecil
                          fontWeight: FontWeight.normal, // Default weight
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'First Name',
                          hintText: 'Enter your first name',
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 15.0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter your first name';
                          }
                          return null;
                        },
                        onSaved: (value) => _firstName = value!,
                      ),
                      const SizedBox(height: 15.0),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Last Name',
                          hintText: 'Enter your Last name',
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 15.0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter your Last name';
                          }
                          return null;
                        },
                        onSaved: (value) => _lastName = value!,
                      ),
                      const SizedBox(height: 15.0),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Username',
                          hintText: 'Enter your Username',
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 15.0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter your Username';
                          }
                          return null;
                        },
                        onSaved: (value) => _username = value!,
                      ),
                      const SizedBox(height: 15.0),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Email',
                          hintText:
                              'e.g., example@student.telkomuniversity.ac.id',
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 15.0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter your Email';
                          }
                          return null;
                        },
                        onSaved: (value) => _email = value!,
                      ),
                      const SizedBox(height: 15.0),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: 'Enter your Password',
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 15.0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureText
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureText = !_obscureText;
                              });
                            },
                          ),
                        ),
                        obscureText: _obscureText,
                        onChanged: (value) {
                          setState(() {
                            _passwordLengthValid = value.length >= 8;
                            _passwordContainsUppercase =
                                value.contains(RegExp(r'[A-Z]'));
                            _passwordContainsNumber =
                                value.contains(RegExp(r'[0-9]'));
                            _passwordContainsSpecialCharacter = value
                                .contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
                          });
                        },
                        validator: (value) {
                          if (value!.length < 8) {
                            return 'Password must be at least 8 characters long';
                          }
                          if (!value.contains(RegExp(r'[A-Z]'))) {
                            return 'Password must contain at least one uppercase letter';
                          }
                          if (!value.contains(RegExp(r'[0-9]'))) {
                            return 'Password must contain at least one number';
                          }
                          if (!value
                              .contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
                            return 'Password must contain at least one special character';
                          }
                          return null;
                        },
                        onSaved: (value) => _password = value ?? '',
                      ),

                      const SizedBox(height: 15.0),

                      Row(
                        children: [
                          const SizedBox(width: 10.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Password requirements:',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                              const SizedBox(height: 5.0),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.check_circle_outline,
                                    color: Colors.green,
                                    size: 16.0,
                                  ),
                                  const SizedBox(width: 5.0),
                                  Text(
                                    'At least 8 characters long',
                                    style: TextStyle(
                                      color: _passwordLengthValid
                                          ? Colors.green
                                          : Colors.grey,
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5.0),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.check_circle_outline,
                                    color: Colors.green,
                                    size: 16.0,
                                  ),
                                  const SizedBox(width: 5.0),
                                  Text(
                                    'At least one uppercase letter',
                                    style: TextStyle(
                                      color: _passwordContainsUppercase
                                          ? Colors.green
                                          : Colors.grey,
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5.0),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.check_circle_outline,
                                    color: Colors.green,
                                    size: 16.0,
                                  ),
                                  const SizedBox(width: 5.0),
                                  Text(
                                    'At least one number',
                                    style: TextStyle(
                                      color: _passwordContainsNumber
                                          ? Colors.green
                                          : Colors.grey,
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5.0),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.check_circle_outline,
                                    color: Colors.green,
                                    size: 16.0,
                                  ),
                                  const SizedBox(width: 5.0),
                                  Text(
                                    'At least one special character',
                                    style: TextStyle(
                                      color: _passwordContainsSpecialCharacter
                                          ? Colors.green
                                          : Colors.grey,
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 15.0),

                      const SizedBox(height: 20.0),
                      Center(
                        child: ElevatedButton(
                          onPressed: _submitForm,
                          child: const Text(
                            'Submit',
                            style: TextStyle(
                              color: Colors.white, // Warna teks
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: GlobalColors.secondColor,
                            minimumSize: const Size(
                                double.infinity, 50), // Ukuran minimum
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(7), // Radius sudut
                            ),
                            elevation: 5, // Tinggi bayangan
                            shadowColor:
                                Colors.black.withOpacity(0.1), // Warna bayangan
                          ),
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginView()));
                        },
                        child: Center(
                          child: Text(
                            'Sudah punya akun? Login',
                            style: TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
