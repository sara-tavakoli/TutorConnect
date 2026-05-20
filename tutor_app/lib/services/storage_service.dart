import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

/// Handles image picking and uploading profile photos to Cloudinary.
class StorageService {
  final ImagePicker _picker = ImagePicker();

  static const _uploadPreset = 'oh0kwd3d';
  static const _uploadUrl =
      'https://api.cloudinary.com/v1_1/dtfzr3awd/image/upload';

  /// Opens the device gallery or camera and returns the selected image file.
  Future<XFile?> pickImage({bool fromCamera = false}) async {
    return await _picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 800,
    );
  }

  /// Uploads [file] to Cloudinary and returns the secure URL of the uploaded image.
  Future<String> uploadProfilePhoto({
    required String uid,
    required XFile file,
  }) async {
    final bytes = await file.readAsBytes();

    final request = http.MultipartRequest('POST', Uri.parse(_uploadUrl));
    request.fields['upload_preset'] = _uploadPreset;
    request.fields['tags'] = 'profile';
    request.files.add(http.MultipartFile.fromBytes(
      'file',
      bytes,
      filename: 'photo.jpg',
    ));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['secure_url'] as String;
    } else {
      throw Exception('Upload failed: ${response.body}');
    }
  }
}
