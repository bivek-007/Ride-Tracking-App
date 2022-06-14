//@dart=2.1

import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tracking2_app/configMaps.dart';
import 'package:tracking2_app/main.dart';
import 'package:tracking2_app/model/rideDetails.dart';
import 'package:tracking2_app/notifications/notificationDialog.dart';

class PushNotificationServices {
  // final FirebaseMessaging firebaseMessaging = FirebaseMessaging();

  Future initialize(BuildContext context) async {
    FirebaseMessaging.onMessage.listen((event) {
      retrieveRideRequestInfo(getRideRequestId(event.data), context);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      retrieveRideRequestInfo(getRideRequestId(message.data), context);
    });
  }

  //
  Future<String> getToken() async {
    String token = await FirebaseMessaging.instance.getToken();
    print('this is token');
    print(token);
    driversRef.child(currentfirebaseUser.uid).child("token").set(token);
    FirebaseMessaging.instance.subscribeToTopic("alldrivers");
    FirebaseMessaging.instance.subscribeToTopic("allusers");
  }

  String getRideRequestId(Map<String, dynamic> message) {
    String rideRequestId = "";
    if (Platform.isAndroid) {
      rideRequestId = message['ride_request_id'];
      print(rideRequestId);
    } else {
      rideRequestId = message['ride_request_id'];
      print(rideRequestId);
    }
    return rideRequestId;
  }

  void retrieveRideRequestInfo(String rideRequestId, BuildContext context) {
    print('retrieveRideRequestInfo');
    newRequestRef.child(rideRequestId).once().then((DataSnapshot datasnapshot) {
      if (datasnapshot.value != null) {
        // final assetAdudioPlayer=AssetsA
        double pickUpLocationLat =
            double.parse(datasnapshot.value['pickup']['latitude'].toString());
        double pickUpLocationLon =
            double.parse(datasnapshot.value['pickup']['longitude'].toString());

        String pickUpAddress = datasnapshot.value['pickup_address'].toString();

        double dropOffLocationLat =
            double.parse(datasnapshot.value['dropoff']['latitude'].toString());
        double dropOffLocationLon =
            double.parse(datasnapshot.value['dropoff']['longitude'].toString());

        String dropOffAddress =
            datasnapshot.value['dropoff_address'].toString();

        String paymentMethod = datasnapshot.value["payment_method"].toString();

        int totalPayment = datasnapshot.value["totalPayment"];
        int distance = datasnapshot.value["requestDistance"];

        RideDetails rideDetails = RideDetails();
        rideDetails.ride_request_id = rideRequestId;
        rideDetails.pickupAddress = pickUpAddress;
        rideDetails.dropoff_address = dropOffAddress;
        rideDetails.pickUp = LatLng(pickUpLocationLat, pickUpLocationLon);
        rideDetails.dropoff = LatLng(dropOffLocationLat, dropOffLocationLon);
        rideDetails.payment_method = paymentMethod;
        rideDetails.distance = distance.toString();
        rideDetails.totalPayment = totalPayment.toString();

        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) => NotificationDialog(
                  rideDetails: rideDetails,
                ));
      }
    });
  }
}
