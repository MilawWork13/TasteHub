import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:string_similarity/string_similarity.dart';
import 'package:taste_hub/components/toast.dart';
import 'package:taste_hub/controller/services/mongo_db_service.dart';
import 'package:taste_hub/model/Culture.dart';
import 'package:taste_hub/model/Recipe.dart';

class SuggestedPageController {
  late final MongoDBService mongoDBService;
  List<Recipe> allRecipes = [];
  final ValueNotifier<List<Culture>> cultures = ValueNotifier([]);
  final ValueNotifier<List<Recipe>> suggestedRecipes = ValueNotifier([]);
  final ValueNotifier<List<Recipe>> searchedRecipes = ValueNotifier([]);
  final ValueNotifier<bool> isSearching = ValueNotifier(false);
  final ValueNotifier<List<Recipe>> favouriteRecipes = ValueNotifier([]);
  final ValueNotifier<List<Recipe>> searchedFavouriteRecipes =
      ValueNotifier([]);
  final ValueNotifier<List<Recipe>> createdByUserRecipes = ValueNotifier([]);
  final ValueNotifier<List<Recipe>> searchedCreatedByUserRecipes =
      ValueNotifier([]);

  Future<void> initialize() async {
    mongoDBService = await MongoDBService.create();
    await fetchAllCultures();
    await fetchAllRecipes();
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await fetchFavoriteRecipes(user.email!);
    }
  }

  Future<void> fetchAllRecipes() async {
    try {
      allRecipes = await mongoDBService.getAllRecipes();
      allRecipes.shuffle(); // Shuffle all recipes
      suggestedRecipes.value = allRecipes
          .where((recipe) => recipe.creator.toLowerCase() == 'tastehub')
          .take(6)
          .toList();
    } catch (e) {
      print('Error fetching recipes: $e');
    }
  }

  Future<void> refreshPage() async {
    await fetchAllRecipes();
  }

  void searchRecipes(String query) {
    if (query.isNotEmpty) {
      isSearching.value = true;
      searchedRecipes.value = allRecipes
          .where((recipe) =>
              recipe.creator.toLowerCase() == 'tastehub' &&
              (recipe.name.toLowerCase().startsWith(query.toLowerCase()) ||
                  recipe.name.toLowerCase().similarityTo(query.toLowerCase()) >
                      0.7))
          .toList();
    } else {
      isSearching.value = false;
      searchedRecipes.value = [];
    }
  }

  void searchFavouriteRecipes(String query) {
    if (query.isNotEmpty) {
      isSearching.value = true;
      searchedFavouriteRecipes.value = favouriteRecipes.value
          .where((recipe) =>
              recipe.creator.toLowerCase() == 'tastehub' &&
              (recipe.name.toLowerCase().startsWith(query.toLowerCase()) ||
                  recipe.name.toLowerCase().similarityTo(query.toLowerCase()) >
                      0.7))
          .toList();
    } else {
      isSearching.value = false;
      searchedFavouriteRecipes.value = [];
    }
  }

  Future<void> showRecipesByCulture(String cultureId) async {
    try {
      isSearching.value = true;
      List<Recipe> recipes =
          await mongoDBService.getRecipesByCultureId(cultureId);
      searchedRecipes.value = recipes
          .where((recipe) => recipe.creator.toLowerCase() == 'tastehub')
          .toList(); // Filter recipes created by TasteHub
    } catch (e) {
      print('Error fetching recipes by culture: $e');
    }
  }

  Future<void> fetchAllCultures() async {
    try {
      cultures.value = await mongoDBService.getAllCultures();
    } catch (e) {
      print('Error fetching cultures: $e');
    }
  }

  Future<void> fetchFavoriteRecipes(String email) async {
    try {
      List<String> favoriteRecipeIds =
          await mongoDBService.getUserFavoriteRecipeByEmail(email);
      List<Recipe> recipes = [];
      for (String recipeId in favoriteRecipeIds) {
        Recipe? recipe = await mongoDBService.getRecipeById(recipeId);
        if (recipe != null) {
          recipes.add(recipe);
        }
      }
      favouriteRecipes.value = recipes;
    } catch (e) {
      print('Error fetching favorite recipes: $e');
    }
  }

  Future<void> fetchRecipesCreatedByUser(String email) async {
    try {
      List<Recipe> userRecipes =
          await mongoDBService.getRecipesCreatedByUser(email);
      createdByUserRecipes.value = userRecipes;
    } catch (e) {
      print('Error fetching recipes created by user: $e');
    }
  }

  void searchCreatedByUserRecipes(String query) {
    if (query.isNotEmpty) {
      isSearching.value = true;
      searchedCreatedByUserRecipes.value = createdByUserRecipes.value
          .where((recipe) =>
              recipe.name.toLowerCase().startsWith(query.toLowerCase()) ||
              recipe.name.toLowerCase().similarityTo(query.toLowerCase()) > 0.7)
          .toList();
    } else {
      isSearching.value = false;
      searchedCreatedByUserRecipes.value = [];
    }
  }

  void createRecipe(
    BuildContext context,
    TextEditingController nameController,
    TextEditingController priceController,
    TextEditingController prepTimeController,
    List<Map<String, TextEditingController>> ingredientControllers,
    List<Map<String, TextEditingController>> instructionControllers,
    List<TextEditingController> allergenControllers,
    String? selectedImage,
    String? selectedCulture,
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

      // Default image handling
      String image = selectedImage ?? 'default_image';

      // Find the selected culture ID
      String? cultureId;
      for (var culture in cultures.value) {
        if (culture.name == selectedCulture) {
          cultureId = culture.id
              .toString()
              .replaceAll('ObjectId("', '')
              .replaceAll('")', '');
          break;
        }
      }

      if (cultureId == null) {
        showErrorToast(context, message: 'Selected culture not found.');
        return;
      }

      // Get the user's email
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        showErrorToast(context, message: 'User not logged in.');
        return;
      }
      String creatorEmail = user.email!;

      // Get current date

      // Collect allergens
      List<String> allergens =
          allergenControllers.map((controller) => controller.text).toList();
      if (allergens.isEmpty) {
        allergens.add('No allergens');
      }

      // Collect audios (assuming you have a way to add audio files)
      List<String> audios =
          []; // Replace with actual audio paths or URLs if applicable

      // Create a new Recipe object
      Recipe newRecipe = Recipe(
        id: ObjectId(),
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
        cultureId: cultureId,
        preparationTime: int.tryParse(prepTimeController.text) ?? 0,
        allergens: allergens.isEmpty ? ['No allergens'] : allergens,
        price: double.tryParse(priceController.text) ?? 0.0,
        creator: creatorEmail,
        creationDate: _getCurrentDate(),
        image: image,
        audios: audios,
      );

      // Convert the recipe to JSON
      Map<String, dynamic> recipeJson = {
        '_id': newRecipe.id,
        'name': newRecipe.name,
        'ingredients': newRecipe.ingredients
            .map((i) => {'name': i.name, 'quantity': i.quantity})
            .toList(),
        'instructions': newRecipe.instructions
            .map((i) => {'step': i.step, 'order': i.order})
            .toList(),
        'culture': newRecipe.cultureId,
        'preparation_time': newRecipe.preparationTime,
        'allergens': newRecipe.allergens,
        'price': newRecipe.price,
        'creator': newRecipe.creator,
        'creation_date': newRecipe.creationDate,
        'image': newRecipe.image,
        'audios': newRecipe.audios,
      };

      // Insert the recipe into MongoDB
      await mongoDBService.addRecipe(context, recipeJson);
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    } catch (e) {
      print(e);
    }
  }

  bool _validateControllers(
    List<Map<String, TextEditingController>> controllers,
  ) {
    // Iterate over each map in the list
    for (var controllerMap in controllers) {
      // Iterate over each controller in the map
      for (var controller in controllerMap.values) {
        // Check if the controller itself is null
        if (controller.text.trim().isEmpty) {
          // If any controller is empty, return false
          return false;
        }
      }
    }
    // If all controllers have text and are not null, return true
    return true;
  }

  bool _validatePreparationTime(TextEditingController controller) {
    String? text = controller.text.trim();
    if (text.isEmpty) return false;
    // Check if the text is a valid integer
    return int.tryParse(text) != null;
  }

  bool _validatePrice(TextEditingController controller) {
    String? text = controller.text.trim();
    if (text.isEmpty) return false;
    // Check if the text is a valid double
    return double.tryParse(text) != null;
  }

  bool _validateName(TextEditingController nameController) {
    return nameController.text.isNotEmpty;
  }

  String _getCurrentDate() {
    DateTime now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }

  void dispose() {
    mongoDBService.disconnect();
  }
}
