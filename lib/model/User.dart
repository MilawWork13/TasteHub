import 'package:mongo_dart/mongo_dart.dart';

class UserModel {
  ObjectId id;
  String name;
  String email;
  String preferredLanguage;
  String role;
  List<ObjectId> favouriteReceipts;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.preferredLanguage,
    required this.role,
    required this.favouriteReceipts,
  });

  Map<String, dynamic> toJson() => {
        '_id': id,
        'name': name,
        'email': email,
        'preferred_language': preferredLanguage,
        'role': role,
        'favourite_receipts': favouriteReceipts,
      };

  static UserModel fromJson(Map<String, dynamic> json) => UserModel(
        id: json['_id'],
        name: json['name'],
        email: json['email'],
        preferredLanguage: json['preferred_language'],
        role: json['role'],
        favouriteReceipts: List<ObjectId>.from(json['favourite_receipts']),
      );
}
