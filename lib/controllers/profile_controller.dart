import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileController extends ChangeNotifier {
  String name = "Made Mahestra Wilothama";
  String email = "mahestra.wilothama@student.undiksha.ac.id";
  XFile? profileImage;
  
  final ImagePicker _picker = ImagePicker();

  void updateName(String newName) {
    name = newName;
    notifyListeners();
  }

  void updateEmail(String newEmail) {
    email = newEmail;
    notifyListeners();
  }

  Future<void> capturePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 600,
      );
      if (photo != null) {
        profileImage = photo;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error capturing photo: $e");
    }
  }
}
