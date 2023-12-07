import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pa_mobile/providers/theme.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  String _selectedRole = 'Patient'; // Default role

  List<String> _roles = ['Patient', 'Doctor'];

  Future<void> _register() async {
    try {
      if (_passwordController.text.length < 6) {
        _showAlert('Password Error', 'Password must be at least 6 characters long.');
        return;
      }

      if (_passwordController.text != _confirmPasswordController.text) {
        _showAlert('Password Mismatch', 'Password and Confirm Password do not match.');
        return;
      }

      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Set user role in Firestore
      await _firestore.collection('users').doc(userCredential.user?.uid).set({
        'email': _emailController.text,
        'role': _selectedRole,
      });

      _showAlert('Registration Successful', 'You can now log in.');

      // Navigate back to the login page.
      Navigator.pop(context);
    } catch (e) {
      print('Error registering user: $e');
      String errorMessage = 'An error occurred during registration.';

      if (e is FirebaseAuthException) {
        if (e.code == 'email-already-in-use') {
          errorMessage = 'This email is already in use. Please choose a different email.';
        } else {
          errorMessage = 'An unexpected error occurred. Please try again later.';
        }
      }

      _showAlert('Registration Error', errorMessage);
    }
  }

  void _showAlert(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
Widget build(BuildContext context) {
  Tema tema = Provider.of(context);
  return Scaffold(
    backgroundColor: tema.isDarkMode
          ? tema.display().scaffoldBackgroundColor
          : tema.displaydark().scaffoldBackgroundColor,
    body: Container(
      decoration: BoxDecoration(
        color: Colors.grey[800], // Background color
      ),
      child: ListView(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.pop(context); // Kembali ke halaman sebelumnya
                      },
                    ),
                  ],
                ),
                Image.asset(
                  'assets/logo_putih.png', // Replace with the path to your image
                  height: 300,
                  width: 200,
                ),
                SizedBox(height: 5.0),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white, // Form background color
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black), // Warna hitam
                      ),
                      contentPadding: EdgeInsets.all(12.0),
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white, // Form background color
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black), // Warna hitam
                      ),
                      contentPadding: EdgeInsets.all(12.0),
                    ),
                    obscureText: true,
                  ),
                ),
                SizedBox(height: 16.0),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white, // Form background color
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: TextField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black), // Warna hitam
                      ),
                      contentPadding: EdgeInsets.all(12.0),
                    ),
                    obscureText: true,
                  ),
                ),
                DropdownButton<String>(
                  value: _selectedRole,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedRole = newValue!;
                    });
                  },
                  items: _roles.map((String role) {
                    return DropdownMenuItem<String>(
                      value: role,
                      child: Text(
                        role,
                        style: TextStyle(color: Colors.white), // Warna putih
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _register,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(
                      child: Text(
                        'Register',
                        style: TextStyle(fontSize: 18.0),
                      ),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xFFB12856), // Button background color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
}
