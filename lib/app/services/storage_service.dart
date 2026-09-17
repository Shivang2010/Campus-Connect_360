import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class StorageService extends GetxService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  // Pick an image from device gallery
  Future<XFile?> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      return image;
    } catch (e) {
      Get.snackbar(
        'Image Selection Error',
        'Could not select image: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }
  }

  // Upload image to Firebase Storage under marketplace_images/{itemId}.jpg
  Future<String?> uploadMarketplaceImage({
    required String itemId,
    required XFile imageFile,
  }) async {
    try {
      final Reference ref =
          _storage.ref().child('marketplace_images/$itemId.jpg');

      final Uint8List bytes = await imageFile.readAsBytes();
      final UploadTask uploadTask = ref.putData(
        bytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      Get.snackbar(
        'Upload Error',
        'Could not upload marketplace image: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }
  }

  // Upload image to Firebase Storage under profile_images/{uid}.jpg
  Future<String?> uploadProfileImage({
    required String uid,
    required XFile imageFile,
  }) async {
    try {
      final Reference ref =
          _storage.ref().child('profile_images/$uid.jpg');

      final Uint8List bytes = await imageFile.readAsBytes();
      final UploadTask uploadTask = ref.putData(
        bytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      Get.snackbar(
        'Upload Error',
        'Could not upload profile picture: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }
  }
}
