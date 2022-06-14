//@dart=2.1
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tracking_app/screen/map_Main_screen.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({Key key}) : super(key: key);

  @override
  _HomePageScreenState createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  List<Color> _color = [
    Colors.redAccent,
    Colors.blue,
    Colors.blueGrey,
    Colors.pink,
    Colors.black,
    Colors.indigo
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: Column(
                  children: [
                    Container(
                      height: 100,
                      margin: EdgeInsets.only(bottom: 6),
                      width: 100,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              image: NetworkImage(
                                  'https://1.bp.blogspot.com/-Mqeg4EvAtdw/XhgJArbmdBI/AAAAAAAAAxY/337cZJrPu4cnMGOkVYKJ0LSaa2__kSzrQCEwYBhgL/s1600/Salman%2BKhan%2Bimage%2B.jpg'),
                              fit: BoxFit.fill)),
                    ),
                    Text(
                      'Rajiv Dahal',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                          fontSize: 20),
                    )
                  ],
                )),
            ListTile(
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
              trailing: Icon(Icons.home),
            ),
            ListTile(
              title: const Text('My Profile'),
              onTap: () {
                Navigator.pop(context);
              },
              trailing: Icon(Icons.person_sharp),
            ),
            ListTile(
              title: const Text('Log Out'),
              onTap: () {
                Navigator.pop(context);
              },
              trailing: Icon(Icons.logout),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: Text(
          'Vehicle Tracking',
          style: TextStyle(
            color: Colors.blue,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.blue),
        centerTitle: true,
        shadowColor: Colors.red,
        backgroundColor: Colors.white60,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 16,
              ),
              Text(
                'We serve, \nbetter transportation services',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    height: 1.2),
              ),
              SizedBox(
                height: 23,
              ),
              Container(
                  height: 136 * 6.0,
                  child: ListView.builder(
                      itemCount: 6,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) => Card(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 8),
                              decoration: BoxDecoration(
                                  color: _color[index],
                                  borderRadius: BorderRadius.circular(8)),
                              height: 128,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        height: 60,
                                        width: 60,
                                        margin: EdgeInsets.only(right: 12),
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            image: DecorationImage(
                                                image: NetworkImage(
                                                  'http://photos.demandstudios.com/getty/article/81/18/86526841.jpg',
                                                ),
                                                fit: BoxFit.cover),
                                            color: Colors.white60),
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Samir Lama',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 16),
                                          ),
                                          Text(
                                            'Gwarko, Lalitpur',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                height: 1.4),
                                          ),
                                          Text(
                                            '9846898321',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                height: 1.4),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      IconButton(
                                          onPressed: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        MapMainScreen(
                                                          key: widget.key,
                                                        )));
                                          },
                                          icon: Icon(
                                            Icons.location_pin,
                                            color: Colors.white,
                                          )),
                                      IconButton(
                                          onPressed: () {},
                                          icon: Icon(
                                            Icons.star_border,
                                            color: Colors.white,
                                          ))
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ))),
              SizedBox(
                height: 22,
              )
            ],
          ),
        ),
      ),
    );
  }
}
