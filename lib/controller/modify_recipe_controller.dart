import 'dart:io';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:taste_hub/controller/services/firebase_storage_service.dart';
import 'package:taste_hub/controller/services/mongo_db_service.dart';
import 'package:taste_hub/controller/recipe_controller.dart';
import 'package:taste_hub/model/Culture.dart';
import 'package:taste_hub/model/Recipe.dart';
import 'package:taste_hub/components/toast.dart';

class ModifyRecipeController {
  final Recipe recipe;
  final FirebaseStorageService firebaseStorageService;
  final MongoDBService mongoDBService;

  late User? _user;
  List<Culture> cultures = [];

  ModifyRecipeController({
    required this.recipe,
    required this.firebaseStorageService,
    required this.mongoDBService,
  });

  List<Culture> get culturesList => cultures;

  // Initialize the page by fetching initial data
  Future<void> initializePage() async {
    final RecipeController controller = RecipeController();
    await controller.initialize();
    cultures = controller.cultures.value;
    _user = FirebaseAuth.instance.currentUser;
    if (_user != null) {
      await controller.fetchFavoriteRecipes(_user!.email!);
      await controller.fetchRecipesCreatedByUser(_user!.email!);
    }
  }

  // Load the image of the recipe
  Future<String?> loadImage() async {
    return await firebaseStorageService.downloadRecipeImageURL(recipe.image);
  }

  // Pick an image from the gallery
  Future<void> pickImage(TextEditingController nameController,
      Function(File?) setImagePath, Function(String?) setImageName) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      String randomString = generateRandomString(6);
      String imageName = '${nameController.text}_$randomString';

      setImagePath(File(pickedFile.path));
      setImageName(imageName);

      await firebaseStorageService.uploadImage(
          File(pickedFile.path), imageName);
    }
  }

  // Generate a random string of the specified length
  String generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    return List.generate(length, (index) => chars[random.nextInt(chars.length)])
        .join();
  }

  // Modify the recipe
  Future<void> modifyRecipe(
    BuildContext context,
    TextEditingController nameController,
    TextEditingController priceController,
    TextEditingController prepTimeController,
    List<Map<String, TextEditingController>> ingredientControllers,
    List<Map<String, TextEditingController>> instructionControllers,
    List<TextEditingController> allergenControllers,
    String? selectedCultureName,
    String? selectedImage,
  ) async {
    try {
      // Validate ingredient controllers
      if (!_validateControllers(ingredientControllers)) {
        showErrorToast(context,
            message: 'Please fill in all ingredient fields.');
        return;
      }

      // Validate instruction controllers
      if (!_validateControllers(instructionControllers)) {
        showErrorToast(context,
            message: 'Please fill in all instruction fields.');
        return;
      }

      // Validate name controller
      if (!_validateName(nameController)) {
        showErrorToast(context, message: 'Please enter a recipe name.');
        return;
      }

      // Validate preparation time
      if (!_validatePreparationTime(prepTimeController)) {
        showErrorToast(context,
            message: 'Please enter a valid preparation time.');
        return;
      }

      // Validate price
      if (!_validatePrice(priceController)) {
        showErrorToast(context, message: 'Please enter a valid price.');
        return;
      }

      String selectedCultureId =
          await mongoDBService.getCultureIdByName(selectedCultureName ?? '') ??
              '';

      Recipe updatedRecipe = Recipe(
        id: recipe.id,
        name: nameController.text,
        ingredients: ingredientControllers.map((controllerMap) {
          return Ingredient(
            name: controllerMap['name']!.text,
            quantity: controllerMap['quantity']!.text,
          );
        }).toList(),
        instructions: instructionControllers.map((controllerMap) {
          return Instruction(
            step: controllerMap['step']!.text,
            order: int.tryParse(controllerMap['order']!.text) ?? 0,
          );
        }).toList(),
        cultureId: selectedCultureId,
        preparationTime: int.tryParse(prepTimeController.text) ?? 0,
        allergens: allergenControllers.isEmpty
            ? ['No allergens']
            : allergenControllers.map((controller) => controller.text).toList(),
        price: double.tryParse(priceController.text) ?? 0.0,
        creator: recipe.creator,
        creationDate: recipe.creationDate,
        image: selectedImage ?? 'default_image',
      );

      // Convert the updated recipe to JSON
      Map<String, dynamic> recipeJson = updatedRecipe.toJson();

      // Update the recipe in MongoDB
      // ignore: use_build_context_synchronously
      await mongoDBService.updateRecipe(context, recipeJson);

      if (recipe.image != updatedRecipe.image) {
        final storageRef =
            FirebaseStorage.instance.ref('recipe_images/${recipe.image}');
        await storageRef.delete();
      }
      // ignore: use_build_context_synchronously
      Navigator.pop(context, true);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      // ignore: use_build_context_synchronously
      showErrorToast(context, message: 'Failed to update recipe.');
    }
  }

  // Validate the controllers
  bool _validateControllers(
      List<Map<String, TextEditingController>> controllers) {
    for (var controllerMap in controllers) {
      for (var controller in controllerMap.values) {
        if (controller.text.isEmpty) {
          return false;
        }
      }
    }
    return true;
  }

  // Validate the recipe name
  bool _validateName(TextEditingController controller) {
    return controller.text.isNotEmpty;
  }

  // Validate the preparation time
  bool _validatePreparationTime(TextEditingController controller) {
    return int.tryParse(controller.text) != null;
  }

  // Validate the price
  bool _validatePrice(TextEditingController controller) {
    return double.tryParse(controller.text) != null;
  }
}
