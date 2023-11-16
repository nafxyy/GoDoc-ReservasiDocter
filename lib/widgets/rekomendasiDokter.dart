import 'package:flutter/material.dart';
import 'package:pa_mobile/pages/akhir.dart';

class Doctor {
  final String image;
  final String name;
  final String jenis;
  final String hospital;
  final String review;

  Doctor({
    required this.image,
    required this.name,
    required this.jenis,
    required this.hospital,
    required this.review,
  });
}

class DoctorCard extends StatelessWidget {
  final String image;
  final String name;
  final String jenis;
  final String hospital;
  final String review;

  DoctorCard({
    required this.image,
    required this.name,
    required this.jenis,
    required this.hospital,
    required this.review,
  });

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double imageHeight = screenHeight * 0.15;

    return GestureDetector(
      onTap: () {
        // Navigate to the other screen here
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailDokter(),
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.all(16.0),
        color: Color(0xFFB12856),
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Image.asset(
                'assets/$image.png',
                height: imageHeight,
                fit: BoxFit.contain,
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
                          ' $review',
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
  }
}

final Doctors = [
  Doctor(
    image: 'dokter',
    name: 'Dr. A',
    jenis: 'Umum',
    hospital: 'City Hospital',
    review: '5.0',
  ),
  Doctor(
    image: 'dokter',
    name: 'Dr. B',
    jenis: 'Organ Dalam',
    hospital: 'General Hospital',
    review: '4.3',
  ),
  Doctor(
    image: 'dokter',
    name: 'Dr. C',
    jenis: 'Anak',
    hospital: 'Children\'s Clinic',
    review: '4.7',
  ),
  Doctor(
    image: 'dokter',
    name: 'Dr. D',
    jenis: 'Kulit',
    hospital: 'Skin Care Center',
    review: '5',
  ),
];
