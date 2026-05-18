import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/constants/app_strings.dart';
import '../core/theme/app_theme.dart';
import '../features/map/cubit/map_cubit.dart';
import 'di.dart';
import 'router.dart';

class TareeqApp extends StatelessWidget {
  const TareeqApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Set status bar styling to match premium lottie light theme
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ));

    return BlocProvider<MapCubit>(
      create: (context) => sl<MapCubit>()..initializeMap(),
      child: MaterialApp(
        title: AppStrings.appTitle,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: AppRouter.mapRoute,
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}
