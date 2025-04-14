import 'package:dog_tracker/splash_screen.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'dog_list_screen.dart';
import 'activities_screen.dart';
import 'settings_screen.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WoofWatch', 
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          fontFamily: 'Poppins',
          textTheme: GoogleFonts.poppinsTextTheme(
            Theme.of(context).textTheme,
          )),

      // Routing
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/home': (context) => const HomeScreen(),
        '/dogs': (context) => const DogListScreen(),
        '/activities': (context) => const ActivitiesScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}
