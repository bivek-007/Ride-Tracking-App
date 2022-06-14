//@dart=2.1

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tracking2_app/model/allUsers.dart';
import 'package:tracking2_app/model/drivers.dart';

import 'model/myDetail.dart';

String mapKey = "AIzaSyAYaB2c04r4utzId6h3LPIAMWXiqP-QfOw";

User firebaseUser;
Users userCurrentInfo;
User currentfirebaseUser;

StreamSubscription<Position> homeTabPageStreamSubscription;
Position currentPosition;
Drivers driversIfo;
MyDetail myDetail;

StreamSubscription<Position> rideStreamSubscription;
