import 'dart:io';


import 'package:firebase_storage/firebase_storage.dart';

class FirebaseApi {
  static UploadTask? uploadFile(String destenation, File file) {
    try {
      final ref = FirebaseStorage.instance.ref(destenation);
      return ref.putFile(file);
    } on FirebaseException catch (e) {
      return null;
    }
  }
}
