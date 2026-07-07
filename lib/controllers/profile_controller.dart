import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';

class ProfileController extends ChangeNotifier {
  String name = "Made Mahestra Wilothama";
  String email = "mahestra.wilothama@student.undiksha.ac.id";
  XFile? profileImage;
  bool isUploading = false;
  String? uploadedImageUrl;
  String? uploadError;
  
  final ImagePicker _picker = ImagePicker();

  void updateName(String newName) {
    name = newName;
    notifyListeners();
  }

  void updateEmail(String newEmail) {
    email = newEmail;
    notifyListeners();
  }

  Future<void> selectProfileImage(ImageSource source) async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 600,
      );
      if (photo != null) {
        profileImage = photo;
        isUploading = true;
        uploadError = null;
        uploadedImageUrl = null;
        notifyListeners();

        try {
          final imageUrl = await ApiService().uploadImage(File(photo.path));
          uploadedImageUrl = imageUrl;
        } catch (err) {
          uploadError = err.toString();
          debugPrint("Error uploading photo: $err");
        } finally {
          isUploading = false;
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint("Error selecting profile image: $e");
    }
  }
}
