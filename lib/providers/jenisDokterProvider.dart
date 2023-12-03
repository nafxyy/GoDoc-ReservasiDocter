import 'package:flutter/material.dart';

class JenisDokter with ChangeNotifier{

  String? _selectedJenis;

  String? get selectedJenis => _selectedJenis;

  void setSelectedJenis(String jenis) {
    _selectedJenis = jenis;
    notifyListeners();
  }
}