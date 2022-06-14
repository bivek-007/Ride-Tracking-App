//@dart=2.1

import 'package:shared_preferences/shared_preferences.dart';

class HelperFunctions {
  static String loggedIn = "ISLOGGEDIN";
  static String userNamePrefs = "USERNAMEKEY";
  static String userEmailKey = "USEREMAILKEY";
  static String userProfileKey = "USERPROFILEKEY";

  /// saving data to sharedpreference
  static Future<bool> saveUserLoggedInSharedPreference(
      bool isUserLoggedIn) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.setBool(loggedIn, isUserLoggedIn);
  }

  static Future<bool> setEmail(String userName) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.setString(userNamePrefs, userName);
  }

  static Future<String> getEmail() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.getString(userNamePrefs);
  }

  static Future<bool> saveUserProfileSharedPreference(bool userName) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.setBool(userProfileKey, userName);
  }

  static Future<bool> saveUserEmailSharedPreference(String userEmail) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.setString(userEmailKey, userEmail);
  }

  /// fetching data from sharedpreference
  static Future<bool> getUserLoggedInSharedPreference() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.getBool(loggedIn);
  }

  static Future<String> getUserNameSharedPreference() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.getString(userNamePrefs);
  }

  static Future<String> getUserEmailSharedPreference() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.getString(userEmailKey);
  }

  static Future<bool> getUserProfileSharedPreference() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.getBool(userProfileKey);
  }

  Future<String> getUserName() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String value = await preferences.get("userName");
    return value;
  }

  Future setUserName(value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var status = await prefs.setString("userName", value);
    return status;
  }
}

getStringValuesSF() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  //Return String
  String stringValue = prefs.getString('emailKey');
  print(stringValue + 'ddd');
  return stringValue;
}

getBoolValuesSF() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  //Return bool
  bool boolValue = prefs.getBool('boolValue');
  return boolValue;
}

getIntValuesSF() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  //Return int
  int intValue = prefs.getInt('intValue');
  return intValue;
}

getDoubleValuesSF() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  //Return double
  double doubleValue = prefs.getDouble('doubleValue');
  return doubleValue;
}
