import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pa_mobile/pages/detail_doctor.dart';
import 'package:pa_mobile/providers/DocIDprovider.dart';
import 'package:provider/provider.dart';

import '../providers/theme.dart';

class FavoritePage extends StatelessWidget {
  FavoritePage({Key? key});
  final FirebaseStorage _storage = FirebaseStorage.instance;
  @override
  Widget build(BuildContext context) {
    Tema tema = Provider.of<Tema>(context);
    return Scaffold(
      backgroundColor: tema.isDarkMode
          ? tema.display().scaffoldBackgroundColor
          : tema.displaydark().scaffoldBackgroundColor,
      body: FutureBuilder<List<String>>(
        future: _fetchFavoriteDoctorIds(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('No favorite doctors found'));
          } else {
            List<String> favoriteDoctorIds = snapshot.data!;

            return ListView(
              padding: EdgeInsets.all(16.0),
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
                              'Here\'s your favorite',
                              style: TextStyle(
                                
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Doctors!',
                              style: TextStyle(
                                
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: const Text(
                    "Dokter Favorite Anda",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
                for (var doctorId in favoriteDoctorIds)
                  FutureBuilder<DocumentSnapshot>(
                    future: _fetchDoctorDetails(doctorId),
                    builder: (context, doctorSnapshot) {
                      if (doctorSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (doctorSnapshot.hasError) {
                        return Text('Error: ${doctorSnapshot.error}');
                      } else if (!doctorSnapshot.hasData ||
                          doctorSnapshot.data == null) {
                        return Text('Doctor details not found');
                      } else {
                        var doctorData = doctorSnapshot.data!;
                        return _buildDoctorCard(
                            doctorData['nama'],
                            doctorData['jenis'],
                            doctorData['rumah_sakit'],
                            doctorId,
                            context);
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

  Future<List<String>> _fetchFavoriteDoctorIds() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Fetch the 'doctors' subcollection under the user's 'favorites' document
        QuerySnapshot favoriteSnapshot = await FirebaseFirestore.instance
            .collection('favorites')
            .doc(user.uid)
            .collection('doctors')
            .get();

        // Extract the doctor IDs from the documents in the 'doctors' subcollection
        List<String> favoriteDoctorIds = favoriteSnapshot.docs
            .map(
                (doc) => doc.id) // Assuming the document IDs are the doctor IDs
            .toList();

        return favoriteDoctorIds;
      }

      return [];
    } catch (e) {
      print('Error fetching favorite doctor IDs: $e');
      throw e;
    }
  }

  Future<DocumentSnapshot> _fetchDoctorDetails(String doctorId) async {
    try {
      return await FirebaseFirestore.instance
          .collection('doctors')
          .doc(doctorId)
          .get();
    } catch (e) {
      print('Error fetching doctor details: $e');
      throw e;
    }
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

  Widget _buildDoctorCard(
    String name,
    String jenis,
    String hospital,
    String doctorId,
    BuildContext context,
  ) {
    double screenHeight = MediaQuery.of(context).size.height;
    double imageHeight = screenHeight * 0.15;

    return FutureBuilder<String?>(
      future: _getDoctorImageURL(doctorId),
      builder: (context, imageSnapshot) {
        String imageUrl = imageSnapshot.data ?? '';

        return GestureDetector(
          onTap: () {
            Provider.of<DoctorIdProvider>(context, listen: false)
                .setSelectedDoctorId(doctorId);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DoctorDetail(),
              ),
            );
          },
          child: Card(
            margin: EdgeInsets.symmetric(vertical: 8.0),
            // color: Color(0xFFB12856),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: ClipOval(
                    child: imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            height: imageHeight,
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            'assets/dokter.png',
                            height: imageHeight,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: ListTile(
                    title: Text(
                      name,
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$jenis | $hospital',
                          style: TextStyle(color: Colors.grey),
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              color: Colors.yellow,
                              size: 16,
                            ),
                            Text(
                              ' 5.0',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
