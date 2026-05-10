import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class StorageService {
  final ImagePicker _picker = ImagePicker();

  static const _uploadPreset = 'oh0kwd3d';
  static const _uploadUrl =
      'https://api.cloudinary.com/v1_1/dtfzr3awd/image/upload';

  Future<XFile?> pickImage({bool fromCamera = false}) async {
    return await _picker.pickImage(
      source: fromCamera
          ? ImageSource.camera
          : ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 800,
    );
  }

  Future<String> uploadProfilePhoto({
    required String uid,
    required XFile file,
  }) async {
    print('DEBUG: starting Cloudinary upload for uid=$uid');

    final bytes       = await file.readAsBytes();
    final base64Image = base64Encode(bytes);

    // Always use jpeg regardless of original format
    final dataUri = 'data:image/jpeg;base64,$base64Image';

    print('DEBUG: image encoded — size=${bytes.length} bytes');

    // Use multipart form instead of body map
    // This avoids filename/display name issues entirely
    final request = http.MultipartRequest(
      'POST',
      Uri.parse(_uploadUrl),
    );

    request.fields['upload_preset'] = _uploadPreset;
    request.fields['tags']          = 'profile';

    request.files.add(http.MultipartFile.fromBytes(
      'file',
      bytes,
      filename: 'photo.jpg', // clean simple filename
    ));

    print('DEBUG: sending multipart request...');
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    print('DEBUG: response ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final url  = data['secure_url'] as String;
      print('DEBUG: success — url=$url');
      return url;
    } else {
      print('DEBUG: failed — ${response.body}');
      throw Exception('Upload failed: ${response.body}');
    }
  }
}
