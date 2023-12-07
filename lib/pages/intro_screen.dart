import 'package:flutter/material.dart';
import 'package:intro_screen_onboarding_flutter/introduction.dart';
import 'package:intro_screen_onboarding_flutter/introscreenonboarding.dart';
import 'package:pa_mobile/pages/login.dart';
import 'package:provider/provider.dart';
import 'package:pa_mobile/providers/theme.dart';

class Intro extends StatelessWidget {
  Intro({super.key});

  
  final List<Introduction> list = [
    Introduction(
      imageHeight: 150,
      imageWidth: 150,
      title: 'Welcome',
      titleTextStyle: TextStyle(fontSize: 30),
      subTitle: 'Selamat datang di Aplikasi GoDoc!',
      subTitleTextStyle: TextStyle(fontSize: 16),
      imageUrl: 'assets/dokter1.png',
    ),
    Introduction(
      imageHeight: 150,
      imageWidth: 150,
      title: 'GoDoc',
      titleTextStyle: TextStyle(fontSize: 30),
      subTitle: 'Kami hadir untuk mempermudah akses Anda menuju kesehatan yang lebih baik',
      subTitleTextStyle: TextStyle(fontSize: 16),
      imageUrl: 'assets/dokter2.png',
    ),
    Introduction(
      imageHeight: 150,
      imageWidth: 150,
      title: 'Finish',
      titleTextStyle: TextStyle(fontSize: 30),
      subTitle: 'Temukan kualitas layanan kesehatan terbaik di ujung jari Anda',
      subTitleTextStyle: TextStyle(fontSize: 16),
      imageUrl: 'assets/dokter3.png',
    ),
  ];
  
  @override
  Widget build(BuildContext context) {
    Tema tema = Provider.of<Tema>(context);
    return IntroScreenOnboarding(
      backgroudColor: tema.isDarkMode
          ? tema.display().scaffoldBackgroundColor
          : tema.displaydark().scaffoldBackgroundColor,
      skipTextStyle: TextStyle(color: Color(0XFFB12856),fontWeight: FontWeight.bold),
      foregroundColor: Color(0XFFB12856),
      introductionList: list,
      onTapSkipButton: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LoginPage(),
          ),
          
        );
      
      },
      
    );
  }
}