import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

import 'firebase_auth_service.dart';

class ImageHelper {
  final _picker = ImagePicker();

  Future<File?> selectImageFromGallery() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
      maxHeight: 615,
      maxWidth: 400,
    );

    if (pickedFile == null) {
      // User canceled selecting an image
      return null;
    }

    return File(pickedFile.path);
  }

  Future<File?> takePicture() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 100,
      maxHeight: 615,
      maxWidth: 400,
    );

    if (pickedFile == null) {
      // User canceled taking a picture
      return null;
    }

    return File(pickedFile.path);
  }

  Future<String?> uploadImageToFirebaseStorage(String email, String password, File imageFile) async {
    final FirebaseAuthService authService = FirebaseAuthService();
    User? user = await authService.signInWithEmailAndPassword(email, password);

    if (user != null) {
      try {
        firebase_storage.Reference storageReference =
        firebase_storage.FirebaseStorage.instance.ref().child('images/${DateTime.now()}.png');

        firebase_storage.UploadTask uploadTask = storageReference.putFile(imageFile);

        uploadTask.snapshotEvents.listen((firebase_storage.TaskSnapshot snapshot) {
          print('Task state: ${snapshot.state}'); // Debugging purpose

          if (snapshot.state == firebase_storage.TaskState.success) {
            storageReference.getDownloadURL().then((String url) {
              return url;
            });
          }
        });
      } catch (e) {
        print('Error uploading image to Firebase Storage: $e');
        // Handle the error as needed
      }
    }
    return null;
  }
}
