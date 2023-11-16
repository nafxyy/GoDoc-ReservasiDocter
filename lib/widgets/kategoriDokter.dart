import 'package:flutter/material.dart';

class JenisDokter {
  final String name;
  final String imageUrl;

  JenisDokter({required this.name, required this.imageUrl});
}

class CategoryDokter extends StatelessWidget {
  final JenisDokter jenisDokter;

  const CategoryDokter({Key? key, required this.jenisDokter}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double height = screenHeight * 0.15;
    double screenWidth = MediaQuery.of(context).size.width;
    double width = screenWidth * 0.15;
    return Container(
  margin: const EdgeInsets.all(8.0),
  child: Column(
    children: [
      Expanded(
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFB12856),
            image: DecorationImage(
              image: AssetImage(jenisDokter.imageUrl),
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
      Text(
        jenisDokter.name,
        style: TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    ],
  ),
);
  }
}
