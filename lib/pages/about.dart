import 'package:flutter/material.dart';
import 'package:pa_mobile/providers/theme.dart';
import 'package:provider/provider.dart';




class AboutPage extends StatelessWidget {
  AboutPage({Key? key});

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double containerHeight = screenHeight * 0.2; // 20% of screen height
    Tema tema = Provider.of<Tema>(context);
    TextTheme textTheme = tema.isDarkMode ? tema.teks : tema.teksdark;

    return Scaffold(
      backgroundColor: tema.isDarkMode
          ? tema.display().scaffoldBackgroundColor
          : tema.displaydark().scaffoldBackgroundColor,
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color:textTheme.bodyMedium?.color,
                    ),
                    onPressed: () {
                      Navigator.pop(context); // Untuk kembali ke halaman sebelumnya
                    },
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'About Us',
                         style: textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20,),
          Center(
            child: Text(
              'GoDoc',
              style: TextStyle(
                fontSize: 35,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: Card(
                color: Color(0xFFB12856),
                child: Column(
                  children: [
                    Image.asset(
                      'assets/dokter.png', // Ganti dengan path gambar sesuai kebutuhan
                      width: double.infinity,
                      height: containerHeight,
                      fit: BoxFit.contain,
                    ),
                    ListTile(
                      title: Text(
                        'About Us',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 25.0),
                      subtitle: Text(
                        'Dengan aplikasi reservasi dokter kami, Anda tidak hanya mendapatkan akses instan ke jaringan dokter berkualitas, tetapi juga memasuki dunia perawatan kesehatan yang lebih efisien dan mudah. Mengutamakan kesehatan Anda, aplikasi ini dirancang untuk memastikan bahwa waktu Anda berharga tidak terbuang sia-sia dalam antrian panjang. Pesan janji kapan saja, di mana saja, dan hindari kerumitan administratif dengan sekali sentuhan layar. Kami menghadirkan kemudahan dalam mengelola jadwal kesehatan Anda, memberikan pengingat janji yang berguna, dan memberikan akses langsung ke riwayat kesehatan Anda. Dengan teknologi canggih, aplikasi ini memanjakan Anda dengan kemudahan, membebaskan Anda dari stres antri dan menghadirkan perawatan kesehatan yang lebih terjangkau dan mudah dijangkau. Sehat tak pernah semudah ini—dengan satu aplikasi, Anda memiliki kontrol penuh atas perjalanan kesehatan Anda.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
