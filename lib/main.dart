

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:redeveiculos_flutter/redeveiculosapp.dart';
import 'package:wakelock/wakelock.dart';


Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    Wakelock.enable();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Redeveiculos.com Rastreamento',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const RedeVeiculosApp(),
    );
  }
}
