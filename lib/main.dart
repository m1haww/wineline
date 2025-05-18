import 'package:flutter/material.dart';
import 'package:wineline/pages/welcome_screen.dart';
import 'pages/splash_screen.dart';
import 'navigation/bottom_navigation.dart';
import 'package:provider/provider.dart';
import 'providers/bottle_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => BottleProvider())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WineLine',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
