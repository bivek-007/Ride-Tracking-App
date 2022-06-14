// //@dart=2.1
// import 'dart:async';
// import 'dart:convert';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:http/http.dart' as http;
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:google_sign_in/google_sign_in.dart';
//
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:tracking_app/main.dart';
// import 'package:tracking_app/screen/home_page/home_page_screen.dart';
//
// import 'firestorConstants.dart';
//
// enum Status {
//   uninitialized,
//   authenticated,
//   authenticating,
//   authenticateErroe,
//   authenticateCanceled,
// }
//
// class AuthProvider extends ChangeNotifier {
//   final GoogleSignIn googleSignIn;
//   final FirebaseAuth firebaseAuth;
//   final SharedPreferences sharedPreferences;
//   final FirebaseFirestore firebaseFirestore;
//   Status _status = Status.uninitialized;
//
//   Status get status => _status;
//   AuthProvider({
//     @required this.firebaseFirestore,
//     @required this.sharedPreferences,
//     @required this.firebaseAuth,
//     @required this.googleSignIn,
//   });
//
//   String getUserFirebaseId() {
//     return sharedPreferences.getString(FireStoreConstants.id);
//   }
//
//   Future<bool> isLoggedIn() async {
//     bool isLoggedIn = await googleSignIn.isSignedIn();
//     if (isLoggedIn &&
//         sharedPreferences
//                 .getString(FirebaseAuth.instance.currentUser.uid)
//                 .isNotEmpty ==
//             true) {
//       return true;
//     } else {
//       return false;
//     }
//   }
//
//   Future<bool> handleSignIn() async {
//     _status = Status.authenticating;
//     notifyListeners();
//     GoogleSignInAccount googleUser = await googleSignIn.signIn();
//     if (googleUser != null) {
//       GoogleSignInAuthentication googleAuth = await googleUser.authentication;
//       final AuthCredential credential = GoogleAuthProvider.credential(
//         accessToken: googleAuth.accessToken,
//         idToken: googleAuth.idToken,
//       );
//       final firebaseUser =
//           (await FirebaseAuth.instance.signInWithCredential(credential));
//       if (firebaseUser != null) {
//         final QuerySnapshot result = await firebaseFirestore
//             .collection(FireStoreConstants.pathUserCollection)
//             .where(FireStoreConstants.id, isEqualTo: firebaseUser.user.uid)
//             .get();
//         final List<DocumentSnapshot> document = result.docs;
//         if (document.length == 0) {
//           firebaseFirestore
//               .collection(FireStoreConstants.pathUserCollection)
//               .doc(firebaseUser.user.uid)
//               .set({
//             FireStoreConstants.nickname: firebaseUser.user.displayName,
//             FireStoreConstants.photoUrl: firebaseUser.user.photoURL,
//             FireStoreConstants.id: firebaseUser.user.uid,
//             'createdAt': DateTime.now().millisecondsSinceEpoch.toString(),
//             FireStoreConstants.chattingWith: null
//           });
//           User currentUser = firebaseUser.user;
//           await sharedPreferences.setString(
//               FireStoreConstants.id, currentUser.uid);
//           await sharedPreferences.setString(
//               FireStoreConstants.nickname, currentUser.displayName ?? "");
//           await sharedPreferences.setString(
//               FireStoreConstants.photoUrl, currentUser.photoURL ?? "");
//           await sharedPreferences.setString(
//               FireStoreConstants.phoneNumber, currentUser.phoneNumber ?? '');
//         } else {
//           // DocumentSnapshot documentSnapshot = document[0];
//           // UserChat userChat = UserChat.fromDocument(documentSnapshot);
//           // await sharedPreferences.setString(FireStoreConstants.id, userChat.id);
//           // await sharedPreferences.setString(
//           //     FireStoreConstants.nickname, userChat.nickname ?? "");
//           // await sharedPreferences.setString(
//           //     FireStoreConstants.photoUrl, userChat.photoURL ?? "");
//           // await sharedPreferences.setString(
//           //     FireStoreConstants.aboutMe, userChat.aboutMe ?? "");
//           // await sharedPreferences.setString(
//           //     FireStoreConstants.phoneNumber, userChat.phoneNumber);
//         }
//         _status = Status.authenticated;
//         notifyListeners();
//         return true;
//       } else {
//         _status = Status.authenticateErroe;
//         notifyListeners();
//         return false;
//       }
//     } else {
//       _status = Status.authenticateCanceled;
//       notifyListeners();
//       return false;
//     }
//   }
//
//   String _token; //Expire after one hour
//   DateTime _expiryDate;
//   String _userId;
//   Timer _authTimer;
//
//   bool get isAuth {
//     return _token != null;
//   }
//
//   String get userId {
//     return _userId;
//   }
//
//   String get token {
//     if (_token != null &&
//         _expiryDate != null &&
//         _expiryDate.isAfter(DateTime.now())) {
//       return _token;
//     }
//
//     return null;
//   }
//
//   Future<void> signUp(String email, String password, String name, String phone,
//       BuildContext context) async {
//     final url =
//         "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=AIzaSyAYaB2c04r4utzId6h3LPIAMWXiqP-QfOw";
//     try {
//       final response = await http.post(Uri.parse(url),
//           body: json.encode({
//             'email': email,
//             'password': password,
//             'returnSecureToken': true,
//           }));
//       print(response.body);
//       final responseData = json.decode(response.body);
//       if (responseData['error'] != null) {
//         throw (responseData['error']['message']);
//       }
//       _token = responseData['idToken'];
//       _userId = responseData['localId'];
//       _expiryDate = DateTime.now()
//           .add(Duration(seconds: int.parse(responseData['expiresIn'])));
//       if (responseData['error'] == null) {
//         Map userDataMap = {'name': name, 'email': email, 'phone': phone};
//         userRef.child(_userId).set(userDataMap);
//         print(_userId);
//         print(name);
//         Navigator.pushReplacement(
//             context, MaterialPageRoute(builder: (context) => HomePageScreen()));
//
//         // HelperFunctions.saveUserLoggedInSharedPreference(true);
//         SharedPreferences prefs = await SharedPreferences.getInstance();
//         prefs.setString('emailKey', email);
//       }
//
//       _autoLogOut();
//       notifyListeners();
//       final prefs = await SharedPreferences.getInstance();
//       final userData = json.encode({
//         'token': _token,
//         'userId': _userId,
//         'expiryDate': _expiryDate,
//         'email': email,
//       });
//       prefs.setString('userDta', userData);
//       prefs.setBool('logIn', true);
//     } catch (e) {
//       return showDialog(
//           context: context,
//           builder: (ctx) => AlertDialog(
//                 title: Text('An Error Occurred!'),
//                 content: Text(e.toString()),
//                 actions: [
//                   FlatButton(
//                     child: Text('okay'),
//                     onPressed: () {
//                       // Navigator.pop(context);
//                     },
//                   )
//                 ],
//               ));
//     }
//   }
//
//   Future<dynamic> signIn(
//       String email, String password, BuildContext context) async {
//     final url =
//         "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=AIzaSyAYaB2c04r4utzId6h3LPIAMWXiqP-QfOw";
//     try {
//       final response = await http.post(Uri.parse(url),
//           body: json.encode({
//             'email': email,
//             'password': password,
//             'returnSecureToken': true,
//           }));
//       print(response.body);
//       final responseData = json.decode(response.body);
//       if (responseData['error'] != null) {
//         throw (responseData['error']['message']);
//       }
//       _token = responseData['idToken'];
//       _userId = responseData['localId'];
//       _expiryDate = DateTime.now()
//           .add(Duration(seconds: int.parse(responseData['expiresIn'])));
//       if (responseData['error'] == null) {
//         Navigator.pushReplacement(
//             context, MaterialPageRoute(builder: (context) => HomePageScreen()));
//         // HelperFunctions.saveUserLoggedInSharedPreference(true);
//         SharedPreferences prefs = await SharedPreferences.getInstance();
//         prefs.setString('emailKey', email);
//       }
//       // userRef.child(_userId).once().then((value) => (DataSnapshot snap) async {
//       //   if (snap.value != null && responseData['error'] == null) {
//       //     Navigator.pushReplacement(context,
//       //         MaterialPageRoute(builder: (context) => HomePageScreen()));
//       //     SharedPreferences prefs = await SharedPreferences.getInstance();
//       //     prefs.setString('emailKey', email);
//       //   }
//       // });
//
//       // if (urlSegment == "signUp") {
//       //   final user = await addUsertoDatabase(userId, _token, email);
//       // } else {
//       //   final user = await getUser(_token, userId);
//       // }
//
//       _autoLogOut();
//       notifyListeners();
//       final prefs = await SharedPreferences.getInstance();
//       final userData = json.encode({
//         'token': _token,
//         'userId': _userId,
//         'expiryDate': _expiryDate,
//         'email': email,
//       });
//       prefs.setString('userDta', userData);
//     } catch (e) {
//       print(e.toString());
//       return showDialog(
//           context: context,
//           builder: (ctx) => AlertDialog(
//                 title: Text(e.toString() ==
//                         "Converting object to an encodable object failed: Instance of 'DateTime'"
//                     ? 'Success!!!'
//                     : 'An Error Occurred!'),
//                 content: Text(e.toString()),
//                 actions: [
//                   FlatButton(
//                     child: Text('okay'),
//                     onPressed: () {
//                       Navigator.pop(context);
//                     },
//                   )
//                 ],
//               ));
//     }
//   }
//   //
//   Future<void> logOut() async {
//     _token = null;
//     _expiryDate = null;
//     _userId = null;
//     if (_authTimer != null) {
//       _authTimer.cancel();
//       _authTimer = null;
//     }
//     final prefs = await SharedPreferences.getInstance();
//     prefs.clear();
//     // HelperFunctions.saveUserLoggedInSharedPreference(false);
//
//     notifyListeners();
//   }
//
//   void _autoLogOut() {
//     if (_authTimer != null) {
//       _authTimer.cancel();
//       _authTimer = null;
//     }
//     final timeExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
//     _authTimer = Timer(Duration(seconds: timeExpiry), logOut);
//   }
//
//   Future<bool> autoLogin() async {
//     final prefs = await SharedPreferences.getInstance();
//     if (!prefs.containsKey("userData")) {
//       return false;
//     }
//     final extractedData =
//         json.decode(prefs.getString('userData')) as Map<String, Object>;
//     final expiryDate = DateTime.parse(extractedData['expiryDate']);
//     if (expiryDate.isBefore(DateTime.now())) {
//       return false;
//     }
//     _token = extractedData['token'];
//     _expiryDate = expiryDate;
//     _userId = extractedData['userId'];
//     notifyListeners();
//     _autoLogOut();
//     return true;
//   }
//
// //   Future<void> addUsertoDatabase(
// //       String userId, String authToken, String email) async {
// //     final url =
// //         "https://online-shop-99264.firebaseio.com/users/$userId.json?auth=$authToken";
// //     try {
// //       final response = await http.put(url,
// //           body: json.encode({
// //             'userId': userId,
// //             'email': email,
// //             'type': 'client',
// //           }));
// // //
// //    print(json.decode(response.body)['name']);
// //
// //       notifyListeners();
// //     } catch (error) {
// //       print(error.message);
// //       throw (error);
// //     }
// //   }
// }
