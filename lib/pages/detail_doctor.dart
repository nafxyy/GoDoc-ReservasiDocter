import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pa_mobile/providers/DocIDprovider.dart';
import 'package:provider/provider.dart';

class DoctorDetail extends StatelessWidget {
  const DoctorDetail({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Doctor Details'),
        actions: [
          IconButton(
            color: Colors.black,
            icon: Icon(Icons.favorite),
            onPressed: () {
              // Favorite
            },
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
       
      ),
    );
  }
}

class DoctorProfile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Access the DoctorIdProvider
    final doctorIdProvider = Provider.of<DoctorIdProvider>(context);

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('doctors') // Replace with your Firestore collection name
          .doc(doctorIdProvider.selectedDoctorId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data == null) {
          return Text('Doctor data not found');
        } else {
          var doctorData = snapshot.data;
          return Container(
            margin: EdgeInsets.all(10.0),
            padding: EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // First Column: Image Profile
                Container(
                  width: 100.0,
                  height: 100.0,
                  margin: EdgeInsets.only(right: 20.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: NetworkImage(doctorData?['profileImageUrl']),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Second Column: Doctor Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctorData?['doctorName'],
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Text('Specialization: ${doctorData?['specialization']}'),
                      Text('Price: ${doctorData?['price']}'),
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
}