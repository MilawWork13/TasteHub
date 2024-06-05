import 'package:mongo_dart/mongo_dart.dart';

class Culture {
  final ObjectId id;
  final String name;
  final String image;
  final String description;

  Culture(
      {required this.id,
      required this.name,
      required this.image,
      required this.description});

  factory Culture.fromJson(Map<String, dynamic> json) {
    return Culture(
      id: json['_id'],
      name: json['name'],
      image: json['image'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'image': image,
      'description': description,
    };
  }
}
