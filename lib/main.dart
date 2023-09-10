import 'package:flutter/material.dart';

import 'cgpaListPage.dart';

import 'homePage.dart';



void main() {
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CGPA Calculator',
      // theme: ThemeData(
      //   primarySwatch: Colors.blue,
      // ),

      theme: ThemeData.dark(
        // brightness: Brightness.dark,

        // colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.amber),
      )
          .copyWith(
        primaryColor: Color(0xFF0A0E21),
        scaffoldBackgroundColor: Color(0xFF0A0E21),
        textTheme: TextTheme(
          bodyLarge: TextStyle(
            color: Color(0xFFFFFFFF),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
        '/fourYearCourse': (context) => CGPAListPage(years: 4),
        '/fiveYearCourse': (context) => CGPAListPage(years: 5),
      },
    );
  }
}







