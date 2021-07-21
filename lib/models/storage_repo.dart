import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:sendrax/models/user_repo.dart';

class StorageRepo {
  static StorageRepo _instance;

  final FirebaseStorage _firebaseStorage;

  StorageRepo._internal(this._firebaseStorage);

  factory StorageRepo.getInstance() {
    if (_instance == null) {
      _instance = StorageRepo._internal(FirebaseStorage.instance);
    }
    return _instance;
  }

  Future<String> uploadFile(File file) async {
    final user = await UserRepo.getInstance().getCurrentUser();
    return _firebaseStorage
        .ref()
        .child(user.uid)
        .child(file.uri.pathSegments.last)
        .putFile(file)
        .then((res) {
      return res.metadata.fullPath;
    }, onError: (error) {
      return null;
    });
  }

  void deleteFileByUri(String uri) async {
    _firebaseStorage.ref().child(uri).delete();
  }

  Future<String> decodeUri(String uri) async {
    return _firebaseStorage
        .ref()
        .child(uri)
        .getDownloadURL()
        .then((result) => result.toString());
  }
}
