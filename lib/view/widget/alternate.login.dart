import "package:flutter/material.dart";
import "package:flutter_svg/flutter_svg.dart";
import "package:login_sahabat_mahasiswa/utils/colors.dart";

class AlternateLogin extends StatelessWidget {
  const AlternateLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          alignment: Alignment.center,
          child: Text(
            '-Or sign in with-',
            style: TextStyle(
              color: GlobalColors.textColor,
              fontSize: 16,
              fontWeight: FontWeight.w600
            ),
            ),
        ),
        const SizedBox(height: 20,),
        Row(
          children: [
            Expanded(
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(7),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                    )
                  ]
                ),
                child: SvgPicture.asset('assets/images/google.svg'),
              ),
            )
          ],
        )
      ],
    );
  }
}