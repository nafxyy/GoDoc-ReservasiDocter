import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'package:pa_mobile/widgets/kategoriDokter.dart';
import 'package:pa_mobile/widgets/rekomendasiDokter.dart';

class MainPage extends StatelessWidget {
  MainPage({super.key});

  final FirebaseStorage _storage = FirebaseStorage.instance;

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

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double containerHeight = screenHeight * 0.2; // 20% of screen height

    return Scaffold(
      body: FutureBuilder(
        future: FirebaseFirestore.instance.collection('doctors').get(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator(); // Loading indicator while fetching data
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello, User!',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'How are you today?',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.notifications,
                            color: Colors.black,
                          ),
                          onPressed: () {
                            // Notification
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
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
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'PESAN',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'DOKTER-MU',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  'SEKARANG',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 20),
                          Expanded(
                            child: Center(
                              child: Image.asset(
                                'assets/dokter.png',
                                width:
                                    double.infinity, // Take the available width
                                height: double
                                    .infinity, // Take the available height
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
                  child: Text(
                    "Jenis Dokter",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.2,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        CategoryDokter(
                            jenisDokter: JenisDokter(
                                name: 'Umum', imageUrl: 'assets/dokter.png')),
                        CategoryDokter(
                            jenisDokter: JenisDokter(
                                name: 'THT', imageUrl: 'assets/dokter.png')),
                        CategoryDokter(
                            jenisDokter: JenisDokter(
                                name: 'Kulit', imageUrl: 'assets/dokter.png')),
                        CategoryDokter(
                            jenisDokter: JenisDokter(
                                name: 'Gigi', imageUrl: 'assets/dokter.png')),
                        CategoryDokter(
                            jenisDokter: JenisDokter(
                                name: 'Mata', imageUrl: 'assets/dokter.png')),
                        CategoryDokter(
                            jenisDokter: JenisDokter(
                                name: 'Organ Dalam',
                                imageUrl: 'assets/dokter.png')),
                        CategoryDokter(
                            jenisDokter: JenisDokter(
                                name: 'Anak', imageUrl: 'assets/dokter.png')),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: const Text(
                    "Rekomendasi Dokter",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                for (var doctorDoc in snapshot.data!.docs)
                  FutureBuilder(
                    future: _getDoctorImageURL(doctorDoc.id),
                    builder: (BuildContext context,
                        AsyncSnapshot<String?> imageSnapshot) {
                      if (imageSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (imageSnapshot.hasError) {
                        return Text('Error: ${imageSnapshot.error}');
                      } else {
                        return DoctorCard(
                          image: imageSnapshot.data != null
                              ? '${imageSnapshot.data}' 
                              : null,
                          name: doctorDoc['nama'],
                          jenis: doctorDoc['jenis'],
                          hospital: doctorDoc['rumah_sakit'],
                          review: '5.0',
                          doctor_id: doctorDoc.id,
                        );
                      }
                    },
                  ),
              ],
            );
          }
        },
      ),
    );
  }
}
