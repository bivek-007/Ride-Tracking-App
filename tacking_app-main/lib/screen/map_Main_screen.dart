import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tracking_app/Assistants/assistantMethods.dart';
import 'package:tracking_app/Assistants/geoFireAssistant.dart';
import 'package:tracking_app/DataHandler/appData.dart';
import 'package:tracking_app/chat/chat_screen.dart';
import 'package:tracking_app/configMaps.dart';
import 'package:tracking_app/khalti/khalti_screen.dart';
import 'package:tracking_app/main.dart';
import 'package:tracking_app/model/directionDetail.dart';
import 'package:tracking_app/model/firestorConstants.dart';
import 'package:tracking_app/model/nearByAvailableDrivers.dart';
import 'package:tracking_app/screen/search_screen.dart';
import 'package:tracking_app/screen/sign_in_screen.dart';
import 'package:tracking_app/widgets/Divider.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:tracking_app/widgets/collectionFare.dart';
import 'package:tracking_app/widgets/loading.dart';
import 'package:tracking_app/widgets/noOfAvailableDriverDialog.dart';
import 'package:url_launcher/url_launcher.dart';

class MapMainScreen extends StatefulWidget {
  const MapMainScreen({Key? key}) : super(key: key);

  @override
  _MapMainScreenState createState() => _MapMainScreenState();
}

class _MapMainScreenState extends State<MapMainScreen>
    with TickerProviderStateMixin {
  Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController? newGoogleMapController;

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(27.700769, 85.300140),
    zoom: 14,
  );
  Position? currentPosition;
  double bottomPaddingOfMap = 0;

  DirectionDetails? tripDirectionDetails;
  bool drawerOpen = true;
  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  Set<Marker> markerSet = {};
  Set<Circle> circleSet = {};
  double rideDetailsContainerHeight = 0;
  double requestRideContainerHeight = 0;
  double searchContainerHeight = 300;
  double driverDetailHeightContainer = 0;
  String state = "normal";
  bool nearByAvailableDriverKeysLoaded = false;

  StreamSubscription<Event>? rideStreamSubscription;

  void displayRideDetailsContainer() async {
    await getPlaceDirection();
    setState(() {
      searchContainerHeight = 0;
      rideDetailsContainerHeight = 240;
      bottomPaddingOfMap = 230.0;
      drawerOpen = false;
    });
  }

  void locatePosition() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;
    LatLng latLanPosition = LatLng(position.latitude, position.longitude);
    CameraPosition cameraPosition =
        new CameraPosition(target: latLanPosition, zoom: 14);
    newGoogleMapController!
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    String address =
        await AssistantMethods().searchCoordinateAddress(position, context);
    print('This is your address::' + address);
    initGeoFireListener();
  }

  void displayRequestContainer() {
    setState(() {
      requestRideContainerHeight = 250;
      rideDetailsContainerHeight = 0;
      bottomPaddingOfMap = 230;
      drawerOpen = true;
    });
    saveRideRequest();
  }

  DatabaseReference? rideRequestReference;

  BitmapDescriptor? nearByIcon;

  List<NearByAvailableDrivers>? availableDrivers;

  bool init = true;
  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    if (init) {
      Provider.of<AppData>(context, listen: false).pickUpLocation;
    }
    init = false;
  }

  List<LatLng> pLineCoordinates = [];
  Set<Polyline> polyLineSet = {};

  @override
  void initState() {
    // TODO: implement initState
    getCurrentUser();

    super.initState();
  }

  getCurrentUser() async {
    await AssistantMethods.getCurrentOnlineUserInfo();
  }

  void saveRideRequest() {
    rideRequestReference =
        FirebaseDatabase.instance.reference().child("Ride Requests").push();
    var pickUp = Provider.of<AppData>(context, listen: false).pickUpLocation;
    var dropOf = Provider.of<AppData>(context, listen: false).dropLocation;
    Map picUpLocMap = {
      'latitude': pickUp!.latitude.toString(),
      'longitude': pickUp.longitude.toString(),
    };

    Map dropOfLocMap = {
      'latitude': dropOf?.latitude.toString() ?? '',
      'longitude': dropOf?.longitude.toString() ?? '',
    };

    Map rideInfoMap = {
      'driver_id': 'waiting',
      'payment_method': 'cash',
      'pickup': picUpLocMap,
      'totalPayment': AssistantMethods.calculateFares(
              tripDirectionDetails ?? DirectionDetails()) ??
          '',
      'dropoff': dropOfLocMap,
      'requestDistance': tripDirectionDetails!.distanceValue ?? '',
      'created_at': DateTime.now().toString(),
      'rider_name': userCurrentInfo?.name ?? '',
      'rider_pone': userCurrentInfo?.phone ?? ' ',
      'pickup_address': pickUp.placeName,
      'dropoff_address': dropOf?.placeName ?? ''
    };
    rideRequestReference!.set(rideInfoMap);
    rideStreamSubscription = rideRequestReference!.onValue.listen((event) {
      print('abcd');
      print(event.snapshot.value.toString());
      if (event.snapshot.value == null) {
        return;
      }
      if (event.snapshot.value["status"]! == null) {
        statusRide = event.snapshot.value["status"].toString();
      }
      if (statusRide == 'arrived') {
        displayDetailHeightContainer();
      }
    });
  }

  void displayDetailHeightContainer() {
    setState(() {
      requestRideContainerHeight = 0;

      rideDetailsContainerHeight = 0;
      bottomPaddingOfMap = 230;
      driverDetailHeightContainer = 270;
    });
  }

  void cancelRideRequest() {
    rideRequestReference!.remove();
    setState(() {
      state = 'normal';
    });
  }

  @override
  Widget build(BuildContext context) {
    createIconMarker();
    const colorizeColors = [
      Colors.green,
      Colors.purple,
      Colors.pink,
      Colors.blue,
      Colors.yellow,
      Colors.red,
    ];

    const colorizeTextStyle = TextStyle(
      fontSize: 35.0,
      fontFamily: 'Signatra',
    );
    return Scaffold(
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
                                          .pickUpLocation!
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Google Map',
          style: TextStyle(color: Colors.black),
        ),
        leading: Text(''),
        iconTheme: IconThemeData(color: Colors.black),
        centerTitle: true,
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
      body: userCurrentInfo?.isSuspended == "true"
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
                  padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
                  mapType: MapType.normal,
                  myLocationButtonEnabled: true,
                  markers: markerSet,
                  circles: circleSet,
                  polylines: polyLineSet,
                  initialCameraPosition: _kGooglePlex,
                  myLocationEnabled: true,
                  zoomGesturesEnabled: true,
                  zoomControlsEnabled: true,
                  onMapCreated: (GoogleMapController controller) {
                    _controllerGoogleMap.complete(controller);

                    newGoogleMapController = controller;
                    setState(() {
                      bottomPaddingOfMap = 300.0;
                    });
                    locatePosition();
                  },
                ),
                Positioned(
                  top: 36.0,
                  left: 22.0,
                  child: Builder(
                    builder: (context) {
                      return GestureDetector(
                        onTap: () {
                          if (drawerOpen) {
                            Scaffold.of(context).openDrawer();
                          } else {
                            resetApp();
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black,
                                blurRadius: 6.0,
                                spreadRadius: 0.5,
                                offset: Offset(
                                  0.7,
                                  0.7,
                                ),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Icon(
                              (drawerOpen) ? Icons.menu : Icons.close,
                              color: Colors.black,
                            ),
                            radius: 20.0,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                    left: 0.0,
                    right: 0.0,
                    bottom: 0.0,
                    child: AnimatedSize(
                      vsync: this,
                      curve: Curves.bounceIn,
                      duration: new Duration(microseconds: 200),
                      child: Container(
                        height: searchContainerHeight,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(15.0),
                                topRight: Radius.circular(15.0)),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black,
                                  spreadRadius: 0.5,
                                  offset: Offset(0.7, 0.7))
                            ]),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 24.0, vertical: 18.0),
                          child: Column(children: [
                            SizedBox(
                              height: 6.0,
                            ),
                            Text(
                              'Hi there',
                              style: TextStyle(fontSize: 12.0),
                            ),
                            Text(
                              'Where to?',
                              style: TextStyle(fontSize: 20.0),
                            ),
                            SizedBox(
                              height: 20.0,
                            ),
                            GestureDetector(
                              onTap: () async {
                                var res = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SearchScreen(
                                              key: widget.key,
                                            )));
                                if (res == "obtainDirection") {
                                  displayRideDetailsContainer();
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(5.0),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.black54,
                                          spreadRadius: 0.5,
                                          blurRadius: 6.0,
                                          offset: Offset(0.7, 0.7))
                                    ]),
                                child: Padding(
                                  padding: EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.search,
                                        color: Colors.yellowAccent,
                                      ),
                                      SizedBox(
                                        width: 10.0,
                                      ),
                                      Text('Search Drop Off')
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 24.0,
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.home,
                                  color: Colors.grey,
                                ),
                                SizedBox(
                                  width: 12.0,
                                ),
                                Flexible(
                                  child: FittedBox(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          Provider.of<AppData>(context,
                                                          listen: false)
                                                      .pickUpLocation !=
                                                  null
                                              ? Provider.of<AppData>(context)
                                                  .pickUpLocation!
                                                  .placeName
                                                  .toString()
                                              : "Add Home",
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(
                                          height: 4.0,
                                        ),
                                        Text(
                                          'Your living home address',
                                          style: TextStyle(
                                              color: Colors.black54,
                                              fontSize: 12.0),
                                        )
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            DividerWidget(),
                            SizedBox(
                              height: 16.0,
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.work,
                                  color: Colors.grey,
                                ),
                                SizedBox(
                                  width: 12.0,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Add Work"),
                                    SizedBox(
                                      height: 4.0,
                                    ),
                                    Text(
                                      'Your office address',
                                      style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: 12.0),
                                    )
                                  ],
                                )
                              ],
                            )
                          ]),
                        ),
                      ),
                    )),
                Positioned(
                    bottom: 0,
                    left: 0.0,
                    right: 0.0,
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(16.0),
                              topRight: Radius.circular(16.0)),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black,
                                blurRadius: 16.0,
                                spreadRadius: 0.5,
                                offset: Offset(0.7, 0.7))
                          ]),
                    )),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: AnimatedSize(
                    vsync: this,
                    curve: Curves.bounceIn,
                    duration: new Duration(microseconds: 200),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(16),
                            topLeft: Radius.circular(16.0),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black,
                              blurRadius: 16.0,
                              spreadRadius: 0.5,
                              offset: Offset(0.7, 0.7),
                            )
                          ]),
                      height: rideDetailsContainerHeight,
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 17),
                        child: Column(
                          children: [
                            Container(
                              width: double.infinity,
                              color: Colors.tealAccent[100],
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16.0),
                                child: Row(
                                  children: [
                                    Image.asset(
                                      'assets/images/taxi.png',
                                      height: 70.0,
                                      width: 80.0,
                                    ),
                                    SizedBox(
                                      width: 16,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Car",
                                          style: TextStyle(
                                            fontSize: 18,
                                          ),
                                        ),
                                        Text(
                                          ((tripDirectionDetails != null)
                                              ? tripDirectionDetails!
                                                      .durationText ??
                                                  '0Km'
                                              : ""),
                                          style: TextStyle(
                                              fontSize: 18, color: Colors.grey),
                                        )
                                      ],
                                    ),
                                    Expanded(child: Container()),
                                    Text(
                                      ((tripDirectionDetails != null)
                                          ? 'Rs ${AssistantMethods.calculateFares(tripDirectionDetails ?? DirectionDetails())}'
                                          : ''),
                                      style: TextStyle(
                                          fontSize: 18, color: Colors.grey),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 20.0,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20.0),
                              child: Row(
                                children: [
                                  Icon(
                                    FontAwesomeIcons.moneyBillAlt,
                                    size: 18,
                                    color: Colors.black54,
                                  ),
                                  SizedBox(
                                    width: 16,
                                  ),
                                  Text("Cash"),
                                  SizedBox(
                                    width: 6,
                                  ),
                                  Icon(
                                    Icons.keyboard_arrow_down,
                                    color: Colors.black54,
                                    size: 16,
                                  )
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 24,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: RaisedButton(
                                color: Colors.indigoAccent,
                                onPressed: () async {
                                  setState(() {
                                    state = "requesting";
                                  });
                                  displayRequestContainer();
                                  availableDrivers = GeoFireAssistant
                                      .nearByAvailableDriversList;
                                  searchNearestrDriver();
                                },
                                child: Padding(
                                  padding: EdgeInsets.all(17),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Request ",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Icon(
                                        FontAwesomeIcons.taxi,
                                        color: Colors.white,
                                        size: 26,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: requestRideContainerHeight,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16.0),
                            topRight: Radius.circular(16.0)),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                              spreadRadius: 0.5,
                              blurRadius: 16.0,
                              color: Colors.black54,
                              offset: Offset(0.7, 0.7))
                        ]),
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 12.0,
                            ),
                            SizedBox(
                              width: double.infinity,
                              child: AnimatedTextKit(
                                animatedTexts: [
                                  ColorizeAnimatedText('Requesting a Ride',
                                      textStyle: colorizeTextStyle,
                                      colors: colorizeColors,
                                      textAlign: TextAlign.center),
                                  ColorizeAnimatedText('Please Wait',
                                      textStyle: colorizeTextStyle,
                                      colors: colorizeColors,
                                      textAlign: TextAlign.center),
                                  ColorizeAnimatedText(
                                    'Finding a Driver',
                                    textStyle: colorizeTextStyle,
                                    colors: colorizeColors,
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                                isRepeatingAnimation: true,
                                onTap: () {
                                  print("Tap Event");
                                },
                              ),
                            ),
                            SizedBox(
                              height: 22.0,
                            ),
                            Container(
                              height: 60.0,
                              width: 60,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(26),
                                  border: Border.all(
                                      color: Colors.black54, width: 2)),
                              child: Icon(
                                Icons.close,
                                size: 26,
                                color: Colors.grey[300],
                              ),
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            GestureDetector(
                              onTap: () async {
                                cancelRideRequest();

                                resetApp();
                              },
                              child: Container(
                                width: double.infinity,
                                child: Text(
                                  "Cancel Ride",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: driverDetailHeightContainer,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16.0),
                            topRight: Radius.circular(16.0)),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                              spreadRadius: 0.5,
                              blurRadius: 16.0,
                              color: Colors.black54,
                              offset: Offset(0.7, 0.7))
                        ]),
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 6,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Driver is Coming",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 20),
                                ),
                              ],
                            ),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.star,
                                  color: Colors.yellow,
                                ),
                                Icon(
                                  Icons.star,
                                  color: Colors.yellow,
                                ),
                                Icon(
                                  Icons.star,
                                  color: Colors.yellow,
                                ),
                                Icon(
                                  Icons.star,
                                  color: Colors.yellow,
                                ),
                                Icon(
                                  Icons.star_border,
                                  color: Colors.grey,
                                )
                              ],
                            ),
                            SizedBox(
                              height: 22,
                            ),
                            Divider(),
                            Text(
                              'Whit-Toyota',
                              style: TextStyle(color: Colors.grey),
                            ),
                            Text(
                              'Samir Lama',
                              style: TextStyle(fontSize: 20),
                            ),
                            SizedBox(
                              height: 22,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                      onTap: () async {
                                        await launch(
                                            'tel:+977 ' + '9808140290');
                                      },
                                      child: Container(
                                        height: 55,
                                        width: 55,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(26),
                                            border: Border.all(
                                                width: 2, color: Colors.grey)),
                                        child: Icon(Icons.call),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text('Call')
                                  ],
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => ChatScreen(
                                                id1: 'Rajiv', id2: 'samir')));
                                  },
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        height: 55,
                                        width: 55,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(26),
                                            border: Border.all(
                                                width: 2, color: Colors.grey)),
                                        child: Icon(Icons.message),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text('Chat ')
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      driverDetailHeightContainer = 0;
                                    });
                                  },
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        height: 55,
                                        width: 55,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(26),
                                            border: Border.all(
                                                width: 2, color: Colors.grey)),
                                        child: Icon(Icons.close),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text('Cancel')
                                    ],
                                  ),
                                )
                              ],
                            )
                            // SizedBox(
                            //   height: 12.0,
                            // ),
                            // SizedBox(
                            //   width: double.infinity,
                            //   child: AnimatedTextKit(
                            //     animatedTexts: [
                            //       ColorizeAnimatedText('Requesting a Ride',
                            //           textStyle: colorizeTextStyle,
                            //           colors: colorizeColors,
                            //           textAlign: TextAlign.center),
                            //       ColorizeAnimatedText('Please Wait',
                            //           textStyle: colorizeTextStyle,
                            //           colors: colorizeColors,
                            //           textAlign: TextAlign.center),
                            //       ColorizeAnimatedText(
                            //         'Finding a Driver',
                            //         textStyle: colorizeTextStyle,
                            //         colors: colorizeColors,
                            //         textAlign: TextAlign.center,
                            //       ),
                            //     ],
                            //     isRepeatingAnimation: true,
                            //     onTap: () {
                            //       print("Tap Event");
                            //     },
                            //   ),
                            // ),
                            // SizedBox(
                            //   height: 22.0,
                            // ),
                            // Container(
                            //   height: 60.0,
                            //   width: 60,
                            //   decoration: BoxDecoration(
                            //       color: Colors.white,
                            //       borderRadius: BorderRadius.circular(26),
                            //       border:
                            //       Border.all(color: Colors.black54, width: 2)),
                            //   child: Icon(
                            //     Icons.close,
                            //     size: 26,
                            //     color: Colors.grey[300],
                            //   ),
                            // ),
                            // SizedBox(
                            //   height: 10.0,
                            // ),
                            // GestureDetector(
                            //   onTap: () async {
                            //     cancelRideRequest();
                            //
                            //     resetApp();
                            //   },
                            //   child: Container(
                            //     width: double.infinity,
                            //     child: Text(
                            //       "Cancel Ride",
                            //       textAlign: TextAlign.center,
                            //       style: TextStyle(fontSize: 12),
                            //     ),
                            //   ),
                            // )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Future<void> getPlaceDirection() async {
    var initialPos =
        Provider.of<AppData>(context, listen: false).pickUpLocation;

    var finalPos = Provider.of<AppData>(context, listen: false).dropLocation;

    var pickUpLatLng = LatLng(double.parse(initialPos!.latitude ?? '0'),
        double.parse(initialPos.longitude ?? '0.0'));
    var dropOffLatLng = LatLng(double.parse(finalPos!.latitude ?? '0'),
        double.parse(finalPos.longitude ?? '0'));
    showDialog(
        context: context,
        builder: (BuildContext context) => ProgressDialog(
              message: "Please wait....",
            ));
    var details = await AssistantMethods.obtainPlaceDirectionDetails(
        pickUpLatLng, dropOffLatLng);
    setState(() {
      tripDirectionDetails = details;
    });
    Navigator.pop(context);

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodePolyLinePointResult =
        polylinePoints.decodePolyline(details.encodedPoints ?? '');
    pLineCoordinates.clear();

    if (decodePolyLinePointResult.isNotEmpty) {
      decodePolyLinePointResult.forEach((PointLatLng pointLatLng) {
        pLineCoordinates
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }
    polyLineSet.clear();
    setState(() {
      Polyline polyline = Polyline(
          polylineId: PolylineId('PolylineId'),
          color: Colors.red,
          width: 5,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          points: pLineCoordinates,
          geodesic: true,
          jointType: JointType.round);
      polyLineSet.add(polyline);
    });
    LatLngBounds latLngBounds;
    if (pickUpLatLng.latitude > dropOffLatLng.latitude &&
        pickUpLatLng.longitude > dropOffLatLng.longitude) {
      latLngBounds =
          LatLngBounds(southwest: dropOffLatLng, northeast: pickUpLatLng);
    } else if (pickUpLatLng.longitude > dropOffLatLng.longitude) {
      latLngBounds = LatLngBounds(
          southwest: LatLng(pickUpLatLng.latitude, dropOffLatLng.longitude),
          northeast: LatLng(dropOffLatLng.latitude, pickUpLatLng.longitude));
    } else if (pickUpLatLng.latitude > dropOffLatLng.latitude) {
      latLngBounds = LatLngBounds(
          southwest: LatLng(dropOffLatLng.latitude, pickUpLatLng.longitude),
          northeast: LatLng(pickUpLatLng.latitude, dropOffLatLng.longitude));
    } else {
      latLngBounds =
          LatLngBounds(southwest: pickUpLatLng, northeast: dropOffLatLng);
    }
    newGoogleMapController!
        .animateCamera(CameraUpdate.newLatLngBounds(latLngBounds, 70));
    Marker pickUpMarker = Marker(
      markerId: MarkerId('pickID'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
      infoWindow: InfoWindow(
        title: initialPos.placeName,
        snippet: "my location",
      ),
      position: pickUpLatLng,
    );

    Marker dropOffMarker = Marker(
      markerId: MarkerId('dropOfID'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      infoWindow: InfoWindow(
        title: finalPos.placeName ?? 'Drop off',
        snippet: "DropOff location",
      ),
      position: dropOffLatLng,
    );
    setState(() {
      markerSet.add(pickUpMarker);
      markerSet.add(dropOffMarker);
    });
    Circle pickUpCirlce = Circle(
        circleId: CircleId("pickUpID"),
        fillColor: Colors.purple,
        center: pickUpLatLng,
        radius: 12,
        strokeWidth: 4,
        strokeColor: Colors.deepPurple);

    Circle dropOffCirlce = Circle(
      circleId: CircleId("dropOffId"),
      fillColor: Colors.yellow,
      center: dropOffLatLng,
      radius: 12,
      strokeWidth: 4,
      strokeColor: Colors.red,
    );

    setState(() {
      circleSet.add(pickUpCirlce);
      circleSet.add(dropOffCirlce);
    });
  }

  resetApp() {
    setState(() {
      drawerOpen = true;
      searchContainerHeight = 300.0;
      rideDetailsContainerHeight = 0;
      requestRideContainerHeight = 0;
      bottomPaddingOfMap = 230.0;

      polyLineSet.clear();
      markerSet.clear(); // circlesSet.clear();
      pLineCoordinates.clear();

      statusRide = "";
      driverName = "";
      driverphone = "";
      carDetailsDriver = "";
      String rideStatus = "Driver is Coming";
      driverDetailHeightContainer = 0.0;
    });

    locatePosition();
  }

  void initGeoFireListener() {
    Geofire.initialize("availableDrivers");

    Geofire.queryAtLocation(
            currentPosition!.latitude, currentPosition!.longitude, 15)!
        .listen((map) {
      if (map != null) {
        var callBack = map['callBack'];

        //latitude will be retrieved from map['latitude']
        //longitude will be retrieved from map['longitude']

        switch (callBack) {
          case Geofire.onKeyEntered:
            NearByAvailableDrivers nearByAvailableDrivers =
                NearByAvailableDrivers();
            nearByAvailableDrivers.key = map["key"];
            nearByAvailableDrivers.latitude = map["latitude"];
            nearByAvailableDrivers.longitude = map["longitude"];
            GeoFireAssistant.nearByAvailableDriversList
                .add(nearByAvailableDrivers);
            if (nearByAvailableDriverKeysLoaded == true) {
              updateAvailableDriverOnMap();
            }
            // keysRetrieved.add(map["key"]);
            break;

          case Geofire.onKeyExited:
            GeoFireAssistant.removeDriverFromList(map["key"]);
            updateAvailableDriverOnMap();
            break;

          case Geofire.onKeyMoved:
            NearByAvailableDrivers nearByAvailableDrivers =
                NearByAvailableDrivers();
            nearByAvailableDrivers.key = map["key"];
            nearByAvailableDrivers.latitude = map["latitude"];
            nearByAvailableDrivers.longitude = map["longitude"];
            GeoFireAssistant.updateDriverNearByLocation(nearByAvailableDrivers);
            updateAvailableDriverOnMap();
            break;

          case Geofire.onGeoQueryReady:
            updateAvailableDriverOnMap();
            break;
        }
      }

      setState(() {});
    });
  }

  void updateAvailableDriverOnMap() {
    setState(() {
      markerSet.clear();
    });
    Set<Marker> tMarkers = Set<Marker>();
    for (NearByAvailableDrivers driver
        in GeoFireAssistant.nearByAvailableDriversList) {
      LatLng driverAvailablePosition =
          LatLng(driver.latitude, driver.longitude);
      Marker marker = Marker(
        markerId: MarkerId('driver${driver.key}'),
        position: driverAvailablePosition,
        icon: nearByIcon ??
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
        rotation: AssistantMethods.createRandomNumber(360),
      );
      tMarkers.add(marker);
    }
    setState(() {
      markerSet = tMarkers;
    });
  }

  void createIconMarker() {
    if (nearByIcon == null) {
      ImageConfiguration imageConfiguration =
          createLocalImageConfiguration(context, size: Size(2, 2));
      BitmapDescriptor.fromAssetImage(
              imageConfiguration, "assets/images/car_ios.png")
          .then((value) {
        nearByIcon = value;
      });
    }
  }

  void noDriverFound() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => NoAvailableDriverDialog());
  }

  void searchNearestrDriver() {
    if (availableDrivers!.length == 0) {
      cancelRideRequest();
      resetApp();
      noDriverFound();
      return;
    }
    var driver = availableDrivers![0];
    notifyDriver(driver);
    availableDrivers!.removeAt(0);
  }

  void notifyDriver(NearByAvailableDrivers drivers) {
    driverRef
        .child(drivers.key)
        .child("newRide")
        .set(rideRequestReference!.key);
    driverRef
        .child(drivers.key)
        .child('token')
        .once()
        .then((DataSnapshot snap) {
      if (snap.value != null) {
        String token = snap.value.toString();

        AssistantMethods.sendNotificationDriver(
            token, context, rideRequestReference!.key);
      } else {
        return;
      }

      const oneSecondPassed = Duration(seconds: 1);
      var timer = Timer.periodic(oneSecondPassed, (timer) {
        if (state != 'requesting') {
          driverRef.child(drivers.key).child("newRide").set("cancelled");
          driverRef.child(drivers.key).child("newRide").onDisconnect();
          driverRequestTimeOut = 40;
          timer.cancel();
        }
        driverRequestTimeOut = driverRequestTimeOut - 1;
        driverRef
            .child(drivers.key)
            .child("newRide")
            .onValue
            .listen((event) async {
          if (event.snapshot.value.toString() == 'accepted') {
            displayDetailHeightContainer();
            driverRef.child(drivers.key).child("newRide").onDisconnect();
            driverRequestTimeOut = 40;

            timer.cancel();
          } else if (event.snapshot.value.toString() == 'arrived') {
            setState(() {
              driverDetailHeightContainer = 0;
            });

            Fluttertoast.showToast(
                msg: "Driver had Arrived\nEnjoy your trip...");

            timer.cancel();
          } else if (event.snapshot.value.toString() == 'endTrip') {
            return showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text("Would you like to pay through e-wallet?"),
                content: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          FittedBox(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            KhaltiPaymentApp()));
                              },
                              child: Container(
                                height: 40,
                                width: 140,
                                decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(4)),
                                alignment: Alignment.center,
                                child: Text(
                                  'yes',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 24,
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: FittedBox(
                              child: Container(
                                height: 40,
                                width: 140,
                                decoration: BoxDecoration(
                                    color: Colors.orange,
                                    borderRadius: BorderRadius.circular(4)),
                                alignment: Alignment.center,
                                child: Text(
                                  'No',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                      Text('\n\n\nRate Your Service'),
                      RatingBar.builder(
                        initialRating: 3,
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                        itemBuilder: (context, _) => Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        onRatingUpdate: (rating) {
                          print(rating);
                        },
                      ),
                    ],
                  ),
                ),
                actions: <Widget>[
                  FlatButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                    child: Text("okay"),
                  ),
                ],
              ),
            );
          }

          if (event.snapshot.value.toString() == 'ended') {
            int fare = int.parse(event.snapshot.value['fares'].toString());

            var res = await showDialog(
                context: context,
                builder: (BuildContext context) =>
                    CollectFareDialog(paymentMethod: "cash", fareAmount: fare));

            if (res == "close") {
              rideRequestReference!.onDisconnect();
              rideRequestReference = null;
              rideStreamSubscription!.cancel();
              rideStreamSubscription = null;
              resetApp();
            }
          }
        });

        if (driverRequestTimeOut == 0) {
          driverRef.child(drivers.key).child("newRide").set("timeout");
          driverRef.child(drivers.key).child("newRide").onDisconnect();
          driverRequestTimeOut = 40;
          timer.cancel();
          searchNearestrDriver();
        }
      });
    });
  }
}
