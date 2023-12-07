import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pa_mobile/providers/theme.dart';
import 'package:pa_mobile/widgets/bottomNavbarDoctor.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';

class DoctorPage extends StatefulWidget {
  @override
  _DoctorPageState createState() => _DoctorPageState();
}

class _DoctorPageState extends State<DoctorPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  File? _image;
  final picker = ImagePicker();

  TextEditingController _jenisDokterController = TextEditingController();
  TextEditingController _namaDokterController = TextEditingController();
  TextEditingController _hargaDokterController = TextEditingController();
  TextEditingController _teleponDokterController = TextEditingController();
  TextEditingController _genderDokterController = TextEditingController();
  TextEditingController _rumahSakitDokterController = TextEditingController();

  bool _isFirstTime = true;
  List<String> selectedHours = [];

  @override
  void initState() {
    super.initState();
    _checkDoctorDataExists();
  }

  void didChangeDependencies() {
    super.didChangeDependencies();
    _jenisDokterController.text = 'Umum';
    _genderDokterController.text = 'Laki - Laki';
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
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  Future<void> _checkDoctorDataExists() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot doctorData =
            await _firestore.collection('doctors').doc(user.uid).get();

        setState(() {
          _isFirstTime = !doctorData.exists;
        });
      }
    } catch (e) {
      print('Error checking doctor data: $e');
    }
  }

 Future<void> _saveDoctorData() async {
  try {
    User? user = _auth.currentUser;

    // Check if any required field is empty
    if (_namaDokterController.text.isEmpty ||
        _jenisDokterController.text.isEmpty ||
        _teleponDokterController.text.isEmpty ||
        _hargaDokterController.text.isEmpty ||
        _rumahSakitDokterController.text.isEmpty ||
        _genderDokterController.text.isEmpty ||
        selectedHours.isEmpty) {
      // Show Snackbar if any field is empty
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Data Belum Lengkap'),
          backgroundColor: Colors.red,
        ),
      );
      return; // Stop execution if any field is empty
    }

    if (user != null) {
      // Convert the selectedHours to integers and then sort
      List<int> sortedHours = selectedHours.map(int.parse).toList();
      sortedHours.sort();

      // Convert the sortedHours back to strings
      List<String> sortedHoursStrings =
          sortedHours.map((hour) => hour.toString()).toList();

      await _firestore.collection('doctors').doc(user.uid).set({
        'nama': _namaDokterController.text,
        'jenis': _jenisDokterController.text,
        'telepon': _teleponDokterController.text,
        'harga': _hargaDokterController.text,
        'available_hours': sortedHoursStrings,
        'rumah_sakit': _rumahSakitDokterController.text,
        'gender': _genderDokterController.text,
      });
      _uploadImage(user.uid);
    }
  } catch (e) {
    print('Error saving doctor data: $e');
  }
}
  Widget _buildDoctorDataForm() {
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
            controller: _namaDokterController,
            decoration: InputDecoration(
              labelText: 'Nama Dokter',
              labelStyle: textTheme.bodyMedium,
            ),
            style: textTheme.bodySmall,
          ),
          DropdownButtonFormField<String>(
            value: _genderDokterController.text,
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
                child: Text(
                  specialization,
                  style: textTheme.bodySmall,
                ),
              );
            }).toList(),
            decoration: InputDecoration(
              labelText: 'Jenis Kelamin',
              labelStyle: textTheme.bodyMedium,
            ),
            dropdownColor: Color(0xFFB12856),
          ),
          TextField(
            controller: _hargaDokterController,
            decoration: InputDecoration(
              labelText: 'Harga',
              labelStyle: textTheme.bodyMedium,
            ),
            style: textTheme.bodySmall,
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
            ],
          ),
          TextField(
            controller: _teleponDokterController,
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
          TextField(
            controller: _rumahSakitDokterController,
            decoration: InputDecoration(
              labelText: 'Rumah Sakit',
              labelStyle: textTheme.bodyMedium,
            ),
            style: textTheme.bodySmall,
          ),
          DropdownButtonFormField<String>(
            value: _jenisDokterController.text,
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
                child: Text(
                  specialization,
                  style: textTheme.bodySmall,
                ),
              );
            }).toList(),
            decoration: InputDecoration(
              labelText: 'Jenis Spesialisasi',
              labelStyle: textTheme.bodyMedium,
            ),
            dropdownColor: Color(0xFFB12856),
          ),
          SizedBox(height: 16.0),
          Text(
            'Pilih Jam Praktek:',
            style: textTheme.bodyMedium,
          ),
          SizedBox(height: 8.0),
          _buildHourSelection(),
          SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () {
              _saveDoctorData();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => DoctorPage()),
              );
            },
            child: Text(
              'Simpan Data',
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
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
                color: isSelected ? Colors.blue : Colors.grey,
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

  @override
  Widget build(BuildContext context) {
    Tema tema = Provider.of<Tema>(context);
    return Scaffold(
      backgroundColor: tema.isDarkMode
          ? tema.display().scaffoldBackgroundColor
          : tema.displaydark().scaffoldBackgroundColor,
      body: _isFirstTime ? _buildDoctorDataForm() : BottomNavDoctor(),
    );
  }
}
