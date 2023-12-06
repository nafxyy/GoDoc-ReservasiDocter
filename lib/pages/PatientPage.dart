import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pa_mobile/widgets/bottomNavbar.dart';
import 'package:path/path.dart' as path;

class PatientPage extends StatefulWidget {
  @override
  _PatientPageState createState() => _PatientPageState();
}

class _PatientPageState extends State<PatientPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  File? _image;
  final picker = ImagePicker();

  TextEditingController _namaController = TextEditingController();
  TextEditingController _teleponController = TextEditingController();
  TextEditingController _genderController = TextEditingController();

  bool _isFirstTime = true;
  List<String> selectedHours = [];

  @override
  void initState() {
    super.initState();
    _checkPatientDataExists();
  }

  void didChangeDependencies() {
    super.didChangeDependencies();
    _genderController.text = 'Laki - Laki';
  }

  Future<void> _uploadImage(String userId) async {
    if (_image == null) {
      return;
    }

    try {
      String fileName =
          'Patient_images/$userId/$userId.${path.extension(_image!.path)}';
      Reference firebaseStorageRef =
          FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask = firebaseStorageRef.putFile(_image!);

      await uploadTask.whenComplete(() async {});
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  Future<void> _getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  Future<void> _checkPatientDataExists() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot PatientData =
            await _firestore.collection('Patients').doc(user.uid).get();

        setState(() {
          _isFirstTime = !PatientData.exists;
        });
      }
    } catch (e) {
      print('Error checking Patient data: $e');
    }
  }

  Future<void> _savePatientData() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('Patients').doc(user.uid).set({
          'nama': _namaController.text,
          'telepon': _teleponController.text,
          'gender':_genderController.text,
        });
        _uploadImage(user.uid);
      }
    } catch (e) {
      print('Error saving Patient data: $e');
    }
  }

  Widget _buildPatientDataForm() {
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
                    Colors.grey[200],
                child: _image != null
                    ? Image.file(
                        _image!,
                        width: 50,
                        height: 50, 
                        fit: BoxFit.cover,
                      )
                    : Icon(
                        Icons.camera_alt,
                        size: 40,
                      ),
              ),
            ),
          ),
          TextField(
            controller: _namaController,
            decoration: InputDecoration(labelText: 'Nama'),
          ),
          DropdownButtonFormField<String>(
            value: _genderController.text,
            onChanged: (String? newValue) {
              setState(() {
                _genderController.text = newValue!;
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
            decoration: InputDecoration(labelText: 'Jenis Kelamin'),
          ),
          TextField(
            controller: _teleponController,
            decoration: InputDecoration(labelText: 'Nomor Telepon'),
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
            ],
          ),
         
          ElevatedButton(
            onPressed: () {
              _savePatientData();
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => PatientPage()));
            },
            child: Text('Simpan Data'),
          ),
        ],
      ),
    );
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isFirstTime ? _buildPatientDataForm() : NavScreen(),
    );
  }
}
