import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'models/plant_model.dart';
import 'screens/about_app_screen.dart';
import 'screens/account_info_screen.dart';
import 'screens/add_plant_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/plant_detail_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/success_action_screen.dart';
import 'stores/user_session.dart';

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
        if (_isOAuthCallbackRoute(settings.name)) {
          return _fadeRoute(
            OAuthCallbackScreen(callbackUri: _callbackUri(settings.name!)),
            settings,
          );
        }
        return _notFound(settings);
    }
  }

  static Uri _callbackUri(String routeName) {
    final parsed = Uri.tryParse(routeName);
    final redirect = Uri.parse(UserSession.redirectUri);
    if (parsed == null) return redirect;

    if (parsed.scheme.isNotEmpty && parsed.host.isNotEmpty) {
      return parsed;
    }

    return Uri(
      scheme: redirect.scheme,
      host: redirect.host,
      queryParameters: parsed.queryParameters.isEmpty
          ? null
          : parsed.queryParameters,
      fragment: parsed.fragment.isEmpty ? null : parsed.fragment,
    );
  }

  static bool _isOAuthCallbackRoute(String? routeName) {
    if (routeName == null || routeName.isEmpty) return false;

    final uri = Uri.tryParse(routeName);
    return uri?.queryParameters.containsKey('code') == true ||
        uri?.queryParameters.containsKey('error') == true ||
        routeName.contains('login-callback') ||
        routeName.startsWith('io.supabase.plinplant');
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

class OAuthCallbackScreen extends StatefulWidget {
  final Uri callbackUri;

  const OAuthCallbackScreen({required this.callbackUri, super.key});

  @override
  State<OAuthCallbackScreen> createState() => _OAuthCallbackScreenState();
}

class _OAuthCallbackScreenState extends State<OAuthCallbackScreen> {
  bool _navigated = false;
  bool _showRetry = false;
  String? _callbackError;
  Timer? _retryTimer;

  @override
  void initState() {
    super.initState();
    UserSession().addListener(_onAuthChanged);
    debugPrint(
      '[AUTH DEBUG] OAuth callback route diterima; '
      'code tersedia: ${widget.callbackUri.queryParameters.containsKey('code')}',
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_exchangeCallback());
      _retryTimer = Timer(const Duration(seconds: 15), () {
        if (!mounted || _navigated) return;
        setState(() => _showRetry = true);
        debugPrint('[AUTH DEBUG] OAuth callback belum menghasilkan session');
      });
    });
  }

  Future<void> _exchangeCallback() async {
    try {
      AuthException? lastRetryableError;
      for (var attempt = 1; attempt <= 3; attempt++) {
        try {
          await Supabase.instance.client.auth.getSessionFromUrl(
            widget.callbackUri,
          );
          lastRetryableError = null;
          break;
        } on AuthRetryableFetchException catch (error) {
          lastRetryableError = error;
          debugPrint(
            '[AUTH DEBUG] Pertukaran callback gagal sementara '
            '(percobaan $attempt/3)',
          );
          if (attempt < 3) {
            await Future<void>.delayed(const Duration(seconds: 2));
          }
        }
      }
      if (lastRetryableError != null) {
        throw lastRetryableError;
      }
      await UserSession().restoreCurrentSession();
    } catch (error) {
      debugPrint(
        '[AUTH DEBUG] Pertukaran OAuth callback gagal: '
        '${error.runtimeType}',
      );
      if (mounted) {
        setState(() {
          _showRetry = true;
          _callbackError = error is AuthRetryableFetchException
              ? 'Perangkat tidak dapat terhubung ke Supabase.'
              : 'Supabase menolak callback OAuth.';
        });
      }
    }
    _navigateIfAuthenticated();
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    UserSession().removeListener(_onAuthChanged);
    super.dispose();
  }

  void _onAuthChanged() {
    _navigateIfAuthenticated();
  }

  void _navigateIfAuthenticated() {
    if (!mounted || _navigated || UserSession().currentUser == null) return;

    _navigated = true;
    debugPrint('[AUTH DEBUG] Navigasi ke Home dari OAuth callback');
    Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.home, (_) => false);
  }

  void _returnToLogin() {
    if (!mounted || _navigated) return;

    _navigated = true;
    Navigator.of(context)
        .pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _showRetry
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Login Google belum selesai. Periksa koneksi dan '
                      'konfigurasi OAuth, lalu coba lagi.',
                      textAlign: TextAlign.center,
                    ),
                    if (_callbackError != null) ...[
                      const SizedBox(height: 8),
                      Text(_callbackError!, textAlign: TextAlign.center),
                    ],
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: _returnToLogin,
                      child: const Text('Kembali ke Login'),
                    ),
                  ],
                )
              : const CircularProgressIndicator(),
        ),
      ),
    );
  }
}
