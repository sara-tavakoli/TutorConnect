import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

// Uploads a photo file to Firebase Storage and returns the download URL to save in Firestore.

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  // Opens camera or gallery and returns the picked file
  Future<XFile?> pickImage({bool fromCamera = false}) async {
    return await _picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 800,
    );
  }

  // Uploads the picked image to Firebase Storage
  // Returns the public download URL
  Future<String> uploadProfilePhoto({
    required String uid,
    required XFile file,
  }) async {
    final ref = _storage.ref().child('profile_photos/$uid.jpg');
    await ref.putFile(File(file.path));
    return await ref.getDownloadURL();
  }
}