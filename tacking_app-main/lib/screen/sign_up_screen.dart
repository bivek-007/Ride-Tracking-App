//@dart=2.1
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracking_app/Assistants/assistantMethods.dart';
import 'package:tracking_app/main.dart';
import 'package:tracking_app/model/auth_provider.dart';
import 'package:tracking_app/screen/map_Main_screen.dart';
import 'package:tracking_app/screen/sign_in_screen.dart';
import 'package:tracking_app/widgets/loading.dart';

import '../configMaps.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final formKey = GlobalKey<FormState>();
  TextEditingController unController = new TextEditingController();
  TextEditingController emailController = new TextEditingController();
  TextEditingController pwController = new TextEditingController();
  TextEditingController phoneController = new TextEditingController();

  bool tick = false;
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    // Future<void> signMeUp() async {
    //   if (!formKey.currentState.validate()) {
    //     return;
    //   } else {
    //     formKey.currentState.save();
    //     setState(() {
    //       isLoading = true;
    //     });
    //     // await Provider.of<AuthProvider>(context, listen: false).signUp(
    //     //     emailController.text,
    //     //     pwController.text,
    //     //     unController.text,
    //     //     phoneController.text,
    //     //     context);
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
            image: AssetImage('assets/images/register.png'), fit: BoxFit.cover),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          shadowColor: Colors.transparent,
          leading: Text(''),
        ),
        body: Form(
          key: formKey,
          child: Stack(
            children: [
              Container(
                  padding: EdgeInsets.only(left: 35, top: 30),
                  child: isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 6,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: FittedBox(
                                child: Text(
                                  'Create\nAccount',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 33),
                                ),
                              ),
                            ),
                            Flexible(
                              child: FittedBox(
                                child: Text(
                                  'You will need this mobile email \n you log in.',
                                  style: TextStyle(
                                      color: Colors.white,
                                      height: 1.3,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                  textAlign: TextAlign.center,
                                  maxLines: 3,
                                ),
                              ),
                            ),
                          ],
                        )),
              SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.only(left: 35, right: 35),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: unController,
                              validator: (val) {
                                return val.length < 3
                                    ? "The username must contain 3 digit"
                                    : null;
                              },
                              style: TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: Colors.white,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: Colors.black,
                                    ),
                                  ),
                                  hintText: "Name",
                                  hintStyle: TextStyle(color: Colors.white),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  )),
                            ),
                            SizedBox(
                              height: 17,
                            ),
                            TextFormField(
                              controller: emailController,
                              validator: (val) {
                                return RegExp(
                                            r"^[a-zA-Z0-9.a-zA-Z0-9.13457'*+-/=?^`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                        .hasMatch(val)
                                    ? null
                                    : "Please Provide a valid UserEmail";
                              },
                              style: TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: Colors.white,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: Colors.black,
                                    ),
                                  ),
                                  hintText: "Email",
                                  hintStyle: TextStyle(color: Colors.white),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  )),
                            ),
                            SizedBox(
                              height: 17,
                            ),
                            TextFormField(
                              controller: pwController,
                              validator: (val) {
                                return val.length < 6
                                    ? "The password must contain 6 digit"
                                    : null;
                              },
                              style: TextStyle(color: Colors.white),
                              obscureText: true,
                              decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: Colors.white,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: Colors.black,
                                    ),
                                  ),
                                  hintText: "Password",
                                  hintStyle: TextStyle(color: Colors.white),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  )),
                            ),
                            SizedBox(
                              height: 17,
                            ),
                            TextFormField(
                              controller: phoneController,
                              validator: (val) {
                                return val.length < 10
                                    ? "Please enter valid number"
                                    : null;
                              },
                              style: TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: Colors.white,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: Colors.black,
                                    ),
                                  ),
                                  hintText: "Phone",
                                  hintStyle: TextStyle(color: Colors.white),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  )),
                              keyboardType: TextInputType.phone,
                            ),
                            Row(
                              children: [
                                Flexible(
                                  child: FittedBox(
                                    child: Checkbox(
                                        value: tick,
                                        onChanged: (value) {
                                          setState(() {
                                            tick = value ?? false;
                                          });
                                        }),
                                  ),
                                ),
                                Flexible(
                                  child: FittedBox(
                                    child: Text(
                                      'I have read and accept the ',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ),
                                Flexible(
                                  child: FittedBox(
                                    child: Text(
                                      'Terms of service',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.indigo,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            GestureDetector(
                              onTap: () {
                                tick ? registerNewUser(context) : Container();
                              },
                              child: Container(
                                margin: EdgeInsets.only(top: 8),
                                height: 50,
                                width: 150,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(8)),
                                child: Text(
                                  'Sign up',
                                  style: TextStyle(
                                      color:
                                          tick ? Colors.white : Colors.white60,
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
                                        "Already have an account?",
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
                                                      SignInScreen(
                                                        key: widget.key,
                                                      )));
                                        },
                                        child: Text(
                                          "Sign in",
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

  void registerNewUser(BuildContext context) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return ProgressDialog(
            message: "Registering, Please wait...",
          );
        });

    final User firebaseUser = (await _firebaseAuth
            .createUserWithEmailAndPassword(
                email: emailController.text, password: pwController.text)
            .catchError((errMsg) {
      Navigator.pop(context);
      displayToastMessage("Error: " + errMsg.toString(), context);
    }))
        .user;

    if (firebaseUser != null) //user created
    {
      //save user info to database
      Map userDataMap = {
        "name": unController.text,
        "email": emailController.text.trim(),
        "phone": phoneController.text.trim(),
        "isSuspended": "false",
      };

      userRef.child(firebaseUser.uid).set(userDataMap);

      currentfirebaseUser = firebaseUser;

      AssistantMethods.getCurrentOnlineUserInfo();

      displayToastMessage(
          "Congratulations, your account has been created.", context);

      Navigator.push(
          context, MaterialPageRoute(builder: (context) => MapMainScreen()));
    } else {
      Navigator.pop(context);
      //error occured - display error msg
      displayToastMessage("New user account has not been Created.", context);
    }
  }
}
