import 'package:flutter/material.dart';
import 'screens/main_screens.dart';

      void main() {
        runApp(MyApp());
      }

      class MyApp extends StatelessWidget {
        @override
        Widget build(BuildContext context) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Music Player',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
              useMaterial3: true,
            ),
            home: MainScreen(),
          );
        }
      }