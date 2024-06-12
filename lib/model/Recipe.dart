import 'package:mongo_dart/mongo_dart.dart';

// Ingredient class
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

// Instruction class
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

// Recipe class
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
  late final String image;

  // Constructor
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
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Recipe && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  // Convert from JSON
  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['_id'] is ObjectId
          ? json['_id']
          : ObjectId.fromHexString(json['_id']),
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
      price: json['price'].toDouble(),
      creator: json['creator'],
      creationDate: json['creation_date'],
      image: json['image'],
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'ingredients': ingredients
          .map((i) => {'name': i.name, 'quantity': i.quantity})
          .toList(),
      'instructions':
          instructions.map((i) => {'step': i.step, 'order': i.order}).toList(),
      'culture': cultureId,
      'preparation_time': preparationTime,
      'allergens': allergens,
      'price': price,
      'creator': creator,
      'creation_date': creationDate,
      'image': image,
    };
  }
}
