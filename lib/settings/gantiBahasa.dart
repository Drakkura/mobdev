import 'package:flutter/material.dart';
import 'setting.dart';

class ChangeLanguage extends StatelessWidget {
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
            alignment: Alignment.topCenter, // Menempatkan teks "Setting" dan tombol-tombol ke atas
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 30),
                Text(
                  'Change Language',
                  style: TextStyle(
                    color: Color(0xFF353535),
                    fontSize: 40,
                    fontFamily: 'Nunito Sans',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                // Dropdown untuk mengubah bahasa
                SizedBox(height: 20),
                Container(
                  width: 250,
                  height: 150, 
                  child: DropdownButtonFormField<Locale>(
                    value: Locale('id'), // Nilai default
                    items: [
                      DropdownMenuItem<Locale>(
                        value: Locale('id'),
                        child: Text('Indonesia'),
                      ),
                      DropdownMenuItem<Locale>(
                        value: Locale('en'),
                        child: Text('English'),
                      ),
                    ],
                    onChanged: (Locale? selectedLocale) {
                      // Tambahkan kode untuk menyimpan perubahan bahasa
                      // Anda dapat menggunakan selectedLocale untuk menangani perubahan bahasa
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    // Tambahkan kode untuk menyimpan perubahan bahasa
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF3E4553),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 4,
                    minimumSize: Size(250, 44),
                  ),
                  child: Text(
                    'SAVE',
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
