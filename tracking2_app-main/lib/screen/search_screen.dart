import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracking2_app/Assistants/requestAssistants.dart';
import 'package:tracking2_app/DataHandler/appData.dart';
import 'package:tracking2_app/configMaps.dart';
import 'package:tracking2_app/model/address.dart';
import 'package:tracking2_app/model/dropLatLng.dart';
import 'package:tracking2_app/model/place_prediction.dart';
import 'package:tracking2_app/widgets/Divider.dart';

import 'map_Main_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController pickUpController = TextEditingController();
  TextEditingController dropOffController = TextEditingController();
  List<PlacePrediction> placePredictionList = [];
  @override
  Widget build(BuildContext context) {
    String placeAddress =
        Provider.of<AppData>(context).pickUpLocation?.placeName ?? "";
    pickUpController.text = placeAddress;
    return Scaffold(
      appBar: AppBar(
        title: Text("Set Drop Off"),
        centerTitle: true,
        leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(Icons.arrow_back_ios)),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            Container(
              height: 215.0,
              decoration: BoxDecoration(color: Colors.white, boxShadow: [
                BoxShadow(
                  color: Colors.black,
                  blurRadius: 6.0,
                  spreadRadius: 0.5,
                  offset: Offset(0.7, 0.7),
                ),
              ]),
              child: Padding(
                padding: EdgeInsets.only(
                    left: 25.0, top: 20.0, right: 25.0, bottom: 20.0),
                child: Column(
                  children: [
                    SizedBox(
                      height: 5.0,
                    ),
                    Column(
                      children: [
                        Row(
                          children: [
                            Image.asset(
                              'assets/images/pickicon.png',
                              height: 16,
                              width: 16,
                            ),
                            SizedBox(
                              width: 18,
                            ),
                            Expanded(
                                child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.grey[400],
                                  borderRadius: BorderRadius.circular(5.0)),
                              child: Padding(
                                padding: EdgeInsets.all(3.0),
                                child: TextField(
                                  controller: pickUpController,
                                  decoration: InputDecoration(
                                      hintText: 'PickUp Location',
                                      filled: true,
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.only(
                                          left: 11.0, top: 8.0, bottom: 8.0)),
                                ),
                              ),
                            ))
                          ],
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Row(
                          children: [
                            Image.asset(
                              'assets/images/desticon.png',
                              height: 16,
                              width: 16,
                            ),
                            SizedBox(
                              width: 18,
                            ),
                            Expanded(
                                child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.grey[400],
                                  borderRadius: BorderRadius.circular(5.0)),
                              child: Padding(
                                padding: EdgeInsets.all(3.0),
                                child: TextField(
                                  controller: dropOffController,
                                  onChanged: (val) {
                                    setState(() {
                                      findPlace(val);
                                    });
                                  },
                                  decoration: InputDecoration(
                                      hintText: 'Where to?',
                                      filled: true,
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.only(
                                          left: 11.0, top: 8.0, bottom: 8.0)),
                                ),
                              ),
                            ))
                          ],
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),

            //tile for predictions
            placePredictionList.length > 0
                ? Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: ListView.separated(
                        itemBuilder: (context, index) {
                          return PredictionTile(
                            key: widget.key,
                            placePrediction: placePredictionList[index],
                          );
                        },
                        separatorBuilder: (BuildContext context, index) =>
                            DividerWidget(),
                        shrinkWrap: true,
                        physics: ClampingScrollPhysics(),
                        itemCount: placePredictionList.length),
                  )
                : Container()
          ],
        ),
      ),
    );
  }

  void findPlace(String placeName) async {
    if (placeName.length > 1) {
      String autoCompletUrl =
          "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$placeName&key=$mapKey&sessiontoken=1234567890&components=country:np";
      var res = await RequestAssistant.getRequest(autoCompletUrl);
      if (res == 'failed') {
        print('failed');
        return;
      }
      if (res["status"] == "OK") {
        var predictions = res["predictions"];
        var placeList = (predictions as List)
            .map((e) => PlacePrediction.fromJson(e))
            .toList();
        setState(() {
          placePredictionList = placeList;
        });
      }
    }
  }
}

class PredictionTile extends StatelessWidget {
  final PlacePrediction? placePrediction;
  const PredictionTile({Key? key, this.placePrediction}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      padding: EdgeInsets.all(0),
      onPressed: () {
        getPlaceAddressDetails(placePrediction!.place_id ?? '', context);
      },
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Icon(Icons.add_location),
                SizedBox(
                  width: 14.0,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        placePrediction!.main_text.toString(),
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 16.0),
                      ),
                      SizedBox(
                        height: 3.0,
                      ),
                      Text(
                        placePrediction!.secondary_text.toString(),
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12.0, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              ],
            ),
            SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }

  void getPlaceAddressDetails(String placeId, context) async {
    showDialog(
        context: context,
        builder: (BuildContext context) => CircularProgressIndicator());
    String placeDetailUrl =
        "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$mapKey";
    var res = await RequestAssistant.getRequest(placeDetailUrl);
    Navigator.pop(context);
    if (res == "failed") {
      return;
    }
    if (res["status"] == "OK") {
      Address address = Address();
      address.placeName = res["result"]["name"];
      address.plcaId = placeId;
      address.latitude =
          res["result"]["geometry"]["location"]["lat"].toString();
      address.longitude =
          res["result"]["geometry"]["location"]["lng"].toString();
      Provider.of<AppData>(context, listen: false)
          .updateDropOfLocation(address);

      DropOffLatLng directionDetails = DropOffLatLng();

      Navigator.pop(context, 'obtainDirection');
    }
  }
}
