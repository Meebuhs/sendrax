import 'package:firebase_auth/firebase_auth.dart';

import 'login_response.dart';

class AppUser extends LoginResponse {
  final String uid;

  AppUser(this.uid);

  AppUser.fromFirebaseUser(User firebaseUser) : this(firebaseUser.uid);

  Map<String, dynamic> get map {
    return {"uid": uid};
  }
}
