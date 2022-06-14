import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tracking2_app/configMaps.dart';
import 'package:tracking2_app/main.dart';
import 'package:tracking2_app/screen/home_page/home_tab_screen.dart';
import 'package:tracking2_app/screen/map_Main_screen.dart';
import 'package:tracking2_app/screen/sign_in_screen.dart';

class CarInfoScreen extends StatelessWidget {
  TextEditingController carModel = new TextEditingController();
  TextEditingController carNumber = new TextEditingController();
  TextEditingController carColor = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 22,
              ),
              Image.asset(
                "assets/images/logo.png",
                width: 390,
                height: 250,
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(22.0, 22, 22, 32),
                child: Column(
                  children: [
                    SizedBox(
                      height: 12,
                    ),
                    Text(
                      'Enter Car Details',
                      style: TextStyle(
                        fontSize: 24,
                      ),
                    ),
                    SizedBox(
                      height: 26,
                    ),
                    TextField(
                      controller: carModel,
                      decoration: InputDecoration(
                        labelText: 'Car Model',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 10),
                      ),
                      style: TextStyle(fontSize: 15.0),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: carNumber,
                      decoration: InputDecoration(
                        labelText: 'Car Number',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 10),
                      ),
                      style: TextStyle(fontSize: 15.0),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: carColor,
                      decoration: InputDecoration(
                        labelText: 'Car Color',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 10),
                      ),
                      style: TextStyle(fontSize: 15.0),
                    ),
                    SizedBox(
                      height: 42.0,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: RaisedButton(
                        onPressed: () {
                          if (carModel.text.isEmpty ||
                              carNumber.text.isEmpty ||
                              carColor.text.isEmpty) {
                            displayToastMessage(
                                "Please provide valid info  about you car",
                                context);
                          } else {
                            saveDriveCarInfo(context);
                          }
                        },
                        color: Theme.of(context).accentColor,
                        child: Padding(
                          padding: EdgeInsets.all(17),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Next",
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              Icon(
                                Icons.arrow_forward,
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
              )
            ],
          ),
        ),
      ),
    );
  }

  // DatabaseReference driversRef = FirebaseDatabase.instance.reference();

  void saveDriveCarInfo(context) {
    String userId = currentfirebaseUser.uid;
    Map carInfoMap = {
      "car_color": carColor.text,
      "car_number": carNumber.text,
      "car_model": carModel.text
    };

    driversRef.child(userId).child("car_details").set(carInfoMap);
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => HomeTabScreen()));
  }
}
