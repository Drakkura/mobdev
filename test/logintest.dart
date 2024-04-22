import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:login_sahabat_mahasiswa/view/login.view.dart';

void main() {
  testWidgets('LoginView UI Test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MaterialApp(
      home: LoginView(),
    ));

    // Verify that the 'Sahabat Mahasiswa' text is displayed.
    expect(find.text('Sahabat Mahasiswa'), findsOneWidget);

    // Verify that the image is displayed.
    expect(
      find.byWidgetPredicate(
        (Widget widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName == 'assets/images/Time.png',
      ),
      findsOneWidget,
    );

    // Verify that the 'Login to your account' text is displayed.
    expect(find.text('Login to your account'), findsOneWidget);

    // Verify that the email and password text fields are displayed.
    expect(find.byKey(Key('emailField')), findsOneWidget);
    expect(find.byKey(Key('passwordField')), findsOneWidget);

    // Verify that the login button is displayed.
    expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
  });
}
