import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:timezone/data/latest.dart' as tz;         
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'services/notification_service.dart';             

import 'screens/home_screen.dart';
import 'screens/favorites_screen.dart';
import 'services/favorites_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  tz.initializeTimeZones();   

  await FirebaseAuth.instance.signInAnonymously();              

  final notificationService = NotificationService();
  await notificationService.init();

  runApp(const MealApp());
}

class MealApp extends StatelessWidget {
  const MealApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
      ],
      child: MaterialApp(
        title: 'Meal App / Апликација за рецепти',
        theme: ThemeData(primarySwatch: Colors.deepOrange),
        home: const HomeScreen(),
        routes: {
          FavoritesScreen.routeName: (ctx) => const FavoritesScreen(),
        },
      ),
    );
  }
}
