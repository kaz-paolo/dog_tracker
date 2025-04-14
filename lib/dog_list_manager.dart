import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dog.dart';

class DogListManager {
  static const String _prefsKey = 'dogs_data';

  static Future<void> saveDogList(List<Dog> dogs) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> jsonDogs =
          dogs.map((dog) => dog.toJson()).toList();
      final jsonString = jsonEncode(jsonDogs);

      await prefs.setString(_prefsKey, jsonString);
      debugPrint('Dogs saved to SharedPreferences');
    } catch (e) {
      debugPrint('Error saving dogs: $e');
      throw Exception('Failed to save dogs');
    }
  }

  static Future<List<Dog>> loadDogList() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_prefsKey);

      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final List<dynamic> jsonDogs = jsonDecode(jsonString);

      return jsonDogs.map((json) => Dog.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error loading dogs: $e');
      throw Exception('Failed to load dogs');
    }
  }

  static Future<void> updateDog(Dog oldDog, Dog newDog) async {
    final dogs = await loadDogList();
    final index = dogs.indexWhere((d) => d == oldDog);
    if (index != -1) {
      dogs[index] = newDog;
      await saveDogList(dogs);
    }
  }

  static Future<void> deleteDog(Dog dog) async {
    final dogs = await loadDogList();
    dogs.removeWhere((d) => d == dog);
    await saveDogList(dogs);
  }
}
