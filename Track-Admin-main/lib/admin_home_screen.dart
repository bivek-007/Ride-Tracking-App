import 'package:admint_app/our_rider_screen.dart';
import 'package:admint_app/our_user_screen.dart';
import 'package:admint_app/provider/sharedPrefs.dart';
import 'package:admint_app/sign_in_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'main.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({Key? key}) : super(key: key);

  @override
  _AdminHomeScreenState createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Container(
        color: Colors.white,
        width: 255.0,
        child: Drawer(
          child: ListView(
            children: [
              //Drawer Header
              Container(
                height: 165.0,
                child: DrawerHeader(
                  decoration: BoxDecoration(color: Colors.white),
                  child: Row(
                    children: [
                      Image.network(
                        "https://d30y9cdsu7xlg0.cloudfront.net/png/99475-200.png",
                        height: 65.0,
                        width: 65.0,
                      ),
                      SizedBox(
                        width: 16.0,
                      ),
                      Flexible(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Hello Admin",
                              maxLines: 1,
                              style: TextStyle(
                                  fontSize: 16.0,
                                  fontFamily: "Brand Bold",
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.3),
                            ),
                            SizedBox(
                              height: 6.0,
                            ),
                            GestureDetector(
                                onTap: () {
                                  // Navigator.push(context, MaterialPageRoute(builder: (context)=> ProfileTabPage()));
                                },
                                child: Text(
                                  "Online Tracking App",
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14),
                                )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Divider(
                thickness: 2,
              ),

              SizedBox(
                height: 12.0,
              ),

              //Drawer Body Contrllers
              GestureDetector(
                onTap: () {
                  // Navigator.push(context, MaterialPageRoute(builder: (context)=> HistoryScreen()));
                },
                child: ListTile(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => OurRiderScreen(
                                  key: widget.key,
                                )));
                  },
                  leading: Icon(Icons.history),
                  title: Text(
                    "Our Riders",
                    style: TextStyle(fontSize: 15.0),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Navigator.push(context, MaterialPageRoute(builder: (context)=> ProfileTabPage()));
                },
                child: ListTile(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => OurTotalUserrScreen(
                                  key: widget.key,
                                )));
                  },
                  leading: Icon(Icons.person),
                  title: Text(
                    "Our Users",
                    style: TextStyle(fontSize: 15.0),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Navigator.push(context, MaterialPageRoute(builder: (context)=> AboutScreen()));
                },
                child: ListTile(
                  leading: Icon(Icons.info),
                  title: Text(
                    "About",
                    style: TextStyle(fontSize: 15.0),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  // FirebaseAuth.instance.signOut();
                  HelperFunctions.saveUserLoggedInSharedPreference(false);
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SigninScreen(
                                key: widget.key,
                              )),
                      (route) => false);
                },
                child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text(
                    "Sign Out",
                    style: TextStyle(fontSize: 15.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        title: const Text('Admin Home'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Column(
          children: [
            Container(
              height: 45,
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.black87, width: 1.5)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Search history....'),
                  Icon(Icons.search)
                ],
              ),
            ),
            Expanded(
              child: FirebaseAnimatedList(
                  query: rideHistoryRef,
                  // shrinkWrap: true,
                  // physics: NeverScrollableScrollPhysics(),
                  duration: Duration(seconds: 2),
                  sort: (DataSnapshot a, DataSnapshot b) =>
                      b.key!.compareTo(a.key.toString()),
                  scrollDirection: Axis.vertical,
                  itemBuilder: (BuildContext context, DataSnapshot snap,
                      Animation<double> animation, int index) {
                    return snap.key!.length == 0
                        ? Text('No Necord Found')
                        : Container(
                            margin: const EdgeInsets.only(
                              top: 6,
                            ),
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          height: 54,
                                          width: 54,
                                          margin: EdgeInsets.only(right: 67),
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              image: const DecorationImage(
                                                image: NetworkImage(
                                                  'https://pngimage.net/wp-content/uploads/2018/06/taxi-png.png',
                                                ),
                                                fit: BoxFit.fill,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(34)),
                                        ),
                                        Text(
                                          snap.value['driverName'] == null
                                              ? ''
                                              : snap.value['driverName'],
                                          style: const TextStyle(
                                              color: Colors.white70,
                                              height: 1.5,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w400),
                                        ),
                                        Text(
                                          snap.value['driverPhone'] == null
                                              ? ''
                                              : snap.value['driverPhone'],
                                          style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w400),
                                        )
                                      ],
                                    ),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          'Customer Details',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 16),
                                        ),
                                        Text(
                                          'Bivek Khatiwada',
                                          style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w400),
                                        ),
                                        Text(
                                          '9800908511',
                                          style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w400),
                                        ),
                                        Text(
                                          'Total paid:  Rs.${snap.value['totalPayment']}',
                                          style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w400),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: 27,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'From',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 16),
                                        ),
                                        Text(
                                          snap.value['from'],
                                          style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w400),
                                        ),
                                        Text(
                                          '2022-06-21',
                                          style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w400),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      width: 22,
                                    ),
                                    Flexible(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'To',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 16),
                                          ),
                                          Text(
                                            snap.value['to'],
                                            maxLines: 2,
                                            style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w400),
                                          ),
                                          Text(
                                            '2022-06-21',
                                            style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w400),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                                Center(
                                  child: Text(
                                    'Total Distance:   ${snap.value['distance']}m',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.white,
                                        height: 2,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16),
                                  ),
                                )
                              ],
                            ),
                          );
                  }),
            )
          ],
        ),
      ),
    );
  }
}
