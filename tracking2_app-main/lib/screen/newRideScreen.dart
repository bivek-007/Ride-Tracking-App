//@dart=2.1
import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tracking2_app/Assistants/assistantMethods.dart';
import 'package:tracking2_app/Assistants/maoKitAssitant.dart';
import 'package:tracking2_app/DataHandler/appData.dart';
import 'package:tracking2_app/chat/chat_screen.dart';
import 'package:tracking2_app/configMaps.dart';
import 'package:tracking2_app/main.dart';
import 'package:tracking2_app/model/rideDetails.dart';
import 'package:tracking2_app/screen/home_page/home_tab_screen.dart';
import 'package:tracking2_app/widgets/loading.dart';

class NewRideScreen extends StatefulWidget {
  final RideDetails rideDetails;
  const NewRideScreen({Key key, this.rideDetails}) : super(key: key);
  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  _NewRideScreenState createState() => _NewRideScreenState();
}

class _NewRideScreenState extends State<NewRideScreen> {
  Completer<GoogleMapController> _controllerGoogleMap = Completer();

  GoogleMapController newRideGoogleMapController;

  Set<Marker> markerSet = Set<Marker>();
  Set<Circle> circleSet = Set<Circle>();
  Set<Polyline> polylineSet = Set<Polyline>();
  List<LatLng> polylineCoOrdinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  double mapPaddingFromBottom = 0;
  var geolocator = Geolocator();
  var locationOptions =
      LocationOptions(accuracy: LocationAccuracy.bestForNavigation);
  BitmapDescriptor animatingMarkerIcon;
  Position myPosition;
  String status = "accepted";
  String durationRide = "";

  bool isRequestingDirection = false;

  String btntitle = "Arrived";
  Color btnColor = Colors.blue;

  DatabaseReference rideRequestRef = FirebaseDatabase.instance
      .reference()
      .child('drivers')
      .child(currentfirebaseUser.uid)
      .child("newRide");

  Timer timer;
  int durationCOunter = 0;

  @override
  @override
  void initState() {
    acceptRideRequest();
  }

  void createIconMarker() {
    if (animatingMarkerIcon == null) {
      ImageConfiguration imageConfiguration =
          createLocalImageConfiguration(context, size: Size(2, 2));
      BitmapDescriptor.fromAssetImage(
              imageConfiguration, "assets/images/car_ios.png")
          .then((value) {
        animatingMarkerIcon = value;
      });
    }
  }

  void getRideLiveLocationUpdate() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    myPosition = position;
    LatLng oldPos = LatLng(0, 0);

    rideStreamSubscription =
        Geolocator.getPositionStream().listen((Position position) {
      currentPosition = position;
      LatLng mposition = LatLng(position.latitude, position.longitude);
      var rot = MapKitAssistant.getMarkerRotation(oldPos.latitude,
          oldPos.longitude, myPosition.latitude, myPosition.longitude);
      Marker animatingMarker = Marker(
          markerId: MarkerId('animating'),
          position: mposition,
          rotation: rot,
          icon: animatingMarkerIcon,
          infoWindow: InfoWindow(title: "Current Location"));
      setState(() {
        CameraPosition cameraPosition =
            new CameraPosition(target: mposition, zoom: 17);
        newRideGoogleMapController
            .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
        markerSet.removeWhere((marker) => marker.markerId.value == "animating");
        markerSet.add(animatingMarker);
      });
      oldPos = mposition;
      updateRideDetails();
      String rideRequestId = widget.rideDetails.ride_request_id;

      Map locMap = {
        "latitude": currentPosition.latitude.toString(),
        "longitude": currentPosition.longitude.toString()
      };
      newRequestRef.child(rideRequestId).child('driver_location').set(locMap);
    });
  }

  @override
  Widget build(BuildContext context) {
    createIconMarker();
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(bottom: mapPaddingFromBottom),
            mapType: MapType.normal,
            myLocationButtonEnabled: true,
            markers: markerSet,
            circles: circleSet,
            polylines: polylineSet,
            initialCameraPosition: NewRideScreen._kGooglePlex,
            myLocationEnabled: true,
            onMapCreated: (GoogleMapController controller) async {
              _controllerGoogleMap.complete(controller);

              newRideGoogleMapController = controller;
              setState(() {
                mapPaddingFromBottom = 265;
              });
              var currentLatLng =
                  LatLng(currentPosition.latitude, currentPosition.longitude);
              var pickUp = widget.rideDetails.pickUp;
              await getPlaceDirection(currentLatLng, pickUp);
              getRideLiveLocationUpdate();
            },
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black38,
                        blurRadius: 0.5,
                        spreadRadius: 0.7,
                        offset: Offset(0.7, 0.7))
                  ],
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(16),
                      topLeft: Radius.circular(16))),
              height: 270,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                child: Column(
                  children: [
                    Text(
                      durationRide,
                      style: TextStyle(fontSize: 14, color: Colors.deepPurple),
                    ),
                    SizedBox(
                      height: 6,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Samir Lama',
                          style: TextStyle(fontSize: 24),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ChatScreen(
                                            id1: 'Rajiv', id2: 'samir')));
                              },
                              child: Icon(Icons.message)),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 36,
                    ),
                    Row(
                      children: [
                        Image.asset(
                          "assets/images/pickicon.png",
                          height: 16,
                          width: 16,
                        ),
                        SizedBox(
                          width: 18,
                        ),
                        Expanded(
                            child: Container(
                          child: Text(
                            'Street 44',
                            style: TextStyle(
                                fontSize: 18, overflow: TextOverflow.ellipsis),
                          ),
                        ))
                      ],
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Row(
                      children: [
                        Image.asset(
                          "assets/images/desticon.png",
                          height: 16,
                          width: 16,
                        ),
                        SizedBox(
                          width: 18,
                        ),
                        Expanded(
                            child: Container(
                          child: Text(
                            'Street 88',
                            style: TextStyle(
                                fontSize: 18, overflow: TextOverflow.ellipsis),
                          ),
                        ))
                      ],
                    ),
                    SizedBox(
                      height: 26,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: RaisedButton(
                        onPressed: () async {
                          if (status == "accepted") {
                            status = "arrived";
                            String rideRequestId =
                                widget.rideDetails.ride_request_id;

                            newRequestRef
                                .child(rideRequestId)
                                .child('status')
                                .set('approved');

                            rideRequestRef.set('arrived');

                            setState(() {
                              btntitle = "Start Trip";
                              btnColor = Colors.purple;
                            });
                            showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) =>
                                    ProgressDialog(
                                      message: "Please wait...",
                                    ));
                            await getPlaceDirection(widget.rideDetails.pickUp,
                                widget.rideDetails.dropoff);
                            Navigator.pop(context);
                          } else if (status == "arrived") {
                            rideRequestRef.set('startTrip');
                            status = "onride";
                            String rideRequestId =
                                widget.rideDetails.ride_request_id;

                            newRequestRef
                                .child(rideRequestId)
                                .child('status')
                                .set(status);
                            setState(() {
                              btntitle = "End Trip";
                              btnColor = Colors.redAccent;
                            });

                            initTimer();
                          } else if (status == "onride") {
                            rideRequestRef.set('endTrip');
                            endTrip();
                          }
                        },
                        color: btnColor,
                        child: Padding(
                          padding: EdgeInsets.all(17),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                btntitle,
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              Icon(
                                Icons.directions_car,
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
          )
        ],
      ),
    );
  }

  Future<void> getPlaceDirection(
      LatLng pickUpLatLng, LatLng dropOffLatLng) async {
    showDialog(
        context: context,
        builder: (BuildContext context) => ProgressDialog(
              message: "Please wait....",
            ));
    var details = await AssistantMethods.obtainPlaceDirectionDetails(
        pickUpLatLng, dropOffLatLng);

    Navigator.pop(context);

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodePolyLinePointResult =
        polylinePoints.decodePolyline(details.encodedPoints ?? '');
    polylineCoOrdinates.clear();

    if (decodePolyLinePointResult.isNotEmpty) {
      decodePolyLinePointResult.forEach((PointLatLng pointLatLng) {
        polylineCoOrdinates
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }
    polylineSet.clear();
    setState(() {
      Polyline polyline = Polyline(
          polylineId: PolylineId('PolylineId'),
          color: Colors.red,
          width: 5,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          points: polylineCoOrdinates,
          geodesic: true,
          jointType: JointType.round);
      polylineSet.add(polyline);
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
    newRideGoogleMapController
        .animateCamera(CameraUpdate.newLatLngBounds(latLngBounds, 70));
    Marker pickUpMarker = Marker(
      markerId: MarkerId('pickID'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
      position: pickUpLatLng,
    );

    Marker dropOffMarker = Marker(
      markerId: MarkerId('dropOfID'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
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

  void acceptRideRequest() {
    String rideRequestId = widget.rideDetails.ride_request_id;
    newRequestRef.child(rideRequestId).child("status").set("accepted");
    newRequestRef
        .child(rideRequestId)
        .child("driver_name")
        .set(driversIfo.name);
    newRequestRef
        .child(rideRequestId)
        .child("driver_phone")
        .set(driversIfo.phone);
    newRequestRef.child(rideRequestId).child("driver_id").set(driversIfo.id);
    newRequestRef.child(rideRequestId).child("status").set("accepted");
    newRequestRef
        .child(rideRequestId)
        .child("car_details")
        .set('${driversIfo.car_color}-${driversIfo.car_model}');
    Map locMap = {
      "latitude": currentPosition.latitude.toString(),
      "longitude": currentPosition.longitude.toString()
    };
    newRequestRef.child(rideRequestId).child('driver_location').set(locMap);
  }

  void updateRideDetails() async {
    if (isRequestingDirection == false) {
      isRequestingDirection = true;

      if (myPosition == null) {
        print('data xaina hai');
        return;
      }

      var posLatLng = LatLng(myPosition.latitude, myPosition.longitude);
      LatLng destinationLatLng;
      if (status == "accepted") {
        destinationLatLng = widget.rideDetails.pickUp;
      } else {
        destinationLatLng = widget.rideDetails.dropoff;
      }
      var directionDetails = await AssistantMethods.obtainPlaceDirectionDetails(
          posLatLng, destinationLatLng);
      if (directionDetails != null) {
        setState(() {
          durationRide = directionDetails.durationText;
        });
      }
      isRequestingDirection = false;
    }
  }

  void initTimer() {
    const interval = Duration(seconds: 1);
    timer = Timer.periodic(interval, (timer) {
      durationCOunter = durationCOunter + 1;
    });
  }

  endTrip() async {
    timer.cancel();
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => ProgressDialog(
              message: "Please wait...",
            ));
    var currentLatLng = LatLng(myPosition.latitude, myPosition.longitude);
    var directionalDetails = await AssistantMethods.obtainPlaceDirectionDetails(
        widget.rideDetails.pickUp, currentLatLng);
    Navigator.pop(context);
    int fareAmount = AssistantMethods.calculateFares(directionalDetails);
    String rideRequestId = widget.rideDetails.ride_request_id;
    newRequestRef
        .child(rideRequestId)
        .child('fares')
        .set(fareAmount.toString());

    newRequestRef.child(rideRequestId).child('status').set("Ended");
    rideStreamSubscription.cancel();

    Navigator.push(
        context, MaterialPageRoute(builder: (context) => HomeTabScreen()));
  }
}
