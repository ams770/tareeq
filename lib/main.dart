import 'package:flutter/material.dart';
import 'app/app.dart';
import 'app/di.dart';

void main() async {
  // Ensure Flutter engine bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependency injection container
  await initDI();
  

  // Run the application
  runApp(const TareeqApp());
}
