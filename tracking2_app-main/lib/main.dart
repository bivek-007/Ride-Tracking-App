import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:provider/provider.dart';
import 'package:tracking2_app/DataHandler/appData.dart';
import 'package:tracking2_app/configMaps.dart';
import 'package:tracking2_app/screen/home_page/home_tab_screen.dart';
import 'package:tracking2_app/screen/home_page/tab_over_view.dart';
import 'package:tracking2_app/screen/map_Main_screen.dart';
import 'package:tracking2_app/screen/sign_in_screen.dart';
import 'package:tracking2_app/screen/sign_up_screen.dart';

import 'model/auth_provider.dart';

// const AndroidNotificationChannel channel = AndroidNotificationChannel(
//     'high_importance_channel', // id
//     'High Importance Notifications', //  description
//     importance: Importance.high,
//     playSound: true);
//
// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//     FlutterLocalNotificationsPlugin();

// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
//   print('A bg message just showed up :  ${message.messageId}');
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  //
  // await flutterLocalNotificationsPlugin
  //     .resolvePlatformSpecificImplementation<
  //         AndroidFlutterLocalNotificationsPlugin>()
  //     ?.createNotificationChannel(channel);
  //
  // await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
  //   alert: true,
  //   badge: true,
  //   sound: true,
  // );

  currentfirebaseUser = FirebaseAuth.instance.currentUser;
  runApp(MyApp());
}

DatabaseReference rideRequestRef = FirebaseDatabase.instance
    .reference()
    .child('drivers')
    .child(currentfirebaseUser.uid)
    .child("newRide");
DatabaseReference driversRef =
    FirebaseDatabase.instance.reference().child('drivers');

DatabaseReference saveRideHistory =
    FirebaseDatabase.instance.reference().child('ridesRecord');

DatabaseReference rideHistory =
    FirebaseDatabase.instance.reference().child('rideHistory');

DatabaseReference newRequestRef =
    FirebaseDatabase.instance.reference().child('Ride Requests');

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppData(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: FirebaseAuth.instance.currentUser != null
            ? HomeTabScreen()
            : IntroScreen(
                key: key,
              ),
        // home: IntroScreen(
        //   key: key,
        // ),
      ),
    );
  }
}

class IntroScreen extends StatelessWidget {
  const IntroScreen({Key? key}) : super(key: key);

  List<PageViewModel> getPages() {
    return [
      PageViewModel(
          title: 'Welcome to our vehicle tracking app.',
          body:
              "We've created a system for tracking your vehicles .You can simply enter our interface for the quality traveling experience.",
          image: Image.asset('assets/images/onB1.png')),
      PageViewModel(
          title: 'Our goal is to satisfy traveler.',
          body:
              "We focus more on satisfying the people who loves to travel.We promote quality tracking services to help traveller.",
          image: Image.asset(
            'assets/images/onB3.png',
            fit: BoxFit.fill,
          )),
      PageViewModel(
        title: 'We emphasize on quality tracking service.',
        body:
            "We provide you some special prebooking services while tracking the vehicle you were seeking.User can rate the service.",
        image: Image.asset('assets/images/onB2.png'),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      done: Text(
        'Done',
        style: TextStyle(color: Colors.black),
      ),
      onDone: () {
        print('why');
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => SignInScreen(
                      key: key,
                    )));
      },
      showSkipButton: true,
      next: Icon(Icons.navigate_next),
      skip: const Text(
        'Skip',
        style: TextStyle(color: Colors.black),
      ),
      pages: getPages(),
    );
  }
}
