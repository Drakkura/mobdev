import 'package:flutter/material.dart';
import 'setting.dart';

class ChangeTheme extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 10, top: 50), // Mengatur jarak panah
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Setting()),
                    );
                  },
                  icon: Icon(
                    Icons.arrow_back,
                    size: 30,
                    color: Color(0xFF353535),
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment
                .topCenter, // Menempatkan teks "Setting" dan tombol-tombol ke atas
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 30),
                Text(
                  'Change Theme',
                  style: TextStyle(
                    color: Color(0xFF353535),
                    fontSize: 40,
                    fontFamily: 'Nunito Sans',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                // switch button
                SizedBox(height: 20),
                SwitchButton(),
                SizedBox(height: 10),
                Text(
                  '*Switch to change theme',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontFamily: 'Nunito Sans',
                    fontWeight: FontWeight.w700,
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

class SwitchButton extends StatefulWidget {
  const SwitchButton({super.key});

  @override
  State<SwitchButton> createState() => _SwitchExampleState();
}

class _SwitchExampleState extends State<SwitchButton> {
  bool light = false;

  final MaterialStateProperty<Icon?> thumbIcon =
      MaterialStateProperty.resolveWith<Icon?>(
    (Set<MaterialState> states) {
      if (states.contains(MaterialState.selected)) {
        return const Icon(Icons.check);
      }
      return const Icon(Icons.close);
    },
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 370,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 3,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
            image: DecorationImage(
              image: AssetImage('assets/images/SwitchButton.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        SizedBox(height: 20), 
        Transform.scale(
          scale: 1.5,
          child: Switch(
            thumbIcon: thumbIcon,
            value: light,
            onChanged: (bool value) {
              setState(() {
                light = value;
              });
            },
          ),
        ),
      ],
    );
  }
}
