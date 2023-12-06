import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pa_mobile/providers/theme.dart';
import 'package:provider/provider.dart';

class MainDoctor extends StatelessWidget {
  const MainDoctor({super.key});

  @override
  Widget build(BuildContext context) {
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
                          width: double.infinity, // Take the available width
                          height: double.infinity, // Take the available height
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
          // Use ReservationCard widget here
          ReservationCard(),
        ],
      ),
    );
  }
}

class ReservationCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
          return Text('No reservation data found');
        } else {
          var reservations = snapshot.data!.docs;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: reservations.map((reservation) {
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
                    return Text('Patient data not found');
                  } else {
                    var userData = userSnapshot.data!;
                    String name = userData['nama'];
                    String telepon = userData['telepon'];

                    return Card(
                      margin: EdgeInsets.all(16.0),
                      color: Colors.grey[200],
                      child: ListTile(
                        title: Text('Tanggal: $tanggal\nJam: $jam.00'),
                        subtitle: Text('Pasien: $name\nTelepon: $telepon'),
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
