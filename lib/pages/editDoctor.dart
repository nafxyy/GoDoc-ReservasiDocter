import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:pa_mobile/widgets/bottomNavbarDoctor.dart';
import 'package:path/path.dart' as path;

class EditDoctorPage extends StatefulWidget {
  @override
  _EditDoctorPageState createState() => _EditDoctorPageState();
}

class _EditDoctorPageState extends State<EditDoctorPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final picker = ImagePicker();

  File? _image;
  TextEditingController _jenisDokterController = TextEditingController();
  TextEditingController _namaDokterController = TextEditingController();
  TextEditingController _hargaDokterController = TextEditingController();
  TextEditingController _teleponDokterController = TextEditingController();
  TextEditingController _genderDokterController = TextEditingController();
  TextEditingController _rumahSakitDokterController = TextEditingController();

  List<String> selectedHours = [];

  @override
  void initState() {
    super.initState();
    _fetchDoctorData();
  }

  Future<void> _fetchDoctorData() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot doctorData =
            await _firestore.collection('doctors').doc(user.uid).get();

        setState(() {
          _jenisDokterController.text = doctorData['jenis'];
          _namaDokterController.text = doctorData['nama'];
          _hargaDokterController.text = doctorData['harga'];
          _teleponDokterController.text = doctorData['telepon'];
          _genderDokterController.text = doctorData['gender'];
          _rumahSakitDokterController.text = doctorData['rumah_sakit'];
          selectedHours = List<String>.from(doctorData['available_hours']);
        });
      }
    } catch (e) {
      print('Error fetching doctor data: $e');
    }
  }

  Future<void> _updateDoctorData() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('doctors').doc(user.uid).update({
          'jenis': _jenisDokterController.text,
          'nama': _namaDokterController.text,
          'harga': _hargaDokterController.text,
          'telepon': _teleponDokterController.text,
          'gender': _genderDokterController.text,
          'rumah_sakit': _rumahSakitDokterController.text,
          'available_hours': selectedHours,
        });

        await _uploadImage(user.uid);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Data Updated!'),
          ),
        );
      }
    } catch (e) {
      print('Error updating doctor data: $e');
    }
  }

  Future<void> _uploadImage(String userId) async {
    if (_image == null) {
      return;
    }

    try {
      String fileName =
          'doctor_images/$userId/$userId.${path.extension(_image!.path)}';
      Reference firebaseStorageRef =
          FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask = firebaseStorageRef.putFile(_image!);

      await uploadTask.whenComplete(() async {});
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  Future<void> _getImage() async {
    // ignore: deprecated_member_use
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  Widget _buildEditDoctorForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          GestureDetector(
            onTap: _getImage,
            child: ClipOval(
              child: CircleAvatar(
                radius: 50,
                backgroundColor:
                    Colors.grey[200], // Set background color as needed
                child: _image != null
                    ? Image.file(
                        _image!,
                        width: 70, // Adjust the width as needed
                        height: 70, // Adjust the height as needed
                        fit: BoxFit.cover, // Use BoxFit.cover for autofit
                      )
                    : Icon(
                        Icons.camera_alt,
                        size: 40,
                      ),
              ),
            ),
          ),
          TextField(
            controller: _namaDokterController,
            decoration: InputDecoration(
                labelText: 'Nama Dokter',
                labelStyle: TextStyle(
                    fontSize: 22, fontFamily: 'poppins', color: Colors.black)),
            style: TextStyle(
              color: Colors.black,
              fontSize: 26,
            ),
          ),
          DropdownButtonFormField<String>(
            value: _genderDokterController.text.isNotEmpty
                ? _genderDokterController.text
                : null,
            onChanged: (String? newValue) {
              setState(() {
                _genderDokterController.text = newValue!;
              });
            },
            items: [
              'Laki - Laki',
              'Perempuan',
            ].map((String specialization) {
              return DropdownMenuItem<String>(
                value: specialization,
                child: Text(specialization),
              );
            }).toList(),
            decoration: InputDecoration(
                labelText: 'Jenis Kelamin',
                labelStyle: TextStyle(
                    fontSize: 22, fontFamily: 'poppins', color: Colors.black)),
            style: TextStyle(
              color: Colors.black,
              fontSize: 26,
            ),
          ),
          TextField(
            controller: _hargaDokterController,
            decoration: InputDecoration(
              labelText: 'Harga',
              labelStyle: TextStyle(
                fontFamily: 'poppins',
                fontSize: 22,
              ),
            ),
            style: TextStyle(
              color: Colors.black,
              fontSize: 26,
            ),
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
            ],
          ),
          TextField(
            controller: _teleponDokterController,
            decoration: InputDecoration(
              labelText: 'Nomor Telepon',
              labelStyle: TextStyle(
                fontFamily: 'poppins',
                fontSize: 22,
              ),
            ),
            style: TextStyle(
              color: Colors.black,
              fontSize: 26,
            ),
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
            ],
          ),
          TextField(
            controller: _rumahSakitDokterController,
            decoration: InputDecoration(
              labelText: 'Rumah Sakit',
              labelStyle: TextStyle(
                fontFamily: 'poppins',
                fontSize: 22,
              ),
            ),
            style: TextStyle(
              color: Colors.black,
              fontSize: 26,
            ),
          ),
          DropdownButtonFormField<String>(
            value: _jenisDokterController.text.isNotEmpty
                ? _jenisDokterController.text
                : null,
            onChanged: (String? newValue) {
              setState(() {
                _jenisDokterController.text = newValue!;
              });
            },
            items: [
              'THT',
              'Umum',
              'Anak',
              'Mata',
              'Kulit',
              'Gigi',
              'Organ Dalam'
            ].map((String specialization) {
              return DropdownMenuItem<String>(
                value: specialization,
                child: Text(specialization),
              );
            }).toList(),
            decoration: InputDecoration(
              labelText: 'Jenis Spesialisasi',
              labelStyle: TextStyle(
                fontFamily: 'poppins',
                fontSize: 25,
              ),
            ),
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          SizedBox(height: 16.0),
          Text('Pilih Jam Praktek:', style: TextStyle(fontSize: 18)),
          SizedBox(height: 8.0),
          _buildHourSelection(),
          SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () {
              _updateDoctorData();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BottomNavDoctor()),
              );
            },
            child: Text(
              'Update Data',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'poppins',
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFB12856),
        title: Text(
          'Edit Doctor',
          style: TextStyle(
            color: Colors.black,
            fontSize: 25,
            fontWeight: FontWeight.bold,
            fontFamily: 'poppins',
          ),
        ),
      ),
      body: _buildEditDoctorForm(),
    );
  }

  Widget _buildHourSelection() {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: List.generate(
        24,
        (index) {
          final hour = index.toString().padLeft(2, '0');
          final isSelected = selectedHours.contains(hour);
          return InkWell(
            onTap: () {
              setState(() {
                if (isSelected) {
                  selectedHours.remove(hour);
                } else {
                  selectedHours.add(hour);
                }
              });
            },
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFB12856) : Colors.grey,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Center(
                child: Text(
                  hour,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
