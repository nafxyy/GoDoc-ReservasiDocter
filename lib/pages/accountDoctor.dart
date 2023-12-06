import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pa_mobile/pages/editDoctor.dart';
import 'package:pa_mobile/pages/login.dart';
import 'package:pa_mobile/pages/about.dart';

class DoctorAccountPage extends StatelessWidget {
  DoctorAccountPage({Key? key});

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<Map<String, dynamic>> _fetchDoctorData() async {
    User user = _auth.currentUser!;
    try {
      DocumentSnapshot snapshot =
          await _firestore.collection('doctors').doc(user.uid).get();

      if (snapshot.exists) {
        return snapshot.data() as Map<String, dynamic>;
      }
    } catch (e) {
      print('Error fetching doctor data: $e');
    }

    // Return an empty map if data is not available or an error occurs
    return {};
  }

  Future<String?> _getDoctorImageURL(String userId) async {
    try {
      // Retrieve the list of items under the doctor_images/$userId path
      ListResult listResult =
          await _storage.ref().child('doctor_images/$userId').list();

      // Check if there are items in the list
      if (listResult.items.isNotEmpty) {
        // Retrieve the download URL for the first item in the list
        return await listResult.items.first.getDownloadURL();
      } else {
        // Return null if there are no items (no image found)
        return null;
      }
    } catch (e) {
      print('Error fetching doctor image: $e');
      return null;
    }
  }

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
    return FutureBuilder<Map<String, dynamic>>(
      future: _fetchDoctorData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        Map<String, dynamic> doctorData = snapshot.data ?? {};
        String userId = _auth.currentUser!.uid;

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
                        'Hello, ${doctorData['nama'] ?? 'Doctor'}!',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => EditDoctorPage()),
                          );
                        },
                        child: Text(
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Container(
                  height: 200, // Adjust the height as needed
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: const Color(0xFFB12856),
                  ),
                  child: FutureBuilder<String?>(
                    future: _getDoctorImageURL(userId),
                    builder: (context, imageSnapshot) {
                      if (imageSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      String? imageUrl = imageSnapshot.data;
                      return Row(
                        children: [
                          Expanded(
                            child: AspectRatio(
                              aspectRatio: 1.0,
                              child: ClipOval(
                                child: imageUrl != null
                                    ? Image.network(
                                        imageUrl,
                                        width: double.infinity,
                                        height: double.infinity,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.asset(
                                        'assets/dokter.png',
                                        width: double.infinity,
                                        height: double.infinity,
                                        fit: BoxFit.contain,
                                      ),
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
                                  doctorData['nama'] ?? 'Doctor Name',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  doctorData['telepon'] ?? '081233218712',
                                  style: TextStyle(
                                    color: Colors.grey[300],
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  doctorData['jenis'] ?? 'Laki - Laki',
                                  style: TextStyle(
                                    color: Colors.grey[300],
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
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
              cardAccount('Tentang Aplikasi', Icons.arrow_forward, Icons.info,
                  () {
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
      },
    );
  }

  Widget cardAccount(String text, IconData arrowIcon, IconData leftIcon,
      VoidCallback onPressed) {
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
