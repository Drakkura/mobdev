import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:login_sahabat_mahasiswa/view/splash.view.dart';

void main() async {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashView(),
    );
  }
}
