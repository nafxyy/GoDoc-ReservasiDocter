import 'package:flutter/material.dart';

class JadwalPage extends StatelessWidget {
  JadwalPage({Key? key});

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double containerHeight = screenHeight * 0.15;

    return Scaffold(
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      Navigator.pop(context); // Kembali ke halaman sebelumnya
                    },
                  ),
                ],
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: const Text(
                "Jadwal Reservasi Anda",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: const Text(
              "Senin, 01 Januari 2023",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          cardAccount('Dokter DikyDaw | Rumah Sakit ABC', Icons.arrow_forward, () {
            // onTap function
          }),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: const Text(
              "Selasa, 02 Januari 2023",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          cardAccount('Dokter Tony Chopper | Rumah Sakit XYZ', Icons.arrow_forward, () {
            // onTap function
          }),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: const Text(
              "Senin, 24 Januari 2023",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          cardAccount('Dokter Trafalgar Law | Rumah Sakit XYZ', Icons.arrow_forward, () {
            // onTap function
          }),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: const Text(
              "Selasa, 26 Januari 2023",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          cardAccount('Dokter Heppo | Rumah Sakit XYZ', Icons.arrow_forward, () {
            // onTap function
          }),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: const Text(
              "Rabu, 02 Februari 2023",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          cardAccount('Dokter Lepo | Rumah Sakit XYZ', Icons.arrow_forward, () {
            // onTap function
          }),
        ],
      ),
    );
  }

  Widget cardAccount(String text, IconData arrowIcon, VoidCallback onPressed) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      color: Color(0xFFB12856),
      child: ListTile(
        title: Row(
          children: [
            Icon(
              Icons.calendar_today, // Ganti dengan ikon kalender yang sesuai
              color: Colors.white,
            ),
            SizedBox(width: 8.0),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        trailing: Icon(
          arrowIcon,
          color: Colors.white,
        ),
        onTap: onPressed,
      ),
    );
  }
}
