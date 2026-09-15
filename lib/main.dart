 import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/email_verification_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/main_screen.dart';
import 'services/theme_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Load the saved theme before the app starts.
  await ThemeService.instance.loadTheme();

  runApp(const SmartExpenseTrackerApp());
}

class SmartExpenseTrackerApp extends StatelessWidget {
  const SmartExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(),
        ),

        ChangeNotifierProvider<ThemeService>.value(
          value: ThemeService.instance,
        ),
      ],
      child: const _SmartExpenseTrackerApp(),
    );
  }
}

class _SmartExpenseTrackerApp extends StatelessWidget {
  const _SmartExpenseTrackerApp();

  @override
  Widget build(BuildContext context) {
    final themeService = context.watch<ThemeService>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Expense Tracker',

      // ============================================================
      // LIGHT THEME
      // ============================================================
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: Colors.green,

        scaffoldBackgroundColor:
            const Color(0xFFF8FAF8),

        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),

        cardTheme: const CardThemeData(
          elevation: 0,
          margin: EdgeInsets.zero,
        ),

        inputDecorationTheme:
            const InputDecorationTheme(
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(14),
            ),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(14),
            ),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(14),
            ),
            borderSide: BorderSide(
              width: 1.5,
            ),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),

        elevatedButtonTheme:
            ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(
              double.infinity,
              52,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),

        filledButtonTheme:
            FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size(
              double.infinity,
              52,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),

        navigationBarTheme:
            NavigationBarThemeData(
          height: 72,
          elevation: 0,
          labelBehavior:
              NavigationDestinationLabelBehavior
                  .alwaysShow,
          indicatorShape:
              RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),

        floatingActionButtonTheme:
            FloatingActionButtonThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),

        snackBarTheme:
            SnackBarThemeData(
          behavior:
              SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),

        dialogTheme: DialogThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),

      // ============================================================
      // DARK THEME
      // ============================================================
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.green,

        scaffoldBackgroundColor:
            const Color(0xFF101410),

        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),

        cardTheme: const CardThemeData(
          elevation: 0,
          margin: EdgeInsets.zero,
        ),

        inputDecorationTheme:
            const InputDecorationTheme(
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(14),
            ),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(14),
            ),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(14),
            ),
            borderSide: BorderSide(
              width: 1.5,
            ),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),

        elevatedButtonTheme:
            ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(
              double.infinity,
              52,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),

        filledButtonTheme:
            FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size(
              double.infinity,
              52,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),

        navigationBarTheme:
            NavigationBarThemeData(
          height: 72,
          elevation: 0,
          labelBehavior:
              NavigationDestinationLabelBehavior
                  .alwaysShow,
          indicatorShape:
              RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),

        floatingActionButtonTheme:
            FloatingActionButtonThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),

        snackBarTheme:
            SnackBarThemeData(
          behavior:
              SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),

        dialogTheme: DialogThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),

      // ============================================================
      // CURRENT THEME
      // ============================================================
      themeMode: themeService.themeMode,

      // ============================================================
      // AUTH GATE
      // ============================================================
      home: const AuthGate(),

      routes: {
        '/login': (context) =>
            const LoginScreen(),

        '/register': (context) =>
            const RegisterScreen(),

        '/verify-email': (context) =>
            const EmailVerificationScreen(),

        '/main': (context) =>
            const MainScreen(),
      },
    );
  }
}

// ================================================================
// AUTH GATE
// ================================================================

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider =
        context.watch<AuthProvider>();

    // Firebase is checking authentication state.
    if (authProvider.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // No logged-in user.
    if (!authProvider.isAuthenticated) {
      return const LoginScreen();
    }

    final user = authProvider.user;

    // Logged in but email is not verified.
    if (user != null && !user.emailVerified) {
      return const EmailVerificationScreen();
    }

    // Logged in and verified.
    return const MainScreen();
  }
} 