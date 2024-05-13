import 'dart:io';

import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RedeVeiculosOneSignal {
  Future<void> init() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      final plataforma = Platform.operatingSystem.toLowerCase();
      const empresa = 'rdv';
      const startInitHash = '0c61139a-2cb6-4951-8c0e-0e2cfdb67273';
      String url = 'https://redeveiculos.com/login?plataforma=$plataforma&empresa=$empresa';
      String? playerId = prefs.getString('idsAutoPush');
      String? pushToken = prefs.getString('pushToken');

      await OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);
      await OneSignal.shared.setAppId(startInitHash);

      if (Platform.isIOS) {
        await OneSignal.shared.promptUserForPushNotificationPermission(
          fallbackToSettings: true,
        );
      }

      if (playerId.isEmpty || pushToken.isEmpty) {
        OneSignal.shared.setSubscriptionObserver((OSSubscriptionStateChanges changes) async {
          await prefs.setString('idsAutoPush', changes.to.userId ?? '');
          await prefs.setString('pushToken', changes.to.pushToken ?? '');
        });

        OSDeviceState? status = await OneSignal.shared.getDeviceState();

        if (status?.userId != null && status?.userId != '' && status?.pushToken != null && status?.pushToken != '') {
          await prefs.setString('idsAutoPush', status?.userId ?? '');
          await prefs.setString('pushToken', status?.pushToken ?? '');
        }

        playerId = prefs.getString('idsAutoPush');
        pushToken = prefs.getString('pushToken');

        if (playerId.isNotEmpty) {
          url = '$url&playerId=$playerId';
        }

        if (pushToken.isNotEmpty) {
          url = '$url&pushToken=$pushToken';
        }

        await prefs.setString('url', Uri.encodeFull(url));
      } else {
        await prefs.setString('url', Uri.encodeFull('$url&playerId=$playerId&pushToken=$pushToken'));
      }
    } catch (e) {
      print('Erro ao iniciar OneSignal');
      print(e);
    }
  }
}
