// import 'dart:async';
//
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:provider/provider.dart';
// import 'package:tracking2_app/Assistants/assistantMethods.dart';
// import 'package:tracking2_app/DataHandler/appData.dart';
// import 'package:tracking2_app/configMaps.dart';
// import 'package:tracking2_app/model/directionDetail.dart';
// import 'package:tracking2_app/screen/search_screen.dart';
// import 'package:tracking2_app/widgets/Divider.dart';
// import 'package:flutter_polyline_points/flutter_polyline_points.dart';
// import 'package:animated_text_kit/animated_text_kit.dart';
// import 'package:tracking2_app/widgets/loading.dart';
//
// class MapMainScreen extends StatefulWidget {
//   const MapMainScreen({Key? key}) : super(key: key);
//
//   @override
//   _MapMainScreenState createState() => _MapMainScreenState();
// }
//
// class _MapMainScreenState extends State<MapMainScreen>
//     with TickerProviderStateMixin {
//   Completer<GoogleMapController> _controllerGoogleMap = Completer();
//   GoogleMapController? newGoogleMapController;
//   static final CameraPosition _kGooglePlex = CameraPosition(
//     target: LatLng(37.42796133580664, -122.085749655962),
//     zoom: 14.4746,
//   );
//   Position? currentPosition;
//   double bottomPaddingOfMap = 0;
//
//   DirectionDetails? tripDirectionDetails;
//   bool drawerOpen = true;
//   GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
//
//   Set<Marker> markerSet = {};
//   Set<Circle> circleSet = {};
//   double rideDetailsContainerHeight = 0;
//   double requestRideContainerHeight = 0;
//   double searchContainerHeight = 300;
//
//   void displayRideDetailsContainer() async {
//     await getPlaceDirection();
//     setState(() {
//       searchContainerHeight = 0;
//       rideDetailsContainerHeight = 240;
//       bottomPaddingOfMap = 230.0;
//       drawerOpen = false;
//     });
//   }
//
//   void locatePosition() async {
//     Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high);
//     currentPosition = position;
//     LatLng latLanPosition = LatLng(position.latitude, position.longitude);
//     CameraPosition cameraPosition =
//         new CameraPosition(target: latLanPosition, zoom: 14);
//     newGoogleMapController!
//         .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
//     String address =
//         await AssistantMethods().searchCoordinateAddress(position, context);
//     print('This is your address::' + address);
//   }
//
//   void displayRequestContainer() {
//     setState(() {
//       requestRideContainerHeight = 250;
//       rideDetailsContainerHeight = 0;
//       bottomPaddingOfMap = 230;
//       drawerOpen = true;
//     });
//     saveRideRequest();
//   }
//
//   DatabaseReference? rideRequestReference;
//
//   bool init = true;
//   @override
//   void didChangeDependencies() {
//     // TODO: implement didChangeDependencies
//     super.didChangeDependencies();
//     if (init) {
//       Provider.of<AppData>(context, listen: false).pickUpLocation;
//     }
//     init = false;
//   }
//
//   List<LatLng> pLineCoordinates = [];
//   Set<Polyline> polyLineSet = {};
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     AssistantMethods.getCurrentOnlineUserInfo();
//
//     super.initState();
//   }
//
//   void saveRideRequest() {
//     rideRequestReference =
//         FirebaseDatabase.instance.reference().child("Ride Requests").push();
//     var pickUp = Provider.of<AppData>(context, listen: false).pickUpLocation;
//     var dropOf = Provider.of<AppData>(context, listen: false).dropLocation;
//     Map picUpLocMap = {
//       'latitude': pickUp!.latitude.toString(),
//       'longitude': pickUp.longitude.toString(),
//     };
//
//     Map dropOfLocMap = {
//       'latitude': dropOf?.latitude.toString() ?? '',
//       'longitude': dropOf?.longitude.toString() ?? '',
//     };
//
//     Map rideInfoMap = {
//       'driver_id': 'waiting',
//       'payment_method': 'cash',
//       'pickup': picUpLocMap,
//       'dropoff': dropOfLocMap,
//       'created_at': DateTime.now().toString(),
//       'rider_name': userCurrentInfo?.name ?? '',
//       'rider_pone': userCurrentInfo?.phone ?? ' ',
//       'pickup_address': pickUp.placeName,
//       'dropoff_address': dropOf?.placeName ?? ''
//     };
//     rideRequestReference!.set(rideInfoMap);
//   }
//
//   void cancelRideRequest() {
//     rideRequestReference!.remove();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     const colorizeColors = [
//       Colors.green,
//       Colors.purple,
//       Colors.pink,
//       Colors.blue,
//       Colors.yellow,
//       Colors.red,
//     ];
//
//     const colorizeTextStyle = TextStyle(
//       fontSize: 35.0,
//       fontFamily: 'Signatra',
//     );
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Google Map'),
//         centerTitle: true,
//       ),
//       body: Stack(
//         children: [
//           GoogleMap(
//             padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
//             mapType: MapType.normal,
//             myLocationButtonEnabled: true,
//             markers: markerSet,
//             circles: circleSet,
//             polylines: polyLineSet,
//             initialCameraPosition: _kGooglePlex,
//             myLocationEnabled: true,
//             zoomGesturesEnabled: true,
//             zoomControlsEnabled: true,
//             onMapCreated: (GoogleMapController controller) {
//               _controllerGoogleMap.complete(controller);
//
//               newGoogleMapController = controller;
//               setState(() {
//                 bottomPaddingOfMap = 300.0;
//               });
//               locatePosition();
//             },
//           ),
//           Positioned(
//             top: 36.0,
//             left: 22.0,
//             child: GestureDetector(
//               onTap: () {
//                 if (drawerOpen) {
//                   scaffoldKey.currentState?.openDrawer();
//                 } else {
//                   resetApp();
//                 }
//               },
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(22.0),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black,
//                       blurRadius: 6.0,
//                       spreadRadius: 0.5,
//                       offset: Offset(
//                         0.7,
//                         0.7,
//                       ),
//                     ),
//                   ],
//                 ),
//                 child: CircleAvatar(
//                   backgroundColor: Colors.white,
//                   child: Icon(
//                     (drawerOpen) ? Icons.menu : Icons.close,
//                     color: Colors.black,
//                   ),
//                   radius: 20.0,
//                 ),
//               ),
//             ),
//           ),
//           Positioned(
//               left: 0.0,
//               right: 0.0,
//               bottom: 0.0,
//               child: AnimatedSize(
//                 vsync: this,
//                 curve: Curves.bounceIn,
//                 duration: new Duration(microseconds: 200),
//                 child: Container(
//                   height: searchContainerHeight,
//                   decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.only(
//                           topLeft: Radius.circular(15.0),
//                           topRight: Radius.circular(15.0)),
//                       boxShadow: [
//                         BoxShadow(
//                             color: Colors.black,
//                             spreadRadius: 0.5,
//                             offset: Offset(0.7, 0.7))
//                       ]),
//                   child: Padding(
//                     padding:
//                         EdgeInsets.symmetric(horizontal: 24.0, vertical: 18.0),
//                     child: Column(children: [
//                       SizedBox(
//                         height: 6.0,
//                       ),
//                       Text(
//                         'Hi there',
//                         style: TextStyle(fontSize: 12.0),
//                       ),
//                       Text(
//                         'Where to?',
//                         style: TextStyle(fontSize: 20.0),
//                       ),
//                       SizedBox(
//                         height: 20.0,
//                       ),
//                       GestureDetector(
//                         onTap: () async {
//                           var res = await Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                   builder: (context) => SearchScreen(
//                                         key: widget.key,
//                                       )));
//                           if (res == "obtainDirection") {
//                             displayRideDetailsContainer();
//                           }
//                         },
//                         child: Container(
//                           decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(5.0),
//                               boxShadow: [
//                                 BoxShadow(
//                                     color: Colors.black54,
//                                     spreadRadius: 0.5,
//                                     blurRadius: 6.0,
//                                     offset: Offset(0.7, 0.7))
//                               ]),
//                           child: Padding(
//                             padding: EdgeInsets.all(12),
//                             child: Row(
//                               children: [
//                                 Icon(
//                                   Icons.search,
//                                   color: Colors.yellowAccent,
//                                 ),
//                                 SizedBox(
//                                   width: 10.0,
//                                 ),
//                                 Text('Search Drop Off')
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                       SizedBox(
//                         height: 24.0,
//                       ),
//                       Row(
//                         children: [
//                           Icon(
//                             Icons.home,
//                             color: Colors.grey,
//                           ),
//                           SizedBox(
//                             width: 12.0,
//                           ),
//                           Flexible(
//                             child: FittedBox(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     Provider.of<AppData>(context, listen: false)
//                                                 .pickUpLocation !=
//                                             null
//                                         ? Provider.of<AppData>(context)
//                                             .pickUpLocation!
//                                             .placeName
//                                             .toString()
//                                         : "Add Home",
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                                   SizedBox(
//                                     height: 4.0,
//                                   ),
//                                   Text(
//                                     'Your living home address',
//                                     style: TextStyle(
//                                         color: Colors.black54, fontSize: 12.0),
//                                   )
//                                 ],
//                               ),
//                             ),
//                           )
//                         ],
//                       ),
//                       SizedBox(
//                         height: 10.0,
//                       ),
//                       DividerWidget(),
//                       SizedBox(
//                         height: 16.0,
//                       ),
//                       Row(
//                         children: [
//                           Icon(
//                             Icons.work,
//                             color: Colors.grey,
//                           ),
//                           SizedBox(
//                             width: 12.0,
//                           ),
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text("Add Work"),
//                               SizedBox(
//                                 height: 4.0,
//                               ),
//                               Text(
//                                 'Your office address',
//                                 style: TextStyle(
//                                     color: Colors.black54, fontSize: 12.0),
//                               )
//                             ],
//                           )
//                         ],
//                       )
//                     ]),
//                   ),
//                 ),
//               )),
//           Positioned(
//               bottom: 0,
//               left: 0.0,
//               right: 0.0,
//               child: Container(
//                 decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.only(
//                         topLeft: Radius.circular(16.0),
//                         topRight: Radius.circular(16.0)),
//                     boxShadow: [
//                       BoxShadow(
//                           color: Colors.black,
//                           blurRadius: 16.0,
//                           spreadRadius: 0.5,
//                           offset: Offset(0.7, 0.7))
//                     ]),
//               )),
//           Positioned(
//             bottom: 0,
//             left: 0,
//             right: 0,
//             child: AnimatedSize(
//               vsync: this,
//               curve: Curves.bounceIn,
//               duration: new Duration(microseconds: 200),
//               child: Container(
//                 decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.only(
//                       topRight: Radius.circular(16),
//                       topLeft: Radius.circular(16.0),
//                     ),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black,
//                         blurRadius: 16.0,
//                         spreadRadius: 0.5,
//                         offset: Offset(0.7, 0.7),
//                       )
//                     ]),
//                 height: rideDetailsContainerHeight,
//                 child: Padding(
//                   padding: EdgeInsets.symmetric(vertical: 17),
//                   child: Column(
//                     children: [
//                       Container(
//                         width: double.infinity,
//                         color: Colors.tealAccent[100],
//                         child: Padding(
//                           padding: EdgeInsets.symmetric(horizontal: 16.0),
//                           child: Row(
//                             children: [
//                               Image.asset(
//                                 'assets/images/taxi.png',
//                                 height: 70.0,
//                                 width: 80.0,
//                               ),
//                               SizedBox(
//                                 width: 16,
//                               ),
//                               Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     "Car",
//                                     style: TextStyle(
//                                       fontSize: 18,
//                                     ),
//                                   ),
//                                   Text(
//                                     ((tripDirectionDetails != null)
//                                         ? tripDirectionDetails!.durationText ??
//                                             '0Km'
//                                         : ""),
//                                     style: TextStyle(
//                                         fontSize: 18, color: Colors.grey),
//                                   )
//                                 ],
//                               ),
//                               Expanded(child: Container()),
//                               Text(
//                                 ((tripDirectionDetails != null)
//                                     ? 'Rs ${AssistantMethods.calculateFares(tripDirectionDetails ?? DirectionDetails())}'
//                                     : ''),
//                                 style:
//                                     TextStyle(fontSize: 18, color: Colors.grey),
//                               )
//                             ],
//                           ),
//                         ),
//                       ),
//                       SizedBox(
//                         height: 20.0,
//                       ),
//                       Padding(
//                         padding: EdgeInsets.symmetric(horizontal: 20.0),
//                         child: Row(
//                           children: [
//                             Icon(
//                               FontAwesomeIcons.moneyBillAlt,
//                               size: 18,
//                               color: Colors.black54,
//                             ),
//                             SizedBox(
//                               width: 16,
//                             ),
//                             Text("Cash"),
//                             SizedBox(
//                               width: 6,
//                             ),
//                             Icon(
//                               Icons.keyboard_arrow_down,
//                               color: Colors.black54,
//                               size: 16,
//                             )
//                           ],
//                         ),
//                       ),
//                       SizedBox(
//                         height: 24,
//                       ),
//                       Padding(
//                         padding: EdgeInsets.symmetric(horizontal: 16),
//                         child: RaisedButton(
//                           color: Colors.indigoAccent,
//                           onPressed: () async {
//                             displayRequestContainer();
//                           },
//                           child: Padding(
//                             padding: EdgeInsets.all(17),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Text(
//                                   "Request ",
//                                   style: TextStyle(
//                                     fontSize: 20,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.white,
//                                   ),
//                                 ),
//                                 Icon(
//                                   FontAwesomeIcons.taxi,
//                                   color: Colors.white,
//                                   size: 26,
//                                 )
//                               ],
//                             ),
//                           ),
//                         ),
//                       )
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           Positioned(
//             bottom: 0,
//             left: 0,
//             right: 0,
//             child: Container(
//               height: requestRideContainerHeight,
//               decoration: BoxDecoration(
//                   borderRadius: BorderRadius.only(
//                       topLeft: Radius.circular(16.0),
//                       topRight: Radius.circular(16.0)),
//                   color: Colors.white,
//                   boxShadow: [
//                     BoxShadow(
//                         spreadRadius: 0.5,
//                         blurRadius: 16.0,
//                         color: Colors.black54,
//                         offset: Offset(0.7, 0.7))
//                   ]),
//               child: Padding(
//                 padding: EdgeInsets.all(30),
//                 child: SingleChildScrollView(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       SizedBox(
//                         height: 12.0,
//                       ),
//                       // SizedBox(
//                       //   width: double.infinity,
//                       //   child: AnimatedTextKit(
//                       //     animatedTexts: [
//                       //       ColorizeAnimatedText('Requesting a Ride',
//                       //           textStyle: colorizeTextStyle,
//                       //           colors: colorizeColors,
//                       //           textAlign: TextAlign.center),
//                       //       ColorizeAnimatedText('Please Wait',
//                       //           textStyle: colorizeTextStyle,
//                       //           colors: colorizeColors,
//                       //           textAlign: TextAlign.center),
//                       //       ColorizeAnimatedText(
//                       //         'Finding a Driver',
//                       //         textStyle: colorizeTextStyle,
//                       //         colors: colorizeColors,
//                       //         textAlign: TextAlign.center,
//                       //       ),
//                       //     ],
//                       //     isRepeatingAnimation: true,
//                       //     onTap: () {
//                       //       print("Tap Event");
//                       //     },
//                       //   ),
//                       // ),
//                       SizedBox(
//                         height: 22.0,
//                       ),
//                       Container(
//                         height: 60.0,
//                         width: 60,
//                         decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(26),
//                             border:
//                                 Border.all(color: Colors.black54, width: 2)),
//                         child: Icon(
//                           Icons.close,
//                           size: 26,
//                           color: Colors.grey[300],
//                         ),
//                       ),
//                       SizedBox(
//                         height: 10.0,
//                       ),
//                       GestureDetector(
//                         onTap: () async {
//                           cancelRideRequest();
//
//                           resetApp();
//                         },
//                         child: Container(
//                           width: double.infinity,
//                           child: Text(
//                             "Cancel Ride",
//                             textAlign: TextAlign.center,
//                             style: TextStyle(fontSize: 12),
//                           ),
//                         ),
//                       )
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           )
//         ],
//       ),
//     );
//   }
//
//   Future<void> getPlaceDirection() async {
//     var initialPos =
//         Provider.of<AppData>(context, listen: false).pickUpLocation;
//
//     var finalPos = Provider.of<AppData>(context, listen: false).dropLocation;
//
//     var pickUpLatLng = LatLng(double.parse(initialPos!.latitude ?? '0'),
//         double.parse(initialPos.longitude ?? '0.0'));
//     var dropOffLatLng = LatLng(double.parse(finalPos!.latitude ?? '0'),
//         double.parse(finalPos.longitude ?? '0'));
//     showDialog(
//         context: context,
//         builder: (BuildContext context) => ProgressDialog(
//               message: "Please wait....",
//             ));
//     var details = await AssistantMethods.obtainPlaceDirectionDetails(
//         pickUpLatLng, dropOffLatLng);
//     setState(() {
//       tripDirectionDetails = details;
//     });
//     Navigator.pop(context);
//
//     PolylinePoints polylinePoints = PolylinePoints();
//     List<PointLatLng> decodePolyLinePointResult =
//         polylinePoints.decodePolyline(details.encodedPoints ?? '');
//     pLineCoordinates.clear();
//
//     if (decodePolyLinePointResult.isNotEmpty) {
//       decodePolyLinePointResult.forEach((PointLatLng pointLatLng) {
//         pLineCoordinates
//             .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
//       });
//     }
//     polyLineSet.clear();
//     setState(() {
//       Polyline polyline = Polyline(
//           polylineId: PolylineId('PolylineId'),
//           color: Colors.red,
//           width: 5,
//           startCap: Cap.roundCap,
//           endCap: Cap.roundCap,
//           points: pLineCoordinates,
//           geodesic: true,
//           jointType: JointType.round);
//       polyLineSet.add(polyline);
//     });
//     LatLngBounds latLngBounds;
//     if (pickUpLatLng.latitude > dropOffLatLng.latitude &&
//         pickUpLatLng.longitude > dropOffLatLng.longitude) {
//       latLngBounds =
//           LatLngBounds(southwest: dropOffLatLng, northeast: pickUpLatLng);
//     } else if (pickUpLatLng.longitude > dropOffLatLng.longitude) {
//       latLngBounds = LatLngBounds(
//           southwest: LatLng(pickUpLatLng.latitude, dropOffLatLng.longitude),
//           northeast: LatLng(dropOffLatLng.latitude, pickUpLatLng.longitude));
//     } else if (pickUpLatLng.latitude > dropOffLatLng.latitude) {
//       latLngBounds = LatLngBounds(
//           southwest: LatLng(dropOffLatLng.latitude, pickUpLatLng.longitude),
//           northeast: LatLng(pickUpLatLng.latitude, dropOffLatLng.longitude));
//     } else {
//       latLngBounds =
//           LatLngBounds(southwest: pickUpLatLng, northeast: dropOffLatLng);
//     }
//     newGoogleMapController!
//         .animateCamera(CameraUpdate.newLatLngBounds(latLngBounds, 70));
//     Marker pickUpMarker = Marker(
//       markerId: MarkerId('pickID'),
//       icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
//       infoWindow: InfoWindow(
//         title: initialPos.placeName,
//         snippet: "my location",
//       ),
//       position: pickUpLatLng,
//     );
//
//     Marker dropOffMarker = Marker(
//       markerId: MarkerId('dropOfID'),
//       icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
//       infoWindow: InfoWindow(
//         title: finalPos.placeName ?? 'Drop off',
//         snippet: "DropOff location",
//       ),
//       position: dropOffLatLng,
//     );
//     setState(() {
//       markerSet.add(pickUpMarker);
//       markerSet.add(dropOffMarker);
//     });
//     Circle pickUpCirlce = Circle(
//         circleId: CircleId("pickUpID"),
//         fillColor: Colors.purple,
//         center: pickUpLatLng,
//         radius: 12,
//         strokeWidth: 4,
//         strokeColor: Colors.deepPurple);
//
//     Circle dropOffCirlce = Circle(
//       circleId: CircleId("dropOffId"),
//       fillColor: Colors.yellow,
//       center: dropOffLatLng,
//       radius: 12,
//       strokeWidth: 4,
//       strokeColor: Colors.red,
//     );
//
//     setState(() {
//       circleSet.add(pickUpCirlce);
//       circleSet.add(dropOffCirlce);
//     });
//   }
//
//   resetApp() {
//     setState(() {
//       drawerOpen = true;
//       searchContainerHeight = 300.0;
//       rideDetailsContainerHeight = 0;
//       requestRideContainerHeight = 0;
//       bottomPaddingOfMap = 230.0;
//
//       polyLineSet.clear();
//       markerSet.clear(); // circlesSet.clear();
//       pLineCoordinates.clear();
//
//       // statusRide = "";
//       // driverName = "";
//       // driverphone = "";
//       // carDetailsDriver = "";
//       // rideStatus = "Driver is Coming";
//       // driverDetailsContainerHeight = 0.0;
//     });
//
//     locatePosition();
//   }
// }
