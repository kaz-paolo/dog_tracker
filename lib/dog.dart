import 'dart:typed_data';
import 'dart:convert';

class Dog {
  final String name;
  final String breed;
  final String gender;
  final String imagePath;
  final Uint8List? imageBytes;
  final String birthDate;
  final String weight;
  final String age;
  final String health;

  Dog({
    required this.name,
    required this.breed,
    required this.gender,
    required this.imagePath,
    this.imageBytes,
    required this.birthDate,
    required this.weight,
    required this.age,
    required this.health,
  });

  // converts the Dog object into a map for json conversion
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'breed': breed,
      'gender': gender,
      'imagePath': imagePath,
      'imageBytes': imageBytes != null ? base64Encode(imageBytes!) : null,
      'birthDate': birthDate,
      'weight': weight,
      'age': age,
      'health': health,
    };
  }

  // create a Dog object from a JSON map
  factory Dog.fromJson(Map<String, dynamic> json) {
    return Dog(
      name: json['name'] ?? '',
      breed: json['breed'] ?? '',
      gender: json['gender'] ?? '',
      imagePath: json['imagePath'] ?? '',
      imageBytes:
          json['imageBytes'] != null ? base64Decode(json['imageBytes']) : null,
      birthDate: json['birthDate'] ?? '',
      weight: json['weight'] ?? '',
      age: json['age'] ?? '',
      health: json['health'] ?? '',
    );
  }
}
