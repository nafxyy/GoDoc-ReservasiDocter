import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pa_mobile/providers/theme.dart';
import 'package:provider/provider.dart';

class RiwayatPage extends StatefulWidget {
  RiwayatPage({Key? key}) : super(key: key);

  @override
  _RiwayatPageState createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    Tema tema = Provider.of<Tema>(context);
    TextTheme textTheme = tema.isDarkMode ? tema.teks : tema.teksdark;
    return Scaffold(
      backgroundColor: tema.isDarkMode
          ? tema.display().scaffoldBackgroundColor
          : tema.displaydark().scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFFB12856),
        title: Text(
          "Riwayat Reservasi",
          style: TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.bold,
            fontFamily: 'poppins',
          ),
        ),
      ),
      body: FutureBuilder(
        future: _getReservations(),
        builder: (context, AsyncSnapshot<List<Reservation>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Text('No reservation data found');
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Reservation reservation = snapshot.data![index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reservation.tanggal,
                        style: textTheme.bodySmall,
                      ),
                      FutureBuilder(
                        future: _getDoctorDetails(reservation.doctorId),
                        builder: (context,
                            AsyncSnapshot<DoctorDetails> doctorSnapshot) {
                          if (doctorSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (doctorSnapshot.hasError) {
                            return Text('Error: ${doctorSnapshot.error}');
                          } else if (!doctorSnapshot.hasData ||
                              doctorSnapshot.data == null) {
                            return Text('Doctor details not found');
                          } else {
                            return cardAccount(
                              'Dokter ${doctorSnapshot.data!.name} | ${doctorSnapshot.data!.hospital}',
                              reservation.jam, // Pass the jam parameter
                              Icons.arrow_forward,
                              () {
                                // onTap function
                              },
                            );
                          }
                        },
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  Widget cardAccount(String hospitalName, String jam, IconData arrowIcon,
      VoidCallback onPressed) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      color: Color(0xFFB12856),
      child: ListTile(
        title: Text(
          hospitalName,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white,
          ),
        ),
        subtitle: Text(
          'Jam: $jam.00',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Future<List<Reservation>> _getReservations() async {
  try {
    User? user = _auth.currentUser;
    if (user != null) {
      QuerySnapshot reservationSnapshot = await FirebaseFirestore.instance
          .collection('reservations')
          .where('user_id', isEqualTo: user.uid)
          .get();

      List<Reservation> reservations =
          await Future.wait(reservationSnapshot.docs.map((doc) async {
        return Reservation(
          tanggal: doc['tanggal'],
          doctorId: doc['id_dokter'],
          jam: doc['jam'],
        );
      }));

      // Sort the reservations list based on tanggal and jam
      reservations.sort((a, b) {
        // First, compare by tanggal
        int tanggalComparison = a.tanggal.compareTo(b.tanggal);
        if (tanggalComparison != 0) {
          return tanggalComparison;
        }
        // If tanggal is the same, compare by jam
        return a.jam.compareTo(b.jam);
      });

      return reservations;
    } else {
      return [];
    }
  } catch (e) {
    print('Error fetching reservation data: $e');
    return [];
  }
}



  Future<DoctorDetails> _getDoctorDetails(String doctorId) async {
    try {
      DocumentSnapshot doctorSnapshot = await FirebaseFirestore.instance
          .collection('doctors')
          .doc(doctorId)
          .get();

      return DoctorDetails(
        name: doctorSnapshot['nama'],
        hospital: doctorSnapshot['rumah_sakit'],
      );
    } catch (e) {
      print('Error fetching doctor details: $e');
      throw e;
    }
  }
}

class Reservation {
  final String tanggal;
  final String doctorId;
  final String jam;

  Reservation({
    required this.tanggal,
    required this.doctorId,
    required this.jam,
  });
}

class DoctorDetails {
  final String name;
  final String hospital;

  DoctorDetails({
    required this.name,
    required this.hospital,
  });
}
