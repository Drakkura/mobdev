import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:login_sahabat_mahasiswa/view/register.dart';

void main() {
  testWidgets('RegistrationPage UI Test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MaterialApp(
      home: RegistrationPage(),
    ));

    // Verify that the 'Sahabat Mahasiswa' text is displayed.
    expect(find.text('Sahabat Mahasiswa'), findsOneWidget);

    // Verify that the 'Register your account' text is displayed.
    expect(find.text('Register your account'), findsOneWidget);

    // Verify that the 'First Name' field is displayed.
    expect(find.text('First Name'), findsOneWidget);

    // Verify that the 'Last Name' field is displayed.
    expect(find.text('Last Name'), findsOneWidget);

    // Verify that the 'Username' field is displayed.
    expect(find.text('Username'), findsOneWidget);

    // Verify that the 'Email' field is displayed.
    expect(find.text('Email'), findsOneWidget);

    // Verify that the 'Password' field is displayed.
    expect(find.text('Password'), findsOneWidget);

    // Verify that the 'Submit' button is displayed.
    expect(find.widgetWithText(ElevatedButton, 'Submit'), findsOneWidget);

    // Verify that the 'Sudah punya akun? Login' button is displayed.
    expect(find.text('Sudah punya akun? Login'), findsOneWidget);
  });
}
