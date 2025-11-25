import 'package:flutter/material.dart';
import '../models/meal.dart';
import '../services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';


class MealDetailScreen extends StatefulWidget {
  final String mealId;
  const MealDetailScreen({super.key, required this.mealId});

  @override
  State<MealDetailScreen> createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends State<MealDetailScreen> {
  Meal? _meal;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final meal = await ApiService.lookupMeal(widget.mealId);
      setState(() => _meal = meal);
    } catch (e) {
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _openYoutube(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _meal == null
              ? const Center(child: Text('The recipe is not valid'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_meal!.strMealThumb != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(_meal!.strMealThumb!),
                        ),
                      const SizedBox(height: 12),
                      Text(_meal!.strMeal, style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 8),
                      if (_meal!.strArea != null) Text('Cuisine / Кујна: ${_meal!.strArea}'),
                      if (_meal!.strCategory != null) Text('Category / Категорија: ${_meal!.strCategory}'),
                      const SizedBox(height: 12),
                      Text('Ingredients / Состојки:', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      ..._meal!.ingredients.map((m) => Text('- ${m['ingredient']}: ${m['measure']}')),
                      const SizedBox(height: 12),
                      Text('Instructions / Инструкции:', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text(_meal!.strInstructions ?? ''),
                      const SizedBox(height: 12),
                      if (_meal!.strYoutube != null && _meal!.strYoutube!.isNotEmpty)
                        ElevatedButton.icon(
                          onPressed: () => _openYoutube(_meal!.strYoutube!),
                          icon: const Icon(Icons.video_library),
                          label: const Text('Watch on YouTube / Гледај го видеото на YouTube'),
                        ),
                    ],
                  ),
                ),
    );
  }
}
