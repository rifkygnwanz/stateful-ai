import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';

class ImageUploaderService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadImage(Uint8List imageBytes, String fileName) async {
    final ref = _storage.ref().child('chat_images/$fileName');
    final uploadTask = await ref.putData(imageBytes);
    return await uploadTask.ref.getDownloadURL();
  }
}
