import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:pa_mobile/providers/DocIDprovider.dart';
import 'package:pa_mobile/providers/theme.dart';
import 'package:pa_mobile/widgets/bottomNavbar.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class DoctorDetail extends StatefulWidget {
  @override
  State<DoctorDetail> createState() => _DoctorDetailState();
}

class _DoctorDetailState extends State<DoctorDetail> {
  // Variables to store selected date, selected hour, and doctor ID
  String selectedDate = "";
  String selectedHour = "";
  String idDokter = "";

  // Firebase authentication and Firestore instances
  final _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Variable to track whether the doctor is a favorite
  bool isFavorite = false;

  // Function to handle booking a doctor
  Future<void> _bookDoctor() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        // Check if the selected date and time are already booked
        bool isAlreadyBooked = await _isAlreadyBooked();

        if (isAlreadyBooked) {
          // Display an error dialog if the doctor is already booked
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text(
                  'Error',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontFamily: 'poppins',
                  ),
                ),
                content: Text(
                  'Doctor is already booked for the selected date and time.',
                  style: TextStyle(
                    fontFamily: 'poppins',
                    color: Colors.black,
                  ),
                ),
                backgroundColor: const Color.fromARGB(255, 217, 217, 217),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'OK',
                      style: TextStyle(
                        fontFamily: 'poppins',
                        color: Colors.black,
                    fontWeight: FontWeight.bold,
                      ),
                    ),
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

          // Display success dialog and navigate to the home screen
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text(
                  'Success',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontFamily: 'poppins',
                  ),
                ),
                content: Text(
                  'Doctor Booked',
                  style: TextStyle(
                    fontFamily: 'poppins',
                    color: Colors.black,
                  ),
                ),
                backgroundColor: const Color.fromARGB(255, 217, 217, 217),
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
                    child: Text('OK',
                    style: TextStyle(
                        fontFamily: 'poppins',
                        color: Colors.black,
                    fontWeight: FontWeight.bold,
                      ),
                      ),
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
      // Query reservations based on selected date, time, and doctor ID
      QuerySnapshot reservationSnapshot = await FirebaseFirestore.instance
          .collection('reservations')
          .where('tanggal', isEqualTo: selectedDate)
          .where('jam', isEqualTo: selectedHour)
          .where('id_dokter', isEqualTo: idDokter)
          .get();

      // Check if there are any reservations for the selected date and time
      return reservationSnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking existing reservations: $e');
      throw e;
    }
  }

  @override
  Widget build(BuildContext context) {
    Tema tema = Provider.of<Tema>(context);
    final doctorIdProvider = Provider.of<DoctorIdProvider>(context);
    final String doctorId = doctorIdProvider.selectedDoctorId;
    idDokter = doctorId;
    TextTheme textTheme = tema.isDarkMode ? tema.teks : tema.teksdark;

    return FutureBuilder<DocumentSnapshot>(
      // Fetch doctor data based on the selected doctor ID
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
          // Extract doctor details from the document snapshot
          var doctorData = snapshot.data!;
          String name = doctorData['nama'];
          String jenis = doctorData['jenis'];
          String hospital = doctorData['rumah_sakit'];
          List<dynamic> availableHours = doctorData['available_hours'];
          String telepon = doctorData['telepon'];
          String harga = doctorData['harga'];
          String imageFileName = doctorId;

          return Scaffold(
            backgroundColor: tema.isDarkMode
                ? tema.display().scaffoldBackgroundColor
                : tema.displaydark().scaffoldBackgroundColor,
            appBar: AppBar(
              backgroundColor: const Color(0xFFB12856),
              title: Text(
                'Doctor Details',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'poppins',
                ),
              ),
              actions: [
                // Favorite button
                IconButton(
                  icon: Icon(Icons.favorite),
                  onPressed: _toggleFavorite,
                ),
                // Share button
                IconButton(
                  icon: Icon(Icons.share),
                  onPressed: () {
                    // Share functionality
                  },
                ),
              ],
            ),
            body: Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      // Doctor details card
                      Card(
                        margin: EdgeInsets.all(16.0),
                        color: const Color(0xFFB12856),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: <Widget>[
                              // Doctor's image
                              Expanded(
                                flex: 1,
                                child: _buildDoctorImage(context,
                                    imageFileName), // Load doctor's image
                              ),
                              // Doctor's information
                              Expanded(
                                flex: 2,
                                child: ListTile(
                                  title: Text(
                                    name,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'poppins',
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Doctor's type and hospital
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 5.0),
                                        child: Text(
                                          '$jenis | $hospital',
                                          style: TextStyle(
                                            color: Colors.grey[300],
                                            fontSize: 21,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'poppins',
                                          ),
                                        ),
                                      ),
                                      // Doctor's contact number
                                      Row(
                                        children: [
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 5.0),
                                            child: Text(
                                              ' $telepon',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'poppins',
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      // Doctor's consultation fee
                                      Row(
                                        children: [
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 5.0),
                                            child: Text(
                                              'Rp. $harga',
                                              style: TextStyle(
                                                color: Colors.grey[300],
                                                fontSize: 22.0,
                                                fontFamily: 'poppins',
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

                      // Menambahkan teks "Tanggal"
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Tanggal ',
                          style: textTheme.bodySmall,
                        ),
                      ),
// Menambahkan container untuk menampilkan tanggal-tanggal
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          height: 50,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: 5,
                            itemBuilder: (context, index) {
                              // Menghitung tanggal untuk 5 hari ke depan
                              DateTime currentDate =
                                  DateTime.now().add(Duration(days: index));
                              // Memformat tanggal sesuai kebutuhan
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
                                        ? const Color(0xFFB12856)
                                        : Colors.grey[300],
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Center(
                                    child: Text(
                                      formattedDate,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'poppins',
                                        color: selectedDate == formattedDate
                                            ? Colors
                                                .white // Ganti warna teks sesuai kebutuhan
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

// Bagian Jam Praktek
                      Container(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Menambahkan teks "Jam Praktek" dengan jam yang dipilih
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: Text(
                                'Jam Praktek',
                                style: textTheme.bodySmall,
                              ),
                            ),
                            SizedBox(height: 8.0),
                            // Menampilkan jam-jam yang tersedia
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
                                          ? const Color(0xFFB12856)
                                          // Ganti warna sesuai kebutuhan
                                          : Colors.grey[300],
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: Text(
                                      '$hour.00',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'poppins',
                                        color: selectedHour == hour
                                            ? Colors
                                                .white // Ganti warna teks sesuai kebutuhan
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

// Tombol untuk memesan dokter
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ElevatedButton(
                          onPressed: (selectedDate.isNotEmpty &&
                                  selectedHour.isNotEmpty)
                              ? _bookDoctor
                              : null,
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.resolveWith<Color>(
                              (Set<MaterialState> states) {
                                if (states.contains(MaterialState.disabled)) {
                                  // Color when the button is disabled
                                  return Colors.grey;
                                }
                                // Color when the button is enabled
                                return const Color(0xFFB12856);
                              },
                            ),
                          ),
                          child: Text(
                            'BOOK DOCTOR',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'poppins',
                            ),
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
      },
    );
  }

  // Widget to build the doctor's image
  Widget _buildDoctorImage(BuildContext context, String imageFileName) {
    // Calculate the image height based on the screen height
    final double imageHeight = MediaQuery.of(context).size.height * 0.15;

    // Function to get the doctor's image URL from Firebase Storage
    Future<String?> _getDoctorImageURL(String doctorId) async {
      try {
        // Retrieve the download URL for the doctor's image
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

    // FutureBuilder to asynchronously load the doctor's image
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

          // Display the doctor's image in a circular clip
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
