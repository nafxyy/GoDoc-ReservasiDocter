import 'package:flutter/material.dart';
import 'package:pa_mobile/pages/detail_doctor.dart';
import 'package:pa_mobile/providers/DocIDprovider.dart';
import 'package:pa_mobile/providers/theme.dart';
import 'package:provider/provider.dart';

class DoctorCard extends StatelessWidget {
  final String? image;
  final String name;
  final String jenis;
  final String hospital;
  final String review;
  final String doctor_id;

  DoctorCard({
    required this.image,
    required this.name,
    required this.jenis,
    required this.hospital,
    required this.review,
    required this.doctor_id,
  });

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double imageHeight = screenHeight * 0.15;

    return GestureDetector(
      onTap: () {
        Provider.of<DoctorIdProvider>(context, listen: false)
            .setSelectedDoctorId(doctor_id);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DoctorDetail(),
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
              child: ClipOval(
                child: image != null
                    ? Image.network(
                        image!,
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
                      style: TextStyle(color: Colors.grey,fontSize: 15),
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
