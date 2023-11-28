import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pa_mobile/pages/login.dart';
import 'package:pa_mobile/pages/about.dart';
import 'package:pa_mobile/widgets/kategoriDokter.dart';
import 'package:pa_mobile/widgets/rekomendasiDokter.dart';

class AccountPage extends StatelessWidget {
  AccountPage({Key? key});

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _logout(BuildContext context) async {
    try {
      await _auth.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } catch (e) {
      print('Error logging out: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double containerHeight = screenHeight * 0.2;

    return Scaffold(
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      'Hello, User!',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Add navigation to the edit page
                    },
                    child: 
                    Text(
                        'Edit',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Container(
              height: containerHeight,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color(0xFFB12856),
              ),
              child: Center(
                child: Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: Image.asset(
                          'assets/mikasa.png',
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Diky Dwicandra',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10,),
                          Text(
                            '081233218712',
                            style: TextStyle(
                              color: Colors.grey[300],
                              fontSize: 16,
                              fontWeight: FontWeight.normal
                            ),
                          ),
                          SizedBox(height: 10,),
                          Text(
                            'Laki - Laki',
                            style: TextStyle(
                              color: Colors.grey[300],
                              fontSize: 16,
                              fontWeight: FontWeight.normal
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: const Text(
              "Ingin melakukan sesuatu?",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          cardAccount('Riwayat Reservasi', Icons.arrow_forward, Icons.history, () {
            
          }),
          cardAccount('Jadwal Reservasi', Icons.arrow_forward, Icons.calendar_month, () {
            
          }),
          cardAccount('Tentang Aplikasi', Icons.arrow_forward, Icons.info, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AboutPage()),
            );
          }),
          cardAccount('Logout', Icons.arrow_forward, Icons.logout, () {
            _logout(context);
          }),
        ],
      ),
    );
  }

  Widget cardAccount(String text, IconData arrowIcon, IconData leftIcon, VoidCallback onPressed) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      color: Color(0xFFB12856),
      child: ListTile(
        leading: Icon(
          leftIcon,
          color: Colors.white,
        ),
        title: Text(text, style: TextStyle(color: Colors.white)),
        trailing: Icon(
          arrowIcon,
          color: Colors.white,
        ),
        onTap: onPressed,
      ),
    );
  }
}
