import 'package:flutter/cupertino.dart';
import 'package:tracking2_app/model/address.dart';

class AppData extends ChangeNotifier {
  Address? pickUpLocation, dropLocation;
  void updatePickUpLocation(Address pickUpAddress) {
    pickUpLocation = pickUpAddress;
    notifyListeners();
  }

  void updateDropOfLocation(Address dropOfAddress) {
    dropLocation = dropOfAddress;

    notifyListeners();
  }
}
