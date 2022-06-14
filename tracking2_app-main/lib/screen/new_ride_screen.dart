// //@dart=2.1
//
// import 'dart:async';
//
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:tracking2_app/model/rideDetails.dart';
//
// class NewRideScreen extends StatefulWidget {
//   final RideDetails rideDetails;
//   const NewRideScreen({Key key, this.rideDetails}) : super(key: key);
//   static final CameraPosition _kGooglePlex = CameraPosition(
//     target: LatLng(37.42796133580664, -122.085749655962),
//     zoom: 14.4746,
//   );
//
//   @override
//   _NewRideScreenState createState() => _NewRideScreenState();
// }
//
// class _NewRideScreenState extends State<NewRideScreen> {
//   Completer<GoogleMapController> _controllerGoogleMap = Completer();
//
//   GoogleMapController newRideGoogleMapController;
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           GoogleMap(
//             // padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
//             mapType: MapType.normal,
//             myLocationButtonEnabled: true,
//             // markers: markerSet,
//             // circles: circleSet,
//             // polylines: polyLineSet,
//             initialCameraPosition: NewRideScreen._kGooglePlex,
//             myLocationEnabled: true,
//
//             onMapCreated: (GoogleMapController controller) {
//               _controllerGoogleMap.complete(controller);
//
//               newRideGoogleMapController = controller;
//               // setState(() {
//               //   bottomPaddingOfMap = 300.0;
//               // });
//               // locatePosition();
//             },
//           ),
//           Positioned(
//             left: 0,
//             right: 0,
//             bottom: 0,
//             child: Container(
//               decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.only(
//                       topLeft: Radius.circular(16),
//                       topRight: Radius.circular(16)),
//                   boxShadow: [
//                     BoxShadow(
//                         color: Colors.black38,
//                         blurRadius: 16,
//                         spreadRadius: 0.5,
//                         offset: Offset(0.7, 0.7))
//                   ]),
//               height: 260,
//               child: Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 18),
//                 child: Column(
//                   children: [
//                     Text(

//                       "10 mins",
//                       style: TextStyle(fontSize: 14, color: Colors.deepPurple),
//                     ),
//                     SizedBox(
//                       height: 6.0,
//                     ),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           "Samir Lama",
//                           style: TextStyle(fontSize: 24),
//                         ),
//                         Padding(
//                           padding: EdgeInsets.only(right: 10),
//                           child: Icon(Icons.phone_android),
//                         ),
//                       ],
//                     ),
//                     SizedBox(
//                       height: 26.0,
//                     ),
//                     Row(
//                       children: [
//                         Image.asset(
//                           "assets/images/pickicon.png",
//                           height: 16,
//                           width: 16,
//                         ),
//                         SizedBox(
//                           width: 18,
//                         ),
//                         Expanded(
//                           child: Container(
//                             child: Text(
//                               "Street#44 Ktam,Nepal",
//                               style: TextStyle(
//                                   fontSize: 18,
//                                   overflow: TextOverflow.ellipsis),
//                             ),
//                           ),
//                         )
//                       ],
//                     ),
//                     SizedBox(
//                       height: 16.0,
//                     ),
//                     Row(
//                       children: [
//                         Image.asset(
//                           "assets/images/desticon.png",
//                           height: 16,
//                           width: 16,
//                         ),
//                         SizedBox(
//                           width: 18,
//                         ),
//                         Expanded(
//                           child: Container(
//                             child: Text(
//                               "Street#88 Ktam,Nepal",
//                               style: TextStyle(
//                                   fontSize: 18,
//                                   overflow: TextOverflow.ellipsis),
//                             ),
//                           ),
//                         )
//                       ],
//                     ),
//                     SizedBox(
//                       height: 26,
//                     ),
//                     Padding(
//                       padding: EdgeInsets.symmetric(horizontal: 16),
//                       child: RaisedButton(
//                         onPressed: () {},
//                         color: Theme.of(context).accentColor,
//                         child: Padding(
//                           padding: EdgeInsets.all(17),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text(
//                                 "Arrived",
//                                 style: TextStyle(
//                                     fontSize: 20,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.white),
//                               ),
//                               Icon(
//                                 Icons.directions_car,
//                                 color: Colors.white,
//                                 size: 26,
//                               )
//                             ],
//                           ),
//                         ),
//                       ),
//                     )
//                   ],
//                 ),
//               ),
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }
