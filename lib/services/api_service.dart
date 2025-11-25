import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category.dart';
import '../models/meal.dart';

class ApiService {
  static const base = 'https://www.themealdb.com/api/json/v1/1';

  static Future<List<Category>> fetchCategories() async {
    final res = await http.get(Uri.parse('$base/categories.php'));
    if (res.statusCode == 200) {
      final j = json.decode(res.body);
      final List cats = j['categories'] ?? [];
      return cats.map((e) => Category.fromJson(e)).toList();
    }
    throw Exception('Failed to load categories');
  }

  static Future<List<Meal>> fetchMealsByCategory(String category) async {
    final res = await http.get(Uri.parse('$base/filter.php?c=$category'));
    if (res.statusCode == 200) {
      final j = json.decode(res.body);
      final List meals = j['meals'] ?? [];
      return meals
          .map((m) => Meal(
                idMeal: m['idMeal'] ?? '',
                strMeal: m['strMeal'] ?? '',
                ingredients: [],
                strMealThumb: m['strMealThumb'],
              ))
          .toList();
    }
    throw Exception('Failed to load meals for category');
  }

  static Future<List<Meal>> searchMeals(String query) async {
    final res = await http.get(Uri.parse('$base/search.php?s=$query'));
    if (res.statusCode == 200) {
      final j = json.decode(res.body);
      final List? meals = j['meals'];
      if (meals == null) return [];
      return meals.map((m) => Meal.fromJson(m)).toList();
    }
    throw Exception('Failed to search meals');
  }

  static Future<Meal> lookupMeal(String id) async {
    final res = await http.get(Uri.parse('$base/lookup.php?i=$id'));
    if (res.statusCode == 200) {
      final j = json.decode(res.body);
      final List meals = j['meals'] ?? [];
      if (meals.isEmpty) throw Exception('Meal not found');
      return Meal.fromJson(meals.first);
    }
    throw Exception('Failed to lookup meal');
  }

  static Future<Meal> randomMeal() async {
    final res = await http.get(Uri.parse('$base/random.php'));
    if (res.statusCode == 200) {
      final j = json.decode(res.body);
      final List meals = j['meals'] ?? [];
      if (meals.isEmpty) throw Exception('No random meal');
      return Meal.fromJson(meals.first);
    }
    throw Exception('Failed to fetch random meal');
  }
}
