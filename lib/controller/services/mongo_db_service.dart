import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:taste_hub/components/toast.dart';
import 'package:taste_hub/model/Recipe.dart';
import 'package:taste_hub/model/User.dart';
import 'package:taste_hub/model/Culture.dart';
import 'package:taste_hub/model/Report.dart';

class MongoDBService {
  final Db _db;
  late DbCollection _usersCollection;
  late DbCollection _recipesCollection;
  late DbCollection _culturesCollection;
  late DbCollection _reportCollection;
  MongoDBService._create(this._db);

  static Future<MongoDBService> create() async {
    final db = await Db.create(dotenv.env['MONGODB_URL']!);
    await db.open();
    final service = MongoDBService._create(db);
    service._usersCollection = db.collection(dotenv.env['USERS_COLLECTION']!);
    service._recipesCollection =
        db.collection(dotenv.env['RECIPES_COLLECTION']!);
    service._culturesCollection =
        db.collection(dotenv.env['CULTURES_COLLECTION']!);
    service._reportCollection =
        db.collection(dotenv.env['REPORTS_COLLECTION']!);
    return service;
  }

  Future<void> disconnect() async {
    await _db.close();
  }

  Future<void> createUser(UserModel user) async {
    await _usersCollection.insert(user.toJson());
  }

  Future<UserModel?> getUserByEmail(String email) async {
    var user = await _usersCollection.findOne(where.eq('email', email));

    if (user != null) {
      List<ObjectId> favouriteReceipts =
          (user['favourite_receipts'] as List<dynamic>)
              .map<ObjectId>((id) => ObjectId.parse(id.toString()))
              .toList();
      return UserModel(
        id: user['_id'],
        name: user['name'],
        email: user['email'],
        preferredLanguage: user['preferred_language'],
        role: user['role'],
        favouriteReceipts: favouriteReceipts,
      );
    }
    return null;
  }

  Future<List<Recipe>> getAllRecipes() async {
    try {
      final recipes = await _recipesCollection.find().toList();
      if (recipes.isNotEmpty) {
        return recipes.map((json) => Recipe.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching recipes: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getCultureById(String cultureId) async {
    try {
      var culture = await _culturesCollection
          .findOne(where.id(ObjectId.parse(cultureId)));
      return culture;
    } catch (e) {
      print('Error fetching culture: $e');
      return null;
    }
  }

  Future<List<Culture>> getAllCultures() async {
    try {
      final cultures = await _culturesCollection.find().toList();
      if (cultures.isNotEmpty) {
        return cultures.map((json) => Culture.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching cultures: $e');
      return [];
    }
  }

  Future<List<Recipe>> searchRecipes(String searchText) async {
    try {
      final query = where.or([
        where.eq('name', searchText),
        where.eq('creator', 'TasteHub'),
      ] as SelectorBuilder);
      final recipes = await _recipesCollection.find(query).toList();
      if (recipes.isNotEmpty) {
        return recipes.map((json) => Recipe.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Error searching recipes: $e');
      return [];
    }
  }

  Future<List<Recipe>> getRecipesByCultureId(String cultureId) async {
    try {
      final query = where.eq('culture',
          cultureId); // Adjust the query based on your MongoDB schema
      final recipes = await _recipesCollection.find(query).toList();
      if (recipes.isNotEmpty) {
        return recipes.map((json) => Recipe.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching recipes by culture ID: $e');
      return [];
    }
  }

  Future<Recipe?> getRecipeById(String recipeId) async {
    try {
      final query = where.id(ObjectId.parse(recipeId));
      final recipe = await _recipesCollection.findOne(query);
      if (recipe != null) {
        return Recipe.fromJson(recipe);
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching recipe by ID: $e');
      return null;
    }
  }

  Future<List<String>> getUserFavoriteRecipeByEmail(String email) async {
    try {
      print("starting the favourite getting");
      final user = await _usersCollection.findOne(where.eq('email', email));
      if (user != null && user['favourite_receipts'] != null) {
        print("Returning the list");
        return List<String>.from(user['favourite_receipts']);
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching user favorite recipe IDs: $e');
      return [];
    }
  }

  Future<void> addRecipeToFavorites(String email, String recipeId) async {
    try {
      await _usersCollection.update(
        where.eq('email', email),
        modify.addToSet('favourite_receipts', recipeId),
      );
    } catch (e) {
      print('Error adding recipe to favorites: $e');
    }
  }

  Future<void> removeRecipeFromFavorites(String email, String recipeId) async {
    try {
      await _usersCollection.update(
        where.eq('email', email),
        modify.pull('favourite_receipts', recipeId),
      );
    } catch (e) {
      print('Error removing recipe from favorites: $e');
    }
  }

  Future<List<Recipe>> getRecipesCreatedByUser(String email) async {
    try {
      final query = where.eq('creator', email);
      final recipes = await _recipesCollection.find(query).toList();
      if (recipes.isNotEmpty) {
        return recipes.map((json) => Recipe.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching recipes created by user: $e');
      return [];
    }
  }

  Future<bool> addRecipe(
    BuildContext context,
    Map<String, dynamic> recipeJson,
  ) async {
    try {
      await _recipesCollection.insert(recipeJson);
      showSuccessToast(context, message: 'Recipe created successfully!');
      return true;
    } catch (e) {
      showErrorToast(context, message: 'Failed to create recipe.');
      return false;
    }
  }

  Future<void> deleteRecipe(BuildContext context, String email, String recipeId,
      String imageName) async {
    try {
      final storageRef =
          FirebaseStorage.instance.ref('recipe_images/$imageName');
      await storageRef.delete();

      await _recipesCollection.remove(
        where.eq('creator', email).eq('_id', ObjectId.parse(recipeId)),
      );
      // ignore: use_build_context_synchronously
      showErrorToast(context, message: 'Recipe deleted successfully');
    } catch (e) {
      print('Error deleting recipe: $e');
    }
  }

  Future<void> storeBugReport({
    required String email,
    required String name,
    required String reportDescription,
    required String date,
  }) async {
    try {
      final bugReport = Report(
        userEmail: email,
        userName: name,
        reportDescription: reportDescription,
        date: date,
      );

      await _reportCollection.insert(bugReport.toJson());
    } catch (e) {
      print('Error storing bug report: $e');
    }
  }
}
