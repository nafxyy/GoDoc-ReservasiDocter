import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:pa_mobile/providers/theme.dart';
import 'package:pa_mobile/widgets/bottomNavbar.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';

class EditPatientPage extends StatefulWidget {
  @override
  _EditPatientPageState createState() => _EditPatientPageState();
}

class _EditPatientPageState extends State<EditPatientPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final picker = ImagePicker();

  File? _image;
  TextEditingController _namaController = TextEditingController();
  TextEditingController _teleponController = TextEditingController();
  TextEditingController _genderController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchPatientData();
  }

  Future<void> _fetchPatientData() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot PatientData =
            await _firestore.collection('Patients').doc(user.uid).get();

        setState(() {
          _namaController.text = PatientData['nama'];
          _teleponController.text = PatientData['telepon'];
          _genderController.text = PatientData['gender'];
        });
      }
    } catch (e) {
      print('Error fetching Patient data: $e');
    }
  }

  Future<void> _updatePatientData() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('Patients').doc(user.uid).update({
          'nama': _namaController.text,
          'telepon': _teleponController.text,
          'gender': _genderController.text,
        });

        await _uploadImage(user.uid);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Data Updated!'),
          ),
        );
      }
    } catch (e) {
      print('Error updating Patient data: $e');
    }
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

  Widget _buildEditPatientForm() {
  Tema tema = Provider.of<Tema>(context);
  TextTheme textTheme = tema.isDarkMode ? tema.teks : tema.teksdark;

  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: ListView(
      children: [
        GestureDetector(
          onTap: _getImage,
          child: ClipOval(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey[200],
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
          decoration: InputDecoration(
            labelText: 'Nama Pasien',
            labelStyle: textTheme.bodyMedium,
          ),
          style: textTheme.bodySmall,
        ),
        DropdownButtonFormField<String>(
          value: _genderController.text.isNotEmpty
              ? _genderController.text
              : null,
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
              child: Text(
                specialization,
                style: textTheme.bodySmall,
              ),
            );
          }).toList(),
          dropdownColor: Color(0xFFB12856),
          decoration: InputDecoration(
            labelText: 'Jenis Kelamin',
            labelStyle: textTheme.bodyMedium,
          ),
        ),
        TextField(
          controller: _teleponController,
          decoration: InputDecoration(
            labelText: 'Nomor Telepon',
            labelStyle: textTheme.bodyMedium,
          ),
          style: textTheme.bodySmall,
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly,
          ],
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            _updatePatientData();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NavScreen()),
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
    Tema tema = Provider.of<Tema>(context);
    return Scaffold(
      backgroundColor: tema.isDarkMode
          ? tema.display().scaffoldBackgroundColor
          : tema.displaydark().scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFFB12856),
        title: Text(
          'Edit Patient',
          style: TextStyle(
            color: Colors.black,
            fontSize: 25,
            fontWeight: FontWeight.bold,
            fontFamily: 'poppins',
          ),
        ),
      ),
      body: _buildEditPatientForm(),
    );
  }
}
