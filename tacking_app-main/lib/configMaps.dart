import 'package:firebase_auth/firebase_auth.dart';
import 'package:tracking_app/model/allUsers.dart';

String mapKey = "AIzaSyAYaB2c04r4utzId6h3LPIAMWXiqP-QfOw";

User? firebaseUser;
Users? userCurrentInfo;
User? currentfirebaseUser;

int driverRequestTimeOut = 40;

String statusRide = "";

String driverName = "";
String driverphone = "";
String carDetailsDriver = "";

String serverToken =
    "key=AAAAw6EeJx8:APA91bGm4NkSOP2WK2NHtagz3qnyItmOOr-IzIEGseQoETH-tw_PBry7ccpZTClz8FI0N6mLTxnVdO2CBa1JbqaY0c_2l1NdpSYdpv6kjWURkqCnSe9fVqOIChYQ-0Fc4jdbYMLpAeIt";
