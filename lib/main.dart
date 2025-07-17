import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './providers/auth_provider.dart';
import './screens/auth_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AuthProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => DiaryProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TagMind',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        // Define custom color palette based on design document
        colorScheme: const ColorScheme(
          primary: Color(0xFF4C6EF5), // Calm Blue
          secondary: Color(0xFFADB5BD), // Soft Gray
          surface: Color(0xFFF8F9FA), // Off-White
          background: Color(0xFFF8F9FA), // Off-White
          error: Color(0xFFDC3545), // Red for errors
          onPrimary: Colors.white,
          onSecondary: Colors.black,
          onSurface: Color(0xFF212529), // Deep Charcoal
          onBackground: Color(0xFF212529), // Deep Charcoal
          onError: Colors.white,
          brightness: Brightness.light,
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: Color(0xFF212529)), // Screen Title
          headlineMedium: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600, color: Color(0xFF212529)), // Section Title
          bodyLarge: TextStyle(fontSize: 16.0, color: Color(0xFF212529)), // Body Text
          bodyMedium: TextStyle(fontSize: 14.0, color: Color(0xFFADB5BD)), // Caption/Auxiliary Text
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF8F9FA),
          foregroundColor: Color(0xFF212529),
          elevation: 0,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
        ),
      ),
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return auth.token != null ? DiaryListScreen() : const AuthScreen();
        },
      ),
    );
  }
}

