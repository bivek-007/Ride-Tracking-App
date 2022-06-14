import 'package:firebase_database/firebase_database.dart';

class Users {
  String? id;
  String? email;
  String? name;
  String? phone;

  String? isSuspended;
  Users({this.id, this.email, this.name, this.phone});
  Users.fromSnapshot(DataSnapshot dataSnapshot) {
    id = dataSnapshot.key;
    email = dataSnapshot.value['email'];

    name = dataSnapshot.value['name'];

    phone = dataSnapshot.value['phone'];
    isSuspended = dataSnapshot.value['isSuspended'];
  }
}
