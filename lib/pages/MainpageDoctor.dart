import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pa_mobile/providers/theme.dart';
import 'package:provider/provider.dart';

// Widget utama untuk tampilan dokter
class MainDoctor extends StatelessWidget {
  const MainDoctor({super.key});

  @override
  Widget build(BuildContext context) {
    // Mengambil instance dari provider tema
    Tema tema = Provider.of<Tema>(context);
    double screenHeight = MediaQuery.of(context).size.height;
    double containerHeight = screenHeight * 0.2;

    return Scaffold(
      backgroundColor: tema.isDarkMode
          ? tema.display().scaffoldBackgroundColor
          : tema.displaydark().scaffoldBackgroundColor,
      body: ListView(
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
                        'Hello, Doctor!',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Are You Ready To Work?',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(
                      tema.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      tema.toggleTheme();
                    },
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                            'KESEHATAN',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'PASIEN',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'NOMOR 1',
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
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
            child: Text(
              "Jadwal Reservasi Pasien",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Gunakan widget ReservationCard di sini
          ReservationCard(),
        ],
      ),
    );
  }
}

// Widget untuk menampilkan kartu reservasi
class ReservationCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Mendapatkan ID dokter dari pengguna saat ini
    String idDokter = FirebaseAuth.instance.currentUser!.uid;

    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('reservations')
          .where('id_dokter', isEqualTo: idDokter)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data == null) {
          return Text('Tidak ada data reservasi ditemukan');
        } else {
          var reservations = snapshot.data!.docs;

          // Convert the list of reservations to a list of maps
          List<Map<String, dynamic>> reservationsList =
              reservations.map((reservation) {
            return {
              'tanggal': reservation['tanggal'],
              'jam': reservation['jam'],
              'user_id': reservation['user_id'],
            };
          }).toList();

          // Sort the list of reservations based on the 'tanggal' and 'jam' fields
          reservationsList.sort((a, b) {
            // Compare 'tanggal' first
            int tanggalComparison = a['tanggal'].compareTo(b['tanggal']);

            // If 'tanggal' is the same, compare 'jam'
            return tanggalComparison == 0
                ? a['jam'].compareTo(b['jam'])
                : tanggalComparison;
          });

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: reservationsList.map((reservation) {
              String tanggal = reservation['tanggal'];
              String jam = reservation['jam'];
              String userId = reservation['user_id'];

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('Patients')
                    .doc(userId)
                    .get(),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (userSnapshot.hasError) {
                    return Text('Error: ${userSnapshot.error}');
                  } else if (!userSnapshot.hasData ||
                      userSnapshot.data == null) {
                    return Text('Data pasien tidak ditemukan');
                  } else {
                    var userData = userSnapshot.data!;
                    String name = userData['nama'];
                    String telepon = userData['telepon'];

                    return Card(
                      margin: EdgeInsets.all(16.0),
                      color: const Color(0xFFB12856),
                      child: ListTile(
                        title: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Tanggal: $tanggal\nJam: $jam.00',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Times New Roman',
                                    ),
                                  ),
                                  Text(
                                    'Pasien: $name\nTelepon: $telepon',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 20),
                            Image.asset(
                              'assets/Stetoskop.png', // Ganti dengan path gambar yang sesuai
                              width:
                                  100, // Sesuaikan dengan lebar gambar yang diinginkan
                              height:
                                  100, // Sesuaikan dengan tinggi gambar yang diinginkan
                              fit: BoxFit.contain,
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                },
              );
            }).toList(),
          );
        }
      },
    );
  }
}
