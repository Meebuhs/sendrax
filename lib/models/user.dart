import 'package:firebase_auth/firebase_auth.dart';

import 'login_response.dart';

class User extends LoginResponse {
  final String uid;

  User(this.uid);

  User.fromFirebaseUser(FirebaseUser firebaseUser)
      : this(firebaseUser.uid);

  Map<String, dynamic> get map {
    return {"uid": uid};
  }
}
