import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<ListResult> listImages() async {
    try {
      // Ensure user is authenticated
      User? user = _auth.currentUser;
      if (user == null) {
        throw Exception('User is not authenticated');
      } else {
        ListResult results = await _storage.ref('recipe_images').listAll();

        return results;
      }
    } catch (e) {
      debugPrint('Error listing images: ${e.toString()}');
      rethrow; // Rethrow the error for handling in UI or other layers
    }
  }

  Future<String> downloadRecipeImageURL(String imageName) async {
    try {
      // Ensure user is authenticated
      User? user = _auth.currentUser;
      if (user == null) {
        throw Exception('User is not authenticated');
      } else {
        String path = 'recipe_images/$imageName';
        String downloadURL = await _storage.ref(path).getDownloadURL();
        return downloadURL;
      }
    } catch (e) {
      return await _storage
          .ref('recipe_images/default_food_img.png')
          .getDownloadURL();
    }
  }

  Future<String> downloadCultureImageURL(String imageName) async {
    try {
      // Ensure user is authenticated
      User? user = _auth.currentUser;
      if (user == null) {
        throw Exception('User is not authenticated');
      } else {
        String path = 'culture_images/$imageName';
        String downloadURL = await _storage.ref(path).getDownloadURL();
        return downloadURL;
      }
    } catch (e) {
      return await _storage
          .ref('recipe_images/default_food_img.png')
          .getDownloadURL();
    }
  }

  Future<String> uploadImage(File imageFile, String imageName) async {
    try {
      // Ensure user is authenticated
      User? user = _auth.currentUser;
      if (user == null) {
        throw Exception('User is not authenticated');
      } else {
        String filePath = 'recipe_images/$imageName';
        await _storage.ref(filePath).putFile(imageFile);
        String downloadURL = await _storage.ref(filePath).getDownloadURL();
        return downloadURL;
      }
    } catch (e) {
      debugPrint('Error uploading image: ${e.toString()}');
      rethrow; // Rethrow the error for handling in UI or other layers
    }
  }
}
