//@dart=2.1

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tracking2_app/Assistants/assistantMethods.dart';
import 'package:tracking2_app/DataHandler/appData.dart';
import 'package:tracking2_app/configMaps.dart';
import 'package:tracking2_app/main.dart';
import 'package:tracking2_app/model/drivers.dart';
import 'package:tracking2_app/model/myDetail.dart';
import 'package:tracking2_app/notifications/push_notifications.dart';
import 'package:tracking2_app/screen/sign_in_screen.dart';
import 'package:tracking2_app/widgets/Divider.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeTabScreen extends StatefulWidget {
  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  State<HomeTabScreen> createState() => _HomeTabScreenState();
}

class _HomeTabScreenState extends State<HomeTabScreen> {
  Completer<GoogleMapController> _controllerGoogleMap = Completer();

  GoogleMapController newGoogleMapController;

  var geolocator = Geolocator();

  String driverStatusText = "Offline Now - Go Online";

  Color driverStatusColor = Colors.black;

  bool isAvailable = false;

  void locatePosition() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;
    LatLng latLanPosition = LatLng(position.latitude, position.longitude);
    CameraPosition cameraPosition =
        new CameraPosition(target: latLanPosition, zoom: 14);
    newGoogleMapController
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    // String address =
    //     await AssistantMethods().searchCoordinateAddress(position, context);
    // print('This is your address::' + address);
  }

  void getCurrentDriverInfo() async {
    await getCurrentUser();
    currentfirebaseUser = FirebaseAuth.instance.currentUser;
    driversRef
        .child(currentfirebaseUser.uid)
        .once()
        .then((DataSnapshot dataSnapshot) {
      if (dataSnapshot.value != null) {
        driversIfo = Drivers.fromSnapShot(dataSnapshot);
      }
    });
    PushNotificationServices pushNotificationServices =
        PushNotificationServices();
    pushNotificationServices.initialize(context);
    pushNotificationServices.getToken();
  }

  getCurrentUser() async {
    await AssistantMethods.getCurrentUser();
  }

  @override
  void initState() {
    getCurrentUser();
    getCurrentDriverInfo();
    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //   RemoteNotification notification = message.notification;
    //   AndroidNotification android = message.notification?.android;
    //   if (notification != null && android != null) {
    //     flutterLocalNotificationsPlugin.show(
    //         notification.hashCode,
    //         notification.title,
    //         notification.body,
    //         NotificationDetails(
    //           android: AndroidNotificationDetails(
    //             channel.id,
    //             channel.name,
    //             // channel.description,
    //             color: Colors.blue,
    //             playSound: true,
    //             icon: '@mipmap/ic_launcher',
    //           ),
    //         ));
    //   }
    // });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      RemoteNotification notification = message.notification;
      AndroidNotification android = message.notification?.android;
      if (notification != null && android != null) {
        showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                title: Text(notification.title),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [Text(notification.body)],
                  ),
                ),
              );
            });
      }
    });
    super.initState();
  }

  int _counter = 0;

  // void showNotification() {
  //   setState(() {
  //     _counter++;
  //   });
  //   // flutterLocalNotificationsPlugin.show(
  //   //     0,
  //   //     "Testing $_counter",
  //   //     "How you doin ?",
  //   //     NotificationDetails(
  //   //         android: AndroidNotificationDetails(channel.name, channel.name,
  //   //             importance: Importance.high,
  //   //             color: Colors.blue,
  //   //             playSound: true,
  //   //             icon: '@mipmap/ic_launcher')));
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        actions: [
          GestureDetector(
            onTap: () async {
              await launch('tel:100');
            },
            child: Container(
              height: 24,
              width: 34,
              margin: EdgeInsets.only(right: 14),
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: NetworkImage(
                          'https://firebasestorage.googleapis.com/v0/b/tracking-app-65c0e.appspot.com/o/download.png?alt=media&token=420e35be-efc1-400c-ad6e-acf90b715bff'),
                      fit: BoxFit.fill)),
            ),
          )
        ],
      ),
      drawer: Container(
        color: Colors.white,
        width: 255.0,
        child: Drawer(
          child: ListView(
            children: [
              //Drawer Header
              Container(
                height: 165.0,
                child: DrawerHeader(
                  decoration: BoxDecoration(color: Colors.white),
                  child: Row(
                    children: [
                      Image.asset(
                        "assets/images/user_icon.png",
                        height: 65.0,
                        width: 65.0,
                      ),
                      SizedBox(
                        width: 16.0,
                      ),
                      Flexible(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userCurrentInfo?.name ?? '',
                              maxLines: 1,
                              style: TextStyle(
                                  fontSize: 16.0,
                                  fontFamily: "Brand Bold",
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.3),
                            ),
                            SizedBox(
                              height: 6.0,
                            ),
                            GestureDetector(
                                onTap: () {
                                  // Navigator.push(context, MaterialPageRoute(builder: (context)=> ProfileTabPage()));
                                },
                                child: Text(
                                  Provider.of<AppData>(context, listen: false)
                                              .pickUpLocation !=
                                          null
                                      ? Provider.of<AppData>(context)
                                          .pickUpLocation
                                          .placeName
                                          .toString()
                                      : userCurrentInfo?.phone ?? '',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14),
                                )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              DividerWidget(),

              SizedBox(
                height: 12.0,
              ),

              //Drawer Body Contrllers
              GestureDetector(
                onTap: () {
                  // Navigator.push(context, MaterialPageRoute(builder: (context)=> HistoryScreen()));
                },
                child: ListTile(
                  leading: Icon(Icons.history),
                  title: Text(
                    "History",
                    style: TextStyle(fontSize: 15.0),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Navigator.push(context, MaterialPageRoute(builder: (context)=> ProfileTabPage()));
                },
                child: ListTile(
                  leading: Icon(Icons.person),
                  title: Text(
                    "Visit Profile",
                    style: TextStyle(fontSize: 15.0),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Navigator.push(context, MaterialPageRoute(builder: (context)=> AboutScreen()));
                },
                child: ListTile(
                  leading: Icon(Icons.info),
                  title: Text(
                    "About",
                    style: TextStyle(fontSize: 15.0),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SignInScreen(
                                key: widget.key,
                              )),
                      (route) => false);
                },
                child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text(
                    "Sign Out",
                    style: TextStyle(fontSize: 15.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: myDetail?.isSuspended == "true"
          ? GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SignInScreen(
                              key: widget.key,
                            )));
              },
              child: Container(
                height: MediaQuery.of(context).size.height - 100,
                width: double.infinity,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: NetworkImage(
                            'https://firebasestorage.googleapis.com/v0/b/tracking-app-65c0e.appspot.com/o/Account-suspended.jpg?alt=media&token=6288c959-92b0-465a-bd83-227afe4872af'),
                        fit: BoxFit.fill)),
              ),
            )
          : Stack(
              children: [
                GoogleMap(
                  // padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
                  mapType: MapType.normal,
                  myLocationButtonEnabled: true,
                  // markers: markerSet,
                  // circles: circleSet,
                  // polylines: polyLineSet,
                  initialCameraPosition: HomeTabScreen._kGooglePlex,
                  myLocationEnabled: true,

                  onMapCreated: (GoogleMapController controller) {
                    _controllerGoogleMap.complete(controller);

                    newGoogleMapController = controller;
                    // setState(() {
                    //   bottomPaddingOfMap = 300.0;
                    // });
                    locatePosition();
                  },
                ),

                //online off line drive container

                Container(
                  height: 140,
                  width: double.infinity,
                  color: Colors.black54,
                ),
                Positioned(
                  top: 60.0,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: RaisedButton(
                          onPressed: () {
                            if (isAvailable != true) {
                              makeDriverOnlineNow();
                              getLocationLiveUpdate();
                              setState(() {
                                driverStatusColor = Colors.green;
                                driverStatusText = "Online Now";
                                isAvailable = true;
                              });

                              displayToastMessage(
                                  "You are Online Now", context);
                            } else {
                              setState(() {
                                driverStatusColor = Colors.black;
                                driverStatusText = "Offline Now - Go Online";
                                isAvailable = false;
                              });
                              makeDriverOfflineNow();
                              displayToastMessage(
                                  "You are Offline Now", context);
                            }
                          },
                          color: driverStatusColor,
                          child: Padding(
                            padding: EdgeInsets.all(17),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  driverStatusText,
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                Icon(
                                  Icons.phone_android,
                                  color: Colors.white,
                                  size: 26,
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
    );
  }

  // DatabaseReference rideRequestRef = FirebaseDatabase.instance.reference();

  void makeDriverOnlineNow() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;
    Geofire.initialize("availableDrivers");
    Geofire.setLocation(currentfirebaseUser.uid, currentPosition.latitude,
        currentPosition.longitude);
    rideRequestRef.set("searching");
    rideRequestRef.onValue.listen((event) {});
  }

  void getLocationLiveUpdate() {
    homeTabPageStreamSubscription =
        Geolocator.getPositionStream().listen((Position position) {
      currentPosition = position;
      if (isAvailable == true) {
        Geofire.setLocation(
            currentfirebaseUser.uid, position.latitude, position.longitude);
      }
      LatLng latLng = LatLng(position.latitude, position.longitude);
      newGoogleMapController.animateCamera(CameraUpdate.newLatLng(latLng));
    });
  }

  void makeDriverOfflineNow() {
    Geofire.removeLocation(currentfirebaseUser.uid);
    rideRequestRef.onDisconnect();
    rideRequestRef.remove();
    rideRequestRef = null;
  }
}
