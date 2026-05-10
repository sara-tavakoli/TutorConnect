import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker     _picker  = ImagePicker();

  // Pick image from gallery or camera
  Future<XFile?> pickImage({bool fromCamera = false}) async {
    return await _picker.pickImage(
      source: fromCamera
          ? ImageSource.camera
          : ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 800,
    );
  }

  // Upload using bytes works on both web and mobile
  Future<String> uploadProfilePhoto({
    required String uid,
    required XFile file,
  }) async {
    final ref   = _storage.ref().child('profile_photos/$uid.jpg');
    final bytes = await file.readAsBytes(); // works on web + mobile
    await ref.putData(
      bytes,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    return await ref.getDownloadURL();
  }
}