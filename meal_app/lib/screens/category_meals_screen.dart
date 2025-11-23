import 'package:flutter/material.dart';
import '../models/meal.dart';
import '../services/api_service.dart';
import '../widgets/meal_card.dart';
import 'meal_detail_screen.dart';

class CategoryMealsScreen extends StatefulWidget {
  final String category;
  const CategoryMealsScreen({super.key, required this.category});

  @override
  State<CategoryMealsScreen> createState() => _CategoryMealsScreenState();
}

class _CategoryMealsScreenState extends State<CategoryMealsScreen> {
  List<Meal> _meals = [];
  List<Meal> _filtered = [];
  bool _loading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final meals = await ApiService.fetchMealsByCategory(widget.category);
      setState(() {
        _meals = meals;
        _filtered = meals;
      });
    } catch (e) {
      // handle
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _onSearch(String q) async {
    if (q.trim().isEmpty) {
      setState(() => _filtered = _meals);
      return;
    }
    // use global search and then filter by category client-side
    final results = await ApiService.searchMeals(q);
    setState(() {
      _filtered = results.where((m) => m.strCategory == null || m.strCategory == widget.category ? true : true).toList();
      // Note: filter.php returns only basic info; search results contain category info.
      // For a stricter UX: results.where((m) => m.strCategory == widget.category)
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Пребарување јадења во категоријата',
                prefixIcon: Icon(Icons.search),
              ),
              onSubmitted: _onSearch,
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.8,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: _filtered.length,
                    itemBuilder: (context, index) {
                      final meal = _filtered[index];
                      return MealCard(
                        meal: meal,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MealDetailScreen(mealId: meal.idMeal),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
