import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:wineline/pages/welcome_screen.dart';
import 'package:wineline/providers/bottle_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    // Load bottles from SharedPreferences
    final provider = Provider.of<BottleProvider>(context, listen: false);
    await provider.loadBottles();
    provider.url = await provider.loadUrl();

    // Navigate to welcome screen after loading
    if (mounted) {
      Timer(
        const Duration(seconds: 3),
        () => Navigator.pushReplacement(
          context,
          CupertinoPageRoute(builder: (context) => const WelcomeScreen()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color(0xFFE86F1C),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              child: Image.asset(
                height: height * 0.8,
                width: width * 0.7,
                'images/123.png',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 32),
            const SizedBox(
              width: 180,
              child: LinearProgressIndicator(
                backgroundColor: Colors.white,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                minHeight: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
