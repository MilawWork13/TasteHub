import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:string_similarity/string_similarity.dart';
import 'package:taste_hub/components/toast.dart';
import 'package:taste_hub/controller/services/mongo_db_service.dart';
import 'package:taste_hub/model/Culture.dart';
import 'package:taste_hub/model/Recipe.dart';

class RecipeController {
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

  // Initialization methods
  Future<void> initialize() async {
    mongoDBService = await MongoDBService.create();
    await fetchAllCultures();
    await fetchAllRecipes();
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await fetchFavoriteRecipes(user.email!);
    }
  }

  // Fetching data methods
  Future<void> fetchAllRecipes() async {
    try {
      allRecipes = await mongoDBService.getAllRecipes();
      allRecipes.shuffle();
      suggestedRecipes.value = allRecipes
          .where((recipe) => recipe.creator.toLowerCase() == 'tastehub')
          .take(6)
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching recipes: $e');
      }
    }
  }

  // Get all cultures from mongoDB
  Future<void> fetchAllCultures() async {
    try {
      cultures.value = await mongoDBService.getAllCultures();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching cultures: $e');
      }
    }
  }

  // Fetch favorite recipes for a user
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
      if (kDebugMode) {
        print('Error fetching favorite recipes: $e');
      }
    }
  }

  // Fetch recipes created by a user
  Future<void> fetchRecipesCreatedByUser(String email) async {
    try {
      List<Recipe> userRecipes =
          await mongoDBService.getRecipesCreatedByUser(email);
      createdByUserRecipes.value = userRecipes;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching recipes created by user: $e');
      }
    }
  }

  // Searching methods
  void searchRecipes(String query) {
    if (query.isNotEmpty) {
      isSearching.value = true;
      searchedRecipes.value =
          _filterRecipesByQuery(allRecipes, query, 'tastehub');
    } else {
      isSearching.value = false;
      searchedRecipes.value = [];
    }
  }

  // Search for favorite recipes
  void searchFavouriteRecipes(String query) {
    if (query.isNotEmpty) {
      isSearching.value = true;
      searchedFavouriteRecipes.value =
          _filterRecipesByQuery(favouriteRecipes.value, query, 'tastehub');
    } else {
      isSearching.value = false;
      searchedFavouriteRecipes.value = [];
    }
  }

  // Search for recipes created by user
  void searchCreatedRecipes(String query, String userEmail) {
    if (query.isNotEmpty) {
      isSearching.value = true;
      searchedCreatedByUserRecipes.value =
          _filterRecipesByQuery(createdByUserRecipes.value, query, userEmail);
    } else {
      isSearching.value = false;
      searchedCreatedByUserRecipes.value = [];
    }
  }

  // Show recipes by culture
  Future<void> showRecipesByCulture(String cultureId) async {
    try {
      isSearching.value = true;
      List<Recipe> recipes =
          await mongoDBService.getRecipesByCultureId(cultureId);
      searchedRecipes.value = recipes
          .where((recipe) => recipe.creator.toLowerCase() == 'tastehub')
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching recipes by culture: $e');
      }
    }
  }

  // Creating recipes
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
        return; // or errorImage
      }

      // Validate instruction controllers
      if (!_validateControllers(instructionControllers)) {
        showErrorToast(context,
            message: 'Please fill in all instruction fields.');
        return; // or errorImage
      }

      // Validate name controller
      if (!_validateName(nameController)) {
        showErrorToast(context, message: 'Please enter a recipe name.');
        return; // or errorImage
      }

      // Validate preparation time
      if (!_validatePreparationTime(prepTimeController)) {
        showErrorToast(context,
            message: 'Please enter a valid preparation time.');
        return; // or errorImage
      }

      // Validate price
      if (!_validatePrice(priceController)) {
        showErrorToast(context, message: 'Please enter a valid price.');
        return; // or errorImage
      }

      String image = selectedImage ?? 'default_image';
      String? cultureId = _getCultureId(selectedCulture);
      if (cultureId == null) {
        showErrorToast(context, message: 'Please select the culture.');
        return;
      }

      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        showErrorToast(context, message: 'User not logged in.');
        return;
      }

      List<String> allergens = _getAllergens(allergenControllers);

      Recipe newRecipe = Recipe(
        id: ObjectId(),
        name: nameController.text,
        ingredients: _getIngredients(ingredientControllers),
        instructions: _getInstructions(instructionControllers),
        cultureId: cultureId,
        preparationTime: int.tryParse(prepTimeController.text) ?? 0,
        allergens: allergens,
        price: double.tryParse(priceController.text) ?? 0.0,
        creator: user.email!,
        creationDate: _getCurrentDate(),
        image: image,
      );

      await mongoDBService.addRecipe(context, newRecipe.toJson());

      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  // Utility methods
  List<Recipe> _filterRecipesByQuery(
      List<Recipe> recipes, String query, String creator) {
    return recipes
        .where((recipe) =>
            recipe.creator.toLowerCase() == creator.toLowerCase() &&
            (recipe.name.toLowerCase().startsWith(query.toLowerCase()) ||
                recipe.name.toLowerCase().similarityTo(query.toLowerCase()) >
                    0.7))
        .toList();
  }

  // Get culture ID from selected culture
  String? _getCultureId(String? selectedCulture) {
    for (var culture in cultures.value) {
      if (culture.name == selectedCulture) {
        return culture.id
            .toString()
            .replaceAll('ObjectId("', '')
            .replaceAll('")', '');
      }
    }
    return null;
  }

  // Get allergens from allergen controllers
  List<String> _getAllergens(List<TextEditingController> allergenControllers) {
    List<String> allergens =
        allergenControllers.map((controller) => controller.text).toList();
    if (allergens.isEmpty) {
      allergens.add('No allergens');
    }
    return allergens;
  }

  // Get ingredients from ingredient controllers
  List<Ingredient> _getIngredients(
      List<Map<String, TextEditingController>> ingredientControllers) {
    return ingredientControllers.map((controllerMap) {
      return Ingredient(
        name: controllerMap['name']!.text,
        quantity: controllerMap['quantity']!.text,
      );
    }).toList();
  }

  // Get instructions from instruction controllers
  List<Instruction> _getInstructions(
      List<Map<String, TextEditingController>> instructionControllers) {
    return instructionControllers.map((controllerMap) {
      return Instruction(
        step: controllerMap['step']!.text,
        order: int.tryParse(controllerMap['order']!.text) ?? 0,
      );
    }).toList();
  }

  // Validate controllers
  bool _validateControllers(
      List<Map<String, TextEditingController>> controllers) {
    for (var controllerMap in controllers) {
      for (var controller in controllerMap.values) {
        if (controller.text.trim().isEmpty) {
          return false;
        }
      }
    }
    return true;
  }

  bool _validatePreparationTime(TextEditingController controller) {
    String? text = controller.text.trim();
    return text.isNotEmpty && int.tryParse(text) != null;
  }

  bool _validatePrice(TextEditingController controller) {
    String? text = controller.text.trim();
    return text.isNotEmpty && double.tryParse(text) != null;
  }

  bool _validateName(TextEditingController nameController) {
    return nameController.text.isNotEmpty;
  }

  Future<void> refreshPage() async {
    await fetchAllRecipes();
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await fetchFavoriteRecipes(user.email!);
    }
  }

  String _getCurrentDate() {
    DateTime now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }

  void dispose() {
    mongoDBService.disconnect();
  }
}
