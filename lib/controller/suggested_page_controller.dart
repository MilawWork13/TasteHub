import 'package:flutter/material.dart';
import 'package:string_similarity/string_similarity.dart';
import 'package:taste_hub/controller/services/mongo_db_service.dart';
import 'package:taste_hub/model/Recipe.dart';

class SuggestedPageController {
  late final MongoDBService mongoDBService;
  late List<Recipe> recipes = [];
  late List<Recipe> suggestedRecipes = [];
  late List<Recipe> searchedRecipes = [];
  final isSearching = ValueNotifier<bool>(false);

  Future<void> initialize() async {
    mongoDBService = await MongoDBService.create();
    await fetchAllRecipes();
  }

  Future<void> fetchAllRecipes() async {
    recipes = await mongoDBService.getAllRecipes();
    recipes.shuffle(); // Shuffle all recipes
    suggestedRecipes =
        recipes.take(6).toList(); // Take the first 6 shuffled recipes
  }

  Future<void> refreshPage() async {
    await fetchAllRecipes();
  }

  void searchRecipes(String query) async {
    if (query.isNotEmpty) {
      isSearching.value = true;
      searchedRecipes = recipes
          .where((recipe) =>
              recipe.creator.toLowerCase() == 'tastehub' &&
              (recipe.name.toLowerCase().startsWith(query.toLowerCase()) ||
                  recipe.name.toLowerCase().similarityTo(query.toLowerCase()) >
                      0.7))
          .toList();
    } else {
      isSearching.value = false;
      searchedRecipes = [];
    }
  }

  void dispose() {
    mongoDBService.disconnect();
  }
}
