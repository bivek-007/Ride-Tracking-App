import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:khalti_flutter/khalti_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tracking_app/DataHandler/appData.dart';
import 'package:tracking_app/screen/map_Main_screen.dart';
import 'package:tracking_app/screen/sign_in_screen.dart';

import 'model/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  runApp(MyApp(
    prefs: prefs,
  ));
}

DatabaseReference userRef =
    FirebaseDatabase.instance.reference().child('users');
DatabaseReference driverRef =
    FirebaseDatabase.instance.reference().child('drivers');

class MyApp extends StatelessWidget {
  final SharedPreferences? prefs;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;
  MyApp({@required this.prefs});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return KhaltiScope(
      publicKey: "test_public_key_c420094596384f26b1b4e8e898ce4f44",
      builder: (context, navigatorKey) {
        return ChangeNotifierProvider(
          create: (context) => AppData(),
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            navigatorKey: navigatorKey,
            home: FirebaseAuth.instance.currentUser != null
                ? MapMainScreen()
                : IntroScreen(
                    key: key,
                  ),
            localizationsDelegates: [
              KhaltiLocalizations.delegate,
            ],
            // home: IntroScreen(
            //   key: key,
            // ),
          ),
        );
      },
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
