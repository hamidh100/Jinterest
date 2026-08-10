import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/photo_provider.dart';
import 'providers/album_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/snackbar_fab_provider.dart';
import 'theme/app_palette.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/upload_screen.dart';
import 'screens/photo_details_screen.dart';
import 'screens/album_details_screen.dart';
import 'screens/admin_screen.dart';
import '/screens/settings_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PhotoProvider()),
        ChangeNotifierProvider(create: (_) => AlbumProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => SnackbarFabProvider()),
      ],
      child: Consumer<ThemeProvider>(
        // Rebuilds MaterialApp when the user toggles the app theme.
        builder: (context, themeProvider, _) => MaterialApp(
          title: 'Jinterest',
          themeMode: themeProvider.themeMode,
          // Light colors used when dark mode is off.
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
          ),
          // Dark colors used when dark mode is on.
          darkTheme: ThemeData(
            colorScheme: const ColorScheme.dark(
              primary: AppPalette.accent,
              onPrimary: Colors.white,
              primaryContainer: AppPalette.surfaceHighlight,
              onPrimaryContainer: Colors.white,
              secondary: AppPalette.surfaceHighlight,
              surface: AppPalette.surface,
              onSurface: Colors.white,
            ),
            scaffoldBackgroundColor: AppPalette.background,
            appBarTheme: const AppBarTheme(
              backgroundColor: AppPalette.background,
            ),
            useMaterial3: true,
          ),
          debugShowCheckedModeBanner: false,
          home: const SplashScreen(),
          routes: {
            '/login': (_) => const LoginScreen(),
            '/signup': (_) => const SignupScreen(),
            '/home': (_) => const HomeScreen(),
            '/upload': (_) => const UploadScreen(),
            '/user-profile': (context) {
              final userId =
                  ModalRoute.of(context)!.settings.arguments as String;
              return ProfileScreen(userId: userId);
            },
            '/photo-details': (context) {
              final photoId =
                  ModalRoute.of(context)!.settings.arguments as String;
              return PhotoDetailsScreen(photoId: photoId);
            },
            '/album-details': (context) {
              final albumId =
                  ModalRoute.of(context)!.settings.arguments as String;
              return AlbumDetailsScreen(albumId: albumId);
            },
            '/admin': (_) => const AdminScreen(),
            '/settings': (_) => const SettingsScreen(),
          },
        ),
      ),
    );
  }
}
