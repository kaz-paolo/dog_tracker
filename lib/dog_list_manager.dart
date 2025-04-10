import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dog.dart';

class DogListManager {
  static const String _dogListKey = 'dog_list';

  static Future<void> saveDogList(List<Dog> dogs) async {
    final prefs = await SharedPreferences.getInstance();
    final dogListJson = jsonEncode(dogs.map((dog) => dog.toJson()).toList());
    await prefs.setString(_dogListKey, dogListJson);
  }

  static Future<List<Dog>> loadDogList() async {
    final prefs = await SharedPreferences.getInstance();
    final dogListJson = prefs.getString(_dogListKey);
    if (dogListJson == null) {
      return [];
    }
    final List<dynamic> decodedList = jsonDecode(dogListJson);
    return decodedList.map((json) => Dog.fromJson(json)).toList();
  }
}