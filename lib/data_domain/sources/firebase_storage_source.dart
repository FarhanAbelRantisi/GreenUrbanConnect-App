import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path; // For getting file extension

abstract class FirebaseStorageSource {
  Future<String> uploadFile(File file, String filePath);
}

class FirebaseStorageSourceImpl implements FirebaseStorageSource {
  final FirebaseStorage _firebaseStorage;

  FirebaseStorageSourceImpl(this._firebaseStorage);

  @override
  Future<String> uploadFile(File file, String storagePath) async {
    try {
      final ref = _firebaseStorage.ref().child(storagePath);
      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask.whenComplete(() => {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } on FirebaseException catch (e) {
      print("Firebase Storage Error: ${e.message} (Code: ${e.code})");
      throw Exception("Failed to upload file: ${e.message}");
    } catch (e) {
      print("Unknown error during file upload: $e");
      throw Exception("An unknown error occurred during file upload.");
    }
  }
}