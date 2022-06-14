//@dart=2.1

import 'package:maps_toolkit/maps_toolkit.dart';

class MapKitAssistant {
  static double getMarkerRotation(sLat, sLng, dLat, dLang) {
    var rot =
        SphericalUtil.computeHeading(LatLng(sLat, sLng), LatLng(dLat, dLang));
    return rot;
  }
}
