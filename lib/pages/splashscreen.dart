import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:redeveiculos_flutter/pages/webview.dart';
import 'package:redeveiculos_flutter/services/onesignal.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  _exitApp() async {
    await Future.delayed(const Duration(milliseconds: 500));
    exit(0); // Do not use this for IOS.
  }

  _startApp() async {

    await FlutterDownloader.initialize(debug: true);

    await [
      Permission.notification,
      Permission.location,
      Permission.bluetooth,
      Permission.storage,
      Permission.camera,
    ].request();

    var durationInSeconds = 3;
    var noInternetMessage = 'Parece que não há internet!\r\nVerifique sua conexão e clique em TENTAR NOVAMENTE.';

    await Future.delayed(Duration(seconds: durationInSeconds));
    var internetStatus = await Connectivity().checkConnectivity();

    if (internetStatus == ConnectivityResult.none) {
      showDialog(
        context: context,
        builder: (BuildContext contextDialog) {
          return AlertDialog(
            title: const Text('ERRO'),
            content: Text(noInternetMessage),
            actions: [
              TextButton(
                  child: const Text('TENTAR NOVAMENTE'),
                  onPressed: () {
                    _startApp();
                    Navigator.pop(contextDialog);
                  }),
              TextButton(
                  child: const Text('CANCELAR'),
                  onPressed: () {
                    _exitApp();
                    Navigator.pop(contextDialog);
                  }),
            ],
          );
        },
      );
      return;
    } else {
      await RedeVeiculosOneSignal().init();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const Webview()),
        (route) => false,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _startApp();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Column(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              color: Colors.black,
              child: const Image(
                image: AssetImage('assets/images/background.gif'),
                fit: BoxFit.fill,
              ),
            )
          ],
        ),
      ],
    );
  }
}