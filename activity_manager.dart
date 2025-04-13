import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'activities_screen.dart';

class ActivityManager {
  static const String _prefsKey = 'activities_data';
  
  static Future<void> saveTasks(List<ActivityTask> tasks) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> jsonTasks = tasks.map((task) => task.toJson()).toList();
      final jsonString = jsonEncode(jsonTasks);
      
      await prefs.setString(_prefsKey, jsonString);
      debugPrint('Tasks saved to SharedPreferences');
    } catch (e) {
      debugPrint('Error saving tasks: $e');
      throw Exception('Failed to save tasks: $e');
    }
  }
  
  static Future<List<ActivityTask>> loadTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_prefsKey);
      
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }
      
      final List<dynamic> jsonTasks = jsonDecode(jsonString);
      
      return jsonTasks
          .map((json) => ActivityTask.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Error loading tasks: $e');
      throw Exception('Failed to load tasks: $e');
    }
  }
}