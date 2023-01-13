import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:meetups/http/web.dart';
import 'package:meetups/models/device.dart';
import 'package:meetups/screens/events_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

final navigatorKey = GlobalKey<NavigatorState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('Permissao concedida ${settings.authorizationStatus}');
    _startPushNotificationsHandler(messaging);
  } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
    print(
        'Permissao concedida provisoriamente ${settings.authorizationStatus}');
    _startPushNotificationsHandler(messaging);
  } else {
    print('Permissão negada pelo usuario');
  }

  runApp(App());
}

void _startPushNotificationsHandler(FirebaseMessaging messaging) async {
  String? token = await messaging.getToken(
    vapidKey: 'BKUxAUQ_wyGaPfAFGaMCu9YlpqtkUvTmY3SLDi6FO_ZapeTiRN78B80ORtj9JnlUmP-b7AihgqAyI9hAtNgN_CA'
  );
  print('Token: $token');
  _setPushToken(token);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('recebi uma mensagem em quanto estava aberto');
    print('Dados da mensangem: ${message.data}');

    if (message.notification != null) {
      print(
          'A mensagem tambem continha uma notificação: ${message.notification!.title} ${message.notification!.body}');
    }
  });
  FirebaseMessaging.onBackgroundMessage(_firebaseMEssaginBacgroudHandler);

  var notification = await FirebaseMessaging.instance.getInitialMessage();

  if (notification != null) {
    if (notification.data['message'].length > 0) {
      showMyDialog(notification.data['message']);
    }
  }
}

void _setPushToken(String? token) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? prefsToken = prefs.getString('pushToken');
  bool? prefSent = prefs.getBool('tokenSent');
  print('prefs token: $prefsToken');
  if (prefsToken != token || (prefsToken == token && prefSent == false)) {
    print('enviando token ');
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String? brand;
    String? model;
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      print('Rodando no ${androidInfo.model}');
      model = androidInfo.model;
      brand = androidInfo.brand;
    } else {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      print('Rodando no ${iosInfo.utsname.machine}');
      model = iosInfo.utsname.machine;
      brand = 'Apple';
    }

    Device device = Device(brand: brand, model: model, token: token);
    sendDevice(device);
  }
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dev meetups',
      home: EventsScreen(),
      navigatorKey: navigatorKey,
    );
  }
}

Future<void> _firebaseMEssaginBacgroudHandler(RemoteMessage message) async {
  print('Mensagem recebida em backgroud: ${message.notification}');
}

void showMyDialog(String message) {
  Widget okButton = OutlinedButton(
      onPressed: () => Navigator.pop(navigatorKey.currentContext!),
      child: Text('OK!'));
  AlertDialog alerta = AlertDialog(
    title: Text('Promoção relampago'),
    content: Text(message),
    actions: [okButton],
  );
  showDialog(
      context: navigatorKey.currentContext!,
      builder: (BuildContext context) {
        return alerta;
      });
}
