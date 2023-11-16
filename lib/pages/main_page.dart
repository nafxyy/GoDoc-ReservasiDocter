import 'package:flutter/material.dart';

import 'package:pa_mobile/widgets/kategoriDokter.dart';
import 'package:pa_mobile/widgets/rekomendasiDokter.dart';


class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double containerHeight = screenHeight * 0.2; // 20% of screen height

    return Scaffold(
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
                        'Hello, User!',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
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
                          name: 'Kelamin', imageUrl: 'assets/dokter.png')),
                  CategoryDokter(
                      jenisDokter: JenisDokter(
                          name: 'Kulit',
                          imageUrl: 'assets/dokter.png')),
                  CategoryDokter(
                      jenisDokter: JenisDokter(
                          name: 'Gigi',
                          imageUrl: 'assets/dokter.png')),
                  CategoryDokter(
                      jenisDokter: JenisDokter(
                          name: 'Mata',
                          imageUrl: 'assets/dokter.png')),
                          CategoryDokter(
                      jenisDokter: JenisDokter(
                          name: 'Organ Dalam',
                          imageUrl: 'assets/dokter.png')),
                          CategoryDokter(
                      jenisDokter: JenisDokter(
                          name: 'Anak',
                          imageUrl: 'assets/dokter.png')),
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
           for (var doctor in Doctors)
            DoctorCard(
              image: doctor.image,
              name: doctor.name,
              jenis: doctor.jenis,
              hospital: doctor.hospital,
              review: doctor.review,
            ),
        ],
      ),
    );
  }
}