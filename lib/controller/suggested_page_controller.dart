import 'package:flutter/material.dart';
import 'package:string_similarity/string_similarity.dart';
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

  Future<void> initialize() async {
    mongoDBService = await MongoDBService.create();
    await fetchAllCultures();
    await fetchAllRecipes();
  }

  Future<void> fetchAllRecipes() async {
    try {
      allRecipes = await mongoDBService.getAllRecipes();
      allRecipes.shuffle(); // Shuffle all recipes
      suggestedRecipes.value =
          allRecipes.take(6).toList(); // Take the first 6 shuffled recipes
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

  Future<void> showRecipesByCulture(String cultureId) async {
    try {
      isSearching.value = true;
      searchedRecipes.value =
          await mongoDBService.getRecipesByCultureId(cultureId);
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

  void dispose() {
    mongoDBService.disconnect();
  }
}
