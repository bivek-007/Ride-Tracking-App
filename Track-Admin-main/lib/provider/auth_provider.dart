import 'dart:async';
import 'dart:convert';
import 'package:admint_app/admin_home_screen.dart';
import 'package:admint_app/provider/sharedPrefs.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum Status {
  uninitialized,
  authenticated,
  authenticating,
  authenticateErroe,
  authenticateCanceled,
}

class AuthProvider extends ChangeNotifier {
  Future<dynamic> signIn(
      String email, String password, BuildContext context) async {
    final url =
        "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=AIzaSyAYaB2c04r4utzId6h3LPIAMWXiqP-QfOw";
    try {
      final response = await http.post(Uri.parse(url),
          body: json.encode({
            'email': email,
            'password': password,
            'returnSecureToken': true,
          }));
      print(response.body);
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw (responseData['error']['message']);
      }

      // _expiryDate = DateTime.now()
      //     .add(Duration(seconds: int.parse(responseData['expiresIn'])));
      if (responseData['error'] == null) {
        HelperFunctions.saveUserLoggedInSharedPreference(true);
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => AdminHomeScreen()));
      }

      notifyListeners();
    } catch (e) {
      print(e.toString());
      return showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
                title: Text(e.toString() ==
                        "Converting object to an encodable object failed: Instance of 'DateTime'"
                    ? "Success"
                    : "Error Occured"),
                content: Text(e.toString()),
                actions: [
                  FlatButton(
                    child: Text("Ok"),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  )
                ],
              ));
    }
  }

  // HelperFunctions.saveUserLoggedInSharedPreference(false);

  notifyListeners();
}
