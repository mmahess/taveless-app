import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class ProfileController extends ChangeNotifier {
  String name = "Made Mahestra Wilothama";
  String email = "mahestra.wilothama@student.undiksha.ac.id";
  XFile? profileImage;
  bool isUploading = false;
  String? uploadedImageUrl;
  String? uploadError;

  final ImagePicker _picker = ImagePicker();

  ProfileController() {
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      name = prefs.getString('profile_name') ?? "Made Mahestra Wilothama";
      email = prefs.getString('profile_email') ?? "mahestra.wilothama@student.undiksha.ac.id";
      uploadedImageUrl = prefs.getString('uploaded_image_url');

      final imagePath = prefs.getString('profile_image_path');
      if (imagePath != null && imagePath.isNotEmpty) {
        final file = File(imagePath);
        if (await file.exists()) {
          profileImage = XFile(imagePath);
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Error loading profile data: $e");
    }
  }

  Future<void> _saveProfileData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_name', name);
      await prefs.setString('profile_email', email);
      if (profileImage != null) {
        await prefs.setString('profile_image_path', profileImage!.path);
      } else {
        await prefs.remove('profile_image_path');
      }
      if (uploadedImageUrl != null) {
        await prefs.setString('uploaded_image_url', uploadedImageUrl!);
      } else {
        await prefs.remove('uploaded_image_url');
      }
    } catch (e) {
      debugPrint("Error saving profile data: $e");
    }
  }

  void updateName(String newName) {
    name = newName;
    _saveProfileData();
    notifyListeners();
  }

  void updateEmail(String newEmail) {
    email = newEmail;
    _saveProfileData();
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
          await _saveProfileData();
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
