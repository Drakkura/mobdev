import 'package:flutter/material.dart';
import 'package:login_sahabat_mahasiswa/utils/colors.dart';

class GlobalButton extends StatelessWidget {
  const GlobalButton({super.key, required Future<void> Function() onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
       
      },
      child: Container(
        alignment: Alignment.center,
        height: 50,
        decoration: BoxDecoration(
          color: GlobalColors.secondColor,
          borderRadius: BorderRadius.circular(7),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
            )
          ]
        ),
        child: const Text(
          'Log In',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600
          ),
          ),
      ),
    );
  }
}