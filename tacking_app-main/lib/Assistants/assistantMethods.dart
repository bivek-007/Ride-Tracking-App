//@dart=2.1

import 'dart:convert';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:tracking_app/Assistants/requestAssistants.dart';

import 'package:tracking_app/DataHandler/appData.dart';
import 'package:tracking_app/configMaps.dart';
import 'package:tracking_app/model/address.dart';
import 'package:tracking_app/model/allUsers.dart';
import 'package:tracking_app/model/directionDetail.dart';

class AssistantMethods {
  Future<String> searchCoordinateAddress(Position position, context) async {
    String placeAddress = "";
    String str1, str2, str3, str4;
    String url =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey";
    var response = await RequestAssistant.getRequest(url);
    if (response != "failed") {
      // placeAddress = response["results"][0]["formatted_address"];
      Address userPickUpAddress = new Address();
      str1 = response["results"][0]["address_components"][0]["long_name"];

      str2 = response["results"][0]["address_components"][1]["long_name"];

      str3 = response["results"][0]["address_components"][2]["long_name"];

      str4 = response["results"][0]["address_components"][3]["long_name"];
      print(str1 + str2 + str3 + str4);
      print('aaa');
      placeAddress = str1 + str2 + str3 + str4;

      userPickUpAddress.longitude = position.longitude.toString();
      userPickUpAddress.latitude = position.latitude.toString();
      userPickUpAddress.placeName = placeAddress;
      Provider.of<AppData>(context, listen: false)
          .updatePickUpLocation(userPickUpAddress);
    }
    return placeAddress;
  }

  static Future<DirectionDetails> obtainPlaceDirectionDetails(
      LatLng initialPosition, LatLng finalPosition) async {
    print(initialPosition.latitude);
    print(initialPosition.longitude);
    print(finalPosition.latitude);
    print(finalPosition.longitude);
    String directionUrl =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${initialPosition.latitude},${initialPosition.longitude}&destination=${finalPosition.latitude},${finalPosition.longitude}&key=$mapKey";
//https://maps.googleapis.com/maps/api/directions/json?origin=41.9027835,12.496365500000024&destination=45.4642035,9.189981999999986&key=AIzaSyAYaB2c04r4utzId6h3LPIAMWXiqP-QfOw
    // "https://maps.googleapis.com/maps/api/directions/json?origin=Disneyland&destination=Universal+Studios+Hollywood&key=$mapKey";

    // "https://maps.googleapis.com/maps/api/directions/json?origin=${initialPosition.latitude},${initialPosition.longitude}&destination=${finalPosition.latitude},${finalPosition.longitude}&key=$mapKey";

    var res = await RequestAssistant.getRequest(directionUrl);

    print(res);

    if (res == 'failed') {
      print(res);
      return null;
    }

    DirectionDetails directionDetails = DirectionDetails();

    directionDetails.encodedPoints =
        res["routes"][0]["overview_polyline"]["points"];

    directionDetails.distanceText =
        res["routes"][0]["legs"][0]["distance"]["text"];
    directionDetails.distanceValue =
        res["routes"][0]["legs"][0]["distance"]["value"];

    directionDetails.durationText =
        res["routes"][0]["legs"][0]["duration"]["text"];
    directionDetails.durationValue =
        res["routes"][0]["legs"][0]["duration"]["value"];

    return directionDetails;
  }

  static int calculateFares(DirectionDetails directionDetails) {
    double timeTravelFare = (directionDetails.durationValue / 60) * 0.20;
    double distanceTravelFare = (directionDetails.distanceValue / 60) * 0.20;
    double totalFareAmount = (timeTravelFare + distanceTravelFare) * 120;
    return (totalFareAmount / 24).truncate();
  }

  static Future<void> getCurrentOnlineUserInfo() async {
    firebaseUser = FirebaseAuth.instance.currentUser;
    String userId = firebaseUser.uid;
    DatabaseReference reference =
        FirebaseDatabase.instance.reference().child('users').child(userId);
    reference.once().then((DataSnapshot dataSnapshot) {
      if (dataSnapshot != null) {
        userCurrentInfo = Users.fromSnapshot(dataSnapshot);
      }
    });
  }

  static double createRandomNumber(int num) {
    var random = Random();
    int randNumber = random.nextInt(num);
    return randNumber.toDouble();
  }

  static sendNotificationDriver(
      String token, context, String rie_request_id) async {
    var destination = Provider.of<AppData>(context, listen: false).dropLocation;
    Map<String, String> headerMap = {
      'Content-Type': 'application/json',
      'Authorization': serverToken
    };

    Map notificationMap = {
      'body': 'DropOff Address, ${destination.placeName}',
      'title': 'New Ride Request'
    };

    Map dataMap = {
      "click_action": "FLUTTER_NOTIFICTION_CLICK",
      "id": "1",
      "status": "done",
      "ride_request_id": rie_request_id
    };
    Map sendNotificationMap = {
      'notification': notificationMap,
      'data': dataMap,
      'priority': 'high',
      'to': token
    };
    var res = await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: headerMap, body: jsonEncode(sendNotificationMap));
  }
}
