//@dart=2.1

import 'package:google_maps_flutter/google_maps_flutter.dart';

class RideDetails {
  String pickupAddress;
  String dropoff_address;
  LatLng pickUp;
  LatLng dropoff;
  String ride_request_id;
  String payment_method;
  String rider_name;
  String rider_phone;
  String distance;
  String totalPayment;
  RideDetails(
      {this.pickupAddress,
      this.dropoff_address,
      this.pickUp,
      this.dropoff,
      this.ride_request_id,
      this.payment_method,
      this.rider_name,
      this.rider_phone,
      this.distance,
      this.totalPayment});
}
