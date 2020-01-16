import 'package:firebase_auth/firebase_auth.dart';

import 'login_response.dart';

class User extends LoginResponse {
  final String uid;
  final String displayName;

  User(this.uid, this.displayName);

  User.fromFirebaseUser(FirebaseUser firebaseUser)
      : this(firebaseUser.uid, firebaseUser.displayName);

  Map<String, dynamic> get map {
    return {"uid": uid, "displayName": displayName};
  }
}
