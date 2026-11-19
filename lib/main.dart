import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/supabase_config.dart';
import 'routes.dart';
import 'stores/user_session.dart';
import 'theme/app_colors.dart';
import 'theme/app_spacing.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Inisialisasi Supabase (wajib sebelum runApp) ──
  await Supabase.initialize(
    url: SupabaseConfig.url,
    publishableKey: SupabaseConfig.anonKey,
  );

  // ── Sinkronisasi sesi auth state ──
  await UserSession().syncFromSupabase();

  runApp(const PlinPlantApp());
}

class PlinPlantApp extends StatelessWidget {
  const PlinPlantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PlinPlant',
      theme: _buildTheme(),
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }

  ThemeData _buildTheme() {
    final base = GoogleFonts.poppinsTextTheme();

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
      textTheme: base,
      scaffoldBackgroundColor: AppColors.background,

      // AppBar: transparan, teks gelap, tanpa shadow
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),

      // ElevatedButton: hijau, tanpa elevation, radius seragam
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(AppSizes.control),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.input),
          ),
          elevation: 0,
          textStyle: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // InputDecoration: border abu, radius seragam, fokus hijau
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(AppSpacing.card),
        hintStyle: GoogleFonts.poppins(color: AppColors.textHint, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}
