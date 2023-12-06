import 'package:flutter/material.dart';
import 'package:pa_mobile/firebase_options.dart';
import 'package:pa_mobile/pages/intro_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pa_mobile/pages/login.dart';
import 'package:pa_mobile/providers/DocIDprovider.dart';
import 'package:pa_mobile/providers/theme.dart';
import 'package:pa_mobile/widgets/bottomNavbarDoctor.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => DoctorIdProvider()),
        ChangeNotifierProvider(create: (context) => Tema())
      ],
      child: Builder(
        builder: (context) {
          return MaterialApp(
            theme: Provider.of<Tema>(context).display(),
            darkTheme: Provider.of<Tema>(context).displaydark(),
            themeMode: Provider.of<Tema>(context).getThemeMode(),
            debugShowCheckedModeBanner: false,
            home: LoginPage(),
          );
        }
      ),
    ),
  );

}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => Tema())
      ],
      child: Builder(
        builder: (context) {
          return MaterialApp(
            theme: Provider.of<Tema>(context).display(),
            darkTheme: Provider.of<Tema>(context).displaydark(),
            themeMode: Provider.of<Tema>(context).getThemeMode(),
            debugShowCheckedModeBanner: false,
            home: Intro(),
          );
        }
      ),
    );
  }
}
