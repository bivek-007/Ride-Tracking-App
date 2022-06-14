//@dart=2.1

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:tracking_app/Assistants/assistantMethods.dart';
import 'package:tracking_app/configMaps.dart';
import 'package:tracking_app/model/auth_provider.dart';
import 'package:tracking_app/screen/home_page/home_page_screen.dart';
import 'package:tracking_app/screen/map_Main_screen.dart';
import 'package:tracking_app/screen/sign_up_screen.dart';
import 'package:tracking_app/widgets/loading.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key key}) : super(key: key);

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final formKey = GlobalKey<FormState>();
  TextEditingController emailController = new TextEditingController();
  TextEditingController pwController = new TextEditingController();

  bool showPassword = false;
  bool tick = false;
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    // Future<void> signIn() async {
    //   if (!formKey.currentState.validate()) {
    //     return;
    //   } else {
    //     formKey.currentState.save();
    //     setState(() {
    //       isLoading = true;
    //     });
    //     await Provider.of<AuthProvider>(context, listen: false)
    //         .signIn(emailController.text, pwController.text, context);
    //
    //     setState(() {
    //       // Navigator.pushNamed(context, RoomOverViwScreen.routName);
    //
    //       isLoading = false;
    //     });
    //   }
    // }

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
            image: AssetImage('assets/images/login.png'), fit: BoxFit.cover),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Form(
          key: formKey,
          child: Stack(
            children: [
              Container(
                height: 130,
                width: MediaQuery.of(context).size.width,
                alignment: Alignment.bottomCenter,
                child: Text(
                  'Looks like yo already have an account \nwith us. Please sign in to access your \n benefits',
                  style:
                      TextStyle(color: Colors.white, fontSize: 15, height: 1.4),
                  textAlign: TextAlign.center,
                ),
              ),
              Container(
                padding: EdgeInsets.only(left: 40, top: 144),
                child: Text(
                  'Welcome\nBack',
                  style: TextStyle(color: Colors.white, fontSize: 33),
                ),
              ),
              SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.only(left: 35, right: 35),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: emailController,
                              style: TextStyle(color: Colors.black),
                              validator: (val) {
                                return RegExp(
                                            r"^[a-zA-Z0-9.a-zA-Z0-9.13457'*+-/=?^`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                        .hasMatch(val)
                                    ? null
                                    : "Please Provide a valid UserEmail";
                              },
                              decoration: InputDecoration(
                                  fillColor: Colors.grey.shade100,
                                  filled: true,
                                  hintText: "Email",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  )),
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            TextFormField(
                              controller: pwController,
                              style: TextStyle(),
                              validator: (val) {
                                return val.length < 6
                                    ? "The password must contain 6 digit"
                                    : null;
                              },
                              obscureText: showPassword,
                              decoration: InputDecoration(
                                  fillColor: Colors.grey.shade100,
                                  suffixIcon: IconButton(
                                    icon: Icon(showPassword
                                        ? Icons.visibility
                                        : Icons.visibility_off),
                                    onPressed: () {
                                      setState(() {
                                        showPassword = !showPassword;
                                      });
                                    },
                                  ),
                                  filled: true,
                                  hintText: "Password",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  )),
                            ),
                            SizedBox(
                              height: 6,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Checkbox(
                                        value: tick,
                                        onChanged: (value) {
                                          setState(() {
                                            tick = value ?? false;
                                          });
                                        }),
                                    Text(
                                      'Remember Me',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w500),
                                    )
                                  ],
                                ),
                                Text(
                                  'Forgot Password',
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                      decoration: TextDecoration.underline,
                                      decorationColor: Colors.lightBlue,
                                      fontWeight: FontWeight.w500),
                                )
                              ],
                            ),
                            isLoading
                                ? CircularProgressIndicator(
                                    strokeWidth: 6,
                                  )
                                : GestureDetector(
                                    onTap: () {
                                      loginAndAuthenticateUser(context);
                                    },
                                    child: Container(
                                      margin: EdgeInsets.only(top: 8),
                                      height: 50,
                                      width: 150,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                          color: Colors.green,
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      child: Text(
                                        'Sign in',
                                        style: TextStyle(
                                            color: Colors.white,
                                            letterSpacing: 0.8,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ),
                            Card(
                              borderOnForeground: true,
                              shadowColor: Colors.black54,
                              elevation: 4,
                              child: Container(
                                  height: 40,
                                  alignment: Alignment.center,
                                  width: 300,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Don't have an account yet?",
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      SizedBox(
                                        width: 14,
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      SignUpScreen(
                                                        key: widget.key,
                                                      )));
                                        },
                                        child: Text(
                                          "Sign up",
                                          style: TextStyle(
                                              fontSize: 15,
                                              color: Colors.blue,
                                              decoration:
                                                  TextDecoration.underline,
                                              decorationColor:
                                                  Colors.indigoAccent,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      )
                                    ],
                                  )),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  DatabaseReference driversRef;

  void loginAndAuthenticateUser(BuildContext context) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return ProgressDialog(
            message: "Authenticating, Please wait...",
          );
        });

    final User firebaseUser = (await _firebaseAuth
            .signInWithEmailAndPassword(
                email: emailController.text, password: pwController.text)
            .catchError((errMsg) {
      Navigator.pop(context);
      displayToastMessage("Error: " + errMsg.toString(), context);
    }))
        .user;

    if (firebaseUser != null) {
      AssistantMethods.getCurrentOnlineUserInfo();

      Navigator.push(
          context, MaterialPageRoute(builder: (context) => MapMainScreen()));
      // driversRef.child(firebaseUser.uid).once().then((DataSnapshot snap) {
      //   if (snap.value != null) {
      //     currentfirebaseUser = firebaseUser;
      //
      //     displayToastMessage("you are logged-in now.", context);
      //   } else {
      //
      //     displayToastMessage(
      //         "No record exists for this user. Please create new account.",
      //         context);
      //   }
      // });
    } else {
      _firebaseAuth.signOut();
      Navigator.pop(context);
      displayToastMessage("Error Occured, can not be Signed-in.", context);
    }
  }
}

displayToastMessage(String message, BuildContext context) {
  Fluttertoast.showToast(msg: message);
}
