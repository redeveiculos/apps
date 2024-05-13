import 'package:flutter/material.dart';
import 'package:redeveiculos_flutter/pages/splashscreen.dart';

class RedeVeiculosApp extends StatefulWidget {
  const RedeVeiculosApp({super.key});

  @override
  State<RedeVeiculosApp> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<RedeVeiculosApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF222222),
      body: SplashScreen(),
    );
  }
}
