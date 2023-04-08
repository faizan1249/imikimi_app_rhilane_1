import 'dart:math';
import 'package:app_settings/app_settings.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:photo_frame/views/splash_screen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  //Firebase.initializeApp();
  initializeFirabseStorage();
  MobileAds.instance.initialize();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);

  runApp(const MyApp());
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // await Firebase.initializeApp();
  // print("inside _firebaseMessagingBackgroundHandler");
  // print(message.notification!.title.toString());
}

void initializeFirabseStorage() async {
  NotificationServices notificationServices = NotificationServices();
  notificationServices.firebaseInit();
  notificationServices.requestNotificationPermission();
  final fcmToekn = await FirebaseMessaging.instance.getToken();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
            fontFamily: "12",
            primarySwatch: Colors.lightBlue,
            scrollbarTheme: ScrollbarThemeData(
                //crossAxisMargin: -10,
                // isAlwaysShown: true,
                thickness: MaterialStateProperty.all(3),
                thumbColor: MaterialStateProperty.all(Colors.lightBlueAccent),
                radius: const Radius.circular(10),
                minThumbLength: 100)),
        debugShowCheckedModeBanner: false,
        //home: HomePage()
        home: SplashScreen()

        // Container(
        //   decoration: BoxDecoration(
        //     image: DecorationImage(
        //       image: AssetImage("assets/bg3.jpg"),
        //       fit: BoxFit.cover,
        //     ),
        //   ),
        //   child: Scaffold(
        //     backgroundColor: Colors.transparent,
        //     appBar: AppBar(
        //       centerTitle: true,
        //       // actions: [
        //       //   TextButton(
        //       //       onPressed: () {
        //       //         // Navigator.push(
        //       //         //     context, MaterialPageRoute(builder: (context) => CategoryPage(frameLocationName:GlobalItems().categoriesList.first.frameLocationName,
        //       //         //     categoryName: GlobalItems().categoriesList.first.name,
        //       //         //     bgColor:GlobalItems().categoriesList.first.bgColor
        //       //         // )));
        //       //       },
        //       //       style: ButtonStyle(
        //       //         foregroundColor: MaterialStateProperty.all(Colors.white),
        //       //       ),
        //       //       child: Row(
        //       //         children: [Text("Start"), Icon(Icons.arrow_forward_sharp)],
        //       //       ))
        //       // ],
        //       backgroundColor: Colors.transparent,
        //       elevation: 0.0,
        //       title: Text("Photo Frames"),
        //       flexibleSpace: Custom_AppBar(),
        //     ),
        //      body: HomePage(),
        //     //body: SplashScreen(),
        //   ),
        // ),
        );
  }
}

class NotificationServices {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  void requestNotificationPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        carPlay: true,
        criticalAlert: true,
        provisional: true,
        sound: true);

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // print("User Granted Permissions");
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      // print("User provesional Permissions");
    } else {
      AppSettings.openNotificationSettings();
      // print("Permission denied");
    }
  }

  void firebaseInit() {
    initLocaleNotifications();
    FirebaseMessaging.onMessage.listen((message) {
      // print(message.notification!.title.toString());
      // print(message.notification!.body.toString());

      showNotification(message);
    });
  }

  Future<void> showNotification(RemoteMessage message) async {
    //
    AndroidNotificationChannel channel = AndroidNotificationChannel(
        Random.secure().nextInt(100000).toString(),
        "High Important Notifications",
        importance: Importance.max);
    // importance: Importance.max);
    //
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
            channel.id.toString(), channel.name.toString(),
            channelDescription: "Your channel Description",
            importance: Importance.high,
            priority: Priority.high,
            ticker: "ticker");
    //
    NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    //
    Future.delayed(Duration.zero, () {
      _flutterLocalNotificationsPlugin.show(
          0,
          message.notification!.title.toString(),
          message.notification!.body.toString(),
          notificationDetails);
    });
  }

  // void initLocaleNotifications(BuildContext context,RemoteMessage message)async{
  void initLocaleNotifications() async {
    var androidInitializationSettings =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var initialicationSettings =
        InitializationSettings(android: androidInitializationSettings);

    await _flutterLocalNotificationsPlugin.initialize(initialicationSettings,
        onDidReceiveNotificationResponse: (paylod) {});
  }

  Future<String> getDeviceToken() async {
    final fcmToekn = await FirebaseMessaging.instance.getToken();
    // print(fcmToekn);
    return fcmToekn!;
  }

  void isTokenRefresh() async {
    messaging.onTokenRefresh.listen((event) {
      event.toString();
    });
  }
}
