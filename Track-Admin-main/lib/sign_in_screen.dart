import 'package:admint_app/provider/auth_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({Key? key}) : super(key: key);

  @override
  _SigninScreenState createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  final formKey = GlobalKey<FormState>();
  TextEditingController emailController = new TextEditingController();
  TextEditingController pwController = new TextEditingController();

  bool showPassword = false;
  bool tick = false;
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      body: Form(
        key: formKey,
        child: Stack(
          children: [
            Container(
              padding: EdgeInsets.only(top: 144),
              alignment: Alignment.topCenter,
              child: Text(
                'Welcome Back\nAdmin',
                textAlign: TextAlign.center,
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
                                      .hasMatch(val ?? '')
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
                              return val!.length < 6
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
                                  onTap: () async {
                                    if (emailController.text ==
                                        "Admin@gmail.com") {
                                      // loginAndAuthenticateUser(context);
                                      setState(() {
                                        isLoading = true;
                                      });
                                      await Provider.of<AuthProvider>(context,
                                              listen: false)
                                          .signIn(emailController.text,
                                              pwController.text, context);
                                      setState(() {
                                        isLoading = false;
                                      });
                                    } else {
                                      Fluttertoast.showToast(
                                          msg: 'Invalid Credential');
                                    }
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(top: 8),
                                    height: 50,
                                    width: 150,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                        color: Colors.black54,
                                        borderRadius: BorderRadius.circular(8)),
                                    child: isLoading
                                        ? CircularProgressIndicator()
                                        : Text(
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
    );
  }
}
