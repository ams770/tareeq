import 'package:flutter/material.dart';
import '../core/constants/app_strings.dart';
import '../features/map/view/map_screen.dart';

class AppRouter {
  static const String mapRoute = AppStrings.defaultRoute;

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case mapRoute:
        return MaterialPageRoute(builder: (_) => const MapScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('${AppStrings.defaultRoute}${settings.name}'),
            ),
          ),
        );
    }
  }
}
