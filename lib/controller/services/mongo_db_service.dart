import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
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
  late final DbCollection _usersCollection;
  late final DbCollection _recipesCollection;
  late final DbCollection _culturesCollection;
  late final DbCollection _reportCollection;

  MongoDBService._create(this._db);

  // Create the MongoDB service
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

  // -------------------
  // User Operations
  // -------------------

  // Create the user with the given JSON data
  Future<void> createUser(UserModel user) async {
    await _usersCollection.insert(user.toJson());
  }

  // Get the user by the given email
  Future<UserModel?> getUserByEmail(String email) async {
    var user = await _usersCollection.findOne(where.eq('email', email));
    return user != null ? _userFromJson(user) : null;
  }

  // Get all users
  Future<List<UserModel>> getAllUsers() async {
    try {
      final users = await _usersCollection.find().toList();
      return users.isNotEmpty ? users.map(_userFromJson).toList() : [];
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching users: $e');
      }
      return [];
    }
  }

  // Update the user with the given JSON data
  UserModel _userFromJson(Map<String, dynamic> json) {
    List<ObjectId> favouriteReceipts =
        (json['favourite_receipts'] as List<dynamic>).map<ObjectId>((id) {
      if (id is String) {
        id = id.replaceAll('ObjectId("', '').replaceAll('")', '');
        return ObjectId.parse(id);
      } else if (id is ObjectId) {
        return id;
      }
      throw ArgumentError('Invalid ObjectId format: $id');
    }).toList();

    return UserModel(
      id: (json['_id']),
      name: json['name'],
      email: json['email'],
      preferredLanguage: json['preferred_language'],
      role: json['role'],
      favouriteReceipts: favouriteReceipts,
    );
  }

  // -------------------
  // Recipe Operations
  // -------------------

  // Get all recipes
  Future<List<Recipe>> getAllRecipes() async {
    try {
      final recipes = await _recipesCollection.find().toList();
      return recipes.isNotEmpty ? recipes.map(Recipe.fromJson).toList() : [];
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching recipes: $e');
      }
      return [];
    }
  }

  // Get the recipe by ID
  Future<Recipe?> getRecipeById(String recipeId) async {
    try {
      final recipe =
          await _recipesCollection.findOne(where.id(ObjectId.parse(recipeId)));
      return recipe != null ? Recipe.fromJson(recipe) : null;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching recipe by ID: $e');
      }
      return null;
    }
  }

  // Get the recipes by the culture ID
  Future<List<Recipe>> getRecipesByCultureId(String cultureId) async {
    try {
      final recipes = await _recipesCollection
          .find(where.eq('culture', cultureId))
          .toList();
      return recipes.isNotEmpty ? recipes.map(Recipe.fromJson).toList() : [];
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching recipes by culture ID: $e');
      }
      return [];
    }
  }

  // Get the recipes created by the user with the given email
  Future<List<Recipe>> getRecipesCreatedByUser(String email) async {
    try {
      final recipes =
          await _recipesCollection.find(where.eq('creator', email)).toList();
      return recipes.isNotEmpty ? recipes.map(Recipe.fromJson).toList() : [];
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching recipes created by user: $e');
      }
      return [];
    }
  }

  // Search for recipes by name or creator
  Future<List<Recipe>> searchRecipes(String searchText) async {
    try {
      final recipes = await _recipesCollection
          .find(where
              .match('name', searchText)
              .or(where.match('creator', 'TasteHub')))
          .toList();
      return recipes.isNotEmpty ? recipes.map(Recipe.fromJson).toList() : [];
    } catch (e) {
      if (kDebugMode) {
        print('Error searching recipes: $e');
      }
      return [];
    }
  }

  // Add the recipe with the given ID to the user's favorite recipes
  Future<void> addRecipeToFavorites(String email, String recipeId) async {
    try {
      await _usersCollection.update(
        where.eq('email', email),
        modify.addToSet('favourite_receipts', recipeId),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error adding recipe to favorites: $e');
      }
    }
  }

  // Remove the recipe with the given ID from the user's favorite recipes
  Future<void> removeRecipeFromFavorites(String email, String recipeId) async {
    try {
      await _usersCollection.update(
        where.eq('email', email),
        modify.pull('favourite_receipts', recipeId),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error removing recipe from favorites: $e');
      }
    }
  }

  // Get the user's favorite recipe IDs
  Future<List<String>> getUserFavoriteRecipeByEmail(String email) async {
    try {
      var user = await _usersCollection.findOne(where.eq('email', email));
      if (user != null && user['favourite_receipts'] != null) {
        return List<String>.from(user['favourite_receipts']);
      } else {
        return [];
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user favorite recipe IDs: $e');
      }
      return [];
    }
  }

  // Add the recipe with the given JSON data
  Future<void> addRecipe(
      BuildContext context, Map<String, dynamic> recipeJson) async {
    try {
      await _recipesCollection.insert(recipeJson);
      // ignore: use_build_context_synchronously
      showSuccessToast(context, message: 'Recipe created successfully!');
    } catch (e) {
      // ignore: use_build_context_synchronously
      showErrorToast(context, message: 'Failed to create recipe.');
    }
  }

  // Update the recipe with the given JSON data
  Future<void> updateRecipe(
      BuildContext context, Map<String, dynamic> recipeJson) async {
    try {
      await _recipesCollection.updateOne(
        where.id(recipeJson['_id']),
        modify
            .set('name', recipeJson['name'])
            .set('ingredients', recipeJson['ingredients'])
            .set('instructions', recipeJson['instructions'])
            .set('culture', recipeJson['culture'])
            .set('preparation_time', recipeJson['preparation_time'])
            .set('allergens', recipeJson['allergens'])
            .set('price', recipeJson['price'])
            .set('creator', recipeJson['creator'])
            .set('creation_date', recipeJson['creation_date'])
            .set('image', recipeJson['image']),
      );
      // ignore: use_build_context_synchronously
      showSuccessToast(context, message: 'Recipe updated successfully!');
    } catch (e) {
      if (kDebugMode) {
        print('Error updating recipe: $e');
      }
      // ignore: use_build_context_synchronously
      showErrorToast(context, message: 'Failed to update recipe.');
    }
  }

  // Delete the recipe with the given ID
  Future<void> deleteRecipe(BuildContext context, String email, String recipeId,
      String imageName) async {
    try {
      if (imageName != 'default_image') {
        final storageRef =
            FirebaseStorage.instance.ref('recipe_images/$imageName');
        await storageRef.delete();
      }
      await _recipesCollection.remove(
        where.eq('creator', email).eq('_id', ObjectId.parse(recipeId)),
      );
      // ignore: use_build_context_synchronously
      showSuccessToast(context, message: 'Recipe deleted successfully!');
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting recipe: $e');
      }
      // ignore: use_build_context_synchronously
      showErrorToast(context, message: 'Failed to delete recipe.');
    }
  }

  // -------------------
  // Culture Operations
  // -------------------

  // Get all cultures
  Future<List<Culture>> getAllCultures() async {
    try {
      final cultures = await _culturesCollection.find().toList();
      return cultures.isNotEmpty ? cultures.map(Culture.fromJson).toList() : [];
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching cultures: $e');
      }
      return [];
    }
  }

  // Get the culture by ID
  Future<Map<String, dynamic>?> getCultureById(String cultureId) async {
    try {
      return await _culturesCollection
          .findOne(where.id(ObjectId.parse(cultureId)));
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching culture: $e');
      }
      return null;
    }
  }

  // Get the culture ID by name
  Future<String?> getCultureIdByName(String cultureName) async {
    try {
      var culture =
          await _culturesCollection.findOne(where.eq('name', cultureName));
      return culture != null ? (culture['_id'] as ObjectId?)?.oid : null;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching culture ID by name: $e');
      }
      return null;
    }
  }

  // -------------------
  // Report Operations
  // -------------------

  // Store the bug report in the database
  Future<void> storeBugReport({
    required ObjectId id,
    required int reportNum,
    required String email,
    required String name,
    required String reportDescription,
    required String date,
    required String status,
  }) async {
    try {
      final bugReport = Report(
        id: id,
        reportNum: reportNum,
        userEmail: email,
        userName: name,
        reportDescription: reportDescription,
        date: date,
        status: status,
      );
      await _reportCollection.insert(bugReport.toJson());
    } catch (e) {
      if (kDebugMode) {
        print('Error storing bug report: $e');
      }
    }
  }

  // Get all reports
  Future<List<Report>> getAllReports() async {
    try {
      final reports = await _reportCollection.find().toList();
      return reports.isNotEmpty ? reports.map(Report.fromJson).toList() : [];
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching reports: $e');
      }
      return [];
    }
  }

  // Solve the report with the given ID
  Future<void> solveReport(ObjectId reportId) async {
    try {
      await _reportCollection.update(
        where.id(reportId),
        modify.set('status', 'solved'),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error solving report: $e');
      }
    }
  }

  // Reopen the report with the given ID
  Future<void> reopenReport(ObjectId reportId) async {
    try {
      await _reportCollection.update(
        where.id(reportId),
        modify.set('status', 'reopened'),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error reopening report: $e');
      }
    }
  }

  // Delete the report with the given ID
  Future<void> deleteReport(ObjectId reportId) async {
    try {
      await _reportCollection.remove(where.id(reportId));
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting report: $e');
      }
    }
  }
}
