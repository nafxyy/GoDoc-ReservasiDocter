import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:pa_mobile/widgets/rekomendasiDokter.dart';

class FilterDokter extends StatelessWidget {
  final String nama;

  FilterDokter({required this.nama, Key? key}) : super(key: key);

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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFB12856),
        title: Text(
          "Dokter Berdasarkan Kategori",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'poppins',
          ),
        ),
      ),
      body: FutureBuilder(
        future: FirebaseFirestore.instance
            .collection('doctors')
            .where('jenis', isEqualTo: nama)
            .get(),
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
                  child: const Text(
                    "Filter Dokter",
                    style: TextStyle(
                      color: Colors.black,
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
