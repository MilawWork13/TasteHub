import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:taste_hub/model/Recipe.dart';
import 'package:taste_hub/model/User.dart';
import 'package:taste_hub/model/Culture.dart';

class MongoDBService {
  final Db _db;
  late DbCollection _usersCollection;
  late DbCollection _recipesCollection;
  late DbCollection _culturesCollection;

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
      return UserModel.fromJson(user);
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
}
