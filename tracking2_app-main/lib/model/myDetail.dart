import 'package:firebase_database/firebase_database.dart';

class MyDetail {
  String? name;

  String? email;
  String? id;
  String? phone;

  String? isSuspended;

  MyDetail({
    this.name,
    this.id,
    this.email,
    this.phone,
    this.isSuspended,
  });

  MyDetail.fromSnapShot(DataSnapshot dataSnapshot) {
    id = dataSnapshot.key;

    email = dataSnapshot.value["email"];
    name = dataSnapshot.value["name"];
    phone = dataSnapshot.value["phone"];
    isSuspended = dataSnapshot.value['isSuspended'] == null
        ? "false"
        : dataSnapshot.value['isSuspended'];
  }
}
