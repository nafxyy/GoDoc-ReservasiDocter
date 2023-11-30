import 'package:flutter/material.dart';

class DoctorIdProvider with ChangeNotifier {
  String _selectedDoctorId = "";

  String get selectedDoctorId => _selectedDoctorId;

  void setSelectedDoctorId(String doctorId) {
    _selectedDoctorId = doctorId;
    notifyListeners();
  }
}