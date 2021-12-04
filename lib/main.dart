import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:dio/dio.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');
  var data = message.data;

  const channel = AndroidNotificationChannel(
      'MATCH_STATUS_CHANNEL_ID', // id
      'MATCH_STATUS', // title
      'reminder', // description
      importance: Importance.high,
   );

  String type = data["type"];

        if(Platform.isIOS) {
          FlutterLocalNotificationsPlugin().show(
                int.parse(data["id"].toString()),
                data["title"],
                data["body"],
                NotificationDetails(
                  iOS: IOSNotificationDetails(
                    presentAlert: true,  // Present an alert when the notification is displayed and the application is in the foreground (only from iOS 10 onwards)
                    presentBadge: false,  // Present the badge number when the notification is displayed and the application is in the foreground (only from iOS 10 onwards)
                    presentSound: false,
                  ),));
        } else {
          FlutterLocalNotificationsPlugin().show(
                int.parse(data["id"].toString()),
                data["title"],
                data["body"],
                NotificationDetails(
                  android: AndroidNotificationDetails(
                    channel.id,
                    channel.name,
                    channel.description,
                    // TODO add a proper drawable resource to android, for now using
                    //      one that already exists in example app.
                    icon: 'launch_background',
                  ),));
        }
      
  // });
}

/// Create a [AndroidNotificationChannel] for heads up notifications
AndroidNotificationChannel? channel;

/// Initialize the [FlutterLocalNotificationsPlugin] package.
FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;
// final DioClient _dioClient = DioClient(Dio());
void main() async {

  // @override
  // void logMessage(String accessToken, String message) async {
  //   final res =
  //         await _dioClient.post("http://soccergs.6633663.com"+"/Game/LogApi",
  //             data: jsonEncode({
  //               "ACTK": accessToken,
  //               "LAPI": "NotificationReceived",
  //               "LGMS": message
  //             }),
  //             options: Options(
  //               // baseUrl: Constants.of().endpoint,
  //               contentType: 'application/json',
  //               // connectTimeout: 30000,
  //               sendTimeout: 30000,
  //               receiveTimeout: 30000,
  //             ));
  // }

  void initFCM()
  {
    print("initFCM");
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
          // print("remote message");
          // print(message);
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      var data = message.data;
      // if (notification != null && android != null && !kIsWeb) {
      // print(data);
      // print("front get");
      if (data != null && !kIsWeb) {


          // print("Notice test: "+ _preferenceRepository.test);
          // print("isEnabled "+key+ " " + isEnabled.toString());
          // logMessage(accessToken);

      
            if (Platform.isAndroid) {
            flutterLocalNotificationsPlugin?.show(
              int.parse(data["id"].toString()),
              data["title"],
              data["body"],
              NotificationDetails(
                android: AndroidNotificationDetails(
                  channel!.id,
                  channel!.name,
                  channel!.description,
                  // TODO add a proper drawable resource to android, for now using
                  //      one that already exists in example app.
                  icon: 'launch_background',
                ),
              ));
            }
            else if (Platform.isIOS) {
              flutterLocalNotificationsPlugin?.show(
              int.parse(data["id"].toString()),
              data["title"],
              data["body"],
              NotificationDetails(
                iOS: IOSNotificationDetails(
                  presentAlert: true,  // Present an alert when the notification is displayed and the application is in the foreground (only from iOS 10 onwards)
                  presentBadge: false,  // Present the badge number when the notification is displayed and the application is in the foreground (only from iOS 10 onwards)
                  presentSound: false,  // Play a sound when the notification is displayed and the application is in the foreground (only from iOS 10 onwards)
                  // sound: String?,  // Specifics the file path to play (only from iOS 10 onwards)
                  // badgeNumber: int?, // The application's icon badge number
                  // attachments: List<IOSNotificationAttachment>?, (only from iOS 10 onwards)
                  // subtitle: String?, //Secondary description  (only from iOS 10 onwards)
                  // threadIdentifier: String? (only from iOS 10 onwards)
                ),
              ));
            }
        ;
        
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
    });
  }

  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  if (!kIsWeb) {
    channel = const AndroidNotificationChannel(
      'MATCH_STATUS_CHANNEL_ID', // id
      'MATCH_STATUS', // title
      'reminder', // description
      importance: Importance.high,
    );

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    /// Create an Android Notification Channel.
    ///
    /// We use this channel in the `AndroidManifest.xml` file to override the
    /// default FCM channel to enable heads up notifications.
    await flutterLocalNotificationsPlugin!
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel?? AndroidNotificationChannel(
        'MATCH_STATUS_CHANNEL_ID', // id
        'MATCH_STATUS', // title
        'reminder', // description
        importance: Importance.high,
      ));

    /// Update the iOS foreground notification presentation options to allow
    /// heads up notifications.
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
