import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:pa_mobile/providers/DocIDprovider.dart';
import 'package:pa_mobile/widgets/bottomNavbar.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class DoctorDetail extends StatefulWidget {
  @override
  State<DoctorDetail> createState() => _DoctorDetailState();
}

class _DoctorDetailState extends State<DoctorDetail> {
  String selectedDate = "";
  String selectedHour = "";
  String idDokter = "";
  final _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isFavorite = false;

  Future<void> _bookDoctor() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        // Check if the selected date and time are already booked
        bool isAlreadyBooked = await _isAlreadyBooked();

        if (isAlreadyBooked) {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Error'),
                content: Text(
                    'Doctor is already booked for the selected date and time.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        } else {
          // Create a new document in the 'reservations' collection
          await _firestore.collection('reservations').add({
            'user_id': user.uid,
            'tanggal': selectedDate,
            'jam': selectedHour,
            'id_dokter': idDokter,
          });

          print('Doctor booked successfully!');
          // ignore: use_build_context_synchronously
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Success'),
                content: Text('Doctor Booked'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NavScreen(),
                        ),
                      );
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        }
      }
    } catch (e) {
      print('Error saving doctor data: $e');
    }
  }

  // Function to toggle the favorite status
  Future<void> _toggleFavorite() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        // Check if the doctor is already in favorites
        bool isAlreadyFavorite = await _isAlreadyFavorite();

        if (isAlreadyFavorite) {
          // Remove from favorites
          await _firestore
              .collection('favorites')
              .doc(user.uid)
              .collection('doctors')
              .doc(idDokter)
              .delete();
          setState(() {
            isFavorite = false;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Dokter Berhasil Dihapus Dari Favorit'),
              ),
            );
          });
        } else {
          // Add to favorites
          await _firestore
              .collection('favorites')
              .doc(user.uid)
              .collection('doctors')
              .doc(idDokter)
              .set({});
          setState(() {
            isFavorite = true;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Dokter Berhasil Ditambahkan Ke Favorit'),
              ),
            );
          });
        }
      } catch (e) {
        print('Error toggling favorite: $e');
      }
    }
  }

  // Function to check if the doctor is already in favorites
  Future<bool> _isAlreadyFavorite() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot favoriteSnapshot = await _firestore
            .collection('favorites')
            .doc(user.uid)
            .collection('doctors')
            .doc(idDokter)
            .get();

        return favoriteSnapshot.exists;
      } catch (e) {
        print('Error checking existing favorites: $e');
        throw e;
      }
    }
    return false;
  }

// Function to check if the selected date and time are already booked
  Future<bool> _isAlreadyBooked() async {
    try {
      QuerySnapshot reservationSnapshot = await FirebaseFirestore.instance
          .collection('reservations')
          .where('tanggal', isEqualTo: selectedDate)
          .where('jam', isEqualTo: selectedHour)
          .where('id_dokter', isEqualTo: idDokter)
          .get();

      return reservationSnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking existing reservations: $e');
      throw e;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Assuming you have a DoctorIdProvider in your app
    final doctorIdProvider = Provider.of<DoctorIdProvider>(context);
    final String doctorId = doctorIdProvider.selectedDoctorId;
    idDokter = doctorId;

    return FutureBuilder<DocumentSnapshot>(
      future:
          FirebaseFirestore.instance.collection('doctors').doc(doctorId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data == null) {
          return Text('Doctor data not found');
        } else {
          var doctorData = snapshot.data!;
          String name = doctorData['nama'];
          String jenis = doctorData['jenis'];
          String hospital = doctorData['rumah_sakit'];
          List<dynamic> availableHours = doctorData['available_hours'];
          String telepon = doctorData['telepon'];
          String harga = doctorData['harga'];
          String imageFileName = doctorId;

          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              title: Text('Doctor Details'),
              actions: [
                IconButton(
                  color: Colors.black,
                  icon: Icon(Icons.favorite),
                  onPressed: _toggleFavorite,
                ),
                IconButton(
                  color: Colors.black,
                  icon: Icon(Icons.share),
                  onPressed: () {
                    // Share
                  },
                ),
              ],
            ),
            body: ListView(
              children: [
                Card(
                  margin: EdgeInsets.all(16.0),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          flex: 1,
                          child: _buildDoctorImage(
                              context, imageFileName), // Load doctor's image
                        ),
                        Expanded(
                          flex: 2,
                          child: ListTile(
                            title: Text(
                              name,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 20.0, // Set the font size as needed
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 5.0),
                                  child: Text(
                                    '$jenis | $hospital',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 5.0),
                                      child: Text(
                                        ' $telepon',
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 5.0),
                                      child: Text(
                                        'Rp. $harga',
                                        style: TextStyle(
                                          color: Color(0xFFB12856),
                                          fontSize:
                                              22.0, // Set the font size as needed
                                        ),
                                      ),
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
                ),
                // Add the "Tanggal" text
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Tanggal $selectedDate',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // Add a container to display the dates
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        // Calculate the date for the next 5 days
                        DateTime currentDate =
                            DateTime.now().add(Duration(days: index));
                        // Format the date as needed
                        String formattedDate =
                            DateFormat('yyyy-MM-dd').format(currentDate);

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedDate = formattedDate;
                            });
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 8.0),
                            padding: EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: selectedDate == formattedDate
                                  ? Colors.blue // Change the color as needed
                                  : Colors.grey[300],
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Center(
                              child: Text(
                                formattedDate,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: selectedDate == formattedDate
                                      ? Colors
                                          .white // Change the text color as needed
                                      : Colors.black,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          'Jam Praktek$selectedHour',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: availableHours.map((hour) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedHour = hour;
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: selectedHour == hour
                                    ? Colors.blue // Change the color as needed
                                    : Colors.grey[300],
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Text(
                                '$hour.00',
                                style: TextStyle(
                                  color: selectedHour == hour
                                      ? Colors
                                          .white // Change the text color as needed
                                      : Colors.black,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed:
                        (selectedDate.isNotEmpty && selectedHour.isNotEmpty)
                            ? _bookDoctor
                            : null,
                    child: Text('Book Doctor'),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _buildDoctorImage(BuildContext context, String imageFileName) {
    final double imageHeight = MediaQuery.of(context).size.height * 0.15;
    Future<String?> _getDoctorImageURL(String doctorId) async {
      try {
        // Your existing code to retrieve the download URL
        ListResult listResult = await FirebaseStorage.instance
            .ref()
            .child('doctor_images/$doctorId')
            .list();

        if (listResult.items.isNotEmpty) {
          return await listResult.items.first.getDownloadURL();
        } else {
          return null;
        }
      } catch (e) {
        print('Error fetching doctor image: $e');
        return null;
      }
    }

    return FutureBuilder<String?>(
      future: _getDoctorImageURL(imageFileName),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          print('Error loading image: ${snapshot.error}');
          return Text('Error loading image');
        } else {
          final imageUrl = snapshot.data;

          return ClipOval(
            child: imageUrl != null
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
          );
        }
      },
    );
  }
}
