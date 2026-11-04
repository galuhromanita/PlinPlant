import 'package:flutter/material.dart';

import 'models/plant_model.dart';
import 'screens/about_app_screen.dart';
import 'screens/account_info_screen.dart';
import 'screens/add_plant_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/plant_detail_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/success_action_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String plantDetail = '/plant-detail';
  static const String addPlant = '/add-plant';
  static const String editPlant = '/edit-plant';
  static const String aboutApp = '/about-app';
  static const String accountInfo = '/account-info';
  static const String successAction = '/success-action';
}

class SuccessActionArguments {
  final String plantName;
  final String action;
  final IconData icon;
  final String plantId;

  const SuccessActionArguments({
    required this.plantName,
    required this.action,
    required this.icon,
    required this.plantId,
  });
}

enum PlantDetailResult { edited, deleted }

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return _fadeRoute(const SplashScreen(), settings);
      case AppRoutes.login:
        return _fadeRoute(const LoginScreen(), settings);
      case AppRoutes.home:
        return _slideRoute(const HomeScreen(), settings);
      case AppRoutes.plantDetail:
        final plantId = settings.arguments;
        if (plantId is! String) return _notFound(settings);
        return _slideRoute(PlantDetailScreen(plantId: plantId), settings);
      case AppRoutes.addPlant:
        return _slideRoute(const AddPlantScreen(), settings);
      case AppRoutes.editPlant:
        final plant = settings.arguments;
        if (plant is! PlantModel) return _notFound(settings);
        return _slideRoute(AddPlantScreen(plantToEdit: plant), settings);
      case AppRoutes.aboutApp:
        return _slideRoute(const AboutAppScreen(), settings);
      case AppRoutes.accountInfo:
        return _slideRoute(const AccountInfoScreen(), settings);
      case AppRoutes.successAction:
        final arguments = settings.arguments;
        if (arguments is! SuccessActionArguments) {
          return _notFound(settings);
        }
        return _slideRoute(
          SuccessActionScreen(
            plantName: arguments.plantName,
            action: arguments.action,
            icon: arguments.icon,
            plantId: arguments.plantId,
          ),
          settings,
        );
      default:
        return _notFound(settings);
    }
  }

  static MaterialPageRoute<void> _notFound(RouteSettings settings) {
    return MaterialPageRoute(
      settings: settings,
      builder: (_) => Scaffold(
        body: Center(child: Text('Halaman tidak ditemukan: ${settings.name}')),
      ),
    );
  }

  static PageRouteBuilder<void> _fadeRoute(
    Widget page,
    RouteSettings settings,
  ) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 600),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
          child: child,
        );
      },
    );
  }

  static PageRouteBuilder<void> _slideRoute(
    Widget page,
    RouteSettings settings,
  ) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 350),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final tween = Tween(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }
}
