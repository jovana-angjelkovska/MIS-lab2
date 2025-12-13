import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/favorites_provider.dart';
import '../widgets/meal_card.dart';
import '../models/meal.dart';
import 'meal_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  static const routeName = '/favorites';

  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    
    final List<Meal> allMeals = ModalRoute.of(context)!.settings.arguments as List<Meal>;
    
    final List<Meal> favoriteMeals = allMeals
        .where((meal) => favoritesProvider.items.contains(meal.idMeal))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite recipes:'),
      ),
      body: favoritesProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : favoriteMeals.isEmpty  
              ? const Center(child: Text('You have no favourite recipes'))
              : GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: favoriteMeals.length,  
                  itemBuilder: (ctx, i) {
                    final meal = favoriteMeals[i];  
                    return MealCard(
                      meal: meal,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                MealDetailScreen(mealId: meal.idMeal),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}
