import 'package:mongo_dart/mongo_dart.dart';

class Ingredient {
  final String name;
  final String quantity;

  Ingredient({required this.name, required this.quantity});

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      name: json['name'],
      quantity: json['quantity'],
    );
  }
}

class Instruction {
  final String step;
  final int order;

  Instruction({required this.step, required this.order});

  factory Instruction.fromJson(Map<String, dynamic> json) {
    return Instruction(
      step: json['step'],
      order: json['order'],
    );
  }
}

class Recipe {
  final ObjectId id;
  final String name;
  final List<Ingredient> ingredients;
  final List<Instruction> instructions;
  final String cultureId;
  final int preparationTime;
  final List<String> allergens;
  final double price;
  final String creator;
  final String creationDate;
  final String image;
  final List<String> audios;

  Recipe({
    required this.id,
    required this.name,
    required this.ingredients,
    required this.instructions,
    required this.cultureId,
    required this.preparationTime,
    required this.allergens,
    required this.price,
    required this.creator,
    required this.creationDate,
    required this.image,
    required this.audios,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['_id'],
      name: json['name'],
      ingredients: (json['ingredients'] as List)
          .map((i) => Ingredient.fromJson(i))
          .toList(),
      instructions: (json['instructions'] as List)
          .map((i) => Instruction.fromJson(i))
          .toList(),
      cultureId: json['culture'],
      preparationTime: json['preparation_time'],
      allergens: List<String>.from(json['allergens']),
      price: json['price'],
      creator: json['creator'],
      creationDate: json['creation_date'],
      image: json['image'],
      audios: List<String>.from(json['audios']),
    );
  }
}
