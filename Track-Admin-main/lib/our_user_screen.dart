import 'package:admint_app/main.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';

class OurTotalUserrScreen extends StatefulWidget {
  const OurTotalUserrScreen({Key? key}) : super(key: key);

  @override
  _OurTotalUserrScreenState createState() => _OurTotalUserrScreenState();
}

class _OurTotalUserrScreenState extends State<OurTotalUserrScreen> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Users'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: 14, right: 14, left: 14),
                height: 45,
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.black87, width: 1.5)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [Text('Search user....'), Icon(Icons.search)],
                ),
              ),
              FirebaseAnimatedList(
                  query: userRef,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  duration: Duration(seconds: 2),
                  sort: (DataSnapshot a, DataSnapshot b) =>
                      b.key!.compareTo(a.key.toString()),
                  scrollDirection: Axis.vertical,
                  itemBuilder: (BuildContext context, DataSnapshot snap,
                      Animation<double> animation, int index) {
                    return snap.key!.length == 0
                        ? Text('No notification')
                        : Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 4),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 14),
                              decoration: BoxDecoration(
                                color: Colors.deepPurple,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            height: 54,
                                            width: 54,
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                image: const DecorationImage(
                                                  image: NetworkImage(
                                                    'https://pluspng.com/img-png/user-png-icon-young-user-icon-2400.png',
                                                  ),
                                                  fit: BoxFit.fill,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(34)),
                                          ),
                                          Text(
                                            snap.value['name'] ?? 'sd',
                                            style: const TextStyle(
                                                color: Colors.white70,
                                                height: 1.5,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w400),
                                          ),
                                          Text(
                                            snap.value['phone'] ?? 'sjdh',
                                            style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w400),
                                          )
                                        ],
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Join Date',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 16),
                                          ),
                                          Text(
                                            snap.value['joinDate'] ??
                                                '2021-12-34',
                                            style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w400),
                                          ),
                                          Text(
                                            'Travel Distance  270km',
                                            style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w400),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          IconButton(
                                              onPressed: () {},
                                              icon: Icon(Icons.edit)),
                                          isLoading
                                              ? CircularProgressIndicator(
                                                  color: Colors.white,
                                                )
                                              : IconButton(
                                                  onPressed: () async {
                                                    setState(() {
                                                      isLoading = true;
                                                    });
                                                    snap.value['isSuspended'] ==
                                                            'false'
                                                        ? userRef
                                                            .child(
                                                                snap.key ?? '')
                                                            .update({
                                                            'isSuspended':
                                                                "true",
                                                          })
                                                        : userRef
                                                            .child(
                                                                snap.key ?? '')
                                                            .update({
                                                            'isSuspended':
                                                                "false",
                                                          });
                                                    setState(() {
                                                      isLoading = false;
                                                    });
                                                  },
                                                  icon: snap.value[
                                                              'isSuspended'] ==
                                                          "false"
                                                      ? Icon(
                                                          Icons.block,
                                                          color: Colors.red,
                                                        )
                                                      : Icon(Icons.add))
                                        ],
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                  }),
            ],
          ),
        ));
  }
}
