//@dart=2.1

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tracking2_app/Assistants/assistantMethods.dart';
import 'package:tracking2_app/main.dart';
import 'package:tracking2_app/model/myDetail.dart';
import 'package:tracking2_app/model/rideDetails.dart';
import 'package:tracking2_app/screen/newRideScreen.dart';
import 'package:tracking2_app/screen/new_ride_screen.dart';
import 'package:tracking2_app/screen/sign_in_screen.dart';

import '../configMaps.dart';

class NotificationDialog extends StatelessWidget {
  final RideDetails rideDetails;

  const NotificationDialog({Key key, this.rideDetails}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      backgroundColor: Colors.transparent,
      elevation: 1,
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.all(5),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(5)),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(
              height: 30,
            ),
            Image.asset(
              'assets/images/taxi.png',
              width: 120,
            ),
            SizedBox(
              height: 18,
            ),
            Text(
              "New Ride Request",
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(
              height: 30,
            ),
            Padding(
              padding: EdgeInsets.all(18),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        "assets/images/pickicon.png",
                        height: 16,
                        width: 16,
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        child: Container(
                          child: Text(
                            rideDetails.pickupAddress,
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        "assets/images/desticon.png",
                        height: 16,
                        width: 16,
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        child: Container(
                          child: Text(
                            rideDetails.dropoff_address,
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 30,
                  )
                ],
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Divider(),
            SizedBox(
              height: 8,
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FlatButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                        side: BorderSide(color: Colors.red),
                      ),
                      color: Colors.white,
                      padding: EdgeInsets.all(8),
                      child: Text(
                        'CANCEL',
                        style: TextStyle(fontSize: 14),
                      )),
                  SizedBox(
                    width: 20,
                  ),
                  FlatButton(
                      onPressed: () {
                        checkAvailabilityOfRide(context);
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                        side: BorderSide(color: Colors.red),
                      ),
                      color: Colors.white,
                      padding: EdgeInsets.all(8),
                      child: Text(
                        'ACCEPT',
                        style: TextStyle(fontSize: 14),
                      ))
                ],
              ),
            ),
            SizedBox(
              height: 14,
            )
          ],
        ),
      ),
    );
  }

  void checkAvailabilityOfRide(context) {
    rideRequestRef.once().then((DataSnapshot dataSnapShot) {
      Navigator.pop(context);
      String theRideId = '';
      if (dataSnapShot.value != null) {
        theRideId = dataSnapShot.value.toString();
      } else {
        displayToastMessage("Ride not Exists", context);
      }
      if (theRideId == rideDetails.ride_request_id) {
        rideRequestRef.set("accepted");
        String userId = currentfirebaseUser.uid;
        Map rideDataMap = {
          "riderName": rideDetails.rider_name,
          "to": rideDetails.pickupAddress,
          "from": rideDetails.dropoff_address,
          "riderPhone": rideDetails.rider_phone,
          "driverPhone": myDetail.phone,
          'driverName': myDetail.name,
          'distance': rideDetails.distance,
          'totalPayment': rideDetails.totalPayment,
          'time': DateTime.now().minute.toString()
        };

        saveRideHistory
            .child(DateTime.now().microsecondsSinceEpoch.toString())
            .set(rideDataMap);
        AssistantMethods.disableHomeTabLocationUpdate();
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => NewRideScreen(
                      key: key,
                      rideDetails: rideDetails,
                    )));
      } else if (theRideId == "cancelled") {
        displayToastMessage("Ride has been cancelled", context);
      } else if (theRideId == "timeout") {
        displayToastMessage("Ride has time out", context);
      } else {
        displayToastMessage("Ride not Exists", context);
      }
    });
  }
}
