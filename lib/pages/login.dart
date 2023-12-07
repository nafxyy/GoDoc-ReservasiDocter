import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pa_mobile/pages/PatientPage.dart';
import 'package:pa_mobile/pages/doctorPage.dart';
import 'package:pa_mobile/pages/regis.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Query Firestore for user information
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user?.uid)
          .get();

      if (userDoc.exists) {
        String role = userDoc['role'];

        if (role.toLowerCase() == 'doctor') {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => DoctorPage()));
        } else if (role.toLowerCase() == 'patient') {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => PatientPage()));
        }
      } else {
        _showAlert(
            'User Not Found', 'User information not found in Firestore.');
      }
    } catch (e) {
      print('Error logging in: $e');
      String errorMessage = 'An error occurred during login.';

      if (e is FirebaseAuthException) {
        if (e.code == 'user-not-found' || e.code == 'wrong-password') {
          errorMessage = 'Invalid email or password. Please try again.';
        } else {
          errorMessage =
              'An unexpected error occurred. Please try again later.';
        }
      }
      _showAlert('Login Error', errorMessage);
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.grey[800], // Background color
        child: ListView(
          padding: EdgeInsets.zero, // Remove default padding
          physics:
              BouncingScrollPhysics(), // Optional: Add a bouncing effect when scrolling
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(color: Colors.black),
                        border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.black), // Warna hitam
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
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(color: Colors.black),
                        border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.black), // Warna hitam
                        ),
                        contentPadding: EdgeInsets.all(12.0),
                      ),
                      obscureText: true,
                    ),
                  ),
                  SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: _login,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Center(
                        child: Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 20.0,
                            color: Colors.white,
                          ),
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
                  SizedBox(height: 16.0),
                  TextButton(
                    onPressed: () {
                      // Navigate to the registration page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RegisterPage(),
                        ),
                      );
                    },
                    child: Text('Don\'t have an account? Register'),
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
