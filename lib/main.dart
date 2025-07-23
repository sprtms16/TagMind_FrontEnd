import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './providers/auth_provider.dart';
import './providers/diary_provider.dart';
import './providers/tag_provider.dart';
import './providers/iap_provider.dart';
import './screens/auth_screen.dart';
import './screens/home_screen.dart';
import './screens/diary_edit_screen.dart';
import './screens/tag_store_screen.dart';

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
        ChangeNotifierProvider(
          create: (context) => TagProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => IapProvider(),
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
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        colorScheme: const ColorScheme(
          primary: Color(0xFF2196F3), // A vibrant blue
          secondary: Color(0xFF42A5F5), // A lighter blue
          surface: Color(0xFFFFFFFF), // White
          background: Color(0xFFF5F5F5), // Light gray
          error: Color(0xFFB00020), // Red for errors
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Colors.black,
          onBackground: Colors.black,
          onError: Colors.white,
          brightness: Brightness.light,
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.black), // Screen Title
          headlineMedium: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600, color: Colors.black), // Section Title
          bodyLarge: TextStyle(fontSize: 16.0, color: Colors.black), // Body Text
          bodyMedium: TextStyle(fontSize: 14.0, color: Colors.grey), // Caption/Auxiliary Text
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2196F3), // Use primary color for AppBar
          foregroundColor: Colors.white, // White text/icons on AppBar
          elevation: 4, // Add a subtle shadow
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return auth.token != null ? HomeScreen() : AuthScreen();
        },
      ),
      routes: {
        DiaryEditScreen.routeName: (ctx) => DiaryEditScreen(),
        TagStoreScreen.routeName: (ctx) => TagStoreScreen(),
      },
    );
  }
}